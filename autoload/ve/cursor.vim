
func! ve#cursor#remove_cursor(txt) abort
  return substitute(a:txt, g:ve_internal_cursor, '', '')
endfunc

func! ve#cursor#clear_text() abort
  let g:ve_search_txt = g:ve_internal_cursor
endfunc

func! ve#cursor#move_after(first_half, second_half, first_space=0, second_space=1) abort
  let l:first_half  = a:first_half
  let l:first_half .= a:first_space ? ' ' : '' 
  let l:txt  = l:first_half . g:ve_internal_cursor 
  let l:txt .= a:second_space ? ' ' : '' 
  let l:txt .= ve#cursor#remove_cursor(a:second_half)
  return l:txt
endfunc

func! ve#cursor#move_front(txt, space=1) abort
  return ve#cursor#move_after('', ve#cursor#remove_cursor(a:txt), 0, a:space)
endfunc

func! ve#cursor#move_back(txt, space=1) abort
  return ve#cursor#move_after(ve#cursor#remove_cursor(a:txt), '', a:space, 0)
endfunc

func! ve#cursor#is_front() abort
  return g:ve_search_txt[0] == g:ve_internal_cursor
endfunc

func! ve#cursor#is_back() abort
  return g:ve_search_txt[strlen(g:ve_search_txt) - 1] == g:ve_internal_cursor
endfunc

func! ve#cursor#is_empty_search() abort
  let l:clean_txt = ve#cursor#remove_cursor(g:ve_search_txt)
  return len(l:clean_txt) == 0
endfunc

func! ve#cursor#split_text() abort
  let l:split_s = split(g:ve_search_txt, g:ve_internal_cursor)
  return l:split_s
endfunc
