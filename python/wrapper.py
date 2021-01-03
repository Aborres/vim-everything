import sys
from os.path import normpath, join
import vim

plugin_root_dir = vim.eval('s:ve_root_dir')
python_root_dir = normpath(join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

from vim_everything import *

def VE_SearchWrapper():
    text = vim.eval('s:ve_search_txt')
    f = int(vim.eval('s:ve_offset_txt'))
    max = int(vim.eval('g:ve_list_size'))

    vim.command('let s:ve_status=%s'%VE_Search(text, f, max))
