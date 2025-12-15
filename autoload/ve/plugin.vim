let g:ve_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../..'
let s:ve_initialized = 0 

"Constants
let g:ve_open_enter = 0
let g:ve_open_vs    = 1
let g:ve_open_sp    = 2
let g:ve_open_tab   = 3

let g:ve_input_mode   = 0
let g:ve_nav_mode     = 1
"--Constants

let g:ve_status = 1
let g:ve_offset_txt =  ""

let g:ve_screen_space_idx = 0
let g:ve_curr_pag         = 0

let g:ve_current_buff = []
let g:ve_current_mode = g:ve_input_mode

let g:ve_search_txt = g:ve_cursor

"UI
let g:ve_top_offset       = 2
let g:ve_bottom_offset    = 4
"--UI

func! ve#plugin#reset() abort

  "Python
  let g:ve_total_r = 0
  let g:ve_num_r   = 0

  let g:ve_r_names = []
  let g:ve_r_paths = []
  let g:ve_r_types = []

  let g:ve_current_buff = []

  let g:ve_current_mode = g:ve_input_mode

  let g:ve_screen_space_idx = 0
  let g:ve_curr_pag         = 0

endfunc

func! ve#plugin#init() abort
  if (s:ve_initialized == 0)

    let l:wrapper_file = escape(g:ve_root_dir, ' ') . '/python/wrapper.py'

    if (g:ve_use_python3 == 1)
      exe 'py3file ' . l:wrapper_file
    else
      exe 'pyfile ' . l:wrapper_file
    endif

    let s:ve_initialized = 1
  endif
endfunc

func! ve#plugin#search_w(text, from) abort

  let g:ve_search_txt = a:text
  let g:ve_last_search = g:ve_search_txt

  let g:ve_offset_txt = a:from 
  let g:ve_status = 1

  if (g:ve_use_python3 == 1)
    python3 VE_SearchWrapper()
  else
    python VE_SearchWrapper()
  endif

  return g:ve_status
endfunc
