{ ... }:
{
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.riscv.tunstall.xyz";
    minSpareServers = 2;
    maxSpareServers = 4;
    maxServers = 8;
    notificationSender = "hydra@system.tunstall.xyz";

    extraConfig = ''
      allow_import_from_derivation = false

      evaluator_workers = 1
      evaluator_max_memory_size = 2048
      max_concurrent_evals = 1
    '';
  };
}
