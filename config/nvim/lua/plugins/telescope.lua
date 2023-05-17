return {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',

    cmd = "Telescope",
    keys = {
        { "<C-e>", ":lua project_picker(require('telescope.themes').get_dropdown{})<CR>", desc = "smart location" },
        { "<Leader>p", ":Telescope find_files<CR>", {} },
        { "<Leader>o", ":Telescope lsp_document_symbols<CR>", {} },
        { "<Leader>P", ":Telescope live_grep<CR>", {} },
        { "<C-q>", ":Telescope oldfiles<CR>", {} },
    },

    dependencies = { 'nvim-lua/plenary.nvim' },
}
