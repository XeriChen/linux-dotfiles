-- Basic keymaps

-- Fix <End>/<Home> under tmux: tmux re-encodes bare End/Home as ESC[4~ / ESC[1~,
-- which libtermkey decodes as the DEC <Select>/<Find> keys. Map them back.
vim.keymap.set({ "n", "i", "v", "c", "s" }, "<Select>", "<End>", { noremap = true })
vim.keymap.set({ "n", "i", "v", "c", "s" }, "<Find>", "<Home>", { noremap = true })

-- 窗口导航：保留 Vim 默认 <C-w>h/j/k/l，不覆盖默认键位（原教旨原则）

-- Resize windows
vim.keymap.set("n", "<S-Up>", ":resize +2<CR>", { noremap = true, silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<S-Down>", ":resize -2<CR>", { noremap = true, silent = true, desc = "Decrease window height" })
vim.keymap.set(
    "n",
    "<S-Left>",
    ":vertical resize +2<CR>",
    { noremap = true, silent = true, desc = "Increase window width" }
)
vim.keymap.set(
    "n",
    "<S-Right>",
    ":vertical resize -2<CR>",
    { noremap = true, silent = true, desc = "Decrease window width" }
)

-- Better indenting
vim.keymap.set("v", "<leader><", function()
    vim.cmd("normal! " .. vim.v.count1 .. "<gv")
    vim.fn["repeat#set"]("<leader><", vim.v.count)
end, { noremap = true, silent = true, desc = "Indent left" })
vim.keymap.set("v", "<leader>>", function()
    vim.cmd("normal! " .. vim.v.count1 .. ">gv")
    vim.fn["repeat#set"]("<leader>>", vim.v.count)
end, { noremap = true, silent = true, desc = "Indent right" })

-- Move selected line/block（映射到 <A-j>/<A-k>，避免覆盖默认 J 合并行）
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })

-- Clear search highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlights" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -vim.v.count1 })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = vim.v.count1 })
end, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic error messages" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

-- LSP keymaps will be set up in lsp.lua

-- Save all files
vim.keymap.set({ "n", "v" }, "<leader>w", "<cmd>wa<CR>", { noremap = true, silent = true, desc = "Save all files" })

local function is_floating_win(winnr)
    local config = vim.api.nvim_win_get_config(winnr)
    return config.relative ~= "" or config.zindex ~= nil
end

-- Smart close with '<leader>Q'
vim.keymap.set("n", "<leader>Q", function()

    local win_list = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            vim.api.nvim_win_get_height(win) ~= -1
            and vim.api.nvim_win_get_width(win) ~= -1
            and not is_floating_win(win)
        then
            win_list[#win_list + 1] = win
        end
    end
    local win_count = #win_list
    local listed_bufs = #vim.tbl_filter(function(b)
        return vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b)
    end, vim.api.nvim_list_bufs())

    local function is_modifiable(bufnr)
        return vim.bo[bufnr].modifiable and vim.bo[bufnr].buftype == ""
    end

    local function is_modified(bufnr)
        return vim.bo[bufnr].modified and is_modifiable(bufnr)
    end

    if win_count > 1 or is_floating_win(0) then
        vim.cmd("hide")
    elseif listed_bufs > 1 then
        if is_modified(0) then
            vim.cmd("write")
        end
        vim.cmd("bnext")
        vim.cmd("bdelete #")
    else
        if is_modified(0) then
            vim.cmd("write")
        end
        vim.cmd("quit")
    end
end, { desc = "Smart close window/buffer/quit with save" })

vim.keymap.set("v", "q", "<Esc>", { noremap = true, desc = "Quit visual mode" })

-- gq 恢复为 Vim 默认「格式化操作符」；宏录制用默认 q

-- Buffer navigation
vim.keymap.set("n", "[b", function()
    for _ = 1, vim.v.count1 do
        vim.cmd.bprevious()
    end
end, { desc = "Previous buffer" })
vim.keymap.set("n", "]b", function()
    for _ = 1, vim.v.count1 do
        vim.cmd.bnext()
    end
end, { desc = "Next buffer" })
vim.keymap.set("n", "[B", function()
    local bufs = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    local idx = math.min(vim.v.count1, #bufs)
    vim.cmd.buffer(bufs[idx])
end, { desc = "First buffer" })
vim.keymap.set("n", "gb", "<cmd>buffer #<CR>", { desc = "Alternate buffer" })

vim.keymap.set("n", "]B", function()
    local bufs = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    local idx = math.max(#bufs - vim.v.count1 + 1, 1)
    vim.cmd.buffer(bufs[idx])
end, { desc = "Last buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- <f1> 恢复 Vim 默认「帮助」
