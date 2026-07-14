{ config, pkgs, ... }:

{
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    
    spiceUSBRedirection.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dnsmasq 
  ];

  users.users.dylan.extraGroups = [ "libvirtd" ];
}
