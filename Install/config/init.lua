-- runtimepath に lazy.nvim を追加
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")


-- プラグイン管理
require("lazy").setup({
{
"nvim-treesitter/nvim-treesitter",
build = ":TSUpdate",
},
"nvim-treesitter/nvim-treesitter-context",
"nvim-treesitter/playground",
{
"nvim-tree/nvim-tree.lua",
dependencies = { "nvim-tree/nvim-web-devicons" },
},
{
"akinsho/toggleterm.nvim", -- Terminal 管理
config = true
},
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 }, 
})

-- Treesitter 設定
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "vim", "python", "javascript", "typescript",
   "html", "css", "markdown", "markdown_inline", "c", "cpp" 
  },
  sync_install = false, -- 起動時に同期インストールしない
  auto_install = false, -- ファイルを開いたときに自動で入れない
  highlight = { enable = true },
}

-- NvimTree 設定
require("nvim-tree").setup {
  filters = {
    dotfiles = false,    -- 初期状態では表示しない
    git_ignored = false,
  },
  git = {
    ignore = true,
  },
  view = {
    width = 30,
  }
}


-- ToggleTerm 設定
require("toggleterm").setup {
size = 20,
open_mapping = [[<c-t>]], -- Ctrl+ t でトグル
shade_terminals = true,
direction = "horizontal",
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
vim.cmd("colorscheme tokyonight")

-- intro message を非表示にする
vim.opt.shortmess:append "I"   

-- ファイル保存を義務化
vim.o.hidden = false

-- Recover and Delete
vim.api.nvim_create_autocmd("SwapExists", {
  callback = function()
    vim.cmd("recover")                    -- 自動で recover する
    vim.fn.delete(vim.v.swapname)         -- recover に使った swap を削除
    vim.notify("Swap recovered and deleted: " .. vim.v.swapname)
  end,
})

-- swap ファイルをカレントディレクトリに置く
vim.opt.directory = "."
