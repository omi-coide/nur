{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.qbittorrent;
in
{
  options = {
    services.qbittorrent = {
      enable = mkEnableOption "qBittorrent-nox";
      package = mkOption {
        type = types.package;
        default = pkgs.qbittorrent-nox;
        defaultText = literalExpression "pkgs.qbittorrent-nox";
        description = ''
          qBittorrent-nox package to use.
        '';
      };
      settings = mkOption rec {
        type = types.attrs;
        apply = recursiveUpdate default;
        default = {
          LegalNotice = {
            Accepted = false;
          };
        };
        example = {
          LegalNotice = {
            Accepted = true;
          };
          Preferences = {
            "Connection\\PortRangeMin" = 20082;
            "Downloads\\SavePath" = "/mnt";
            "WebUI\\UseUPnP" = false;
          };
        };
        description = ''
          Attribute set whos fields overwrites fields in qBittorrent.conf (each
          time the service starts).
        '';
      };
      port = mkOption {
        type = types.port;
        default = 9091;
        description = ''
          TCP port number to run the RPC/web interface.
        '';
      };
      user = mkOption {
        type = types.str;
        description = ''
          User account under which qBittorrent runs.
        '';
      };
      group = mkOption {
        type = types.str;
        description = ''
          Group account under which qBittorrent runs.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.qbittorrent = {
      description = "qBittorrent Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = config.networking.proxy.envVars // {
        HOME = "/var/lib/qBittorrent";
      };
      path = with pkgs; [
        crudini
        cfg.package
      ];
      serviceConfig = {
        ExecStartPre = pkgs.writeShellScript "qbittorrent-pre-start" ''
          set -o errexit
          set -o nounset
          set -o pipefail

          mkdir -p $HOME/.config/qBittorrent/config
          echo ${escapeShellArg (
            generators.toINI { } cfg.settings)
          } | crudini --merge $HOME/.config/qBittorrent/config/qBittorrent.conf
        '';
        ExecStart = pkgs.writeShellScript "qbittorrent-start" ''
          set -o errexit
          set -o nounset
          set -o pipefail

          exec qbittorrent-nox --webui-port=${toString cfg.port} --profile=$HOME/.config
        '';
        StateDirectory = "qBittorrent";
        User = cfg.user;
        Group = cfg.group;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = "7";
        LimitNOFILE = "infinity";
      };
    };
    environment.systemPackages = with pkgs; [ cfg.package ];
  };
}

