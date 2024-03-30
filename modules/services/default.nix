{ ... }:
{
  services.getty.autologinUser = "root";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
}
