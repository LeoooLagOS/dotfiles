return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				bashls = {}, -- bash: Mason installs and starts it
				qmlls = { mason = false }, -- QML: already on the system (dnf)
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = { "shellcheck" }, -- a tool that isn't a server
		},
	},
}
