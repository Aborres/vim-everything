let g:ve_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../..'

"Constants
const g:ve_open_enter = 0
const g:ve_open_vs    = 1
const g:ve_open_sp    = 2
const g:ve_open_tab   = 3

const g:ve_input_mode = 0
const g:ve_nav_mode   = 1
const g:ve_cache_mode = 2
"--Constants

let g:ve_internal_cursor = '?'
let g:ve_search_txt = g:ve_internal_cursor

let g:ve_status = 1
let g:ve_offset_txt =  ""

let g:ve_screen_space_idx = 0
let g:ve_curr_pag         = 0

let g:ve_current_buff = []
let g:ve_current_mode = g:ve_input_mode

let g:ve_py_search_txt = g:ve_internal_cursor

"UI
let g:ve_top_offset    = 2
let g:ve_bottom_offset = 4
"--UI

let s:ve_initialized = 0 
let s:ve_popup = -1

let s:ve_timer = -1
let s:ve_cursor_state = 1

let s:ve_active_backend = {}

func! ve#plugin#reset() abort

  "Python
  let g:ve_total_r = 0
  let g:ve_num_r   = 0

  let g:ve_results = #{
        \ names: [],
        \ paths: [],
        \ types: [],
        \ sizes: [],
        \ modds: [],
      \ }

  let g:ve_current_buff = []

  let g:ve_current_mode = g:ve_input_mode

  let g:ve_screen_space_idx = 0
  let g:ve_curr_pag         = 0

  let g:ve_search_txt = g:ve_internal_cursor
  let g:ve_py_search_txt = g:ve_internal_cursor

  let s:ve_timer = -1

  if (ve#plugin#init())
    return ve#globals#backend().reset()
  endif

  return 0

endfunc

func! ve#plugin#init() abort

  if (s:ve_initialized == 0)

    if (!has('popupwin'))
      call ve#plugin#log('Unssupported version of vim, vim must be compiled with popupwin, check version')
      return 0
    endif

    let l:backend = ve#globals#backend()
    const l:keys = ve#backend#keys()
    for l:key in l:keys
      if (!has_key(l:backend, l:key))
        call ve#plugin#log("Illformed backend, missing key, required keys are: " . string(l:keys))
        return 0
      endif
    endfor

    let s:ve_initialized = ve#globals#backend().init()

  endif

  return s:ve_initialized
endfunc

func! ve#plugin#search_w(text, from) abort

  let g:ve_search_txt = a:text
  let g:ve.last_search = g:ve_search_txt

  let g:ve_py_search_txt = ve#cursor#remove_cursor(g:ve_search_txt)

  let g:ve_offset_txt = a:from 

  let g:ve_status = ve#globals#backend().search()
  return g:ve_status

endfunc

func ve#plugin#ve(keep_prev_search = 1) abort

  if ((a:keep_prev_search != 1) || (ve#globals#keep_prev_search() != 1))
    let g:ve_search_txt = ""
  endif

  call ve#plugin#search(g:ve_search_txt)

endfunc

func! s:Blink(timer) abort
  if ((g:ve_current_mode == g:ve_input_mode) ||
    \ (g:ve_current_mode == g:ve_nav_mode))
    let s:ve_cursor_state = !s:ve_cursor_state
    call ve#update#screen_body(s:ve_popup, s:ve_cursor_state)
  endif
endfunc

func! ve#plugin#search(txt) abort

  if (!ve#plugin#reset())
    call ve#plugin#log('Failed to initialize plugin')
    return 0
  endif

  " If we are searching with a path insert the cursor at the front to start writing there
  " Otherwise it might be an already formed query
  let l:search_text = a:txt
  if ((l:search_text[0] == "\\") || (l:search_text[0] == "/"))
    let l:search_text = ve#cursor#move_front(l:search_text, 1)
  else
  endif

  if (!ve#plugin#search_w(l:search_text, 0))
    call ve#plugin#log('Search failed')
    return 0
  endif

  let l:text = ve#update#screen_text(g:ve_search_txt, 0)

  if (s:ve_popup == -1)
    let s:ve_popup = popup_menu([''], {})
    call ve#plugin#refresh_style()
  else
    call popup_show(s:ve_popup)
  endif

  call ve#jump#to_input(s:ve_popup)
  call ve#plugin#text_refresh(s:ve_popup)

  if (ve#globals#style().cursor.blink)
    let s:ve_cursor_state = 1
    let s:ve_timer = timer_start(ve#globals#style().cursor.blink, function('s:Blink'), {'repeat': -1}) 
  endif

  return 1

endfunc

func! s:GetStyle() abort

  let l:ve_args = #{
          \ title:       'vim-everything',
          \ filter:      've#filter#call',
          \ callback:    've#callback#call',
          \ resize:      ve#globals#style().window.resize,
          \ opacity:     ve#globals#style().window.opacity,
          \ wrap:        ve#globals#style().window.wrap,
          \ borderchars: ve#globals#style().window.border.icons,
          \ scrollbar:   ve#globals#style().window.scrollbar.enabled,
          \ close:       'click'
        \}

  if (len(ve#globals#style().window.bg_image))
    let l:ve_args.image = ve#globals#style().window.bg_image
  endif

  if (ve#globals#style().window.style != '')
    let l:ve_args.highlight = ve#globals#style().window.style
  endif

  if (len(ve#globals#style().window.border.style))
    let l:ve_args.borderhighlight = ve#globals#style().window.border.style
  endif

  if (ve#globals#style().window.scrollbar.style != '')
    let l:ve_args.scrollbarhighlight = ve#globals#style().window.scrollbar.style
  endif

  if (ve#globals#style().window.scrollbar.thumb_style != '')
    let l:ve_args.thumbhighlight = ve#globals#style().window.scrollbar.thumb_style
  endif

  if (ve#globals#style().window.fixed_w)
    let l:ve_args.minwidth = ve#globals#style().window.fixed_w
    let l:ve_args.maxwidth = ve#globals#style().window.fixed_w
  endif

  let l:min_height = ve#update#header_len() + ve#update#footer_len()
  let l:max_height = l:min_height + ve#filter#list_size()
  let l:ve_args.minheight = l:min_height
  let l:ve_args.maxheight = l:max_height

  return l:ve_args
endfunc

func! ve#plugin#refresh_style() abort
  let l:ve_args = s:GetStyle()

  let l:style = ve#globals#style().window.selection
  if (!empty(l:style) && hlexists(l:style))
    execute 'hi! link PopupSelected ' .. l:style
  endif

  call popup_setoptions(s:ve_popup, l:ve_args)
endfunc

func! s:ClearTimer() abort
  if (ve#globals#style().cursor.blink && (s:ve_timer > -1))
    call timer_stop(s:ve_timer)
    let s:ve_timer = -1
  endif
endfunc

func! ve#plugin#close(id) abort
  call popup_hide(a:id)
  call s:ClearTimer()
  return 1
endfunc

func! ve#plugin#destroy() abort
  call ve#plugin#reset()
  call s:ClearTimer()
  call popup_close(a:id, [-1, -1])
  return 1
endfunc

func! s:VEQueryFromPrevSearch(path) abort

  if (ve#globals#config_keep_prev_search())
    let l:last_search = ve#cursor#remove_cursor(g:ve.last_search)
    let l:file_name   = ve#filter#clear_path_text(l:last_search)
    if (l:file_name != g:ve.last_search)
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

func! ve#plugin#set_text(id, text) abort
  call popup_settext(a:id, a:text)
  return 1
endfunc

func! ve#plugin#text_refresh(id = 0) abort

  let l:id = a:id
  if (!l:id)
    let l:id = s:ve_popup
  endif

  return ve#plugin#set_text(l:id, ve#update#screen_text(g:ve_search_txt, 0))

endfunc

func! ve#plugin#refresh(id = 0) abort

  if (!ve#plugin#search_w(g:ve_search_txt, 0))
    call ve#plugin#log('Search failed')
    return 0
  endif

  call ve#plugin#text_refresh(a:id)

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

func! ve#plugin#log(log) abort
  echo('vim-everything: ' . a:log) 
endfunc
