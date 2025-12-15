
func! s:GetFileFullPath(r) abort
  return g:ve_r_paths[a:r] . "/" . g:ve_r_names[a:r]
endfunc

func! s:IsFileAlreadyOpened(path) abort

  let l:buffer_number = bufnr(a:path)
  if l:buffer_number <= 0
    return -1
  endif

  return l:buffer_number

endfunc

func! s:FocusBuffer(buffer) abort

  let l:wnr = bufwinnr(a:buffer)
  if l:wnr != -1
    execute l:wnr . 'wincmd w'
    return 1
  "else "This is for switching windows to the one containing the buffer
  "  execute 'buffer' l:bnr
  endif

  return 0
endfunc

func! ve#callback#call(id, result) abort

  let l:r = a:result[0]
  let l:m = a:result[1]

  if (l:r > -1 && g:ve_num_r > 0)

    let l:path = g:ve_r_paths[l:r]
    let l:is_folder = g:ve_r_types[l:r]

    if (g:ve_switch_focus)

      let l:full_path = l:is_folder ? l:path : s:GetFileFullPath(l:r)

      let l:buffer = s:IsFileAlreadyOpened(l:full_path)
      if (l:buffer > -1)
        if (s:FocusBuffer(l:buffer))
          return 1
        endif
      endif
    endif

    if (!l:is_folder)
      if (l:m == g:ve_open_enter)
          execute g:ve_edit . s:GetFileFullPath(l:r)
      elseif (l:m == g:ve_open_vs)
          execute g:ve_vedit . s:GetFileFullPath(l:r) 
      elseif (l:m == g:ve_open_sp)
          execute g:ve_hedit . s:GetFileFullPath(l:r)
      elseif (l:m == g:ve_open_tab)
          execute g:ve_tedit . s:GetFileFullPath(l:r)
      else 
        echo "VE: Undefined mode to open file"
      endif
    else
      if (l:m == g:ve_open_enter)
          execute g:ve_explore . l:path
      elseif (l:m == g:ve_open_vs)
          execute g:ve_vexplore . l:path
      elseif (l:m == g:ve_open_sp)
          execute g:ve_hexplore . l:path
      elseif (l:m == g:ve_open_tab)
          execute g:ve_texplore . l:path
      else 
        echo "VE: Undefined mode to open folder"
      endif
    endif
  endif

  return 1

endfunc
