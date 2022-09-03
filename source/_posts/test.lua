function p(id, data, name)
  print(id, data, name)
end

for name, value in pairs(vim) do
  -- print(name)
  if type(value) == "table" then
    for fnname, v in pairs(value) do
      -- print(fnname)
      if fnname == "jobstart" then
        print(name, fnname)
      end
    end
    print()
  end
end

-- vim.g.jobstart("echo 0", {on_stdout = p})
