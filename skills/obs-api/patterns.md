# Obsidian Plugin Patterns

Common patterns and TypeScript idioms for Obsidian plugin development.

## Plugin lifecycle

```ts
export default class MyPlugin extends Plugin {
    async onload() {
        // Register things here — they auto-unregister on unload
        this.addCommand({ ... });
        this.registerView(VIEW_TYPE, (leaf) => new MyView(leaf));
        this.addSettingTab(new MySettingTab(this.app, this));

        // Wait for workspace to be ready before accessing leaves/views
        this.app.workspace.onLayoutReady(() => {
            this.activateView();
        });
    }
}
```

## Commands

```ts
this.addCommand({
    id: 'do-thing',          // no plugin prefix needed, Obsidian adds it
    name: 'Do the thing',    // no plugin prefix needed
    callback: () => { ... },
});

// With editor context
this.addCommand({
    id: 'insert-text',
    name: 'Insert text at cursor',
    editorCallback: (editor: Editor, view: MarkdownView) => {
        editor.replaceSelection('inserted');
    },
});

// Conditional availability
this.addCommand({
    id: 'conditional',
    name: 'Only when ready',
    checkCallback: (checking: boolean) => {
        const view = this.app.workspace.getActiveViewOfType(MarkdownView);
        if (view) {
            if (!checking) { /* do the thing */ }
            return true;
        }
        return false;
    },
});
```

## Custom views

```ts
const VIEW_TYPE = 'my-view';

class MyView extends ItemView {
    getViewType() { return VIEW_TYPE; }
    getDisplayText() { return 'My View'; }

    async onOpen() {
        const container = this.containerEl.children[1];
        container.empty();
        container.createEl('h4', { text: 'Hello' });
    }

    async onClose() {
        // cleanup
    }
}

// Register in plugin onload
this.registerView(VIEW_TYPE, (leaf) => new MyView(leaf));

// Activate the view
async activateView() {
    const { workspace } = this.app;
    let leaf = workspace.getLeavesOfType(VIEW_TYPE)[0];
    if (!leaf) {
        const rightLeaf = workspace.getRightLeaf(false);
        if (rightLeaf) {
            await rightLeaf.setViewState({ type: VIEW_TYPE, active: true });
            leaf = rightLeaf;
        }
    }
    if (leaf) workspace.revealLeaf(leaf);
}
```

## Settings

```ts
interface MySettings {
    setting1: string;
    setting2: boolean;
}

const DEFAULT_SETTINGS: MySettings = {
    setting1: 'default',
    setting2: false,
};

// In plugin class
settings: MySettings;

async loadSettings() {
    this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
}

async saveSettings() {
    await this.saveData(this.settings);
}

// Settings tab
class MySettingTab extends PluginSettingTab {
    plugin: MyPlugin;

    constructor(app: App, plugin: MyPlugin) {
        super(app, plugin);
        this.plugin = plugin;
    }

    display() {
        const { containerEl } = this;
        containerEl.empty();

        new Setting(containerEl)
            .setName('Setting 1')
            .setDesc('Description')
            .addText(text => text
                .setPlaceholder('placeholder')
                .setValue(this.plugin.settings.setting1)
                .onChange(async (value) => {
                    this.plugin.settings.setting1 = value;
                    await this.plugin.saveSettings();
                }));
    }
}
```

## Vault operations

```ts
// Prefer Vault.process() for atomic read-modify-write
await this.app.vault.process(file, (content) => {
    return content.replace('old', 'new');
});

// Frontmatter edits
await this.app.fileManager.processFrontMatter(file, (fm) => {
    fm.tags = fm.tags || [];
    fm.tags.push('new-tag');
});

// Read
const content = await this.app.vault.read(file);
const cached = await this.app.vault.cachedRead(file);

// Create
await this.app.vault.create('path/to/file.md', 'content');

// Delete (prefer trash)
await this.app.vault.trash(file, false); // false = system trash
```

## Event registration

```ts
// this.registerEvent auto-detaches on plugin unload
this.registerEvent(
    this.app.vault.on('create', (file) => { ... })
);
this.registerEvent(
    this.app.vault.on('modify', (file) => { ... })
);
this.registerEvent(
    this.app.workspace.on('file-open', (file) => { ... })
);

// Interval (auto-cleared on unload)
this.registerInterval(
    window.setInterval(() => { ... }, 5 * 60 * 1000)
);
```

## DOM helpers

```ts
// Obsidian extends HTMLElement with helpers
containerEl.createEl('div', { cls: 'my-class', text: 'hello' });
containerEl.createEl('a', { href: 'https://...', text: 'link' });
el.empty();       // clear children
el.addClass('x');
el.removeClass('x');
el.toggleClass('x', condition);
```

## Modals

```ts
class MyModal extends Modal {
    result: string;
    onSubmit: (result: string) => void;

    constructor(app: App, onSubmit: (result: string) => void) {
        super(app);
        this.onSubmit = onSubmit;
    }

    onOpen() {
        const { contentEl } = this;
        new Setting(contentEl)
            .setName('Enter value')
            .addText(text => text.onChange(value => this.result = value));
        new Setting(contentEl)
            .addButton(btn => btn
                .setButtonText('Submit')
                .setCta()
                .onClick(() => {
                    this.close();
                    this.onSubmit(this.result);
                }));
    }

    onClose() {
        this.contentEl.empty();
    }
}
```

## Notice

```ts
new Notice('Quick message');
new Notice('Stays longer', 10000); // ms
```

## Common gotchas

- Use `this.app` not global `app`
- Don't prefix command id/name with plugin name — Obsidian does it
- Keep `onload()` fast — defer heavy work to `onLayoutReady`
- `Vault.process()` over read+modify to avoid race conditions
- `FileManager.processFrontMatter()` for YAML — don't parse manually
- Prefer `trash()` over `delete()` for user-facing file removal
- Custom views may not exist yet when `onload` runs — check before casting
