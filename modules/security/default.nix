{ ... }:

{
  users = {
    mutableUsers = false;

    users = {
      root.password = "secret";

      nixos = {
        isNormalUser = true;
        password = "nixos";
        extraGroups = [ "wheel" ];
      };
    };
  };
}
