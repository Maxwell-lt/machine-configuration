{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    nodejs_22 yarn
    nixd
    nixfmt-rfc-style
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      extraLuaConfig = ''
        vim.opt.backup = false
        vim.opt.writebackup = false
        vim.opt.swapfile = false
        vim.opt.cmdheight = 2
        vim.opt.updatetime = 300

        vim.opt.termguicolors = true

        vim.opt.number = true
        vim.opt.showmode = false
        vim.opt.mouse = ""

        vim.cmd('autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab')
        vim.cmd('autocmd FileType javascript setlocal ts=4 sts=4 sw=4 expandtab')
        vim.cmd('autocmd FileType typescript setlocal ts=4 sts=4 sw=4 expandtab')

        -- nvim-cmp / nvim-lspconfig setup
        -- Add additional capabilities supported by nvim-cmp
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local lspconfig = require('lspconfig')

        -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
        local servers = { 'rust_analyzer', 'pyright', 'nixd' }
        for _, lsp in ipairs(servers) do
          lspconfig[lsp].setup {
            capabilities = capabilities,
          }
        end
        lspconfig["ts_ls"].setup({
          capabilities = capabilities,
          init_options = {
            tsserver = {
              path = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib/"
            }
          },
          cmd = { 
            "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", 
            "--stdio" 
          }
        })
        
        -- Set nvim-lspconfig keybinds
        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<space>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<space>f', function()
              vim.lsp.buf.format { async = true }
            end, opts)

            -- Inlay setup
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { ev.buf })
            end
          end,
        })

        -- luasnip setup
        local luasnip = require 'luasnip'

        -- nvim-cmp setup
        local cmp = require 'cmp'
        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
            ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
            -- C-b (back) C-f (forward) for snippet placeholder navigation.
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          }),
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          },
        }

        require('telescope').setup {
          extensions = {
            fzf = {
              fuzzy = true,                    -- false will only do exact matching
              override_generic_sorter = true,  -- override the generic sorter
              override_file_sorter = true,     -- override the file sorter
              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                               -- the default case_mode is "smart_case"
            },
            file_browser = {
              hijack_netrw = true
            }
          }
        }
        require('telescope').load_extension('fzf')
        require('telescope').load_extension('file_browser')

        local file_browser = require('telescope').extensions.file_browser
        vim.keymap.set('n', '<leader>fd', file_browser.file_browser, {})

        vim.g.yuck_lisp_indentation = 1
      '';
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-solarized-lua;
          type = "lua";
          config = ''
            vim.cmd('colorscheme solarized-high')
          '';
        }
        nvim-lspconfig      # Configurations for LSP servers
        nvim-cmp            # Autocomplete
        cmp-nvim-lsp        # LSP source for nvim-cmp
        cmp_luasnip         # Snippets source for nvim-cmp
        luasnip             # Snippets plugin
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
          '';
        }
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = "require('gitsigns').setup()";
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = "require('lualine').setup()";
        }
        nvim-web-devicons   # Icons
        (nvim-treesitter.withPlugins (
          # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/development/tools/parsing/tree-sitter/grammars
          plugins:
            with plugins; [
              tree-sitter-lua
              tree-sitter-vim
              tree-sitter-html
              tree-sitter-yaml
              tree-sitter-comment
              tree-sitter-bash
              tree-sitter-javascript
              tree-sitter-nix
              tree-sitter-typescript
            ]
        ))

        vim-parinfer  # Balance parentheses when writing Lisp-style code

        vim-wakatime  # Time tracking

        # Language support
        vim-nix     # Nix
        vim-toml    # TOML
        vim-json    # JSON
        yuck-vim    # Yuck
      ];
      extraPackages = with pkgs; [
        nil
        rust-analyzer
        pyright
        fd
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodePackages.yaml-language-server
        wl-clipboard
      ];
    };
    fzf = {
      enable = true;
    };
  };
}
