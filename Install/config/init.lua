-- plugin 管理
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Packer自身

  -- Syntax highlight / better parsing
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/nvim-treesitter-context' -- 常に上部に関数/クラス名を表示
  use 'nvim-treesitter/playground'              -- Treesitterのデバッグ/可視化

  -- File explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' } -- アイコン表示
  }
end)

-- Treesitter 設定
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "vim", "python", "javascript", "typescript",
   "html", "css", "markdown", "markdown_inline" 
  },
  sync_install = false, -- 起動時に同期インストールしない
  auto_install = false, -- ファイルを開いたときに自動で入れない
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = { enable = true },
}

-- NvimTree 設定
require("nvim-tree").setup {
  filters = {
    dotfiles = false,    -- 初期状態では表示しない
    git_ignored = true,  -- 初期状態では表示しない
  },
  git = {
    ignore = true,
  },
  view = {
    width = 30,
  }
}

-- キーマッピング
-- Ctrl + h
vim.keymap.set('n', '<C-h>', function()
  -- 隠しファイルのトグル
  require("nvim-tree.api").tree.toggle_hidden_filter()
  -- gitignore 無視ファイルのトグル
  require("nvim-tree.api").tree.toggle_gitignore_filter()
end, { noremap = true, silent = true })



-- Ctrl + n
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- システムクリップボード
vim.opt.clipboard = "unnamedplus"
-- wl-clipboard を使うように明示的に設定
vim.g.clipboard = {
  name = "wl-clipboard",
  copy = {
    ["+"] = "wl-copy --foreground --type text/plain",
    ["*"] = "wl-copy --foreground --type text/plain",
  },
  paste = {
    ["+"] = "wl-paste --no-newline",
    ["*"] = "wl-paste --no-newline",
  },
  cache_enabled = true,
}

-- Line Number
vim.opt.number = true


-- 標準テーマ morning を使う
vim.cmd("colorscheme morning")

vim.opt.shortmess:append "I"   -- intro message を非表示にする
