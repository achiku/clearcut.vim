# Testing clearcut.vim

## Running Tests with vader.vim

### Setup

```bash
# Clone vader.vim if not already present
git clone https://github.com/junegunn/vader.vim.git
```

### Run All Tests

```bash
# With Vim
/usr/bin/vim -Nu <(cat << 'EOF'
filetype off
set rtp+=vader.vim
set rtp+=.
filetype plugin indent on
EOF
) -c 'Vader test/basic.vader'
```

### Manual Testing

1. Start Vim:
   ```bash
   /usr/bin/vim
   ```

2. Set your API key:
   ```vim
   :let $OPEN_AI_KEY='sk-your-key-here'
   ```

3. Create some text:
   ```vim
   :new
   :put='This is a very long sentence that contains many unnecessary words and could definitely be made much more concise and shorter.'
   ```

4. Select the text and run Clearcut:
   ```vim
   :1,$Clearcut
   ```

5. Check the result - it should append a shorter version below the original text.

## Test Coverage

The vader test suite in `test/basic.vader` covers:

- Plugin loading
- Command existence
- Error handling (empty text, missing API key)
- Configuration variables

For full integration testing with the OpenAI API, you need a valid API key.
