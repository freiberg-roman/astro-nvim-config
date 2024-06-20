local dap = require('dap')

local function load_project_specific_dap()
  local dap_config_path = vim.fn.getcwd() .. '/.vim/dap.lua'
  if vim.fn.filereadable(dap_config_path) == 1 then
    local project_dap = dofile(dap_config_path)
    if project_dap and project_dap.dap then
      if project_dap.dap.adapters then
        for adapter_name, adapter_config in pairs(project_dap.dap.adapters) do
          dap.adapters[adapter_name] = adapter_config
        end
      end
      if project_dap.dap.configurations then
        for language, configs in pairs(project_dap.dap.configurations) do
          dap.configurations[language] = configs
        end
      end
    end
  else
    -- Fallback to default configuration if `.vim/dap.lua` does not exist
    dap.adapters.python = {
      type = "executable",
      command = "/usr/bin/python3",
      args = { "-m", "debugpy.adapter" },
    }
    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          local conda_prefix = os.getenv("CONDA_PREFIX")
          if conda_prefix then
            return conda_prefix .. "/bin/python"
          else
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
              return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
              return cwd .. "/.venv/bin/python"
            else
              return "/usr/bin/python"
            end
          end
        end,
        cwd = function()
          return vim.fn.getcwd()
        end,
      },
    }
  end
end

load_project_specific_dap()
