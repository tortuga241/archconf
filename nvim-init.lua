-- ========================================================================== --
-- 1. БАЗОВЫЕ НАСТРОЙКИ (Клавиша-модификатор)
-- ========================================================================== --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

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
  -- Список плагинов:
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8', -- используем стабильный релиз
    dependencies = { 
      'nvim-lua/plenary.nvim' -- обязательная зависимость для Telescope
    },
    config = function()
      -- Этот блок выполнится сразу после установки Telescope
      local telescope = require('telescope')
      
      telescope.setup({
        defaults = {
          -- Игнорируем тяжелые папки, чтобы поиск не лагал
          file_ignore_patterns = { "node_modules", ".git/", ".next/" },
        }
      })

      -- Настраиваем горячие клавиши (Keymaps)
      local builtin = require('telescope.builtin')
      
      -- Пробел + f + f -> Искать файлы по имени
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope Find Files' })
      -- Пробел + f + g -> Искать текст внутри файлов (работает через ripgrep!)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope Live Grep' })
      -- Пробел + f + b -> Список открытых вкладок (буферов)
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope Buffers' })
      -- Пробел + f + h -> Поиск по документации Neovim
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope Help Tags' })
    end
  }
})
