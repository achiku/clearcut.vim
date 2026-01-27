# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

clearcut.vim is a Vim plugin that uses OpenAI's API to shorten selected text. Users select text in Vim, run `:Clearcut`, and the plugin sends the text to OpenAI which returns a more concise version appended below the original selection.

## Architecture

### Plugin Structure (Standard Vim Plugin Layout)

- `plugin/clearcut.vim` - Plugin entry point. Defines the `:Clearcut` command and `<leader>cct` mapping. Loads once per Vim session.
- `autoload/clearcut.vim` - **Vim9 script** containing `clearcut#Rewrite()` function. Auto-loaded on first use (not at startup) following Vim's autoload convention. Handles all API communication via curl.
- `test/clearcut.vader` - vader.vim test suite for automated testing.

### Data Flow

1. User selects text in Vim (visual mode) and runs `:Clearcut`
2. `plugin/clearcut.vim` calls `clearcut#Rewrite(line1, line2)`
3. `autoload/clearcut.vim` (Vim9 script):
   - Extracts selected text
   - Builds JSON payload using `json_encode()`
   - Invokes `curl` via `system()` to call OpenAI API
   - Parses JSON response using `json_decode()`
4. Response is appended below the original selection in the buffer

### Technology Stack

- **Vim9 script**: Modern VimScript with type annotations and improved syntax
- **curl**: HTTP client for API calls (no Python dependency)
- **JSON functions**: Native `json_encode()` and `json_decode()` (available in Vim 7.4.1304+ and all Neovim versions)

### Configuration System

The plugin reads configuration from Vim global variables:
- `g:clearcut_target_ratio` - Target length ratio (default: 0.75)
- `g:clearcut_model` - OpenAI model name (default: gpt-4o-mini)
- `g:clearcut_endpoint` - API endpoint URL (default: https://api.openai.com/v1/chat/completions)

The plugin expects `OPEN_AI_KEY` environment variable for API authentication.

## Development Commands

### Testing the Plugin in Vim

```vim
" Reload plugin after changes
:source plugin/clearcut.vim
:source autoload/clearcut.vim

" Test the command
" 1. Select some text with V or v
" 2. Run:
:'<,'>Clearcut
```

### Running Automated Tests

```bash
# Install vader.vim
git clone https://github.com/junegunn/vader.vim.git

# Run all tests
vim -Nu <(cat << EOF
filetype off
set rtp+=vader.vim
set rtp+=.
filetype plugin indent on
EOF
) -c 'Vader test/*.vader'

# Run tests with Neovim
nvim -u <(cat << EOF
filetype off
set rtp+=vader.vim
set rtp+=.
filetype plugin indent on
EOF
) -c 'Vader test/*.vader'
```

### Manual API Testing

```bash
# Test curl command manually
curl -s -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPEN_AI_KEY" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "system", "content": "You are a concise editor."},
      {"role": "user", "content": "Shorten this: This is a test."}
    ],
    "temperature": 0.2
  }'
```

## Key Implementation Details

### Vim9 Script Features

The plugin uses modern Vim9 script features:
- Type annotations (`: string`, `: float`, `: dict<any>`)
- String interpolation (`$"text {variable}"`)
- Export functions (`export def Rewrite()`)
- Const declarations for immutable values

### API Key Handling

The API key is read from the `$OPEN_AI_KEY` environment variable. No hardcoded keys. The plugin checks for this at runtime and throws a clear error if missing.

### Error Handling Pattern

- Vim9 script uses `throw` for exceptions
- `try/catch` blocks handle API errors gracefully
- `echoerr` displays user-friendly error messages
- Shell errors from curl are caught via `v:shell_error`

### JSON Handling

Uses Vim's native JSON functions:
- `json_encode()` - Converts Vim dictionaries/lists to JSON strings
- `json_decode()` - Parses JSON responses from API

### Testing Strategy

Tests are organized by category in `test/clearcut.vader`:
1. **Configuration tests** - Verify default settings and overrides
2. **Error handling tests** - Empty text, missing API key
3. **Command tests** - Command existence and range support
4. **Mock API tests** - Test with mocked curl responses
5. **Integration tests** - Real API calls (skipped in CI)

## Installation Location

The plugin is installed at `~/.vim/plugged/clearcut.vim`, suggesting it's managed by a plugin manager (likely vim-plug based on the path convention).
