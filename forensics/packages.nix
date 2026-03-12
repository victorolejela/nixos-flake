{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Hashing and verification
    hashdeep
    ssdeep
    
    # Disk imaging
    ddrescue
    dc3dd
    
    # Filesystem analysis
    sleuthkit
    testdisk
    photorec
    
    # Memory forensics
    volatility3
    
    # Network forensics
    wireshark
    tshark
    tcpdump
    
    # Binary analysis
    radare2
    binwalk
    hexedit
    strace
  ];
}
