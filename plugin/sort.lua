vim.cmd [[ command -nargs=* -range Sort :lua require('sort').sort(<f-args>) ]]
