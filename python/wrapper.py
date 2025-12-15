import sys
from os.path import normpath, join
import vim

plugin_root_dir = vim.eval('g:ve_root_dir')
python_root_dir = normpath(join(plugin_root_dir, 'python'))
sys.path.insert(0, python_root_dir)

from vim_everything import *

def VE_SearchWrapper():
    text = vim.eval('g:ve_search_txt')
    f = int(vim.eval('g:ve_offset_txt'))
    max = int(vim.eval('g:ve_list_size'))

    vim.command('let g:ve_status=%s'%VE_Search(text, f, max))
