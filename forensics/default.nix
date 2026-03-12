sudo tee /etc/nixos/forensics/default.nix > /dev/null << 'EOF'
{ config, pkgs, lib, ... }:

{
  imports = [
    ./packages.nix
    ./users.nix
  ];
  
  # Disable automatic upgrades - we control changes
  system.autoUpgrade.enable = false;
  
  # Disable automatic garbage collection
  nix.gc.automatic = false;
  
  # Create forensic directories with proper permissions
  systemd.tmpfiles.rules = [
    "d /forensics 0750 forensics forensics -"
    "d /forensics/cases 0750 forensics forensics -"
    "d /forensics/evidence 0550 forensics forensics -"
    "d /forensics/templates 0755 forensics forensics -"
    "d /forensics/iso 0755 forensics forensics -"
    "d /forensics/audit 0750 forensics forensics -"
  ];
  
  # Enable forensic kernel modules
  boot.kernelModules = [ "loop" "dm-snapshot" "nbd" ];
  
  # Security settings
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  
  # Time settings (UTC for forensics)
  time.timeZone = "UTC";
  services.timesyncd.enable = true;
  
  # Journald configuration (valid options only)
  services.journald.extraConfig = ''
    Storage=persistent
    Compress=yes
    MaxRetentionSec=1year
    ForwardToSyslog=yes
  '';
  
  # Environment variables
  environment.variables = {
    TZ = "UTC";
    FORENSICS_CASES = "/forensics/cases";
    FORENSICS_EVIDENCE = "/forensics/evidence";
  };
  
  # Shell aliases for forensics
  environment.shellAliases = {
    "f-cases" = "cd /forensics/cases";
    "f-evidence" = "cd /forensics/evidence";
    "hash-dir" = "hashdeep -r -l";
    "hash-file" = "sha256deep -l";
  };
}
EOF
