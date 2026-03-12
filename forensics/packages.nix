{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Hashing
    hashdeep
    ssdeep
    
    # Disk imaging
    ddrescue
    dc3dd
    
    # Filesystem analysis
    sleuthkit
    
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
