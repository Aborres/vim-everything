func ve#jump#to_element(id, e)
  let g:ve_screen_space_idx = a:e
  call win_execute(a:id, ":". (g:ve_screen_space_idx + 1))
  
  return 1
endfunc

func ve#jump#to_next_line(id)
  call ve#jump#to_element(a:id, g:ve_screen_space_idx + 1)
endfunc

func ve#jump#to_prev_line(id)
  call ve#jump#to_element(a:id, g:ve_screen_space_idx - 1)
endfunc

func ve#jump#first_item_idx()
   return g:ve_top_offset
endfunc

func ve#jump#last_item_idx()
  return g:ve_num_r + g:ve_top_offset - 1
endfunc

func ve#jump#to_first_element(id)
  if (g:ve_screen_space_idx == ve#jump#first_item_idx())
    return 1
  endif

  return ve#jump#to_element(a:id, ve#jump#first_item_idx())
endfunc

func ve#jump#to_last_element(id)

  if (g:ve_screen_space_idx == ve#jump#last_item_idx())
    return 1
  endif

  return ve#jump#to_element(a:id, ve#jump#last_item_idx())
endfunc

func ve#jump#to_input(id)
  return ve#jump#to_element(a:id, 0)
endfunc

func ve#jump#page(id, dir)

  let g:ve_curr_pag += (1 * a:dir)

  let l:total = ve#filter#total_pages()
  if (g:ve_curr_pag > l:total)
    let g:ve_curr_pag = 0
  elseif (g:ve_curr_pag < 0)
    let g:ve_curr_pag = l:total
  endif
  call ve#plugin#search_w(g:ve_search_txt, g:ve_curr_pag * ve#filter#list_size())

  let l:next_pos = g:ve_screen_space_idx
  if (g:ve_screen_space_idx < ve#jump#first_item_idx())
    let l:next_pos = ve#jump#first_item_idx()
  elseif (g:ve_screen_space_idx > ve#jump#last_item_idx())
    let l:next_pos = ve#jump#last_item_idx()
  endif

  call ve#jump#to_element(a:id, l:next_pos)
  call ve#update#screen_body(a:id)

  return 1
endfunc

