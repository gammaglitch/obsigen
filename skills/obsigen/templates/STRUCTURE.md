# STRUCTURE

## Plugin identity

- Display name: <Title Case plugin name>
- Plugin id: <kebab-case id>
- Platform classification: <cross-platform safe | desktop-only>

## Scaffold base

- Template source: `.obsigen/templates/obsikit/`
- Template snapshot: <copy the pinned version or upstream note if available>
- Notes: <anything preserved intentionally from the scaffold>

## Core shell

- `public/manifest.json`: <plugin manifest identity and release metadata>
- `package.json`: <package name and build scripts>
- `src/main.ts`: <plugin class, view registration, command registration>
- `src/obsidian/constants.ts`: <view type, display name, icon>
- `src/obsidian/view.ts`: <open/reveal helper>
- `src/ViewWrapper.tsx`: <top-level mounted view wrapper>

## Feature files

- View component: <path>
- Vault helper: <path>
- Command logic: <path>
- Tests or harness hooks: <path or "none yet">

## Verification surfaces

- Build command: `pnpm build`
- Reload path: <CLI reload tool, bridge fallback, or manual note>
- Runtime checks: <command, view, and vault behavior checks>
- DOM/CSS selectors: <stable selectors or planned selectors>

## Rename map

- Plugin class: `ObsikitPlugin` -> `<PascalCasePluginName>Plugin`
- Item view class: `ObsikitView` -> `<PascalCasePluginName>View`
- View component: `src/components/ExampleView.tsx` -> `src/components/PluginView.tsx`
- View type: `obsikit-example-view` -> `<plugin-id>-view`
