
func! ve#globals#backend() abort
  return g:ve.backend
endfunc

func! ve#globals#callbacks() abort
  return g:ve.callbacks
endfunc

func! ve#globals#config_globals() abort
  return g:ve.config
endfunc

func! ve#globals#config_list_size() abort
  return ve#globals#config_globals().list_size
endfunc

func! ve#globals#config_enable_number_jump() abort
  return ve#globals#config_globals().enable_number_jump
endfunc

func! ve#globals#config_jump_shortcuts() abort
  return ve#globals#config_globals().jump_shortcuts
endfunc

func! ve#globals#config_keep_prev_search() abort
  return ve#globals#config_globals().keep_prev_search
endfunc

func! ve#globals#config_use_python3() abort
  return ve#globals#config_globals().use_python3
endfunc

func! ve#globals#config_file_results() abort
  return ve#globals#config_globals().file_results
endfunc

func! ve#globals#config_results_size() abort
  return ve#globals#config_globals().results_size
endfunc

func! ve#globals#config_results_mod_date() abort
  return ve#globals#config_globals().results_mod_date
endfunc

func! ve#globals#config_use_alternative_search() abort
  return ve#globals#config_globals().use_alternative_search
endfunc

func! ve#globals#config_alternative_search_mode() abort
  return ve#globals#config_globals().alternative_search_mode
endfunc

func! ve#globals#config_switch_focus() abort
  return ve#globals#config_globals().switch_focus
endfunc

func! ve#globals#actions() abort
  return g:ve.actions 
endfunc

func! ve#globals#actions_edit() abort
  return ve#globals#actions().edit
endfunc

func! ve#globals#actions_vedit() abort
  return ve#globals#actions().vedit
endfunc

func! ve#globals#actions_hedit() abort
  return ve#globals#actions().hedit
endfunc

func! ve#globals#actions_tedit() abort
  return ve#globals#actions().tedit
endfunc

func! ve#globals#actions_explore() abort
  return ve#globals#actions().explore
endfunc

func! ve#globals#actions_vexplore() abort
  return ve#globals#actions().vexplore
endfunc

func! ve#globals#actions_hexplore() abort
  return ve#globals#actions().hexplore
endfunc

func! ve#globals#actions_texplore() abort
  return ve#globals#actions().texplore
endfunc

func! ve#globals#shortcuts() abort
  return g:ve.shortcuts
endfunc

func! ve#globals#shortcuts_clear() abort
  return ve#globals#shortcuts().clear
endfunc

func! ve#globals#shortcuts_clear_name() abort
  return ve#globals#shortcuts().clear_name
endfunc

func! ve#globals#shortcuts_clear_path() abort
  return ve#globals#shortcuts().clear_path
endfunc

func! ve#globals#shortcuts_clear_ext() abort
  return ve#globals#shortcuts().clear_ext
endfunc

func! ve#globals#shortcuts_clear_filter() abort
  return ve#globals#shortcuts().clear_filter
endfunc

func! ve#globals#shortcuts_clear_last_folder() abort
  return ve#globals#shortcuts().clear_last_folder
endfunc

func! ve#globals#shortcuts_open_history_window() abort
  return ve#globals#shortcuts().open_history_window
endfunc

func! ve#globals#history() abort
  return g:ve.history
endfunc

func! ve#globals#history_enabled() abort
  return ve#globals#history().enabled 
endfunc

func! ve#globals#history_pool_size() abort
  return ve#globals#history().pool_size
endfunc

func! ve#globals#style() abort
  return g:ve.style
endfunc
