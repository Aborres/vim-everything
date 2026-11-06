
" VE(keep_prev_search = 1)        "Searchs previous search if g:ve.config.keep_prev_search == 1
" VE_Search(txt)                  "Searches specified text
" VE_SearchFileInPath(file, path) "Searches specified text in specified path
" VE_SearchInPath(path)           "Opens VE in the specified path
" VE_Path()                       "Searchs input text but keeps the input path if g:ve.config.keep_prev_search == 1
" VE_Refresh()                    "Refresh results list
" VE_AddCallback(callback)        "Adds callback to vim-everything window

hi VESelected guifg=#000000 guibg=#ffa500 ctermfg=0 ctermbg=24
hi VEStyle    guifg=#ffffff guibg=NONE    ctermfg=1 ctermbg=24

let g:ve = #{
  \ backend: ve#backend#py(),
 "\ Set by vim-everything
  \ last_search: "",
  \ callbacks: [],
  \ config: #{
    "\ Changes the minimum number of elements to show in searches
    \ list_size: 20,
    "\ If enabled limits list_size to len(g:ve.config.jump_shortcuts)
    \ enable_number_jump: 1,
    \ jump_shortcuts: [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p' ],
    "\ Forces VE to keep the input text in between searchs
    \ keep_prev_search: 1,
    "\ Set 0 to use python27
    \ use_python3: 1,
    "\ 0: All, 1: Files, 2: Folders, can be overwritten using a:, f:, d: in the input field, this setting doesn't work with the rg fallback
    \ file_results: 1,
    \ results_size: 1,
    \ results_mod_date: 1,
    "\ If enabled will use fallback search
    \ use_alternative_search: 0,
    "\ 0: fd, 1: rg
    \ alternative_search_mode: 0,
    "\ Whether to switch to a buffer if the search file is already opened
    \ switch_focus: 1,
  \},
  \ actions: #{
    "\ Default action when pressing Enter on a file
    \ edit: 'edit',
    "\ Default action when pressing V on a file
    \ vedit: 'vsplit',
    "\ Default action when pressing S on a file
    \ hedit: 'split',
    "\ Default action when pressing T on a file
    \ tedit: 'tabe',
    "\ Default action when pressing Enter on a folder
    \ explore:  'Explore',
    "\ Default action when pressing V on a folder
    \ vexplore: 'Vexplore',
    "\ Default action when pressing S on a folder
    \ hexplore: 'Hexplore',
    "\ Default action when pressing T on a folder
    \ texplore: 'Texplore',
  \ },
  \ shortcuts: #{
    "\ Key used to clear input search
    \ clear:               '`',
    "\ Key used to clear name from the input search
    \ clear_name:          '!',
    "\ Key used to clear path from the input search
    \ clear_path:          '@',
    "\ Key used to clear ext from the input search
    \ clear_ext:           '#',
    "\ Key used to clear filter from the input search
    \ clear_filter:        '%',
    "\ Key used to clear last folder from the path in the input search
    \ clear_last_folder:   ';',
    "\ If history is enabled, switches context to history window
    \ open_history_window: '?',
  \},
  \ history: #{
    "\ Caches queries for later quicker retrieval, this does not keep the results but the queries themselves
    \ enabled: 1,
    "\ How many queries to cachy at any given time, max of 10
    \ pool_size: 10,
  \ },
  \ style: #{
    \ window: #{
      \ style: 'VEStyle',
      \ selection: 'VESelected',
      \ fixed_w: &columns * 2 / 3,
      \ fixed_h: 1,
      \ resize: 1, 
      \ opacity: 100,
      \ wrap: 0,
      \ bg_image: [],
      \ scrollbar: #{
        \ enabled: 0,
        \ style: '',
        \ thumb_style: '',
      \},
      \ border: #{
        \ icons: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ style: [],
      \},
      \ },
    \ cursor: #{
      \ blink: 500, 
      \ icon: '|', 
    \ },
    \ footer: #{
      \ style: 0
    \ },
  \ },
\ }

func VE(keep_prev_search = 1)
  call ve#plugin#ve(a:keep_prev_search)
endfunc

func! VE_Search(txt) abort
  call ve#plugin#search(a:txt)
endfunc

" Only supports g:ve.config.keep_prev_search if file is ''
func! VE_SearchFileInPath(file, path) abort
  call ve#plugin#search_text_in_path(a:file, a:path)
endfunc

func! VE_SearchInPath(path) abort
  call ve#plugin#search_in_path(a:path)
endfunc

func! VE_Path() abort
  call VE_SearchInPath(g:ve_search_txt)
endfunc

func! VE_Refresh() abort
  call ve#plugin#refresh()
endfunc

" callback = ['key', 'Name', function(id, file)]
func! VE_AddCallback(callback) abort
  call ve#callback#add_callback(a:callback)
endfunc
