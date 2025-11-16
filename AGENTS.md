# Repository Guidelines

These notes keep plugin changes predictable so contributors and automation can work safely without regressing session handling.

## Project Structure & Module Organization
- `main.lua` is the sole entry point and exports `setup`; it subscribes to `cd` and `tab` events and writes current tab directories to the `YAZI_SESSION_FILE`.
- Treat the plugin directory itself (`session-save.yazi/`) as the package root; add helper modules under this folder (for example `session.lua`) and require them from `main.lua`.
- Keep session persistence logic pure and file‑system interactions isolated so they can be mocked or replaced easily.

## Build, Test, and Development Commands
- `yazi` – Launch Yazi from a terminal after starting it in the directory where the plugin is installed to validate live behavior.
- `YA_PLUGIN_RELOAD=1 yazi` – Forces Yazi to reload plugin code without restarting the editor; useful when iterating quickly.
- `rg --files` – Audit tracked files and ensure no ad‑hoc scripts are introduced outside this plugin root.

## Coding Style & Naming Conventions
- Lua files use two‑space indentation, `local` helpers, and snake_case for variables (`session_file`).
- Avoid globals; attach exports to the returned table from `main.lua`.
- Guard filesystem calls (`io.open`, `os.getenv`) and prefer explicit nil checks over relying on truthiness.
- Keep functions short and composable; extract shared logic into `local function`s near the top of each file.

## Testing Guidelines
- No automated test harness exists; validation happens by running `yazi`, opening multiple tabs, and confirming `YAZI_SESSION_FILE` contains each tab’s `cwd`.
- When adding functionality, craft reproducible manual scenarios (e.g., split panes, rapid tab closures) and document them in PR descriptions.
- Ensure the session file is cleaned between runs to avoid stale directories; a simple `> "$YAZI_SESSION_FILE"` before testing is acceptable.

## Commit & Pull Request Guidelines
- Use imperative, scope-tagged commit subjects (`feat: add per-tab metadata`); include a concise body explaining motivation and user impact.
- Reference related Yazi issues or discussions in the PR body and list manual test steps plus observed results.
- Provide before/after behavior summaries and attach screenshots or terminal captures if the change affects visible behavior (such as tab counts shown in logs).
