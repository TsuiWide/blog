return {
    cmd = "Telescope",
    keys = {
        { "<C-e>", ":lua project_picker(require('telescope.themes').get_dropdown{})<CR>", desc = "smart location" },
        { "<Leader>p", ":Telescope find_files<CR>", {} },
        { "<Leader>o", ":Telescope lsp_document_symbols<CR>", {} },
        { "<Leader>P", ":Telescope live_grep<CR>", {} },
        { "<C-q>", ":Telescope oldfiles<CR>", {} },
    },
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
}
