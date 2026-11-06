
" Backend spec:
" init: Checks whether the backend can run in the current vim env
"
" search:
"   Actual search for results
"   Must read 
"     - g:ve_py_search_txt "Text to search
"     - g:ve_offset_txt    "Offset within results to return
"     - g:ve.config.list_size     "Total size of search
"   Must fill the following variables:
"     let g:ve_results = #{
"           \ names: [], "List of names for results
"           \ paths: [], "List of paths for results
"           \ types: [], "List of types for results (folder 1 or file 0)
"           \ sizes: [], "List of sizes for results
"           \ modds: [], "List of modification times for results
"         \ }
"     - g:ve_current_buff=[] "List with formated results for displaying in UI
"     - g:ve_total_r=0       "Total number of files matching query
"     - g:ve_num_r=0         "Total number of returned files
"   Must be able to handle prefixes for queries
"     - a: "Any type
"     - f: "Files only
"     - d: "Directories only
"   Must be able to deal with split queries the way Everything does
"     - file_name.ext \some_path\
"   Must return 1 or 0 depending on whether the search was successful
"
" reset: Backend specific cleanup, no need to clean global state

func! ve#backend#keys() abort
  return ['name', 'init', 'search', 'reset']
endfunc

func! ve#backend#es_init() abort

  "TODO: will investigate wether is worth running this in parallel
  const l:vj_start = exists('*VJStart') 
  const l:es = executable('es')

  if (!l:vj_start || !l:es)
    call ve#plugin#log(printf("Can't run with es backend, vim-jobs: %d, es.exe: %d", l:vj_start, l:es))
    return 0
  endif

  return 1
endfunc

func! s:ProcessOutput(output, offset, total) abort

  let l:from = a:offset
  let l:to   = min([(a:offset + a:total), len(a:output)]) - 1

  if (l:to > l:from)

    for l:i in range(l:from, l:to)
      let l:res = a:output[l:i]

      let l:name = l:res.name
      let l:file = l:res.filename
      let l:attr = l:res.attributes

      call add(g:ve_results.names, l:name)
      call add(g:ve_results.paths, l:file)
      call add(g:ve_results.types, and(l:file, 16 != 0))
      call add(g:ve_current_buff, l:name . ' ' . l:file)
    endfor

    let g:ve_num_r = len(g:ve_current_buff)

    return 1

  endif

  return 0

endfunc

func! s:ESUpdate(job, log) abort
  let ve#globals#backend().cached_query .= a:log
  return a:log
endfunc

func! s:ESExit(job) abort
  const l:raw =json_decode(join(a:job.parsed, ' '))
  call s:ProcessOutput(l:raw, 0, 20)
endfunc

func! ve#backend#es_search() abort

  const l:exec = 'es.exe'

  if (g:ve_py_search_txt != ve#globals#backend().cached_query)

    const l:query = printf('%s %s', l:exec, g:ve_py_search_txt)

    const l:count_query = l:query . ' -get-result-count'
    let g:ve_total_r = system(l:count_query)

    if (g:ve_total_r)

      " TODO
      const l:folders_filter = '/ad' 
      const l:files_filter   = '/a-d' 

      let l:res_query = [l:exec, g:ve_py_search_txt, '-s', '-o', g:ve_offset_txt, '-n', ve#filter#list_size(), '-json', '-name', '-full-path-and-name', '-attributes']

      let l:res_query = join(l:res_query, ' ')
      const l:raw = system(l:res_query, ' ')
      const l:json = json_decode(l:raw)

      call s:ProcessOutput(l:json, 0, ve#filter#list_size())

      "const l:res_query = [l:exec, g:ve_py_search_txt, '-s', '-json', '-name', '-full-path-and-name', '-attributes']
      "let l:args = { 'focus': 0, 'auto_kill': 1, 'on_log': function('s:ESUpdate'), 'on_pre_exit': function('s:ESExit') }
      "call VJStart('TEST', l:res_query, l:args)

      let ve#globals#backend().cached_query = g:ve_py_search_txt
      let ve#globals#backend().cached_results = l:json

    endif
  endif

  "call s:ProcessOutput(ve#globals#backend().cached_results, g:ve_offset_txt, ve#globals#config_list_size())

  return 1
endfunc

func! ve#backend#es_reset() abort
  return 1
endfunc

func! ve#backend#es() abort
  return #{
      \ name: 'EverythingES',
      \ init:   function('ve#backend#es_init'),
      \ search: function('ve#backend#es_search'),
      \ reset:  function('ve#backend#es_reset'),
      \ cached_query: '_NO_QUERY_',
      \ cached_results: [],
    \ }
endfunc

func! ve#backend#fd_init() abort

  const l:vj_start = exists('*VJStart') 
  const l:fd = executable('fd')

  if (!l:vj_start || !l:fd)
    call ve#plugin#log(printf("Can't run with fd backend, vim-jobs: %d, fd: %d", l:vj_start, l:fd))
    return 0
  endif

  return 1

endfunc

func! s:GenerateFDOutput(raw) abort

  let l:output = []
  for l:res in a:raw
    let l:item = #{ name: '', filename: '', attributes: 0 }
    let l:item.name = fnamemodify(l:res, ':t')
    let l:item.filename = l:res
    let l:attributes = 0
    call add(output, l:item)
  endfor

  return l:output
endfunc

func! s:FixQuery(query) abort
  let l:pos = ve#filter#split_name_path(trim(a:query))
  if (l:pos == 0)
    return '. ' . a:query
  endif
  return a:query
endfunc

func! ve#backend#fd_search() abort

  if (g:ve_py_search_txt != ve#globals#backend().cached_query)

    let l:query = s:FixQuery(g:ve_py_search_txt)

    let l:res_query = ['fd', l:query, '-i', '-a']

    if (g:ve_py_search_txt[1] == ':')
      if (g:ve_py_search_txt[0] == 'f')
        call add(l:res_query, '-t f')
      elseif (g:ve_py_search_txt[0] == 'd')
        call add(l:res_query, '-t d')
      endif
    endif

    let l:res_query = join(l:res_query, ' ')
    let l:raw = split(system(l:res_query, ' '), "\n")

    let ve#globals#backend().cached_query   = g:ve_py_search_txt
    let ve#globals#backend().cached_results = s:GenerateFDOutput(l:raw)
  endif

  return s:ProcessOutput(ve#globals#backend().cached_results, g:ve_offset_txt, g:ve_total_r)

endfunc

func! ve#backend#fd_reset() abort
  return 1
endfunc

func! ve#backend#fd() abort
  return #{
        \ name: 'EverythingFD',
        \ init:   function('ve#backend#fd_init'),
        \ search: function('ve#backend#fd_search'),
        \ reset:  function('ve#backend#fd_reset'),
        \ cached_query: '_NO_QUERY_',
        \ cached_results: [],
      \ }
endfunc

func! ve#backend#py_init() abort

  const l:py = has('python') || has('python3') 
  if (!l:py)
    call ve#plugin#log(printf("Can't run with py backend, no python support found"))
    return 0
  endif

  const l:wrapper_file = escape(g:ve_root_dir, ' ') . '/python/wrapper.py'
  
  if (ve#globals#config_use_python3())
    exe 'py3file ' . l:wrapper_file
  else
    exe 'pyfile ' . l:wrapper_file
  endif

  return 1

endfunc

func! ve#backend#py_search() abort

  if (ve#globals#config_use_python3())
    python3 VE_SearchWrapper()
  else
    python VE_SearchWrapper()
  endif

  " Set by wrapper
  return g:ve_status

endfunc

func! ve#backend#py_reset() abort
  return 1
endfunc

func! ve#backend#py() abort
return #{
      \ name: 'EverythingPy',
      \ init:   function('ve#backend#py_init'),
      \ search: function('ve#backend#py_search'),
      \ reset:  function('ve#backend#py_reset'),
    \ }
endfunc
