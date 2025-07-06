local M = {}

M.fs_root = vim.fn.fnamemodify("./.tests/fs", ":p")

function M.path(path)
  return vim.fs.normalize(M.fs_root .. "/" .. path)
end

---@param files string[]
function M.fs_create(files)
  ---@type string[]
  local ret = {}

  for _, file in ipairs(files) do
    ret[#ret + 1] = vim.fs.normalize(M.fs_root .. "/" .. file)
    local parent = vim.fn.fnamemodify(ret[#ret], ":h:p")
    vim.fn.mkdir(parent, "p")
    
    -- Write empty file.
    local f = io.open(ret[#ret], "w")
    if f then
      f:close()
    end
  end
  return ret
end

function M.fs_rm(dir)
  dir = vim.fs.normalize(M.fs_root .. "/" .. dir)
  vim.fn.delete(dir, "rf")
end

return M