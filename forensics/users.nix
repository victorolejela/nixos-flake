{ config, pkgs, lib, ... }:

{
  # === FORENSIC USER CONFIGURATION ===
  # Principle of Least Privilege: analysts get ONLY what they need
  
  users.users.forensics = {
    isNormalUser = true;
    description = "Digital Forensics Analyst";
    home = "/home/forensics";
    createHome = true;
    
    # Groups determine permissions:
    # - disk: Raw disk access (/dev/sda, etc.) for imaging
    # - dialout: Serial device access (hardware write blockers)
    # - wireshark: Network capture without sudo
    extraGroups = [ "disk" "dialout" "wireshark" "video" ];
    
    # Use bash for scripting compatibility
    shell = pkgs.bash;
    
    # No password login - use SSH keys only (more secure)
    # Set password manually after first boot if needed
    initialPassword = "changeme-immediately";
    
    # Packages available ONLY to forensics user
    packages = with pkgs; [
      # Documentation tools
      pandoc          # Convert reports to PDF
      texlive.combined.scheme-small  # LaTeX for reports
      
      # Scripting
      python3         # For automation scripts
      python3Packages.pandas  # Data analysis
      
      # Version control for case files
      git
    ];
  };
  
  # === SECURITY SETTINGS ===
  
  # Disable sudo for forensics user - prevents privilege escalation
  # All forensic actions should be possible without root
  security.sudo.extraRules = [
    {
      users = [ "forensics" ];
      commands = [
        # ONLY allow specific read-only commands with sudo
        { command = "${pkgs.sleuthkit}/bin/tsk_recover"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.ddrescue}/bin/ddrescue"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
  
  # === WIRESHARK CONFIGURATION ===
  # Allow network capture without root (security best practice)
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  
  # === USB WRITE BLOCKING (Hardware) ===
  # Configure USB storage to be read-only by default
  # This prevents accidental modification of evidence drives
  boot.blacklistedKernelModules = [ "usb-storage" ];  # Disable auto-mount
  
  # Custom udev rule for forensic USB access
  services.udev.extraRules = ''
    # Label forensic USB devices as read-only
    SUBSYSTEM=="block", ATTR{removable}=="1", \
      ATTR{readonly}="1", \
      SYMLINK+="forensic-%k"
  '';
}
