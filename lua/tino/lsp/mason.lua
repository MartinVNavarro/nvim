local servers = {
--    'jdtls',
    'gopls',
    'lua_ls',
}

local settings = {
    ui = {
        border = "none",
        icons = {
            package_installed = "◍",
            package_pending = "◍",
            package_uninstalled = "◍",
        },
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_installation = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
    return
end

local opts = {}

for _, server in pairs(servers) do
    opts = {
        on_attach = require("tino.lsp.handlers").on_attach,
        capabilities = require("tino.lsp.handlers").capabilities,
    }

    server = vim.split(server, "@")[1]

    local status_ok, conf_opts = pcall(require, "tino.lsp.settings." .. server)
    if status_ok then
        opts = vim.tbl_extend("force", opts, conf_opts)
    end

    if server == "jdtls" then
        local df_ok, df = pcall(require, "tino.lsp.settings.jdtls")

        if not df_ok then
           vim.g.testtino = "error"
       else
           vim.g.testtino = df 
        end
        --vim.tbl_extend("force", opts, df)
    end

    lspconfig[server].setup(opts)
end
