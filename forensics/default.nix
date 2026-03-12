{ config, pkgs, lib, ... }:

{
  imports = [
    ./packages.nix
    ./users.nix
  ];
  
  system.autoUpgrade.enable = false;
  nix.gc.automatic = false;
  
  systemd.tmpfiles.rules = [
    "d /forensics 0750 forensics forensics -"
    "d /forensics/cases 0750 forensics forensics -"
    "d /forensics/evidence 0550 forensics forensics -"
    "d /forensics/templates 0755 forensics forensics -"
    "d /forensics/iso 0755 forensics forensics -"
    "d /forensics/audit 0750 forensics forensics -"
  ];
  
  boot.kernelModules = [ "loop" "dm-snapshot" "nbd" ];
  
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  
  time.timeZone = lib.mkForce "UTC";
  services.timesyncd.enable = true;
  
  services.journald.extraConfig = ''
    Storage=persistent
    Compress=yes
    MaxRetentionSec=1year
    ForwardToSyslog=yes
  '';
  
  environment.variables = {
    TZ = "UTC";
    FORENSICS_CASES = "/forensics/cases";
    FORENSICS_EVIDENCE = "/forensics/evidence";
  };
  
  environment.shellAliases = {
    "f-cases" = "cd /forensics/cases";
    "f-evidence" = "cd /forensics/evidence";
    "hash-dir" = "hashdeep -r -l";
    "hash-file" = "sha256deep -l";
  };
}
