
func! s:CallbackOpenFile(r) abort
  return g:ve_r_paths[a:r] . "/" . g:ve_r_names[a:r]
endfunc

func! ve#callback#call(id, result) abort

  let l:r = a:result[0]
  let l:m = a:result[1]

  if (l:r > -1 && g:ve_num_r > 0)
    if (l:m == g:ve_open_enter)
      if (g:ve_r_types[r])
        :execute g:ve_explore . g:ve_r_paths[r]
      else
        :execute g:ve_edit . s:CallbackOpenFile(r)
      endif
    elseif (l:m == g:ve_open_vs)
      if (g:ve_r_types[r])
        :execute g:ve_vexplore . g:ve_r_paths[r]
      else
        :execute g:ve_vedit . s:CallbackOpenFile(r) 
      endif
    elseif (l:m == g:ve_open_sp)
      if (g:ve_r_types[r])
        :execute g:ve_hexplore . g:ve_r_paths[r]
      else
        :execute g:ve_hedit . s:CallbackOpenFile(r) 
      endif
    elseif (l:m == g:ve_open_tab)
      if (g:ve_r_types[r])
        :execute g:ve_texplore . g:ve_r_paths[r]
      else
        :execute g:ve_tedit . s:CallbackOpenFile(r) 
      endif
    else 
      echo "VE: Undefined mode to open file"
    endif
  endif
  return 1
endfunc
