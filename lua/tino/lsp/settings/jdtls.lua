local M = {}

local home = os.getenv('HOME')
local CONFIG = 'linux'

local WORKSPACE_PATH = home .. '/workspace/'

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = WORKSPACE_PATH .. project_name

local function on_init(client)
    if client.config.settings then
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
end

local bundles = {}
local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(mason_path ..
        "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
)

local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local enable_custom_config = false

M.default_cmd = function()
    return
        {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",

            "-jar",
            vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
            "-configuration",
            home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. CONFIG,

            "-data",
            workspace_dir,
        };
    end


M.get_config = function()
    if not enable_custom_config then
        return {
            cmd = M.default_cmd(),
        }
    end

    return {
        cmd = M.default_cmd(),
        flags = {
            debounce_text_changes = 150,
            allow_incremental_sync = true,
        },
        handlers = {},
        root_dir = function() 
            require("jdtls.setup").find_root({ 'gradle.build', 'pom.xml', '.git' })
        end,
        capabilities = M.capabilities,
        contentProvider = { preferred = 'fernflower' },
        on_init = on_init,
        on_attach = require("tino.lsp.handlers").on_attach,
        init_options = {
            bundles = bundles,
            extendedClientCapabilities = extendedClientCapabilities,
        },
        settings = {
            java = {
                signatureHelp = { enabled = true },
                configuration = {
                    updateBuildConfiguration = "interactive",
                },

                eclipse = {
                    downloadSources = true,
                },
                maven = {
                    downloadSources = true,
                },
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
                references = {
                    includeDecompiledSources = true,
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all", -- literals, all, none
                    },
                },
                completion = {
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*"
                    }
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    },
                },
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                    },
                    useBlocks = true,
                },
            }
        }
    }
end

return M.get_config()
