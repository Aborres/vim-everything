
func! ve#filter#list_size() abort
  if g:ve_enable_number_jump 
    return min([len(g:ve_jump_shortcuts), g:ve_list_size])
  endif
  return g:ve_list_size
endfunc

func! ve#filter#total_pages() abort
  return g:ve_total_r / ve#filter#list_size()
endfunc

func! ve#filter#split_name_path(txt) abort

  let l:pos = stridx(a:txt, '/')
  if (l:pos == -1)
    let l:pos = stridx(a:txt, '\')
  endif

  return l:pos
endfunc

func! ve#filter#clear_name(id, key) abort

  let l:pos = ve#filter#split_name_path(g:ve_search_txt)
  if (l:pos > 0) 
    let g:ve_search_txt = ve#cursor#move_front(g:ve_search_txt[l:pos - 1:], 0)
    return ve#update#input_text(a:id)
  endif
  return 1
endfunc

func! ve#filter#clear_path_w(text) abort
  let l:new_text = a:text
  let l:pos = ve#filter#split_name_path(l:new_text)
  if (l:pos > 0) 
    let l:new_text = l:new_text[:l:pos - 1]
  endif
  return l:new_text
endfunc

func! ve#filter#clear_path(id, key) abort

  let l:search_txt = ve#cursor#remove_cursor(g:ve_search_txt)
  let l:new_text = ve#filter#clear_path_w(l:search_txt)
  if (l:new_text != l:search_txt)
    let g:ve_search_txt = ve#cursor#move_back(l:new_text, 0)
    return ve#update#input_text(a:id)
  endif

  return 1
endfunc

func! ve#filter#call(id, key) abort

  if (g:ve_current_mode == g:ve_input_mode)
    return s:FilterInput_mode(a:id, a:key)
  elseif (g:ve_current_mode == g:ve_nav_mode)
    return ve#filter#nav_mode(a:id, a:key)
  else
    echo "VE: Undefined filter mode"
  endif

  " Shouldn't ever happen
  return 1

endfunc

func! s:SelectedFileId() abort
  return g:ve_screen_space_idx - g:ve_top_offset
endfunc

func! s:FilterCloseWidth(id, mode) abort
  call popup_close(a:id, [s:SelectedFileId(), a:mode])
  return 1
endfunc

func! s:GetCurrentlyFocusedFile()
  let l:file_id = s:SelectedFileId()
  return ve#callback#get_file_full_path(l:file_id)
endfunc

func! s:CursorFront(id) abort
  let g:ve_search_txt = ve#cursor#move_front(g:ve_search_txt, 0)
  return ve#update#screen_body(a:id)
endfunc

func! s:CursorEnd(id) abort
  let g:ve_search_txt = ve#cursor#move_back(g:ve_search_txt, 0)
  return ve#update#screen_body(a:id)
endfunc

func! s:FilterUp(id, key) abort
  if (ve#cursor#is_empty_search() || ve#cursor#is_front())
    return 1
  endif
  let g:ve_search_txt = ve#cursor#move_front(g:ve_search_txt, 0)
  return ve#update#screen_body(a:id)
endfunc

func! s:FilterDown(id, key) abort
  if (ve#cursor#is_empty_search() || ve#cursor#is_back())
    return 1
  endif
  let g:ve_search_txt = ve#cursor#move_back(g:ve_search_txt, 0)
  return ve#update#screen_body(a:id)
endfunc

func! s:FilterRight(id, key) abort

  if (ve#cursor#is_empty_search() || ve#cursor#is_back())
    return 1
  endif

  let l:split_s = ve#cursor#split_text()

  if (ve#cursor#is_front())
    let l:txt = l:split_s[0]
    let g:ve_search_txt = ve#cursor#move_after(l:txt[0], l:txt[1:], 0, 0)
    return ve#update#screen_body(a:id)
  endif
  
  let l:left  = l:split_s[0] . l:split_s[1][0]
  let l:right = l:split_s[1][1:]
  let g:ve_search_txt = ve#cursor#move_after(l:left, l:right, 0, 0)
  return ve#update#screen_body(a:id)
endfunc

func! s:FilterLeft(id, key) abort

  if (ve#cursor#is_empty_search() || ve#cursor#is_front())
    return 1
  endif

  let l:split_s = ve#cursor#split_text()

  if (ve#cursor#is_back())
    let l:txt = l:split_s[0]
    let g:ve_search_txt = ve#cursor#move_after(l:txt[:-2], l:txt[len(l:txt) - 1], 0, 0)
    return ve#update#screen_body(a:id)
  endif
  
  let l:left  = l:split_s[0][:-2]
  let l:right = l:split_s[0][len(l:split_s[0]) - 1] . l:split_s[1]
  let g:ve_search_txt = ve#cursor#move_after(l:left, l:right, 0, 0)
  return ve#update#screen_body(a:id)
endfunc

func! s:FilterBS(id, key) abort

  if (ve#cursor#is_empty_search() || ve#cursor#is_front())
    return 1
  endif

  let l:split_s = ve#cursor#split_text()
  
  if (ve#cursor#is_back())
    let l:txt = l:split_s[0]
    let g:ve_search_txt = ve#cursor#move_back(l:txt[:-2], 0)
    return ve#update#input_text(a:id)
  endif 

  let l:left = l:split_s[0][:-2]
  let l:right = l:split_s[1]

  let g:ve_search_txt = ve#cursor#move_after(l:left, l:right, 0, 0)
  return ve#update#input_text(a:id)
endfunc

func! s:FilterDel(id, key) abort

  if (ve#cursor#is_empty_search() || ve#cursor#is_back())
    return 1
  endif

  let l:split_s = ve#cursor#split_text()

  if (ve#cursor#is_front())
    let l:txt = l:split_s[0]
    let g:ve_search_txt = ve#cursor#move_front(l:txt[1:], 0)
    return ve#update#input_text(a:id)
  endif

  let l:prev_cursor = l:split_s[0]
  let l:aftr_cursor = l:split_s[1][1:]

  let g:ve_search_txt = ve#cursor#move_after(l:prev_cursor, l:aftr_cursor, 0, 0)
  return ve#update#input_text(a:id)
endfunc

func! s:FilterExt(id, key) abort

  let l:new_text = ve#cursor#remove_cursor(g:ve_search_txt)

  let l:ext_pos =  stridx(l:new_text, '.')
  if (l:ext_pos > 0) 

    let l:new_text = ve#cursor#move_back(l:new_text[0:l:ext_pos], 0)

    let g:ve_search_txt = ve#cursor#remove_cursor(g:ve_search_txt)
    let l:path_pos = ve#filter#split_name_path(g:ve_search_txt)
    if (l:path_pos > 0)
      let l:new_text = l:new_text . ' ' . trim(g:ve_search_txt[l:path_pos - 1:])
    endif 

    let g:ve_search_txt = l:new_text

    return ve#update#input_text(a:id)
  endif

  return 1
endfunc

func! s:FilterFilter(id, key) abort

  let l:text = ve#cursor#remove_cursor(g:ve_search_txt)

  if (l:text[1] == ':')
    if ((l:text[0] == 'a') || (l:text[0] == 'f') || (l:text[0] == 'd'))
      let g:ve_search_txt = ve#cursor#move_front(l:text[2:], 0)
      return ve#update#input_text(a:id)
    endif
  endif

  return 1

endfunc

func! s:FilterLastFolder(id, key) abort

  let l:text = ve#cursor#remove_cursor(g:ve_search_txt)
  let l:pos  = ve#filter#split_name_path(l:text)

  if (l:pos > -1) 

    let l:name = ""
    let l:path = l:text

    " Avoid separators ending in the name
    if (l:pos > 0)
      let l:split = max([0, l:pos - 1])
      let l:name = l:text[:l:split]
      let l:path = trim(l:text[l:split:])
    endif

    let l:path = fnamemodify(l:path, ':h')

    let g:ve_search_txt = ve#cursor#move_back(l:name . l:path, 0)

    return ve#update#input_text(a:id)
  endif

  return 1
endfunc

func! ve#filter#close(id) abort
  call popup_close(a:id, [-1, -1])
  return 1
endfunc

func! s:FilterInput(id, key) abort

  if (ve#cursor#is_empty_search())
    let g:ve_search_txt = ve#cursor#move_back(a:key)
    return ve#update#input_text(a:id)
  endif 

  let l:split_s = ve#cursor#split_text()

  if (ve#cursor#is_front())
    let l:txt = l:split_s[0]
    let g:ve_search_txt = ve#cursor#move_after(a:key, l:txt, 0, 0)
    return ve#update#input_text(a:id)
  endif

  let l:c_left  = l:split_s[0]
  let l:c_right = len(l:split_s) > 1 ? l:split_s[1] : ''

  let g:ve_search_txt = ve#cursor#move_after(l:c_left . a:key, l:c_right, 0, 0)
  return ve#update#input_text(a:id)
endfunc

func! s:FilterInput_mode(id, key) abort

  if (len(g:ve_search_txt))

    if (a:key == '^')
      return s:CursorFront(a:id)
    endif

    if (a:key == '$')
      return s:CursorEnd(a:id)
    endif

    if (a:key == "\<Up>" || a:key == "\<Home>")
      return s:FilterUp(a:id, a:key)
    endif

    if (a:key == "\<Down>" || a:key == "\<End>")
      return s:FilterDown(a:id, a:key)
    endif

    if (a:key == "\<Right>")
      return s:FilterRight(a:id, a:key)
    endif

    if (a:key == "\<Left>")
      return s:FilterLeft(a:id, a:key)
    endif

    if (a:key == "\<BS>")
      return s:FilterBS(a:id, a:key)
    endif

    if (a:key == g:ve_clear_c)
      call ve#cursor#clear_text()
      return ve#update#input_text(a:id)
    endif

    if (a:key == g:ve_clear_name)
      return ve#filter#clear_name(a:id, a:key)
    endif

    if (a:key == g:ve_clear_path)
      return ve#filter#clear_path(a:id, a:key)
    endif

    if (a:key == g:ve_clear_ext)
      return s:FilterExt(a:id, a:key)
    endif

    if (a:key == g:ve_clear_filter)
      return s:FilterFilter(a:id, a:key)
    endif

    if (a:key == g:ve_clear_last_folder)
      return s:FilterLastFolder(a:id, a:key)
    endif
  endif

  if (a:key == "\<Del>")
    return s:FilterDel(a:id, a:key)
  endif

  if (a:key == "\<CR>") "Enter
    let g:ve_current_mode = g:ve_nav_mode
    return ve#jump#to_first_element(a:id)
  endif

  if (a:key == "\<Esc>")
    return ve#filter#close(a:id)
  endif

  if (a:key >= ' ' && a:key <= '~')
    return s:FilterInput(a:id, a:key)
  endif

  return popup_filter_menu(a:id, a:key)
endfunc

func! s:FromNavToInput(id, key) abort
  let g:ve_current_mode = g:ve_input_mode
  return ve#jump#to_input(a:id)
endfunc

func! ve#filter#nav_mode(id, key) abort

  if (a:key == "\<CR>") "Enter
    if (g:ve_num_r)
      return s:FilterCloseWidth(a:id, g:ve_open_enter)
    endif
    return 1 " Avoid window closure if there are no files
  endif

  if (a:key == "V")
    return s:FilterCloseWidth(a:id, g:ve_open_vs)
  endif

  if (a:key == "S")
    return s:FilterCloseWidth(a:id, g:ve_open_sp)
  endif

  if (a:key == "T")
    return s:FilterCloseWidth(a:id, g:ve_open_tab)
  endif 

  if (a:key == "\<Esc>")
    return s:FromNavToInput(a:id, a:key)
  endif

  if (a:key == 'h' || a:key == "\<Left>")
    return ve#jump#page(a:id, -1)
  endif

  if (a:key == 'j' || a:key == "\<Down>")
    return ve#update#down(a:id)
  endif

  if (a:key == 'k' || a:key == "\<Up>")
    return ve#update#up(a:id)
  endif

  if (a:key == 'l' || a:key == "\<Right>")
    return ve#jump#page(a:id, 1)
  endif

  if (a:key == 'g')
    call ve#jump#to_first_element(a:id)
    return ve#update#input_text(a:id)
  endif

  if (a:key == 'G')
    call ve#jump#to_last_element(a:id)
    return ve#update#input_text(a:id)
  endif

  if (a:key == g:ve_clear_c)
    call s:FromNavToInput(a:id, a:key)
    call ve#cursor#clear_text()
    return ve#update#input_text(a:id)
  endif

  if (a:key == g:ve_clear_name)
    call s:FromNavToInput(a:id, a:key)
    return ve#filter#clear_name(a:id, a:key)
  endif

  if (a:key == g:ve_clear_ext)
    call s:FromNavToInput(a:id, a:key)
    return s:FilterExt(a:id, a:key)
  endif

  if (a:key == g:ve_clear_filter)
    call s:FromNavToInput(a:id, a:key)
    return s:FilterFilter(a:id, a:key)
  endif

  if (a:key == g:ve_clear_path)
    call s:FromNavToInput(a:id, a:key)
    return ve#filter#clear_path(a:id, a:key)
  endif

  if (g:ve_enable_number_jump)

    let l:num_shortcuts = len(g:ve_jump_shortcuts)
    let l:jump_range = min([g:ve_num_r - 1, l:num_shortcuts - 1]) " Ranges are [] so need to remove one here

    for i in range(0, l:jump_range) 
      if (a:key == g:ve_jump_shortcuts[i])
        call ve#jump#to_element(a:id, i + g:ve_top_offset)
        return s:FilterCloseWidth(a:id, g:ve_open_enter)
      endif
    endfor
  endif

  for l:c in g:ve_callbacks
    if ((a:key == l:c[0]) && g:ve_num_r)
      let l:file = s:GetCurrentlyFocusedFile()
      let l:Ptr = l:c[2]
      return l:Ptr(a:id, l:file)
    endif
  endfor

  return popup_filter_menu(a:id, a:key)
endfunc
