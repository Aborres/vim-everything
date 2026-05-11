let g:ve_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../..'

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

let g:ve_search_txt = g:ve_internal_cursor
let g:ve_py_search_txt = g:ve_internal_cursor

"UI
let g:ve_top_offset    = 2
let g:ve_bottom_offset = 4
"--UI

let s:ve_initialized = 0 
let s:ve_popup = 0

let s:ve_timer = -1
let s:ve_cursor_state = 1

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

  let s:ve_popup = 0

  let g:ve_search_txt = g:ve_internal_cursor
  let g:ve_py_search_txt = g:ve_internal_cursor

  call ve#plugin#init()

  let s:ve_timer = -1

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

  let g:ve_py_search_txt = ve#cursor#remove_cursor(g:ve_search_txt)

  let g:ve_offset_txt = a:from 
  let g:ve_status = 1

  if (g:ve_use_python3 == 1)
    python3 VE_SearchWrapper()
  else
    python VE_SearchWrapper()
  endif

  return g:ve_status
endfunc

func ve#plugin#ve(keep_prev_search = 1) abort

  if ((a:keep_prev_search != 1) || (g:ve_keep_prev_search != 1))
    let g:ve_search_txt = ""
  endif

  call ve#plugin#search(g:ve_search_txt)

endfunc

func! s:Blink(timer) abort
  let s:ve_cursor_state = !s:ve_cursor_state
  call ve#update#screen_body(s:ve_popup, s:ve_cursor_state)
endfunc

func! ve#plugin#search(txt) abort

  call ve#plugin#reset()

  " If we are searching with a path insert the cursor at the front to start writing there
  " Otherwise it might be an already formed query
  let l:search_text = a:txt
  if ((l:search_text[0] == "\\") || (l:search_text[0] == "/"))
    let l:search_text = ve#cursor#move_front(l:search_text)
  else
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

  let s:ve_popup = popup_menu(ve#update#screen_text(g:ve_search_txt, 0), l:ve_args)
  if (g:ve_cursor_blink)
    let s:ve_cursor_state = 1
    let s:ve_timer = timer_start(g:ve_cursor_blink_speed, function('s:Blink'), {'repeat': -1}) 
  endif
endfunc

func! ve#plugin#close(id) abort

  call popup_close(a:id, [-1, -1])

  if (g:ve_cursor_blink && (s:ve_timer > -1))
    call timer_stop(s:ve_timer)
    let s:ve_timer = -1
  endif
  return 1
endfunc

func! s:VEQueryFromPrevSearch(path) abort

  if (g:ve_keep_prev_search)
    let l:last_search = ve#cursor#remove_cursor(g:ve_last_search)
    let l:file_name   = ve#filter#clear_path_w(l:last_search)
    if (l:file_name != g:ve_last_search)
      return ve#cursor#move_after(l:file_name, a:path)
    endif
  endif

  return a:path
endfunc

func! s:VECleanPathForSearch(path) abort

  let l:txt = ve#plugin#check_sep_terminated(a:path)
  let l:pos = ve#filter#split_name_path(l:txt)

  if (l:pos > 0)
    let l:txt = l:txt[l:pos:]
  endif

  return l:txt
endfunc

func! ve#plugin#search_in_path(path) abort

  let l:txt = s:VECleanPathForSearch(a:path)
  let l:txt = s:VEQueryFromPrevSearch(l:txt)

  call ve#plugin#search(l:txt)

endfunc

func! ve#plugin#search_text_in_path(file, path) abort

  if (a:file == '')
    call ve#plugin#search_in_path(a:path)
    return
  endif

  let l:txt = s:VECleanPathForSearch(a:path)
  let l:txt = ve#cursor#move_after(a:file, l:txt)

  call ve#plugin#search(l:txt)

endfunc

func! ve#plugin#refresh(id = 0) abort

  if (!ve#plugin#search_w(g:ve_search_txt, 0))
    return 0
  endif

  let l:id = a:id
  if (!l:id)
    let l:id = s:ve_popup
  endif

  call popup_settext(l:id, ve#update#screen_text(g:ve_search_txt, 0))

endfunc

func! ve#plugin#check_sep_terminated(path) abort

  let l:len = len(a:path)
  if (l:len > 0)
    let l:end = a:path[l:len - 1]
    let l:term = l:end == '/' || l:end == '\'
    if (!l:term)
      return a:path . '\'
    endif
  endif

  return a:path
endfunc
