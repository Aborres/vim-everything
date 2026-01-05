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

  if ((a:keep_prev_search != 1) || (g:ve_keep_prev_search != 1))
    let g:ve_search_txt = ""
  endif

  call VE_Search(g:ve_search_txt)

endfunc

func! VE_Search(txt) abort

  call ve#plugin#init()

  call ve#plugin#reset()

  " If we are searching with a path insert the cursor at the front to start writing there
  " Otherwise it might be an already formed query
  let l:search_text = a:txt
  if ((l:search_text[0] == "\\") || (l:search_text[0] == "/"))
    let l:search_text = g:ve_cursor . " " . trim(ve#filter#remove_cursor(l:search_text))
  endif

  if (!ve#plugin#search_w(l:search_text, 0))
    return 0
  endif
  
  let l:ve_args = #{
  	  \ title:'vim-Everything',
          \ filter: 've#filter#call',
          \ callback: 've#callback#call',
          \ resize: 'g:ve_resize',
          \ highlight: 'g:ve_style',
          \ borderchars: g:ve_borders,
          \ wrap: 0,
          \ scrollbar: 1,
          \ close: 'click'
        \}

  if (g:ve_fixed_w)
    let l:ve_args.minwidth = g:ve_fixed_w
    let l:ve_args.maxwidth = g:ve_fixed_w
  endif

  call popup_menu(ve#update#screen_text(g:ve_search_txt, 0), l:ve_args)
endfunc

func! VE_SearchInPath(path) abort

  let l:txt = a:path
  let l:pos = ve#filter#split_name_path(l:txt)

  if (l:pos > 0)
    let l:txt = l:txt[l:pos:]
  endif

  if (g:ve_keep_prev_search)
    let l:last_search = ve#filter#remove_cursor(g:ve_last_search)
    let l:file_name   = ve#filter#clear_path_w(l:last_search)
    if (l:file_name != g:ve_last_search)
      let l:txt = trim(l:file_name) . g:ve_cursor . ' ' . l:txt
    endif
  endif
  
  call VE_Search(l:txt)

endfunc

func! VE_Path() abort
  call VE_SearchInPath(g:ve_search_txt)
endfunc
