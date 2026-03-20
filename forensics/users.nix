{ config, pkgs, ... }:

{
  # === FORENSICS GROUP ===
  users.groups.forensics = {};

  # === FORENSICS SYSTEM USER (NO LOGIN) ===
  users.users.forensics = {
    isSystemUser = true;
    isNormalUser = false;

    description = "Forensics Service User";

    # REQUIRED: assign group
    group = "forensics";

    shell = "/run/current-system/sw/bin/nologin";

    home = "/var/lib/forensics";
    createHome = true;

    packages = with pkgs; [
      pandoc
      texlive.combined.scheme-small
      python3
      python3Packages.pandas
      git
    ];
  };

  # === SUDO RULES ===
  security.sudo.extraRules = [
    {
      users = [ "forensics" ];
      commands = [
        { command = "${pkgs.sleuthkit}/bin/tsk_recover"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.ddrescue}/bin/ddrescue"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # === WIRESHARK ===
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.venom.extraGroups = [ "wireshark" ];

  # === DIRECTORY STRUCTURE ===
  systemd.tmpfiles.rules = [
    "d /forensics 0750 root root -"
    "d /forensics/cases 0750 root root -"
    "d /forensics/evidence 0550 root root -"
    "d /forensics/templates 0755 root root -"
    "d /forensics/iso 0755 root root -"
    "d /forensics/audit 0750 root root -"
  ];

  # === USB (READ-ONLY) ===
  services.udev.extraRules = ''
    SUBSYSTEM=="block", ATTR{removable}=="1", ATTR{readonly}="1"
  '';
}
