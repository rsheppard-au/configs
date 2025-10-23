-- ######################
-- ## GENERAL SETTINGS ##
-- ######################

-- Set leader key
vim.g.mapleader = " "

-- Line numbers and scrolling
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

-- Tabs and indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Appearance
vim.cmd.colorscheme("habamax")
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",         -- Show tabs as arrows
  trail = "·",        -- Show trailing spaces as dots
  nbsp = "␣",         -- Show non-breaking spaces
  extends = "»",      -- Show when line is too long
  precedes = "«",     -- Show when line starts off-screen
}

-- Auto-complete
vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Split window behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Enable mouse support in all modes
vim.opt.mouse = "a"

-- Diagnostic display settings
vim.diagnostic.config({
  update_in_insert = false
})


-- ##############
-- ## KEYBINDS ##
-- ##############

-- Keybind helper: sets `noremap` and `silent` by default
function Keybind(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Window navigation
Keybind("n", "<C-h>", "<C-w>h")
Keybind("n", "<C-j>", "<C-w>j")
Keybind("n", "<C-k>", "<C-w>k")
Keybind("n", "<C-l>", "<C-w>l")
Keybind("t", "<C-h>", "<cmd>wincmd h<CR>")
Keybind("t", "<C-j>", "<cmd>wincmd j<CR>")
Keybind("t", "<C-k>", "<cmd>wincmd k<CR>")
Keybind("t", "<C-l>", "<cmd>wincmd l<CR>")
-- Window resizing
Keybind("n", "<C-Up>", ":resize -2<CR>")
Keybind("n", "<C-Down>", ":resize +2<CR>")
Keybind("n", "<C-Left>", ":vertical resize -2<CR>")
Keybind("n", "<C-Right>", ":vertical resize +2<CR>")
Keybind("t", "<C-Up>", "<cmd>resize -2<CR>")
Keybind("t", "<C-Down>", "<cmd>resize +2<CR>")
Keybind("t", "<C-Left>", "<cmd>vertical resize -2<CR>")
Keybind("t", "<C-Right>", "<cmd>vertical resize +2<CR>")
-- Shifting code up/down in visual mode
Keybind("v", "J", ":m '>+1<CR>gv=gv")
Keybind("v", "K", ":m '<-2<CR>gv=gv")
-- Saving, quitting
Keybind("n", "<leader>w", ":w<CR>")
Keybind("n", "<leader>q", ":q<CR>")
Keybind("n", "<leader>x", ":x<CR>")
-- Convenience keybinds
Keybind("n", "<leader>ch", ":nohlsearch<CR>")                     -- (C)lear (H)ighlights
Keybind("n", "<leader>v", ":vsplit<CR>")                          -- (V)ertically split the window
Keybind("n", "<leader>h", ":split<CR>")                           -- (H)orizontally split the window
Keybind("n", "<leader>e", ":Explore<CR>")                         -- (E)xplore - show file browser
Keybind("n", "<leader>rr", ":!cargo run<CR>")                     -- (R)un (R)ust
Keybind("i", "<C-Space>", "<C-x><C-o>")                           -- Show auto-complete (insert mode)

-- LSP key mappings (set when language server attaches)
local on_attach = function(client, bufnr)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  local opts = { buffer=bufnr }
  Keybind("n", "K", vim.lsp.buf.hover, opts)                      -- Show hover documentation
  Keybind("n", "gd", vim.lsp.buf.definition, opts)                -- Go to definition
  Keybind("n", "gr", vim.lsp.buf.references, opts)                -- List references
  Keybind("n", "<leader>rn", vim.lsp.buf.rename, opts)            -- Rename symbol
  Keybind("n", "<leader>ca", vim.lsp.buf.code_action, opts)       -- Code actions
  Keybind("n", "<leader>d", vim.diagnostic.open_float, opts)      -- Show diagnostics in floating window
  Keybind("n", "[d", vim.diagnostic.goto_prev, opts)              -- Go to previous diagnostic
  Keybind("n", "]d", vim.diagnostic.goto_next, opts)              -- Go to next diagnostic
end


-- ################
-- ## AUTOMATION ##
-- ################

-- Format on save autocmd using LSP formatting if available
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
    for _, client in ipairs(clients) do
      if client.supports_method("textDocument/formatting") then
        vim.lsp.buf.format({ async = false })
        break
      end
    end
  end,
})


-- ######################
-- ## LANGUAGE SUPPORT ##
-- ######################

-- Rust LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.lsp.start({
      name = "rust-analyzer",
      cmd = { "rust-analyzer" },
      root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true })[1]),
      on_attach = on_attach,
    })
  end,
})

-- Typescript LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript,typescriptreact",
  callback = function()
    vim.lsp.start({
      name = "tsserver",
      cmd = { "typescript-language-server", "--stdio" },
      root_dir = vim.fs.dirname(vim.fs.find({ "tsconfig.json", "package.json" }, { upward = true })[1]),
      on_attach = on_attach,
    })
  end,
})
