from everything import *

import sys
import vim
import threading
import unicodedata

def __TranslateP3(buff):
  out = buff.encode().decode('unicode-escape')
  out = out[2:]
  return out.replace("'b", "")

def __TranslateInput(buff):
  if (sys.version_info >= (3,0)):
      return __TranslateP3(buff)

  return buff.decode('unicode-escape')


def __Translate(buff):

  if (sys.version_info >= (3,0)):
    return __TranslateP3(buff)
  
  return buff

def __UpdateVimBuffers(names, paths, types):
  out = []

  count = len(paths)
  for i in range(0, count):
    paths[i] = __Translate(paths[i])

  count = len(names)

  curr = 1
  for i in range(0, count):
    names[i] = __Translate(names[i])
    curr = max(len(names[i]), curr)

  for i in range(0, count):
    diff = curr - len(names[i])
    s = names[i]
    for j in range(0, diff):
      s += " "
    s += " | "
    s += paths[i]
    out.append(__Translate(s))

  vim.command("let g:ve_r_names=%s"%names)
  vim.command("let g:ve_r_paths=%s"%paths)
  vim.command("let g:ve_r_types=%s"%types)
  vim.command("let g:ve_current_buff=%s"%out)

def VE_Search(text, f, buff_size):

  text = text.replace("|", "") #remove cursor
  text = text.replace("\\", "\\\\")
  text = text.replace("/", "\\\\") #standard any separator so Everything is happy

  # the encoding is important
  # it gets lost when calling from VIM, probably because of vim's parsing
  if (len(text)):
    text = __TranslateInput(text)

  e = Everything()
  if (not e.search(text, f, buff_size)):
    return 0

  vim.command("let g:ve_total_r=%s"%e.total_results)
  vim.command("let g:ve_num_r=%s"%e.num_results)
  __UpdateVimBuffers(e.file_names, e.file_paths, e.file_types)
  return 1

