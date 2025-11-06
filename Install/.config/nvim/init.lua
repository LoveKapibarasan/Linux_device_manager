-- https://neovim.io/doc/user/index.html


-- runtimepath に lazy.nvim を追加
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

-- submodules
-- require('sub')


-- プラグイン管理
require("lazy").setup({
--
{
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
},
--
	"nvim-treesitter/nvim-treesitter-context",
--
	"nvim-treesitter/playground",
--
{
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
},
--
{ 
	"folke/tokyonight.nvim", lazy = false, priority = 1000 
}, 
{
  "yetone/avante.nvim",
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  -- ⚠️ must add this setting! ! !
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    -- this file can contain specific instructions for your project
    instructions_file = "avante.md",
    -- for example
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
      },
      moonshot = {
        endpoint = "https://api.moonshot.ai/v1",
        model = "kimi-k2-0711-preview",
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-mini/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
},


--
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
