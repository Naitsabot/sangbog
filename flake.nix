{
    description = "F-klubben sangbog";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-23.11";
    };

    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
        deps = with pkgs; [ ghostscript texliveFull psutils gnumake which perl ];
        booklet = pkgs.stdenv.mkDerivation rec {
            name = "F-klubbens sangbog booklet";
            src = ./.;
            nativeBuildInputs = deps;
            installPhase = ''
                mkdir -p $out/{bin,share}
                ${pkgs.gnumake}/bin/make booklet
                mv main_book.pdf $out/share
                echo "${pkgs.xdg-utils}/bin/xdg-open $out/share/main_book.pdf" > $out/bin/${builtins.replaceStrings [" "] ["-"] name}
                chmod +x $out/bin/${builtins.replaceStrings [" "] ["-"] name}
            '';
        };
        pdf = pkgs.stdenv.mkDerivation rec{
            name = "F-klubbens sangbog continuous";
            src = ./.;
            nativeBuildInputs = deps;
            installPhase = ''
                mkdir -p $out/{bin,share}
                ${pkgs.gnumake}/bin/make pdf
                mv main.pdf $out/share
                echo "${pkgs.xdg-utils}/bin/xdg-open $out/share/main.pdf" > $out/bin/${builtins.replaceStrings [" "] ["-"] name}
                chmod +x $out/bin/${builtins.replaceStrings [" "] ["-"] name}
            '';

        };

    in {
        devShells.${system}.default = pkgs.mkShell {
            packages = deps;
        };

        packages.${system} = {
            default = booklet; 
            pdf = pdf;
            booklet = booklet;
        };

    };
}
