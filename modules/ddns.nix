{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.duckdns;
  makeArg = { domain, token, ... }:
    "https://www.duckdns.org/update?domains=${domain}&token=${token}&ipv6=$IP&verbose=true"
  ;
in
{
  options = {
    services.duckdns = {
      enable = mkEnableOption "duckdns";
      package = mkOption {
        type = types.package;
        default = pkgs.curl;
        defaultText = literalExpression "pkgs.curl";
        description = ''
          curl package to use.
        '';
      };
      user = mkOption {
        type = types.str;
        default = "nobody";
        description = ''
          User account under which curl runs.
        '';
      };
      domain = mkOption {
        type = types.str;
        description = ''
          User account under which curl runs.
        '';
      };
      token = mkOption {
        type = types.str;
        description = ''
          User account under which curl runs.
        '';
      };
      group = mkOption {
        type = types.str;
        default = "users";
        description = ''
          Group account under which curl runs.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.duckdns = {
      description = "DuckDNS Service";
      after = [ "network.target" ];
      # environment = config.networking.proxy.envVars;
      path = with pkgs; [
        cfg.package
      ];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "duckdns" ''
          set -o errexit
          set -o nounset
          set +x
          set -o pipefail
          IP=$(curl -6 https://lug.hit.edu.cn/myip)
          if [ "$?" -eq "0" ];then
            echo Got IP $IP
            exec curl "${makeArg{domain=cfg.domain;token=cfg.token;}}"
          fi
        '';
        StateDirectory = "DuckDNS";
        User = cfg.user;
        Type = "oneshot";
        Group = cfg.group;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = "7";
        LimitNOFILE = "infinity";
      };
    };
    environment.systemPackages = with pkgs; [ cfg.package ];
    systemd.timers."duckdns" = {
      wantedBy = [ "timers.target" ];
      after = [ "network.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "2m";
        Unit = "duckdns.service";
      };
    };
  };
}

