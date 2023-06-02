vim.g.mapleader = " "

local function go_to_netrw(action)
	if action == 'save' then
		vim.cmd('w')
	elseif action == 'quit' then
		vim.cmd('e!')
    elseif action == 'force_quit' then
        vim.cmd('Ex')
	else
		print('Invalid action specified for go_to_netrw')
		return
	end

	vim.cmd('Ex')
end

vim.keymap.set("n","<leader>ms", function() go_to_netrw('save') end)
vim.keymap.set("n","<leader>mf", function() go_to_netrw('quit') end)
vim.keymap.set("n","<leader>mq", function() go_to_netrw('force_quit') end)
