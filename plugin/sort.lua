vim.cmd(
  [[ command! -nargs=* -bang -range Sort :lua require('sort').sort("<bang>", <q-args>) ]]
)
