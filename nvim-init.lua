-- ========================================================================== --
-- 1. БАЗОВЫЕ НАСТРОЙКИ
-- ========================================================================== --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

-- Внимание: Автоматическое форматирование убрано отсюда, 
-- так как теперь за него отвечает плагин conform.nvim (см. ниже).

-- ========================================================================== --
-- 2. АВТОМАТИЧЕСКАЯ УСТАНОВКА МЕНЕДЖЕРА ПЛАГИНОВ (lazy.nvim)
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
  -- [ПЛАГИН 1] ТЕЛЕСКОП (Поиск файлов и текста)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", ".next/" },
          vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case', '--hidden'
          },
        }
      })

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope Find Files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope Live Grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope Buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope Help Tags' })
    end
  },

  -- [ПЛАГИН 2] LSP CONFIG (Связь с серверами) + ИНТЕГРАЦИЯ BLINK
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' }, -- Зависимость от blink для capabilities
    config = function()
      -- Передаем возможности автодополнения (capabilities) от blink.cmp в LSP
      local blink_capabilities = require('blink.cmp').get_lsp_capabilities()
      
      -- В Neovim 0.11+ используем vim.lsp.config для инъекции capabilities
      -- Если в будущем перейдете на 'ts_ls', просто поменяйте 'vtsls' здесь
      vim.lsp.config('vtsls', { capabilities = blink_capabilities })
      vim.lsp.config('biome', { capabilities = blink_capabilities })

      -- Включаем серверы
      vim.lsp.enable('vtsls')
      vim.lsp.enable('biome')

      -- Горячие клавиши для работы с кодом (LSP)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP Go to Definition' })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP Hover Docs' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })
      vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'LSP Rename' })
    end
  },

  -- [ПЛАГИН 3] OIL.NVIM (Файловый менеджер в виде текстового буфера)
  {
    'stevearc/oil.nvim',
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = { "icons" },
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name, bufnr) return name == ".." or name == "." end,
        },
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })
    end
  },

  -- [ПЛАГИН 4] LAZYGIT.NVIM
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Toggle LazyGit" },
    },
  },

  -- ========================================================================
  -- НОВЫЕ ПЛАГИНЫ
  -- ========================================================================

  -- [ПЛАГИН 5] BLINK.CMP (Молниеносное автодополнение)
  {
    'saghen/blink.cmp',
    version = '*', -- Использовать скомпилированные бинарники
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      appearance = { 
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      signature = { enabled = true },
      sources = { 
        default = { 'lsp', 'path', 'snippets', 'buffer' } 
      },
    }
  },

  -- [ПЛАГИН 6] CONFORM.NVIM (Форматирование при сохранении)
  {
    'stevearc/conform.nvim',
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },

-- [ПЛАГИН 7] TREESITTER & AUTOTAG (Умный парсинг и автозакрытие тегов)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', 
    opts = {
      ensure_installed = { "lua", "typescript", "javascript", "tsx", "html", "css", "json" },
      highlight = { 
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    opts = {},
    -- Убрали зависимость, чтобы не создавать циклических ожиданий
  },

  -- [ПЛАГИН 8] LUALINE (Строка состояния внизу)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { theme = 'auto', globalstatus = true },
    }
  },

  -- [ПЛАГИН 9] NOICE & NUI (Красивый UI для командной строки и сообщений)
  { 
    'folke/noice.nvim', 
    event = "VeryLazy",
    dependencies = { 'MunifTanjim/nui.nvim' },
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
    }
  },

  -- [ПЛАГИН 10] TROUBLE (Панель для просмотра ошибок кода)
  {
    'folke/trouble.nvim',
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    },
    opts = {}
  },

  -- [ПЛАГИН 11] WHICH-KEY (Подсказки горячих клавиш)
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    opts = {}
  },

  -- [ПЛАГИН 12] SNACKS (Набор полезных компонентов: экран приветствия, уведомления и др.)
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { enabled = true },
      notifier = { enabled = true },
    }
  }
})
