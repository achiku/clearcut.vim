let s:default_script = fnamemodify(expand('<sfile>:p:h') . '/../scripts/clearcut_openai.py', ':p')

function! s:script_path() abort
  let l:override = get(g:, 'clearcut_rewrite_script', '')
  if !empty(l:override)
    return expand(l:override)
  endif
  return s:default_script
endfunction

function! clearcut#rewrite(line1, line2) range abort
  let l:script = s:script_path()
  if !filereadable(l:script)
    echoerr 'Concise rewrite script not found: ' . l:script
    return
  endif

  let l:selected = getline(a:line1, a:line2)
  let l:text = join(l:selected, "\n")
  if empty(trim(l:text))
    echoerr 'No text selected'
    return
  endif

  let l:ratio = get(g:, 'clearcut_target_ratio', 0.75)
  let l:cmd = ['python3', l:script, '--ratio', printf('%.2f', l:ratio)]
  let l:model = get(g:, 'clearcut_model', '')
  if !empty(l:model)
    call extend(l:cmd, ['--model', l:model])
  endif
  let l:endpoint = get(g:, 'clearcut_endpoint', '')
  if !empty(l:endpoint)
    call extend(l:cmd, ['--endpoint', l:endpoint])
  endif

  let l:result = system(l:cmd, l:text)
  if v:shell_error
    echohl ErrorMsg
    echom 'Clearcut rewrite failed: ' . substitute(l:result, '\n\+$', '', '')
    echohl None
    return
  endif

  let l:lines = split(trim(l:result), "\n", 1)
  call append(a:line2, l:lines)
  echom 'Clearcut rewrite inserted '
endfunction
