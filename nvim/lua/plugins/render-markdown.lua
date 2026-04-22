return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- In LazyVim, nvim-treesitter is usually already installed.
		-- We use mini.icons as it is the modern standard for LazyVim setups.
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		ft = { "markdown", "Avante" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			heading = {
				-- Customizing icons to ensure they look sharp in your terminal
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
			},
			code = {
				-- Renders code blocks as distinct visual blocks
				width = "block",
				right_pad = 1,
			},
		},
	},
}
