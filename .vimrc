colorscheme xoria256
syntax on
set number

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

highlight ExtraWithespace ctermbg=red guibg=red
match ExtraWithespace /\s\+$/

let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_python_checkers = ['flake8']

" Unfo in vimdiff
nmap du :wincmd w<cr>:normal u<cr>:wincmd w<cr>

" Python syntax
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set fileformat=unix
set hls
