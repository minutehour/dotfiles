-- options
vim.o.number = true
vim.o.relativenumber = true
vim.o.list = true
vim.o.wrap = false
vim.o.scrolloff = 9
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.nrformats = "unsigned,alpha,hex,bin"
vim.o.completeopt = "menuone,popup,fuzzy,noselect"
vim.o.pummaxwidth = 40
vim.o.pumheight = 20

-- keymaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", ":lua MiniFiles.open()<CR>")
vim.keymap.set("n", "<leader>f", ":Pick files<CR>")
vim.keymap.set("n", "<leader>h", ":Pick help<CR>")
vim.keymap.set("n", "<leader>d", ":lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "<leader>n", ":lua vim.diagnostic.jump({ count =  1 })<CR>")
vim.keymap.set("n", "<leader>p", ":lua vim.diagnostic.jump({ count = -1 })<CR>")

-- plugins
vim.pack.add({
	{ src = "https://git.mhsn.net/lain.vim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/creativenull/efmls-configs-nvim" },
})

-- theme
vim.cmd.colorscheme("lain")

-- plugin setup
require("mason").setup()
require("mini.align").setup()
require("mini.files").setup({ windows = { preview = true, width_preview = 80 } })
require("mini.icons").setup({ style = "ascii" })
require("mini.pick").setup()
require("mini.surround").setup()
require("mini.completion").setup({ window = { info = { height = 80, width = 80 } } })
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "python", "rust", "typst" },
	sync_install = false,
	auto_install = true,
	ignore_install = {},
	modules = {},
	highlight = { enable = true },
})

-- LSPs
vim.lsp.enable({ "clangd", "lua_ls", "rust_analyzer", "ty", "tinymist", "zls" })

-- LSP configs
vim.lsp.config("lua_ls", { settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } } })

-- efmls formatting
local efm_languages = {
	c = { require("efmls-configs.formatters.clang_format"), require("efmls-configs.linters.clang_format") },
	lua = { require("efmls-configs.formatters.stylua") },
	markdown = { require("efmls-configs.formatters.mdformat") },
	nix = { require("efmls-configs.formatters.nixfmt") },
	python = { require("efmls-configs.formatters.ruff"), require("efmls-configs.linters.ruff") },
	rust = { require("efmls-configs.formatters.rustfmt") },
	sh = { require("efmls-configs.formatters.shfmt"), require("efmls-configs.linters.shellcheck") },
	typst = { require("efmls-configs.formatters.typstyle") },
}

require("lspconfig").efm.setup({
	filetypes = vim.tbl_keys(efm_languages),
	settings = {
		rootMarkers = { ".git/" },
		languages = efm_languages,
	},
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
	},
})

-- format on save
local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = lsp_fmt_group,
	callback = function(ev)
		local efm = vim.lsp.get_clients({ name = "efm", bufnr = ev.buf })
		if vim.tbl_isempty(efm) then
			return
		end
		vim.lsp.buf.format({ name = "efm" })
	end,
})
