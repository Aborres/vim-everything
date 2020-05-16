"public
let g:ve_list_size = 20
let g:ve_resize = 1

" use PopupNotification to change BG color
" use PopupSelected to change cursor color
hi PopupSelected guifg=#000000 guibg=#ffa500

let g:ve_explore  = 'Explore '
let g:ve_vexplore = 'Vexplore '
let g:ve_hexplore = 'Hexplore '
let g:ve_texplore = 'Texplore '

let g:ve_edit  = 'edit '
let g:ve_vedit = 'vsplit '
let g:ve_hedit = 'split '
let g:ve_tedit = 'tabe '

"private
let s:ve_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

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

let s:ve_search_txt   = ""

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

endfunction

func VE_FirstItemIdx()
  return s:ve_top_offset
endfunction

func VE_LastItemIdx()
  return g:ve_num_r + s:ve_top_offset - 1
endfunction

func VE_TotalPages()
  return g:ve_total_r / g:ve_list_size
endfunction

"These functions update the text in the buffers
func VE_UpdateScreenText()
  let out = s:header_text
  let out += g:ve_current_buff
  let out += s:footer_text
  return out
endfunction

func VE_UpdateHeader(text)
  let s:header_text = []
  call add(s:header_text, "VE: " . a:text)
  call add(s:header_text, "")
  return s:header_text
endfunction

func VE_UpdateFooter(id)
  let s:footer_text = []
  call add(s:footer_text, " ")
  call add(s:footer_text, "Esc: Close | Enter: Open file | V: VSplit | S: HSplit | T: New Tab")
  call add(s:footer_text, "Num res: " . g:ve_total_r . " | Idx: " . a:id . " | Pag: " . s:ve_curr_pag . "/" . VE_TotalPages())
  return s:footer_text
endfunction

func VE_FormScreenText(header, footer)
  let out = []
  let out += VE_UpdateHeader(a:header)
  let out += g:ve_current_buff
  let out += VE_UpdateFooter(a:footer)
  return out
endfunction
"

"These functions update the screen directly
func VE_UpdateScreen(id, header, footer)
  call popup_settext(a:id, VE_FormScreenText(a:header, a:footer))
endfunction

func VE_UpdateScreenBody(id)
  call popup_settext(a:id, VE_FormScreenText(s:ve_search_txt, VE_ToList(s:ve_screen_space_idx)))
endfunction

func VE_UpdateScreenFooter(id, txt)
  call popup_settext(a:id, VE_FormScreenText(s:ve_search_txt, a:txt))
endfunction
"

func VE_SearchW(text, from)

let s:ve_search_txt = a:text
let s:ve_offset_txt = a:from 

python << EOF
import sys
from os.path import normpath, join
import vim

plugin_root_dir = vim.eval('s:ve_root_dir')
python_root_dir = normpath(join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

from vim_everything import *

text = str(vim.eval('s:ve_search_txt'))
f = int(vim.eval('s:ve_offset_txt'))
max = int(vim.eval('g:ve_list_size'))

VE_Search(text, f, max)

EOF
endfunction

func VE_JumpToElement(id, e)

  let f_ir = a:e
  let dif = f_ir - s:ve_screen_space_idx
  let key = 'j'
  if (s:ve_screen_space_idx > f_ir)
    let key = 'k'
    let dif = s:ve_screen_space_idx - f_ir 
  endif

  let i = 0
  while (i < dif)
    call popup_filter_menu(a:id, key)
    let i+=1
  endwhile

  let s:ve_screen_space_idx = a:e
  
  return 1
endfunction

func VE_JumpToFirstElement(id)

  if (s:ve_screen_space_idx == VE_FirstItemIdx())
    return 1
  endif

  return VE_JumpToElement(a:id, VE_FirstItemIdx())
endfunction

func VE_JumpToLastElement(id)

  if (s:ve_screen_space_idx == VE_LastItemIdx())
    return 1
  endif

  return VE_JumpToElement(a:id, VE_LastItemIdx())
endfunction

func VE_JumpToInput(id)
  return VE_JumpToElement(a:id, 0)
endfunction

func VE_ToList(id)
  let out = a:id - s:ve_top_offset
  if (out < 0)
    let out = 0
  endif
  return out
endfunction

func VE_JumpPage(id, dir)

  let s:ve_curr_pag += (1 * a:dir)

  let total = VE_TotalPages()
  if (s:ve_curr_pag > total)
    let s:ve_curr_pag = 0
  elseif (s:ve_curr_pag < 0)
    let s:ve_curr_pag = total
  endif
  call VE_SearchW(s:ve_search_txt, s:ve_curr_pag * g:ve_list_size)
  call VE_UpdateScreenBody(a:id)

  return 1
endfunction

func VE_UpdateDown(id)

  let s:ve_screen_space_idx += 1
  call popup_filter_menu(a:id, 'j')

  if (s:ve_screen_space_idx > VE_LastItemIdx())

    call VE_JumpToFirstElement(a:id)
    call VE_JumpPage(a:id, -1)

  else
    call VE_UpdateScreenFooter(a:id, VE_ToList(s:ve_screen_space_idx))
  endif

  return 1
endfunction

func VE_UpdateUp(id)
  
  let s:ve_screen_space_idx -= 1
  call popup_filter_menu(a:id, 'k')

  if (s:ve_screen_space_idx < VE_FirstItemIdx())

    call VE_JumpToLastElement(a:id)
    call VE_JumpPage(a:id, -1)

  else
    call VE_UpdateScreenFooter(a:id, VE_ToList(s:ve_screen_space_idx))
  endif

  return 1
endfunction

func VE_UpdateInputText(id)
  let s:ve_curr_pag         = 0
  call VE_SearchW(s:ve_search_txt, 0)
  call VE_UpdateScreenBody(a:id)
  return 1
endfunction

func VE_FilterInputMode(id, key)

  if (a:key == "\<Up>" || a:key == "\<Home>")

    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0)
      return 1
    endif

    let c_left  = split_s[0]
    let c_right = ""
    if (l > 1)
      let c_right = split_s[1]
    endif

    let s:ve_search_txt = s:ve_cursor . c_left . c_right
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == "\<Down>" || a:key == "\<End>")

    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0)
      return 1
    endif

    let c_left  = split_s[0]
    let c_right = ""
    if (l > 1)
      let c_right = split_s[1]
    endif

    let s:ve_search_txt = c_left . c_right . s:ve_cursor
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == "\<Right>")

    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0 || s:ve_search_txt[strlen(s:ve_search_txt) - 1] == s:ve_cursor)
      return 1
    endif

    if (s:ve_search_txt[0] == s:ve_cursor)
      let s:ve_search_txt = s:ve_search_txt[1] . s:ve_cursor . s:ve_search_txt[2:]
      return VE_UpdateInputText(a:id)
    endif

    let c_left  = split_s[0]
    let c_right = ""
    let last_char = "" 

    if (l > 1)
      let c_right = split_s[1]
      let last_char = c_right[0]
      let c_right = c_right[1:]
    endif

    let s:ve_search_txt = c_left . last_char . s:ve_cursor . c_right
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == "\<Left>")

    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0 || s:ve_search_txt[0] == s:ve_cursor)
      return 1
    endif

    let c_left  = split_s[0]
    let c_right = ""
    if (l > 1)
      let c_right = split_s[1]
    endif

    let last_char = c_left[len(c_left) - 1]
    let c_left = c_left[:-2]

    let s:ve_search_txt = c_left . s:ve_cursor . last_char  . c_right
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == "\<BS>")
    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0)
      return 1
    endif

    let prev_cursor = split_s[0][:-2]
    let aftr_cursor = ""

    if (l > 1)
      let aftr_cursor = split_s[1]
    endif

    let s:ve_search_txt = prev_cursor . s:ve_cursor . aftr_cursor
    return VE_UpdateInputText(a:id)
  endif

  if (a:key == "\<Del>")
    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0)
      return 1
    endif

    let prev_cursor = split_s[0]
    let aftr_cursor = ""

    if (l > 1)
      let aftr_cursor = split_s[1][1:]
    endif

    let s:ve_search_txt = prev_cursor . s:ve_cursor . aftr_cursor
    return VE_UpdateInputText(a:id)
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

    let split_s = split(s:ve_search_txt, s:ve_cursor)
    let l = len(split_s)
    if (l == 0)
      let s:ve_search_txt = a:key . s:ve_cursor
      return VE_UpdateInputText(a:id)
    endif 

    let c_left  = split_s[0]
    let c_right = ""
    if (l > 1)
      let c_right = split_s[1]
    endif

    let s:ve_search_txt = c_left . a:key . s:ve_cursor . c_right

    return VE_UpdateInputText(a:id)
  endif

  return popup_filter_menu(a:id, a:key)
endfunction

func VE_CloseWith(id, mode)
  call popup_close(a:id, [s:ve_screen_space_idx - s:ve_top_offset, a:mode])
  return 1
endfunction

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

  return popup_filter_menu(a:id, a:key)
endfunction

func VE_Filter(id, key)

  hi PmenuSel ctermfg=red

  if (s:ve_current_mode == s:ve_input_mode)
    return VE_FilterInputMode(a:id, a:key)
  elseif (s:ve_current_mode == s:ve_nav_mode)
    return VE_FilterNavMode(a:id, a:key)
  else
    echo "VE: Undefined filter mode"
  endif

endfunction

func VE_OpenFile(r)
  return g:ve_r_paths[a:r] . "/" . g:ve_r_names[a:r]
endfunction

func VE_Callback(id, result)

  let r = a:result[0]
  let m = a:result[1]

  echo g:ve_r_types[r]

  if (r > -1)
    if (m == s:ve_open_enter)
      if (g:ve_r_types[r])
        :execute g:ve_explore . g:ve_r_paths[r]
      else
        :execute g:ve_edit . VE_OpenFile(r)
      endif
    elseif (m == s:ve_open_vs)
      if (g:ve_r_types[r])
        :execute g:ve_vexplore . g:ve_r_paths[r]
      else
        :execute g:ve_vedit . VE_OpenFile(r) 
      endif
    elseif (m == s:ve_open_sp)
      if (g:ve_r_types[r])
        :execute g:ve_hexplore . g:ve_r_paths[r]
      else
        :execute g:ve_hedit . VE_OpenFile(r) 
      endif
    elseif (m == s:ve_open_tab)
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
endfunction

function VE()

  call VE_Reset()
  call VE_SearchW(s:ve_search_txt, 0)
  call popup_menu(VE_FormScreenText(s:ve_search_txt, 0), 
        \#{title:'vim-Everything',
          \ filter: 'VE_Filter',
          \ callback: 'VE_Callback',
          \ resize: 'g:ve_resize',
          \ highlight: 'g:ve_style',
          \ wrap: 0,
          \ scrollbar: 1,
          \ close: 'click'
        \})
endfunction
