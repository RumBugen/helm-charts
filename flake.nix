{
  description = "Development shell for Helm chart testing";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              chart-testing
              cosign
              docker-client
              git
              jq
              kubeconform
              kubectl
              kubernetes-helm
              minikube
              yq-go
            ];

            shellHook = ''
              echo "Some useful commands:"
              echo "  helm dependency build charts/mailpiler"
              echo "  helm lint charts/mailpiler"
              echo "  helm template mailpiler charts/mailpiler --set mailpiler.hostname=archive.example.com | kubeconform -strict -ignore-missing-schemas"
              echo "  minikube start --driver=docker"
            '';
          };
        });
    };
}
