{
  config,
  lib,
  self,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({
        lib,
        pkgs,
        ...
      }: let
        actions-languageserver = self.packages.${pkgs.stdenv.hostPlatform.system}.actions-languageserver;
      in {
        programs.nvf.settings.vim.lsp.servers.actionsls = {
          # From https://github.com/actions/languageservices/tree/main/languageserver
          cmd = [
            (lib.getExe actions-languageserver)
            "--stdio"
          ];
          filetypes = ["yaml"];
          root_dir = lib.mkLuaInline ''
            function(bufnr, on_dir)
              local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
              if
                vim.endswith(parent, '/.github/workflows')
                or vim.endswith(parent, '/.forgejo/workflows')
                or vim.endswith(parent, '/.gitea/workflows')
              then
                on_dir(parent)
              end
            end
          '';
          init_options = lib.mkLuaInline ''
            (function()
              local function command_output(command)
                local handle = io.popen(command)
                if not handle then
                  return nil
                end

                local output = handle:read('*a'):gsub('%s+$', "")
                handle:close()
                return output ~= "" and output or nil
              end

              local function get_repo_info(owner, repo)
                local repository = string.format('%q', owner .. '/' .. repo)
                local result = command_output(
                  '${lib.getExe pkgs.github-cli} repo view '
                    .. repository
                    .. " --json id,owner --template '{{.id}}\\t{{.owner.type}}' 2>/dev/null"
                )
                if not result then
                  return nil
                end

                local id, owner_type = result:match('^(%d+)\\t(.+)$')
                if id then
                  return {
                    id = tonumber(id),
                    organizationOwned = owner_type == 'Organization',
                  }
                end
                return nil
              end

              local git_root = command_output('${lib.getExe pkgs.git} rev-parse --show-toplevel 2>/dev/null')
              if not git_root then
                return {
                  sessionToken = command_output('${lib.getExe pkgs.github-cli} auth token 2>/dev/null'),
                }
              end

              local remote_url = command_output('${lib.getExe pkgs.git} remote get-url origin 2>/dev/null')
              local owner, repo
              if remote_url then
                owner, repo = remote_url:match('^git@github%.com:([^/]+)/(.+)$')
                if not owner then
                  owner, repo = remote_url:match('^https://github%.com/([^/]+)/(.+)$')
                end
                if repo then
                  repo = repo:gsub('%.git$', "")
                end
              end

              local info = owner and repo and get_repo_info(owner, repo) or nil
              return {
                sessionToken = command_output('${lib.getExe pkgs.github-cli} auth token 2>/dev/null'),
                repos = owner and repo and {
                  {
                    id = info and info.id or 0,
                    owner = owner,
                    name = repo,
                    organizationOwned = info and info.organizationOwned or false,
                    workspaceUri = 'file://' .. git_root,
                  },
                } or nil,
              }
            end)()
          '';
          capabilities = {
            workspace = {
              didChangeWorkspaceFolders = {
                dynamicRegistration = true;
              };
            };
          };
          handlers."actions/readFile" = lib.mkLuaInline ''
            function(_, result)
              if type(result.path) ~= 'string' then
                return nil, nil
              end

              local file_path = vim.uri_to_fname(result.path)
              if vim.fn.filereadable(file_path) == 1 then
                local file = assert(io.open(file_path, 'r'))
                local text = file:read('*a')
                file:close()
                return text, nil
              end
              return nil, nil
            end
          '';
        };
      })
    ];
  };
}
