{
	description = "Parker's Nix Setup";

	inputs = {
		# shorthand for github.com/NixOS/nixpkgs...
		# nixpkgs.url = "nixpkgs/nixos-25.11";
		nixpkgs.url = "nixpkgs/nixos-unstable";

		home-manager = {
			# url = "github:nix-community/home-manager/release-25.11";
			url = "github:nix-community/home-manager/master";
			# prevents home-manager from pulling its own version of nixpkgs, avoiding mismatched package sets
			inputs.nixpkgs.follows = "nixpkgs";	
		};

    # nix-darwin = {
    #   url = "github:LnL7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
	};

	outputs = { self, nixpkgs, home-manager, ... }:
    let
      user = import ./lib/user.nix;
    in
    {
      nixosConfigurations = {
        parker-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux"; 
          specialArgs = { inherit user; };
          modules = [
            ./hosts/nixos/parker-desktop/configuration.nix
            # we include home-manager as a module here becase we want home-manager
            # to be managed by the flake itself (i.e. we don't have to bootstrap it
            # separately, everything is applied with a nixos-rebuild switch)
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                backupFileExtension = "backup";
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user; };
                users.${user.username} = {
                  imports = [ ./hosts/nixos/parker-desktop/home.nix ];
                };
              };
            }
          ];
        };
      };
    };
}
