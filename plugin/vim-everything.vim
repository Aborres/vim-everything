"public
let g:ve_list_size = 20 "Changes the minimum number of elements to show in searches
let g:ve_enable_number_jump = 1 "If enabled limits g:ve_list_size to 20
let g:ve_resize = 1 "Toggles if the popup window should be resizeable with the mouse
let g:ve_keep_prev_search = 1 "Forces VE to keep the input text in between searchs
let g:ve_use_python3 = 1 "set g:ve_use_python3 = 0 to use python27

" VE(keep_prev_search = 1) "Searchs previous search if g:ve_keep_prev_search == 1
" VE_Path()                "Searchs input text but keeps the input path if g:ve_keep_prev_search == 1
" VE_SearchInPath(path)    "Opens VE in the specified path
" VE_Search(txt)           "Searches specified text

" use PopupNotification to change BG color
" use PopupSelected to change cursor color
hi PopupSelected guifg=#000000 guibg=#ffa500

let g:ve_clear_c    = '$' "Key used to clear input search
let g:ve_clear_name = '!' "Key used to clear name from the input search
let g:ve_clear_path = '@' "Key used to clear path from the input search
let g:ve_clear_ext  = '#' "Key used to clear ext from the input search

let g:ve_fixed_w = 128 "if set to any value, the window will have that size
let g:ve_use_alternative_search = 0 "If enabled will use ripgrep

let g:ve_explore  = 'Explore '  "Default action when pressing Enter on a folder
let g:ve_vexplore = 'Vexplore ' "Default action when pressing V on a folder
let g:ve_hexplore = 'Hexplore ' "Default action when pressing S on a folder
let g:ve_texplore = 'Texplore ' "Default action when pressing T on a folder

let g:ve_edit  = 'edit '   "Default action when pressing Enter on a file
let g:ve_vedit = 'vsplit ' "Default action when pressing V on a file
let g:ve_hedit = 'split '  "Default action when pressing S on a file
let g:ve_tedit = 'tabe '   "Default action when pressing T on a file

"private
let s:ve_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:ve_initialized = 0 

"Constants
let s:ve_open_enter = 0
let s:ve_open_vs    = 1
let s:ve_open_sp    = 2
let s:ve_open_tab   = 3

let s:ve_input_mode   = 0
let s:ve_nav_mode     = 1
let s:ve_cursor = "|" 
"--Constants

let s:ve_screen_space_idx = 0
let s:ve_curr_pag         = 0

"UI
let s:ve_top_offset       = 2
let s:ve_bottom_offset    = 4
"--UI

let s:header_text = []
let s:footer_text = []
let g:ve_current_buff = []
let s:ve_current_mode = s:ve_input_mode

let s:ve_search_txt   = s:ve_cursor

func VE_Reset()

  "Python
  let g:ve_total_r = 0
  let g:ve_num_r   = 0

  let g:ve_r_names = []
  let g:ve_r_paths = []
  let g:ve_r_types = []

  let g:ve_current_buff = []

  let s:ve_current_mode = s:ve_input_mode

  let s:ve_screen_space_idx = 0
  let s:ve_curr_pag         = 0

endfunc

func VE_FirstItemIdx()
  return s:ve_top_offset
endfunc

func VE_LastItemIdx()
  return g:ve_num_r + s:ve_top_offset - 1
endfunc

func VE_ListSize()
  if g:ve_enable_number_jump 
    return min([20, g:ve_list_size])
  endif
  return g:ve_list_size
endfunc

func VE_TotalPages()
  return g:ve_total_r / VE_ListSize()
endfunc

"These functions update the text in the buffers
func VE_UpdateScreenText()
  let l:out = s:header_text
  let l:out += g:ve_current_buff
  let l:out += s:footer_text
  return l:out
endfunc

func VE_UpdateHeader(text)
  let s:header_text = []
  call add(s:header_text, "VE: " . a:text)
  call add(s:header_text, "")
  return s:header_text
endfunc

func VE_UpdateFooter(id)
  let s:footer_text = []
  call add(s:footer_text, " ")
  call add(s:footer_text, "Esc: Close | Enter: Open file | V: VSplit | S: HSplit | T: New Tab")
  call add(s:footer_text, "Num res: " . g:ve_total_r . " | Idx: " . a:id . " | Pag: " . s:ve_curr_pag . "/" . (VE_TotalPages() + 1))
  return s:footer_text
endfunc

func VE_FormScreenText(header, footer)
  let l:out = []
  let l:out += VE_UpdateHeader(a:header)
  let l:out += g:ve_current_buff
  let l:out += VE_UpdateFooter(a:footer)
  return l:out
endfunc
"

"These functions update the screen directly
func VE_UpdateScreen(id, header, footer)
  call popup_settext(a:id, VE_FormScreenText(a:header, a:footer))
endfunc

func VE_UpdateScreenBody(id)
  call popup_settext(a:id, VE_FormScreenText(s:ve_search_txt, VE_ToList(s:ve_screen_space_idx)))
endfunc

func VE_UpdateScreenFooter(id, txt)
  call popup_settext(a:id, VE_FormScreenText(s:ve_search_txt, a:txt))
endfunc
"

func VE_SearchW(text, from)

  let s:ve_search_txt = a:text
  let s:ve_offset_txt = a:from 
  let s:ve_status = 1

  if (g:ve_use_python3 == 1)
    python3 VE_SearchWrapper()
  else
    python VE_SearchWrapper()
  endif

  return s:ve_status
endfunc

func VE_JumpToElement(id, e)
  let s:ve_screen_space_idx = a:e
  call win_execute(a:id, ":". (s:ve_screen_space_idx + 1))
  
  return 1
endfunc

func VE_JumpToNextLine(id)
  call VE_JumpToElement(a:id, s:ve_screen_space_idx + 1)
endfunc

func VE_JumpToPrevLine(id)
  call VE_JumpToElement(a:id, s:ve_screen_space_idx - 1)
endfunc

func VE_JumpToFirstElement(id)
  if (s:ve_screen_space_idx == VE_FirstItemIdx())
    return 1
  endif

  return VE_JumpToElement(a:id, VE_FirstItemIdx())
endfunc

func VE_JumpToLastElement(id)

  if (s:ve_screen_space_idx == VE_LastItemIdx())
    return 1
  endif

  return VE_JumpToElement(a:id, VE_LastItemIdx())
endfunc

func VE_JumpToInput(id)
  return VE_JumpToElement(a:id, 0)
endfunc

func VE_ToList(id)
  let l:out = a:id - s:ve_top_offset
  if (out < 0)
    let l:out = 0
  endif
  return l:out
endfunc

func VE_RemoveCursor(txt)
  return substitute(a:txt, s:ve_cursor, '', '')
endfunc

func VE_JumpPage(id, dir)

  let s:ve_curr_pag += (1 * a:dir)

  let l:total = VE_TotalPages()
  if (s:ve_curr_pag > l:total)
    let s:ve_curr_pag = 0
  elseif (s:ve_curr_pag < 0)
    let s:ve_curr_pag = l:total
  endif
  call VE_SearchW(s:ve_search_txt, s:ve_curr_pag * VE_ListSize())

  let l:next_pos = s:ve_screen_space_idx
  if (s:ve_screen_space_idx < VE_FirstItemIdx())
    let l:next_pos = VE_FirstItemIdx()
  elseif (s:ve_screen_space_idx > VE_LastItemIdx())
    let l:next_pos = VE_LastItemIdx()
  endif

  call VE_JumpToElement(a:id, l:next_pos)
  call VE_UpdateScreenBody(a:id)

  return 1
endfunc

func VE_UpdateDown(id)

  call VE_JumpToNextLine(a:id)

  if (s:ve_screen_space_idx > VE_LastItemIdx())
    call VE_JumpToFirstElement(a:id)
    call VE_JumpPage(a:id, 1)
  else
    call VE_UpdateScreenFooter(a:id, VE_ToList(s:ve_screen_space_idx))
  endif

  return 1
endfunc

func VE_UpdateUp(id)

  call VE_JumpToPrevLine(a:id)

  if (s:ve_screen_space_idx < VE_FirstItemIdx())
    call VE_JumpToLastElement(a:id)
    call VE_JumpPage(a:id, -1)
  else
    call VE_UpdateScreenFooter(a:id, VE_ToList(s:ve_screen_space_idx))
  endif

  return 1
endfunc

func VE_UpdateInputText(id)
  let s:ve_curr_pag = 0
  call VE_SearchW(s:ve_search_txt, 0)
  call VE_UpdateScreenBody(a:id)
  return 1
endfunc

func VE_FilterUp(id, key)
  if ((strlen(s:ve_search_txt) < 2) || (s:ve_search_txt[0] == s:ve_cursor))
    return 1
  endif
  let s:ve_search_txt = s:ve_cursor . VE_RemoveCursor(s:ve_search_txt)
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterDown(id, key)
  if ((strlen(s:ve_search_txt) < 2) || (s:ve_search_txt[strlen(s:ve_search_txt) - 1] == s:ve_cursor))
    return 1
  endif

  let s:ve_search_txt = VE_RemoveCursor(s:ve_search_txt) . s:ve_cursor
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterRight(id, key)
  let l:split_s = split(s:ve_search_txt, s:ve_cursor)
  let l:l = len(l:split_s)
  if (l:l == 0 || s:ve_search_txt[strlen(s:ve_search_txt) - 1] == s:ve_cursor)
    return 1
  endif

  if (s:ve_search_txt[0] == s:ve_cursor)
    let s:ve_search_txt = s:ve_search_txt[1] . s:ve_cursor . s:ve_search_txt[2:]
    return VE_UpdateInputText(a:id)
  endif

  let l:c_left  = l:split_s[0]
  let l:c_right = ""
  let l:last_char = "" 

  if (l > 1)
    let l:c_right = l:split_s[1]
    let l:last_char = l:c_right[0]
    let l:c_right = l:c_right[1:]
  endif

  let s:ve_search_txt = l:c_left . l:last_char . s:ve_cursor . l:c_right
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterLeft(id, key)
  
  let l:split_s = split(s:ve_search_txt, s:ve_cursor)
  let l:l = len(l:split_s)
  if (l:l == 0 || s:ve_search_txt[0] == s:ve_cursor)
    return 1
  endif

  let l:c_left  = l:split_s[0]
  let l:c_right = ""
  if (l > 1)
    let l:c_right = l:split_s[1]
  endif

  let l:last_char = l:c_left[len(l:c_left) - 1]
  let l:c_left = l:c_left[:-2]

  let s:ve_search_txt = l:c_left . s:ve_cursor . l:last_char  . l:c_right
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterBS(id, key)
  let l:l = len(s:ve_search_txt)

  if (l:l < 2)
    return 1
  endif
  
  if (s:ve_search_txt[0] == s:ve_cursor)
    return 1
  endif

  if (s:ve_search_txt[l - 1] == s:ve_cursor)
    let s:ve_search_txt = s:ve_search_txt[:-3] . s:ve_cursor 
    echo s:ve_search_txt
    return VE_UpdateInputText(a:id)
  endif 

  let l:split_s = split(s:ve_search_txt, s:ve_cursor)
  let l:prev_cursor = l:split_s[0][:-2]
  let l:aftr_cursor = l:split_s[1]

  let s:ve_search_txt = l:prev_cursor . s:ve_cursor . l:aftr_cursor
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterDel(id, key)
  let l:l = len(s:ve_search_txt)

  if (l:l < 2)
    return 1
  endif

  if (s:ve_search_txt[l - 1] == s:ve_cursor)
    return 1
  endif 

  if (s:ve_search_txt[0] == s:ve_cursor)
    let s:ve_search_txt = s:ve_cursor . s:ve_search_txt[2:]
    return VE_UpdateInputText(a:id)
  endif

  let l:split_s = split(s:ve_search_txt, s:ve_cursor)
  let l:prev_cursor = l:split_s[0]
  let l:aftr_cursor = l:split_s[1][1:]

  let s:ve_search_txt = l:prev_cursor . s:ve_cursor . l:aftr_cursor
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterInput(id, key)
  let l:split_s = split(s:ve_search_txt, s:ve_cursor)
  let l:l = len(l:split_s)
  if (l:l == 0)
    let s:ve_search_txt = a:key . s:ve_cursor
    return VE_UpdateInputText(a:id)
  endif 

  let l:c_left  = l:split_s[0]
  if (s:ve_search_txt[0] == s:ve_cursor)
    let s:ve_search_txt = a:key . s:ve_cursor . l:c_left
    return VE_UpdateInputText(a:id)
  endif

  let l:c_right = ""
  if (l:l > 1)
    let l:c_right = l:split_s[1]
  endif

  let s:ve_search_txt = l:c_left . a:key . s:ve_cursor . l:c_right
  return VE_UpdateInputText(a:id)
endfunc

func VE_FilterSplitNamePath(txt)

  let l:pos = stridx(a:txt, '/')
  if (l:pos == -1)
    let l:pos = stridx(a:txt, '\')
  endif

  return l:pos
endfunc

func VE_FilterClearName(id, key)

  let l:pos = VE_FilterSplitNamePath(s:ve_search_txt)
  if (l:pos > 0) 
    let s:ve_search_txt = VE_RemoveCursor(s:ve_search_txt)
    let s:ve_search_txt = s:ve_cursor . " " . s:ve_search_txt[l:pos - 1:]
    return VE_UpdateInputText(a:id)
  endif
  return 1
endfunc

func VE_VE_FilterExt(txt)
  return stridx(a:txt, '.')
endfunc

func VE_FilterExt(id, key)
  let l:path_pos = VE_FilterSplitNamePath(s:ve_search_txt)
  let l:ext_pos = VE_VE_FilterExt(s:ve_search_txt)
  if (l:path_pos > 0 && l:ext_pos > 0) 
    let s:ve_search_txt = VE_RemoveCursor(s:ve_search_txt)
    let s:ve_search_txt = s:ve_search_txt[0:l:ext_pos] . s:ve_cursor . " " . s:ve_search_txt[l:path_pos - 1:]
    return VE_UpdateInputText(a:id)
  endif
  return 1
endfunc

func VE_FilterClearPath(id, key)

  let l:pos = VE_FilterSplitNamePath(s:ve_search_txt)
  if (l:pos > 0) 
    let s:ve_search_txt = VE_RemoveCursor(s:ve_search_txt)
    let s:ve_search_txt = s:ve_search_txt[:pos - 1] . s:ve_cursor
    return VE_UpdateInputText(a:id)
  endif
  return 1
endfunc

func VE_FilterInputMode(id, key)

  if (a:key == "\<Up>" || a:key == "\<Home>")
    return VE_FilterUp(a:id, a:key)
  endif

  if (a:key == "\<Down>" || a:key == "\<End>")
    return VE_FilterDown(a:id, a:key)
  endif

  if (a:key == "\<Right>")
    return VE_FilterRight(a:id, a:key)
  endif

  if (a:key == "\<Left>")
    return VE_FilterLeft(a:id, a:key)
  endif

  if (a:key == "\<BS>")
    return VE_FilterBS(a:id, a:key)
  endif

  if (a:key == g:ve_clear_c)
    let s:ve_search_txt = s:ve_cursor
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == g:ve_clear_name)
    return VE_FilterClearName(a:id, a:key)
  endif

  if (a:key == g:ve_clear_ext)
    return VE_FilterExt(a:id, a:key)
  endif

  if (a:key == g:ve_clear_path)
    return VE_FilterClearPath(a:id, a:key)
  endif

  if (a:key == "\<Del>")
    return VE_FilterDel(a:id, a:key)
  endif

  if (a:key == "\<CR>") "Enter
    let s:ve_current_mode = s:ve_nav_mode
    return VE_JumpToFirstElement(a:id)
  endif

  if (a:key == "\<Esc>")
    call popup_close(a:id, [-1, -1])
    return 1
  endif

  if (a:key >= ' ' && a:key <= '~')
    return VE_FilterInput(a:id, a:key)
  endif

  return popup_filter_menu(a:id, a:key)
endfunc

func VE_CloseWith(id, mode)
  call popup_close(a:id, [s:ve_screen_space_idx - s:ve_top_offset, a:mode])
  return 1
endfunc

func VE_FilterNavMode(id, key)

  if (a:key == "\<CR>") "Enter
    return VE_CloseWith(a:id, s:ve_open_enter)
  endif

  if (a:key == "V")
    return VE_CloseWith(a:id, s:ve_open_vs)
  endif

  if (a:key == "S")
    return VE_CloseWith(a:id, s:ve_open_sp)
  endif

  if (a:key == "T")
    return VE_CloseWith(a:id, s:ve_open_tab)
  endif 

  if (a:key == "\<Esc>")
    let s:ve_current_mode = s:ve_input_mode
    return VE_JumpToInput(a:id)
  endif

  if (a:key == 'h' || a:key == "\<Left>")
    return VE_JumpPage(a:id, -1)
  endif

  if (a:key == 'j' || a:key == "\<Down>")
    return VE_UpdateDown(a:id)
  endif

  if (a:key == 'k' || a:key == "\<Up>")
    return VE_UpdateUp(a:id)
  endif

  if (a:key == 'l' || a:key == "\<Right>")
    return VE_JumpPage(a:id, 1)
  endif

  if (a:key == 'g')
    call VE_JumpToFirstElement(a:id)
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == 'G')
    call VE_JumpToLastElement(a:id)
    return VE_UpdateInputText(a:id)
  endif

  if (g:ve_enable_number_jump)

    let l:valid_ids = []
    for i in range(0, 9)
      call add(l:valid_ids, string(i))
      echo i
    endfor

    let l:valid_ids = l:valid_ids + ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']

    for i in range(1, VE_ListSize() - 1) 
      if (a:key == l:valid_ids[i])
        call VE_JumpToElement(a:id, i + s:ve_top_offset)
        return VE_CloseWith(a:id, s:ve_open_enter)
      endif
    endfor
  endif

  return popup_filter_menu(a:id, a:key)
endfunc

func VE_Filter(id, key)

  if (s:ve_current_mode == s:ve_input_mode)
    return VE_FilterInputMode(a:id, a:key)
  elseif (s:ve_current_mode == s:ve_nav_mode)
    return VE_FilterNavMode(a:id, a:key)
  else
    echo "VE: Undefined filter mode"
  endif

endfunc

func VE_OpenFile(r)
  return g:ve_r_paths[a:r] . "/" . g:ve_r_names[a:r]
endfunc

func VE_Callback(id, result)

  let l:r = a:result[0]
  let l:m = a:result[1]

  if (l:r > -1 && g:ve_num_r > 0)
    if (l:m == s:ve_open_enter)
      if (g:ve_r_types[r])
        :execute g:ve_explore . g:ve_r_paths[r]
      else
        :execute g:ve_edit . VE_OpenFile(r)
      endif
    elseif (l:m == s:ve_open_vs)
      if (g:ve_r_types[r])
        :execute g:ve_vexplore . g:ve_r_paths[r]
      else
        :execute g:ve_vedit . VE_OpenFile(r) 
      endif
    elseif (l:m == s:ve_open_sp)
      if (g:ve_r_types[r])
        :execute g:ve_hexplore . g:ve_r_paths[r]
      else
        :execute g:ve_hedit . VE_OpenFile(r) 
      endif
    elseif (l:m == s:ve_open_tab)
      if (g:ve_r_types[r])
        :execute g:ve_texplore . g:ve_r_paths[r]
      else
        :execute g:ve_tedit . VE_OpenFile(r) 
      endif
    else 
      echo "VE: Undefined mode to open file"
    endif
  endif
  return 1
endfunc

function VE(keep_prev_search = 1)

  if ((a:keep_prev_search != 1) || (g:ve_keep_prev_search != 1))
    let s:ve_search_txt = ""
  endif

  call VE_Search(s:ve_search_txt)

endfunction

function VE_Init()
  if (s:ve_initialized == 0)

    let l:wrapper_file = escape(s:ve_root_dir, ' ') . '\..\python\wrapper.py'

    if (g:ve_use_python3 == 1)
      exe 'py3file ' . l:wrapper_file
    else
      exe 'pyfile ' . l:wrapper_file
    endif

    let s:ve_initialized = 1
  endif
endfunction

function VE_Search(txt)

  call VE_Init()

  call VE_Reset()
  let l:search_text = s:ve_cursor . " " . trim(VE_RemoveCursor(a:txt))

  if (!VE_SearchW(l:search_text, 0))
    return 0
  endif
  
  let l:ve_args = #{
  	  \ title:'vim-Everything',
          \ filter: 'VE_Filter',
          \ callback: 'VE_Callback',
          \ resize: 'g:ve_resize',
          \ highlight: 'g:ve_style',
          \ wrap: 0,
          \ scrollbar: 1,
          \ close: 'click'
        \}

  if (g:ve_fixed_w)
    let l:ve_args.minwidth = g:ve_fixed_w
    let l:ve_args.maxwidth = g:ve_fixed_w
  endif

  call popup_menu(VE_FormScreenText(s:ve_search_txt, 0), l:ve_args)
endfunc

function VE_SearchInPath(path)

  let l:txt = a:path
  let l:pos = VE_FilterSplitNamePath(l:txt)

  if (l:pos > 0)
    let l:txt = l:txt[l:pos:]
  endif
  
  call VE_Search(l:txt)

endfunction

funct VE_Path()
  call VE_SearchInPath(s:ve_search_txt)
endfunction
