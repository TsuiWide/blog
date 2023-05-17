vim.g.mapleader = " "
vim.g.maplocalleader = " "

local set = vim.o

set.number = true
set.relativenumber = true
set.clipboard = "unnamed"

require("autocmd")
require("keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    im.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
})

--vim.cmd.colorscheme("base16-tender")
--vim.cmd.colorscheme("tokyonight")
vim.cmd.colorscheme("gruvbox")
