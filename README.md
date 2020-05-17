# vim-everything

## What is it?
VE is a small wrapper for the black magic tool: [Everything](https://www.voidtools.com/)

![Everything_img](/img/everything.jpg)

## Installation and Requirements
**Requires Python and a version of Vim compiled with Python support.**

**Requires Everything to be running in the background.**

The plugin makes use of Vim's popup windows from Vim 8.2+.

Just clone the repository using your favorite vim plugging manager or the in-built one.

## Navigation

#### Search:
VE accepts the same regex syntax Everything accepts.
For example: *.vim \vim\ would list all the .vim files under the \vim\ hierarchy.

Use the arrow keys to move and edit the text.
Up/Down To jump to the front/end of the text.
~ will clear the search.

#### Results:
VE uses default hjkl vim navigation (or arrow keys) when moving through files.

Use j/k and to move up/down between the results.

Use h/l to jump result pages.

Use g/G to jump to the first/last element of the results.

## Usage

VE doesn't bind to any keys by default, whenever you want to start VE just call VE()

For example:
```vim
  nnoremap <C-p> :call VE()<CR>
```

Use Enter/Esc to move between the search bar and the results.
Use Esc to close from the search bar.
From the results:
Enter: Open file/folder in current buffer.
V: Open file/folder in a vertical split.
S: Open file/folder in a horizontal split.
T: Open file/folder in a new tab.

![VE_Open_File](/img/open_file.gif)

The default behavior for VE when opening folders is to open the path in netrw.
This can be customized, see Options.

![VE_Open_Folder](/img/open_folder.gif)

## Options
These options are customizable:
```vim
let g:ve_list_size = 20 "Changes the minimum number of elements to show in searches
let g:ve_resize = 1 "Toggles if the popup window should be resizeable with the mouse

" use PopupNotification to change BG color
" use PopupSelected to change cursor color
hi PopupSelected guifg=#000000 guibg=#ffa500

let g:ve_explore  = 'Explore '  "Default action when pressing Enter on a folder
let g:ve_vexplore = 'Vexplore ' "Default action when pressing V on a folder
let g:ve_hexplore = 'Hexplore ' "Default action when pressing S on a folder
let g:ve_texplore = 'Texplore ' "Default action when pressing T on a folder

let g:ve_edit  = 'edit '   "Default action when pressing Enter on a file
let g:ve_vedit = 'vsplit ' "Default action when pressing V on a file
let g:ve_hedit = 'split '  "Default action when pressing S on a file
let g:ve_tedit = 'tabe '   "Default action when pressing T on a file
```
