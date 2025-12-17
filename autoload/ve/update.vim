
let s:header_text = []
let s:footer_text = []

func! ve#update#screen_text(header, footer) abort
  let l:out = []
  let l:out += ve#update#header(a:header)
  let l:out += g:ve_current_buff
  let l:out += ve#update#footer(a:footer)
  return l:out
endfunc

func! ve#update#input_text(id) abort
  let g:ve_curr_pag = 0
  call ve#plugin#search_w(g:ve_search_txt, 0)
  call ve#update#screen_body(a:id)
  return 1
endfunc

func! ve#update#down(id) abort

  call ve#jump#to_next_line(a:id)

  if (g:ve_screen_space_idx > ve#jump#last_item_idx())
    call ve#jump#to_first_element(a:id)
    call ve#jump#page(a:id, 1)
  else
    call ve#update#screen_footer(a:id, ve#update#to_list(g:ve_screen_space_idx))
  endif

  return 1
endfunc

func! ve#update#up(id) abort

  call ve#jump#to_prev_line(a:id)

  if (g:ve_screen_space_idx < ve#jump#first_item_idx())
    call ve#jump#to_last_element(a:id)
    call ve#jump#page(a:id, -1)
  else
    call ve#update#screen_footer(a:id, ve#update#to_list(g:ve_screen_space_idx))
  endif

  return 1
endfunc

"These functions update the text in the buffers
func! ve#update#header(text) abort
  let s:header_text = []
  call add(s:header_text, "VE: " . a:text)
  call add(s:header_text, "")
  return s:header_text
endfunc

func! ve#update#footer(id) abort
  let s:footer_text = []
  call add(s:footer_text, " ")

  if (g:ve_footer_style < 2)
    call add(s:footer_text, "Esc: Close | Enter: Open file | V: VSplit | S: HSplit | T: New Tab")
  endif

  if (g:ve_footer_style < 1)
    let l:fmt = "Clear: Input(%s) | Name(%s) | Path(%s) | Ext(%s) | Filter(%s)"
    call add(s:footer_text, printf(l:fmt, g:ve_clear_c, g:ve_clear_name, g:ve_clear_path, g:ve_clear_ext, g:ve_clear_filter))
  endif

  call add(s:footer_text, "Num res: " . g:ve_total_r . " | Idx: " . a:id . " | Pag: " . g:ve_curr_pag . "/" . (ve#filter#total_pages() + 1))
  return s:footer_text
endfunc

func! ve#update#to_list(id) abort
  let l:out = a:id - g:ve_top_offset
  if (out < 0)
    let l:out = 0
  endif
  return l:out
endfunc

func! ve#update#screen_body(id) abort
  call popup_settext(a:id, ve#update#screen_text(g:ve_search_txt, ve#update#to_list(g:ve_screen_space_idx)))
endfunc

func! ve#update#screen_footer(id, txt) abort
  call popup_settext(a:id, ve#update#screen_text(g:ve_search_txt, a:txt))
endfunc
