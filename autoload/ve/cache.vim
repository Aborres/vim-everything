
let s:pool = []

func! ve#cache#num_queries() abort
  return len(s:pool)
endfunc

func! ve#cache#max() abort
  return max([ve#globals#history_pool_size(), 10])
endfunc

func! s:IsQueryCached(query)
  const l:len = ve#cache#num_queries()
  for l:i in range(0, l:len - 1)
    if (s:pool[l:i] == a:query)
      return 1
    endif
  endfor
  return 0
endfunc

func! ve#cache#query(query)
  if (!ve#globals#history_enabled() || ve#globals#history_pool_size() <= 0)
    return
  endif

  if (!s:IsQueryCached(a:query))
    let l:len = ve#cache#num_queries()
    if (l:len < ve#cache#max())
      call add(s:pool, '')
      let l:len = l:len + 1
    endif

    let l:i = l:len - 1
    while l:i > 0
      let s:pool[l:i] = s:pool[l:i - 1]
      let l:i = l:i - 1
    endwhile

    let s:pool[0] = a:query
  endif

endfunc

func! ve#cache#pool() abort
  return s:pool
endfunc

func! ve#cache#text() abort

  let l:text = []
  const l:query_size = ve#cache#num_queries()
  if (l:query_size)
    const l:cache_fmt = "%d: %s"
    for l:i in range(0, ve#cache#max() - 1)
      let l:cached = printf(l:cache_fmt, l:i, l:i < l:query_size ? s:pool[l:i] : '')
      call add(l:text, l:cached)
    endfor

    call add(l:text, '')
    call add(l:text, 'Esc: Back to Search | Enter: Open Query')

  endif

  return l:text
endfunc

func! s:MoveUp(id) abort
  call ve#jump#to_prev_line(a:id)
  if (g:ve_screen_space_idx < 0)
    let l:pos = ve#cache#num_queries() - 1
    call ve#jump#to_element(a:id, l:pos)
  endif
  return 1
endfunc

func! s:MoveDown(id) abort
  call ve#jump#to_next_line(a:id)
  let l:num = ve#cache#num_queries()
  if (g:ve_screen_space_idx >= l:num)
    call ve#jump#to_element(a:id, 0)
  endif
endfunc

func! s:OpenCache(id, pos) abort
  call ve#filter#from_cache_to_input(a:id)
  let l:txt = s:pool[a:pos]
  return ve#plugin#search(l:txt)
endfunc

func! ve#cache#filter(id, key) abort

  if (a:key == "\<Esc>")
    return ve#filter#from_cache_to_input(a:id)
  endif

  if (a:key == 'j' || a:key == "\<Down>")
    return s:MoveDown(a:id)
  endif

  if (a:key == 'k' || a:key == "\<Up>")
    return s:MoveUp(a:id)
  endif

  if (a:key >= ' ' && a:key <= '~')
    let l:num = ve#cache#num_queries()
    for l:i in range(0, l:num - 1)
      if (a:key == string(l:i))
        return s:OpenCache(a:id, l:i)
      endif
    endfor
  endif

  if (a:key == "\<CR>") "Enter
    let l:idx = g:ve_screen_space_idx
    return s:OpenCache(a:id, l:idx)
  endif

  return 1
endfunc

func! ve#cache#callback(id, result) abort
endfunc
