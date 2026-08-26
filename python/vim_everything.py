import sys

windows = True
if "win32" in sys.platform.lower():
  from everything import *
else:
  from find import *
  windows = False

import vim
import threading
import unicodedata

def __BytesToString(size):

  offset = 500

  if (size < 1000):
    return str(size) + ' B'

  if (size < offset * 1000):
    return str(size / 1000) + 'KB'

  if (size < offset * (1000 * 1000)):
    return str(size / (1000 * 1000)) + 'MB'

  return str(size / (1000 * 1000 * 1000)) + 'GB'

def __Count(count, buffer):
  max_l = 1
  for i in range(count):
    max_l = max(len(buffer[i]), max_l)
  return max_l

def __Delta(max_l, e):
    
  diff = max_l - len(e)
  
  s = "" 
  for j in range(0, diff):
    s += " "
  return s

def __UpdateVimBuffers(names, paths, types, sizes, modds, inc_size, inc_modd):
  out = []

  enable_jump = vim.vars["ve_enable_number_jump"]
  valid_ids = vim.eval("g:ve_jump_shortcuts")

  count = len(names)

  max_l = __Count(count, names)

  for i in range(count):

    s = names[i] + __Delta(max_l, names[i])

    s += " | "
    s += paths[i]

    if (enable_jump and i < len(valid_ids)):
      s = f"{valid_ids[i]}: " + s
    out.append(s)

  size_t = []

  if (inc_size):
    max_l = __Count(count, out)

    for i in range(count):

      size_t.append(__BytesToString(sizes[i]))

      s = __Delta(max_l, out[i])
      s += " | "

      out[i] += s

    max_l = __Count(count, size_t)

    for i in range(count):
      s = __Delta(max_l, size_t[i])
      s += size_t[i]
      s += " | "
      out[i] += s

  if (inc_modd):
    for i in range(count):
      out[i] += modds[i] + " | "

  vim.command("let g:ve_results.names=%s"%names)
  vim.command("let g:ve_results.paths=%s"%paths)
  vim.command("let g:ve_results.types=%s"%types)
  vim.command("let g:ve_results.sizes=%s"%sizes)
  vim.command("let g:ve_results.modds=%s"%modds)
  vim.command("let g:ve_current_buff=%s"%out)

def __VE_QueryType(text):

  type = vim.vars["ve_file_results"]

  filter = text[:2].lower()

  if (filter == "a:"):
      return text[2:], 0

  if (filter == "f:"):
      return text[2:], 1
      
  if (filter == "d:"):
      return text[2:], 2

  return text, type
  
def VE_Search(text, f, buff_size, inc_size, inc_modd):

  text = text.replace("/", "\\") #standard any separator so Everything is happy
  text = text.replace("\\\\", "\\")

  use_as = vim.vars["ve_use_alternative_search"]

  e = None
  if (windows and not use_as):
    e = Everything()
  else:
    search_mode = vim.vars["ve_alternative_search_mode"]
    e = Find()
    e.setMode(search_mode)

  text, type = __VE_QueryType(text)

  if (not e.search(text, type, f, buff_size, inc_size, inc_modd)):
    return 0

  total_r    = e.query.total
  num_r      = e.query.num
  file_names = e.query.names
  file_paths = e.query.paths
  file_types = e.query.types
  file_sizes = e.query.sizes
  file_modds = e.query.modds

  vim.command("let g:ve_total_r=%s"%total_r)
  vim.command("let g:ve_num_r=%s"%num_r)

  # For now non everything paths don't support sizes and modd
  inc_size = inc_size and not use_as
  inc_modd = inc_modd and not use_as

  __UpdateVimBuffers(file_names, file_paths, file_types, file_sizes, file_modds, inc_size, inc_modd)

  return 1

