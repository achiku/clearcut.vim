if exists('g:loaded_clearcut_agent')
  finish
endif
let g:loaded_clearcut_agent = 1

command! -range Clearcut call clearcut#rewrite(<line1>, <line2>)

xnoremap <silent> <leader>cct :<C-u>Clearcut<CR>
