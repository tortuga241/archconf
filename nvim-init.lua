-- ========================================================================== --
-- 1. БАЗОВЫЕ НАСТРОЙКИ
-- ========================================================================== --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.termguicolors = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

-- ========================================================================== --
-- 2. АВТОМАТИЧЕСКАЯ УСТАНОВКА МЕНЕДЖЕРА ПЛАГИНОВ (lazy.nvim)
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 3. УСТАНОВКА И НАСТРОЙКА ПЛАГИНОВ
-- ========================================================================== --
require("lazy").setup({

  -- ── ТЕМА ─────────────────────────────────────────────────────────────────
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({ transparent_mode = true })
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- ── СТРОКА СОСТОЯНИЯ ─────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "gruvbox", globalstatus = true },
    },
  },

  -- ── UI ───────────────────────────────────────────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  -- ── ПОИСК ────────────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", ".next/" },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
          },
        },
      })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files,  { desc = "Telescope Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,   { desc = "Telescope Live Grep" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep,   { desc = "Telescope Live Grep (alt)" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "Telescope Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags,   { desc = "Telescope Help Tags" })
    end,
  },

  -- ── ФАЙЛОВЫЙ МЕНЕДЖЕР ────────────────────────────────────────────────────
  {
    "stevearc/oil.nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = { "icon" },
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name) return name == ".." or name == "." end,
        },
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })
    end,
  },

  -- ── ПОДСКАЗКИ КЛАВИШ ─────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ── РАЗНОЕ ───────────────────────────────────────────────────────────────
  { "ThePrimeagen/vim-be-good" },
  {
    "amitds1997/remote-nvim.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },

  -- ── GIT ──────────────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({ current_line_blame = true })
      vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next Git Hunk" })
      vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Prev Git Hunk" })
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- ── TREESITTER ───────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = { "lua", "vim", "vimdoc", "query", "javascript", "typescript" },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- ── ФОРМАТИРОВАНИЕ ───────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format file",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript      = { "biome" },
        typescript      = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json            = { "biome" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },

  -- ── АВТОДОПОЛНЕНИЕ ───────────────────────────────────────────────────────
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"]   = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"]    = { "accept", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          path = {
            enabled = function()
              local line = vim.api.nvim_get_current_line()
              return not string.match(line, "@/")
            end,
          },
        },
      },
    },
  },

  -- ── LSP ──────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = { 
      "saghen/blink.cmp",
      -- 1. Добавляем сам Mason
      "williamboman/mason.nvim",
      -- 2. Добавляем мост между Mason и встроенным LSP
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Вначале иницируем Mason
      require("mason").setup()
      require("mason-lspconfig").setup({
          -- Список серверов, которые Mason установит автоматически
          ensure_installed = { "vtsls", "biome" } 
      })
  
      local capabilities = require("blink.cmp").get_lsp_capabilities()
  
      -- Настройка сервисов установленных через Mason
      require("mason-lspconfig").setup_handlers({
          function(server_name)
              -- Neovim 0.11+ нативный синтаксис
              vim.lsp.config(server_name, {
                  capabilities = capabilities
              })
              vim.lsp.enable(server_name)
          end,
      })
  
      -- Кастомные горячие клавиши (keymaps)
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open Diagnostics" })
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.util or vim.lsp.buf.code_action, { desc = "Code Action" })
    end,
  }

  -- ── ДИАГНОСТИКА ──────────────────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    },
    opts = {},
  },
})
