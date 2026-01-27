# Clearcut Vim Plugin

This repository ships a small Vim plugin that forwards selected text to OpenAI and prints a shorter version directly beneath the selection. Use it to practice writing succinct prose.

## Requirements
- Vim 8.2+ or Neovim 0.5+
- `curl` command-line tool

## Installation
1. Copy/clone this repository into `~/.vim/pack/plugins/start/vim-clearcut` (or add it to any directory listed in `runtimepath`).
2. Export your API key: `export OPEN_AI_KEY="sk-your-key"`.
3. (Optional) Set overrides in your `vimrc`:
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
- `OPEN_AI_KEY is not set`: export the key in your shell or inside Vim (`:let $OPEN_AI_KEY="..."`).
- `curl not found`: ensure curl is installed (`brew install curl` on macOS, `apt-get install curl` on Ubuntu).
- API errors are displayed in Vim's error messages; check the error output for details.

## Development

### Running Tests
```bash
# Install vader.vim
git clone https://github.com/junegunn/vader.vim.git

# Run tests
vim -Nu <(cat << EOF
filetype off
set rtp+=vader.vim
set rtp+=.
filetype plugin indent on
EOF
) -c 'Vader test/*.vader'
```
