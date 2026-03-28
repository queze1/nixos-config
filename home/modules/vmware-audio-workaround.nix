{ ... }:
{
  # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Troubleshooting#stuttering-audio-in-virtual-machine
  xdg.configFile."wireplumber/wireplumber.conf.d/50-alsa-config.conf".text = ''
    monitor.alsa.rules = [
      {
        matches =[
          # This matches the value of the 'node.name' property of the node.
          {
            node.name = "~alsa_output.*"
          }
        ]
        actions = {
          # Apply all the desired node specific settings here.
          update-props = {
            api.alsa.period-size   = 1024
            api.alsa.headroom      = 8192
            session.suspend-timeout-seconds = 86400  # disable suspend
            api.alsa.start-delay   = 1024
          }
        }
      }
    ]
  '';
}
