{
  description = "Install eduroam on NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    eduroam-ostfalia = {
      url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=5049&device=linux&generatedfor=user&openroaming=0";
      flake = false;
    };
  };

  outputs = {self, ...} @ inputs:
    with inputs; let
      supportedSystems = ["aarch64-linux" "x86_64-linux"];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
        });
    in {
      packages = forAllSystems (system: let
        pkgs = nixpkgsFor.${system};
        python-with-dbus = pkgs.python3.withPackages (p: with p; [dbus-python]);
      in {
        # nix run .#eduroam-ostfalia
        eduroam-ostfalia =
          pkgs.writeShellScriptBin "install-eduroam-ostfalia"
          "${python-with-dbus}/bin/python3 ${eduroam-ostfalia}";
      });
    };
}
