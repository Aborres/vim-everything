from everything import *

import sys
import vim
import threading
import unicodedata

def __UpdateVimBuffers(names, paths, types):
  out = []

  count = len(names)

  curr = 1
  for i in range(0, count):
    curr = max(len(names[i]), curr)

  valid_ids = []
  for i in range(0, 10):
    valid_ids.append(i)

  valid_ids += ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']

  for i in range(0, count):
    diff = curr - len(names[i])
    s = names[i]
    for j in range(0, diff):
      s += " "
    s += " | "
    s += paths[i]

    if (vim.vars["ve_enable_number_jump"]):
      s = f"{valid_ids[i]}: " + s
    out.append(s)

  vim.command("let g:ve_r_names=%s"%names)
  vim.command("let g:ve_r_paths=%s"%paths)
  vim.command("let g:ve_r_types=%s"%types)
  vim.command("let g:ve_current_buff=%s"%out)

def VE_Search(text, f, buff_size):

  text = text.replace("|", "") #remove cursor
  text = text.replace("/", "\\") #standard any separator so Everything is happy
  text = text.replace("\\\\", "\\")

  e = Everything()
  if (not e.search(text, f, buff_size)):
    return 0

  vim.command("let g:ve_total_r=%s"%e.total_results)
  vim.command("let g:ve_num_r=%s"%e.num_results)
  __UpdateVimBuffers(e.file_names, e.file_paths, e.file_types)
  return 1

