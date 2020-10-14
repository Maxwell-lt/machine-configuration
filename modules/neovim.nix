{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    nodejs yarn
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      extraConfig = ''
        filetype plugin indent on
        syntax on
        set backspace=indent,eol,start
        set hidden
        set nobackup
        set nowritebackup
        set noswapfile
        set cmdheight=2
        set updatetime=300
        set shortmess+=c
        colorscheme breezy
        set background=light
        set number

        " Suggested configuration for coc.nvim
        inoremap <silent><expr> <TAB>
          \ pumvisible() ? "\<C-n>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        inoremap <silent><expr> <c-space> coc#refresh()

        inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

        nmap <silent> [g <Plug>(coc-diagnostic-prev)
        nmap <silent> ]g <Plug>(coc-diagnostic-next)

        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        nnoremap <silent> K :call <SID>show_documentation()<CR>

        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          else
            call CocActionAsync('doHover')
          endif
        endfunction

        nmap <leader>rn <Plug>(coc-rename)

        xmap <leader>f  <Plug>(coc-format-selected)
        nmap <leader>f  <Plug>(coc-format-selected)

        augroup mygroup
          autocmd!
          " Setup formatexpr specified filetype(s).
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          " Update signature help on jump placeholder.
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        command! -nargs=0 Format :call CocAction('format')
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)
        command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

        let g:lightline = {
          \ 'colorscheme': 'breezy',
          \ 'component': {
          \   'readonly': '%{&readonly?"":""}',
          \ },
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
          \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
          \ },
          \ 'component_function': {
          \   'cocstatus': 'coc#status'
          \ },
          \ 'separator': { 'left': '', 'right': '' },
          \ 'subseparator': { 'left': '', 'right': '' }
          \ }
        autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

        let g:coc_user_config = {
          \ 'rust-client.disableRustup': v:true,
          \ 'diagnostic.errorSign': '☢️',
          \ 'diagnostic.warningSign': '!',
          \ 'diagnostic.hintSign': '?'
          \ }
      '';
      plugins = let
        breezy = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "breezy";
          version = "2020-03-24";
          src = pkgs.fetchFromGitHub {
            owner = "fneu";
            repo = "breezy";
            rev = "453167dc346f39e51141df4fe7b17272f4833c2b";
            sha256 = "09w4glff27sw4z2998gpq5vmlv36mfx9vp287spm7xvaq9fnn6gb";
          };
        };
      in with pkgs.vimPlugins; [
        lightline-vim coc-nvim vim-nix fzf-vim coc-fzf fzfWrapper breezy
        coc-java coc-json coc-python coc-rls coc-yaml
      ];
    };
    fzf = {
      enable = true;
    };
  };
}
