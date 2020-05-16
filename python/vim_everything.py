from everything import *
import vim
import threading

def __UpdateVimBuffers(names, paths, types):
  out = []

  count = len(names)

  curr = 1
  for i in range(0, count):
    curr = max(len(names[i]), curr)

  for i in range(0, count):
    diff = curr - len(names[i])
    s = names[i]
    for j in range(0, diff):
      s += " "
    s += " | "
    s += paths[i]
    out.append(s)

  vim.command("let g:ve_r_names=%s"%names)
  vim.command("let g:ve_r_paths=%s"%paths)
  vim.command("let g:ve_r_types=%s"%types)
  vim.command("let g:ve_current_buff=%s"%out)

def VE_Search(text, f, buff_size):

  text = text.replace("|", "") #remove cursor
  text = text.replace("\\", "\\\\")
  text = text.replace("/", "\\\\") #standart any separator so Everything is happy

  # the encoding is important
  # it gets lost when calling from VIM, probably because of vim's parsing
  if (len(text)):
    text = text.decode('unicode-escape')

  e = Everything()
  e.search(text, f, buff_size)

  vim.command("let g:ve_total_r=%s"%e.total_results)
  vim.command("let g:ve_num_r=%s"%e.num_results)
  __UpdateVimBuffers(e.file_names, e.file_paths, e.file_types)
