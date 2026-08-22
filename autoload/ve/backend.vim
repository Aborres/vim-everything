
" Backend spec:
" init: Checks whether the backend can run in the current vim env
"
" search:
"   Actual search for results
"   Must read 
"     - g:ve_py_search_txt "Text to search
"     - g:ve_offset_txt    "Offset within results to return
"     - g:ve_list_size     "Total size of search
"   Must fill the followin variables:
"     - g:ve_r_names=[]      "List of names for results
"     - g:ve_r_paths=[]      "List of paths for results
"     - g:ve_r_types=[]      "List of types for results (folder 1 or file 0)
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

const g:ve_backend_type_es = 0 "Requires vim-jobs
const g:ve_backend_type_fd = 1 "Requires vim-jobs
const g:ve_backend_type_py = 2 "Requires python
const g:ve_backend_type_cm = 3 "Custom, externally provided

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

func! s:ESProcessOutput(json, offset, total) abort

  for l:i in range(a:offset, a:total -1)
    let l:res = a:json[l:i]

    let l:name = l:res.name
    let l:file = l:res.filename
    let l:attr = l:res.attributes

    call add(g:ve_r_names, l:name)
    call add(g:ve_r_paths, l:file)
    call add(g:ve_r_types, and(l:file, 16 != 0))
    call add(g:ve_current_buff, l:name . ' ' . l:file)
  endfor

  let g:ve_num_r = len(g:ve_current_buff)

endfunc

func! s:ESUpdate(job, log) abort
  let g:ve_backend.cached_query .= a:log
  return a:log
endfunc

func! s:ESExit(job) abort
  const l:raw =json_decode(join(a:job.parsed, ' '))
  call s:ESProcessOutput(l:raw, 0, 20)
endfunc

func! ve#backend#es_search() abort

  const l:exec = 'es.exe'

  if (g:ve_py_search_txt != g:ve_backend.cached_query)

    const l:query = printf('%s %s', l:exec, g:ve_py_search_txt)

    const l:count_query = l:query . ' -get-result-count'
    let g:ve_total_r = system(l:count_query)

    if (g:ve_total_r)

      " TODO
      const l:folders_filter = '/ad' 
      const l:files_filter   = '/a-d' 

      let l:res_query = [l:exec, g:ve_py_search_txt, '-s', '-o', g:ve_offset_txt, '-n', g:ve_list_size, '-json', '-name', '-full-path-and-name', '-attributes']

      let l:res_query = join(l:res_query, ' ')
      const l:raw = system(l:res_query, ' ')
      const l:json = json_decode(l:raw)

      call s:ESProcessOutput(l:json, 0, g:ve_list_size)

      "const l:res_query = [l:exec, g:ve_py_search_txt, '-s', '-json', '-name', '-full-path-and-name', '-attributes']
      "let l:args = { 'focus': 0, 'auto_kill': 1, 'on_log': function('s:ESUpdate'), 'on_pre_exit': function('s:ESExit') }
      "call VJStart('TEST', l:res_query, l:args)

      let g:ve_backend.cached_query = g:ve_py_search_txt
      let g:ve_backend.cached_results = l:json

    endif
  endif

  "call s:ESProcessOutput(g:ve_backend.cached_results, g:ve_offset_txt, g:ve_list_size)

  return 1
endfunc

func! ve#backend#es_reset() abort
  return 1
endfunc

func! ve#backend#es() abort
  return #{
      \ name: 'EverythingES',
      \ platform: g:ve_backend_type_es,
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

func! ve#backend#fd_search() abort
endfunc

func! ve#backend#fd_reset() abort
endfunc

const g:ve_fd_backend = #{
      \ name: 'EverythingFD',
      \ platform: g:ve_backend_type_fd,
      \ init:   function('ve#backend#fd_init'),
      \ search: function('ve#backend#fd_search'),
      \ reset:  function('ve#backend#fd_reset'),
    \ }

func! ve#backend#py_init() abort

  const l:py = has('python') || has('python3') 
  if (!l:py)
    call ve#plugin#log(printf("Can't run with py backend, no python support found"))
    return 0
  endif

  const l:wrapper_file = escape(g:ve_root_dir, ' ') . '/python/wrapper.py'
  
  if (g:ve_use_python3 == 1)
    exe 'py3file ' . l:wrapper_file
  else
    exe 'pyfile ' . l:wrapper_file
  endif

  return 1

endfunc

func! ve#backend#py_search() abort

  if (g:ve_use_python3 == 1)
    python3 VE_SearchWrapper()
  else
    python VE_SearchWrapper()
  endif

endfunc

func! ve#backend#py_reset() abort
  return 1
endfunc

func! ve#backend#py() abort
return #{
      \ name: 'EverythingPy',
      \ platform: g:ve_backend_type_py,
      \ init:   function('ve#backend#py_init'),
      \ search: function('ve#backend#py_search'),
      \ reset:  function('ve#backend#py_reset'),
    \ }
endfunc
