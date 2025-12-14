# Clearcut Vim Plugin

This repository ships a small Vim plugin that forwards selected text to OpenAI and prints a shorter version directly beneath the selection. Use it to practice writing succinct prose.

## Installation
1. Copy/clone this repository into `~/.vim/pack/plugins/start/vim-clearcut` (or add it to any directory listed in `runtimepath`).
2. Ensure `python3` is available in your `$PATH`.
3. Export your API key: `export OPEN_AI_KEY="sk-your-key"`.
4. (Optional) Set overrides in your `vimrc`:
   ```vim
   let g:clearcut_target_ratio = 0.72
   let g:clearcut_model = 'gpt-4o-mini'
   let g:clearcut_endpoint = 'https://api.openai.com/v1/chat/completions'
   ```

## Usage
1. In Vim, visually select the lines you want to shrink (`v` or `V`).
2. Run `:Clearcut` (or use the provided mapping `<leader>cct`). The plugin sends the selection to OpenAI and appends the concise rewrite below the original text.
3. Review the output, edit as needed, and delete the original text once you are satisfied.

A typical workflow looks like this:
```vim
:'<,'>Clearcut
```
This command works in normal mode after a visual selection and keeps the context so you can compare the texts line by line.

## Troubleshooting
- `Clearcut rewrite script not found`: double-check that `scripts/clearcut_openai.py` is executable and lives next to the plugin.
- `OPEN_AI_KEY is not set`: export the key in your shell or inside Vim (`:let $OPEN_AI_KEY="..."`).
- API errors bubble up from the CLI script; inspect the echoed message for HTTP status codes.
