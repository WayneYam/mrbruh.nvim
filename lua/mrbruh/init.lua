local setup = function()
	local compile_arg = {
		cpp = "g++ -g -Dzisk -Wall -Wextra -Wshadow -Wno-sign-conversion -std=c++17 -O2 -fsanitize=address,undefined $file -o $dir/_$fileNameWithoutExt",
		cpp_debug = "g++ -g -Dzisk -DDAP_DEBUG -Wall -Wextra -Wshadow -Wno-sign-conversion -std=c++17 -O0 -fsanitize=address,undefined $file -o $dir/_$fileNameWithoutExt_debug",
		c = "gcc $file -o $dir/_$fileNameWithoutExt",
		haskell = "ghc -O2 -Wall $dir/$file -o $dir/_$fileNameWithoutExt",
		-- cpp = "g++ D_GLIBCXX_DEBUG -D_GLIBCXX_ASSERTIONS -g -Dzisk -Wall -Wextra -Wshadow -Wno-sign-conversion -std=c++17 -O2 -fsanitize=address,undefined $file -o $dir/_$fileNameWithoutExt"
		ocaml = "dune build ./$relFileNameWithoutExt.exe",
	}

	local run_arg = {
		cpp = "$dir/_$fileNameWithoutExt",
		c = "$dir/_$fileNameWithoutExt",
		r = "Rscript $file",
		python = "python $file",
		haskell = "$dir/_$fileNameWithoutExt",
		sh = "bash $file",
		ocaml = "dune exec --no-build ./$relFileNameWithoutExt.exe",
		ocaml_submit = "dune build ./$relFileNameWithoutExt_submit.exe &| wl-copy",
	}

	local function replaceVars(command, path, user_argument)
		if type(command) == "function" then
			local cmd = command(user_argument)
			if type(cmd) == "string" then
				command = cmd
			else
				return
			end
		end

		local no_sub_command = command

		command = command:gsub("$fileNameWithoutExt", vim.fn.fnamemodify(path, ":t:r"))
		command = command:gsub("$fileName", vim.fn.fnamemodify(path, ":t"))
		command = command:gsub("$relFileNameWithoutExt", vim.fn.fnamemodify(path, ":.:r"))
		command = command:gsub("$relFileName", vim.fn.fnamemodify(path, ":."))
		command = command:gsub("$relDir", vim.fn.fnamemodify(path, ":.:h"))
		command = command:gsub("$file", path)
		command = command:gsub("$dir", vim.fn.fnamemodify(path, ":p:h"))
		command = command:gsub("$end", "")

		if command == no_sub_command then
			command = command .. " " .. path
		end

		return command
	end

	local function getCompileCommand(filetype, path, user_argument)
		path = path or vim.fn.expand("%:p")
		local command = compile_arg[filetype]
		if command then
			local command_vim = replaceVars(command, path, user_argument)
			return command_vim
		end
	end

	local function getRunCommand(filetype, path, user_argument)
		path = path or vim.fn.expand("%:p")
		local command = run_arg[filetype]
		if command then
			local command_vim = replaceVars(command, path, user_argument)
			return command_vim
		end
	end

	local function getDefaultPath()
		local info = vim.cmd('let history = execute("ls t")')
		info = vim.api.nvim_eval("history")
		for w in string.gmatch(info, '"([^%s]+)"') do
			return w
		end
	end

	local terminal = require("toggleterm.terminal")

	TermExist = {
		compile = true,
		run = true,
	}

	local getCompileTerminal = function()
		return terminal.Terminal:new({
			display_name = "Compile",
			direction = "float",
			close_on_exit = true,
			on_open = function()
				vim.cmd("startinsert!")
			end,
			on_exit = function()
				TermExist.compile = false
			end,
		})
	end

	local getRunTerminal = function()
		return terminal.Terminal:new({
			display_name = "Run",
			direction = "vertical",
			close_on_exit = true,
			on_open = function()
				vim.cmd("startinsert!")
			end,
			on_exit = function()
				TermExist.run = false
			end,
		})
	end

	local compileTerminal = getCompileTerminal()
	local runTerminal = getRunTerminal()

	function CompileFile(path, filetype)
		vim.cmd("wa")
		path = path or getDefaultPath()
		filetype = filetype or vim.filetype.match({ filename = path })
		local cmd = getCompileCommand(filetype, path, "")
		if not TermExist.compile then
			compileTerminal = getCompileTerminal()
			compileTerminal:open()
			TermExist.compile = true
		end

		if not compileTerminal:is_open() then
			compileTerminal:open()
		end
		compileTerminal:send("clear", false)

		if cmd then
			compileTerminal:send(cmd, false)
		end
	end

	function RunFile(path, filetype)
		path = path or getDefaultPath()
		filetype = filetype or vim.filetype.match({ filename = path })
		local cmd = getRunCommand(filetype, path, "")

		if TermExist.compile and compileTerminal:is_open() then
			compileTerminal:close()
		end

		if not TermExist.run then
			runTerminal = getRunTerminal()
			runTerminal:open()
			TermExist.run = true
		end

		if not runTerminal:is_open() then
			runTerminal:open()
		end
		runTerminal:focus()

		if cmd then
			runTerminal:send(cmd, false)
		end
		local owo = function()
			vim.cmd("startinsert!")
		end
		vim.defer_fn(owo, 50)
	end

	function ToggleCompile()
		if not TermExist.compile then
			compileTerminal = getCompileTerminal()
			compileTerminal:open()
			TermExist.compile = true
		else
			compileTerminal:toggle()
		end
	end

	function ToggleRun()
		if not TermExist.run then
			runTerminal = getRunTerminal()
			runTerminal:open()
			TermExist.run = true
		else
			runTerminal:toggle()
		end
	end

	vim.keymap.set({ "n", "i", "t" }, "<F9>", "<cmd>lua CompileFile()<CR>")
	vim.keymap.set({ "n", "i", "t" }, "<F8>", "<cmd>lua RunFile()<CR>")
	vim.keymap.set({ "n", "i", "t" }, "<C-F9>", "<cmd>lua ToggleCompile()<CR>")
	vim.keymap.set({ "n", "i", "t" }, "<C-F8>", "<cmd>lua ToggleRun()<CR>")
end

return {
	setup = setup,
}
