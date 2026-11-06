import sys
from os.path import normpath, join
import vim

plugin_root_dir = vim.eval('g:ve_root_dir')
python_root_dir = normpath(join(plugin_root_dir, 'python'))
sys.path.insert(0, python_root_dir)

from vim_everything import *

def VE_SearchWrapper():

    text = vim.eval('g:ve_py_search_txt')
    f = int(vim.eval('g:ve_offset_txt'))
    max = int(vim.eval('ve#filter#list_size()'))
    inc_size = int(vim.eval('ve#globals#config_results_size()'))
    inc_modd = int(vim.eval('ve#globals#config_results_mod_date()'))

    vim.command('let g:ve_status=%s'%VE_Search(text, f, max, inc_size, inc_modd))
