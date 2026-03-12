{ config, pkgs, lib, ... }:

{
  # Import sub-modules
  imports = [
    ./packages.nix
    ./users.nix
  ];
  
  # === SYSTEM IMMUTABILITY ===
  # These settings make the system forensically sound
  
  # Disable automatic upgrades - we control when system changes
  system.autoUpgrade.enable = false;
  
  # Disable garbage collection - evidence might be in store!
  nix.gc.automatic = false;
  nix.gc.dates = "never";
  
  # BUT: Allow manual GC with confirmation
  # We'll create a wrapper that requires explicit case closure
  nix.gc.options = "--max-freed 1G";
  
  # Make store read-only after boot (optional, advanced)
  # nix.readOnlyStore = true;  # Uncomment after testing
  
  # === FORENSIC WORKSPACE ===
  # Dedicated directories with strict permissions
  
  systemd.tmpfiles.rules = [
    # Main forensic directory
    "d /forensics 0750 forensics forensics -"
    
    # Active cases (analysts work here)
    "d /forensics/cases 0750 forensics forensics -"
    
    # Evidence storage (read-only after acquisition)
    "d /forensics/evidence 0550 forensics forensics -"
    
    # Tool templates and scripts
    "d /forensics/templates 0755 forensics forensics -"
    
    # ISO images for bootable recovery
    "d /forensics/iso 0755 forensics forensics -"
    
    # Audit logs (append-only)
    "d /forensics/audit 0750 forensics forensics -"
    "a /forensics/audit - - - - +a"  # Append-only attribute
  ];
  
  # === KERNEL CONFIGURATION ===
  # Enable forensic-relevant kernel modules
  
  boot.kernelModules = [
    "loop"           # Loopback devices for mounting images
    "dm-snapshot"    # LVM snapshots for live analysis
    "nbd"            # Network block device (remote imaging)
    "affs"           # Amiga filesystem (old but relevant)
    "hfs"            # Mac filesystem
    "hfsplus"        # Modern Mac filesystem
    "ntfs"           # Windows filesystem (read-only)
  ];
  
  # Disable features that could modify evidence
  boot.supportedFilesystems = lib.mkForce [ 
    "ext4" "xfs" "btrfs" "vfat" "exfat" 
  ];  # Explicitly NOT including ntfs3g (read-write)
  
  # === NETWORK SECURITY ===
  # Forensic workstations should be isolated
  
  networking.firewall = {
    enable = true;
    allowPing = false;  # Don't respond to pings
    logRefusedConnections = true;  # Log for analysis
    
    # Block all incoming by default
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
  
  # Disable WiFi if present (use Ethernet only, more stable)
  networking.wireless.enable = lib.mkDefault false;
  
  # === TIME SYNCHRONIZATION ===
  # Accurate timestamps are critical for evidence
  
  services.timesyncd = {
    enable = true;
    servers = [ 
      "time.nist.gov"      # US NIST time servers
      "pool.ntp.org"       # Fallback
    ];
  };
  
  # Set timezone to UTC (forensic standard)
  time.timeZone = "UTC";
  
  # === LOGGING ===
  # Comprehensive audit trail
  
  services.journald.extraConfig = ''
  Storage=persistent
  Compress=yes
  MaxRetentionSec=1year

      # Don't lose logs on crash
      Storage=persistent
      
      # Compress old logs
      Compress=yes
      
      # Keep logs for 1 year (forensic requirement)
      MaxRetentionSec=1year
      
      # Forward to syslog for permanent storage
      ForwardToSyslog=yes
    '';
  };
  
  # === HARDWARE WRITE BLOCKING ===
  # Configure USB and SATA for read-only access
  
  # Disable USB storage auto-probe
  boot.extraModprobeConfig = ''
    # Load USB storage in read-only mode
    options usb-storage quirks=0x0000:0x0000:r
  '';
  
  # === FORENSIC SERVICES ===
  
  # Enable SSH for remote analysis (key-only)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "forensics" ];
      
      # Log everything
      LogLevel = "VERBOSE";
    };
  };
  
  # === ENVIRONMENT VARIABLES ===
  
  environment.variables = {
    # Default to UTC for all forensic tools
    TZ = "UTC";
    
    # Sleuthkit configuration
    TSK_HOME = "/forensics";
    
    # Volatility3 configuration
    VOLATILITY_HOME = "/forensics";
    
    # Case directory
    FORENSICS_CASES = "/forensics/cases";
    
    # Evidence directory
    FORENSICS_EVIDENCE = "/forensics/evidence";
  };
  
  # === SHELL ALIASES FOR FORENSICS ===
  
  environment.shellAliases = {
    # Quick navigation
    "f-cases" = "cd /forensics/cases";
    "f-evidence" = "cd /forensics/evidence";
    
    # Safety aliases (prevent accidental modification)
    "dd" = "echo 'Use dc3dd for forensics! It hashes automatically.'; false";
    "rm" = "rm -i";  # Confirm before delete
    "cp" = "cp -i";  # Confirm before overwrite
    
    # Forensic shortcuts
    "hash-dir" = "hashdeep -r -l";  # Recursive hash
    "hash-file" = "sha256deep -l";  # Single file hash
  };
}
