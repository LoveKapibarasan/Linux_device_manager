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
  },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    
    -- マウス左クリック時の動作を設定
    vim.keymap.set("n", "<LeftMouse>", function()
      -- クリックされたファイルを取得
      local node = api.tree.get_node_under_cursor()
      
      -- ファイルだったらタブで開く
      if node and node.type == "file" then
        vim.cmd("tabnew " .. node.absolute_path)
      -- フォルダだったら展開/閉じる
      else
        api.node.open.edit()
      end
    end, { buffer = bufnr, noremap = true, silent = true })
  end,
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

-- Color Schema
vim.cmd("colorscheme tokyonight")

-- intro message を非表示にする
vim.opt.shortmess:append "I"   

-- ファイル保存を義務化
vim.o.hidden = false

-- Swap Location
vim.opt.directory = "."

-- タブラインの表示設定
vim.opt.showtabline = 2      -- 常にタブラインを表示（1=タブが2個以上で表示）

-- タブラインのハイライト設定
vim.cmd[[
  highlight TabLine guibg=#1e1e1e guifg=#858585
  highlight TabLineSel guibg=#0087af guifg=#ffffff
  highlight TabLineFill guibg=#1e1e1e
]]
