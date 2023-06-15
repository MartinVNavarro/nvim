local snip = require('luasnip')
local types = require('luasnip.util.types')

snip.config.set_config {
    history = false,
    updateevents = 'TextChanged,TextChangedI',
    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { '<-', 'Error' } },
            },
        },
    },
    enable_autosnippets = true,
}

local snippet = snip.s

snip.add_snippets("all", {
    snippet("big", snip.text_node "hello world"),
}, { key = "all" })


vim.keymap.set({ "i", "s" }, "<M-space>", function()
    if snip.expand_or_jumpable() then
        snip.expand_or_jumpable()
    end
end, { silent = true })

vim.keymap.set("n", "<leader><leader>r", "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<cr>", { silent = true })
