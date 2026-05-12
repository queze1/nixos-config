{ config, ... }:
{
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    secrets = {
      tavily-api-key = {
        file = ../../secrets/tavily-api-key.age;
      };
    };
  };
}
