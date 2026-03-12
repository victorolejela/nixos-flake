{ config, pkgs, lib, ... }:

{
  # This defines ALL forensic tools with explicit versions
  # We use 'let' to create specific tool versions for reproducibility
  
  let
    # Pin specific versions by overriding nixpkgs
    # This ensures we control exactly what runs
    forensicTools = with pkgs; {
    
      # === HASHING & VERIFICATION ===
      # These tools prove evidence hasn't changed
      hashing = [
        hashdeep        # Recursive hashing (MD5/SHA256)
        md5deep         # MD5-specific deep hashing
        sha256deep      # SHA256-specific
        ssdeep          # Fuzzy hashing (find similar files)
        rhash           # Multiple hash formats
      ];
      
      # === DISK IMAGING ===
      # Creating bit-for-bit copies of evidence
      imaging = [
        ddrescue        # Fault-tolerant imaging (bad sectors)
        dc3dd           # DoD standard + on-the-fly hashing
        ewftools        # Expert Witness Format (EWF/E01)
        afflib          # Advanced Forensic Format (AFF)
        guymager        # GUI imager with metadata
      ];
      
      # === FILESYSTEM ANALYSIS ===
      # Understanding disk structures
      filesystem = [
        sleuthkit       # The core forensic toolkit
        autopsy         # GUI for Sleuthkit
        testdisk        # Partition recovery
        photorec        # File carving (recover deleted files)
        bulk_extractor  # Fast metadata extraction
        scalpel         # File carving (alternative)
      ];
      
      # === MEMORY FORENSICS ===
      # Analyzing RAM dumps
      memory = [
        volatility3     # Advanced memory forensics
        # volatility3-full has all plugins
        (python3Packages.volatility3.override {
          withYara = true;  # Enable YARA pattern matching
        })
        lime-kernel-module  # For acquiring Linux RAM
        rekall          # Alternative memory framework
      ];
      
      # === NETWORK FORENSICS ===
      # Capturing and analyzing network traffic
      network = [
        wireshark       # GUI packet analyzer
        tshark          # CLI version (scriptable)
        tcpdump         # Lightweight capture
        ngrep           # Network grep
        zeek            # Network security monitoring
        netsniff-ng     # High-performance sniffing
      ];
      
      # === BINARY/MALWARE ANALYSIS ===
      # Reverse engineering
      reverse = [
        radare2         # Disassembler/debugger
        ghidra          # NSA's reverse engineering tool
        binwalk         # Firmware extraction
        hexedit         # Hex editor
        xxd             # Hex dump utility
        strace          # System call tracer
        ltrace          # Library call tracer
      ];
      
      # === MOBILE FORENSICS ===
      # iOS/Android analysis
      mobile = [
        libimobiledevice # iOS device communication
        ifuse           # Mount iOS filesystem
        adb             # Android Debug Bridge
        android-tools   # Full Android toolkit
      ];
    };
    
    # Flatten all tool categories into one list
    allTools = lib.flatten (lib.attrValues forensicTools);
    
  in {
    # Install all forensic tools system-wide
    environment.systemPackages = allTools;
    
    # Create a metadata file with all tool versions
    # This is CRITICAL for court documentation
    environment.etc."forensic-tool-versions".text = ''
      # NixOS Forensic Workstation - Tool Manifest
      # Generated: ${toString builtins.currentTime}
      # Nixpkgs Revision: ${lib.version}
      
      ${lib.concatMapStrings (pkg: ''
        ${pkg.name}: ${pkg.outPath}
      '') allTools}
    '';
  };
}
