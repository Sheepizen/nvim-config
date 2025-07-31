vim.g.mapleader = " "
-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  -- File explorer and icons
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },

  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Status line
  { "nvim-lualine/lualine.nvim" },

  -- Indentation Guide
{
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    scope = {
      show_start = true,
      show_end = true,
    },
    indent = {
      char = "│", -- you can use "▏", "¦", "┊", "│"
    },
  },
},
  -- Autocomplete
  { "hrsh7th/nvim-cmp", dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    "saadparwaiz1/cmp_luasnip",
  }},
  { "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },

-- LSP & tools
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

 -- Formatter/linter bridge
  { "nvimtools/none-ls.nvim" },
  { "jay-babu/mason-null-ls.nvim" },

 -- Auto-close brackets, quotes, and tags
{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },
{ 
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-ts-autotag").setup()
  end,
},

 -- fzf through projects
{
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  opts = {}
},

-- themes
{
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
    -- config = function()
    --     vim.g.zenbones_darken_comments = 45
    --     vim.cmd.colorscheme('zenbones')
    -- end
},

{
  "rmehri01/onenord.nvim", -- similar to misterioso/modus-vivendi
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("onenord")
  end,
},

{
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme gruvbox")
  end,
},

})

vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- You can use "●", ">>", "→", or leave it empty
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- General settings
vim.o.number = true
vim.o.relativenumber = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.termguicolors = true
vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.completeopt = "menuone,noselect"

-- Treesitter config
require("nvim-treesitter.configs").setup {
  ensure_installed = { "html", "css", "javascript", "typescript" },
  highlight = { enable = true },
}


-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "html", "cssls" },
  handlers = {
    function(server)
      require("lspconfig")[server].setup {}
    end,
  },
})

-- none-ls (formatting, linting)
local null_ls = require("null-ls")
require("mason-null-ls").setup({
  ensure_installed = { "prettier", "eslint_d" },
  automatic_setup = true,
})
null_ls.setup()

-- Autocomplete config
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- UI plugin setup
require("lualine").setup()
require("nvim-tree").setup(
  {view= {
    width=30,
  }
}
)
require("telescope").setup()

-- autosave
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.css", "*.html", "*.json", "*.md" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- keymap
 -- save
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })

--hide highlighting
vim.keymap.set('n', '<Esc><Esc>', ':nohl<CR>')
 --fzf files and grep
vim.keymap.set('n', '<leader>ff', function() require('fzf-lua').files() end)
vim.keymap.set('n', '<leader>fg', function() require('fzf-lua').live_grep() end)
vim.keymap.set('n', '<leader>fb', function() require('fzf-lua').buffers() end)
vim.keymap.set('n', '<leader>fp', function() require('fzf-lua').files({cwd="~/Projects/"}) end)
 --cycle through buffers
vim.keymap.set('n', '<A-l>',':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-h>',':bprevious<CR>', { noremap = true, silent = true })
--create new tab
vim.keymap.set('n', '<leader>t',':tabnew<CR>', { noremap = true, silent = true })
-- cycle through tabs
vim.keymap.set('n', '<leader>l',':tabnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>h',':tabprevious<CR>', { noremap = true, silent = true })
--close nvim and save all
vim.keymap.set('n', '<Leader>wq',':wqa<CR>', { noremap = true, silent = true })
--nvim tree

--colorscheme
 vim.cmd("colorscheme onenord")


