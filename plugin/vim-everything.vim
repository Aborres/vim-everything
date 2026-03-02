let g:ve_list_size = 20         "Changes the minimum number of elements to show in searches
let g:ve_enable_number_jump = 1 "If enabled limits g:ve_list_size to len(g:ve_jump_shortcuts)
let g:ve_jump_shortcuts = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p' ]
let g:ve_resize = 1             "Toggles if the popup window should be resizeable with the mouse
let g:ve_keep_prev_search = 1   "Forces VE to keep the input text in between searchs
let g:ve_use_python3 = 1        "Set g:ve_use_python3 = 0 to use python27
let g:ve_file_results = 1       "0: All, 1: Files, 2: Folders, can be overwritten using a:, f:, d: in the input field, this setting doesn't work with the rg fallback
let g:ve_footer_style = 0       "0: All, 1: Simplified, 2: Stats only

" VE(keep_prev_search = 1) "Searchs previous search if g:ve_keep_prev_search == 1
" VE_Path()                "Searchs input text but keeps the input path if g:ve_keep_prev_search == 1
" VE_SearchInPath(path)    "Opens VE in the specified path
" VE_Search(txt)           "Searches specified text

" use PopupNotification to change BG color
" use PopupSelected to change cursor color
hi PopupSelected guifg=#000000 guibg=#ffa500

let g:ve_clear_c           = '`' "Key used to clear input search
let g:ve_clear_name        = '!' "Key used to clear name from the input search
let g:ve_clear_path        = '@' "Key used to clear path from the input search
let g:ve_clear_ext         = '#' "Key used to clear ext from the input search
let g:ve_clear_filter      = '%' "Key used to clear filter from the input search
let g:ve_clear_last_folder = ';' "Key used to clear last folder from the path in the input search

let g:ve_cursor = '|' "Cursor Icon
let g:ve_borders = ['─', '│', '─', '│', '╭', '╮', '╯', '╰'] "Floating Window Borders

let g:ve_fixed_w = 128 "if set to any value, the window will have that size
let g:ve_use_alternative_search = 0 "If enabled will use fallback search
let g:ve_alternative_search_mode = 0 "0: fd, 1: rg
let g:ve_switch_focus = 1 "Whether to switch to a buffer if the search file is already opened

let g:ve_explore  = 'Explore '  "Default action when pressing Enter on a folder
let g:ve_vexplore = 'Vexplore ' "Default action when pressing V on a folder
let g:ve_hexplore = 'Hexplore ' "Default action when pressing S on a folder
let g:ve_texplore = 'Texplore ' "Default action when pressing T on a folder

let g:ve_edit  = 'edit '   "Default action when pressing Enter on a file
let g:ve_vedit = 'vsplit ' "Default action when pressing V on a file
let g:ve_hedit = 'split '  "Default action when pressing S on a file
let g:ve_tedit = 'tabe '   "Default action when pressing T on a file

let g:ve_last_search = ""

let g:ve_callbacks = []

func VE(keep_prev_search = 1)
  call ve#plugin#ve(a:keep_prev_search)
endfunc

func! VE_Search(txt) abort
  call ve#plugin#search(a:txt)
endfunc

func! VE_SearchInPath(path) abort
  call ve#plugin#search_in_path(a:path)
endfunc

func! VE_Path() abort
  call VE_SearchInPath(g:ve_search_txt)
endfunc
