{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.filebrowser;
in {
  options.services.filebrowser =
    {
      enable = mkEnableOption "filebrowser";
      package = mkOption {
        type = types.package;
        default = pkgs.filebrowser;
        defaultText = literalExpression "pkgs.filebrowser";
        description = ''
          filebrowser package to use. https://filebrowser.org
        '';
      };
      user = mkOption {
        type = types.str;
        default = "nobody";
        description = ''
          User account under which filebrowser runs.
        '';
      };
      path = mkOption {
        type = types.str;
        default = "/srv/filebrowser/"
          description = ''
        Path which filebrowser shares.
      '';
      };
    }
      config = mkIf cfg.enable {
  systemd.services.filebrowser = {
  description = "FileBrowser Service";
  after = [ "network.target" ];
  # environment = config.networking.proxy.envVars;
  path = with pkgs; [
    cfg.package
  ];
  serviceConfig = {
    ExecStart = pkgs.writeShellScript "filebrowser" ''
      set -o errexit
      set -o nounset
      set +x
      set -o pipefail
      ${getExe cfg.package} -r ${cfg.path}
    '';
    StateDirectory = "FileBrowser";
    User = cfg.user;
    Type = "normal";
    IOSchedulingClass = "idle";
    IOSchedulingPriority = "7";
    LimitNOFILE = "infinity";
  };
};
environment.systemPackages = with pkgs; [ cfg.package ];
};

}
