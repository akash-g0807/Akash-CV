{
  description = "LaTeX Document with Carlito";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-minimal latex-bin latexmk titlesec geometry tabulary tabularew 
        collection-latexextra collection-fontsrecommended 
        fontawesome5 luatexbase fontspec;
      };
      fonts = pkgs.carlito;
    in rec {
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.coreutils tex fonts pkgs.fira-code ];

        shellHook = ''
          export OSFONTDIR="${fonts}/share/fonts/truetype"
          export TEXMFHOME="$PWD/.cache"
          export TEXMFVAR="$PWD/.cache/texmf-var"
          
          echo "Setting up Fontconfig..."
          fc-cache -fv >/dev/null 2>&1
          luaotfload-tool --update >/dev/null 2>&1        
 
          echo "Carlito should now be available in LuaLaTeX!"
        '';
      };
      
      defaultPackage = pkgs.stdenvNoCC.mkDerivation rec {
        name = "latex-demo-document";
        src = self;
        buildInputs = [ pkgs.coreutils tex fonts pkgs.fira-code ];
        phases = ["unpackPhase" "buildPhase" "installPhase"];
        
        buildPhase = ''
          export PATH="${pkgs.lib.makeBinPath buildInputs}"
          mkdir -p .cache/texmf-var
          export OSFONTDIR="${fonts}/share/fonts/truetype"
          export TEXMFHOME=".cache"
          export TEXMFVAR=".cache/texmf-var"

          env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
            OSFONTDIR="${fonts}/share/fonts/truetype" \
            SOURCE_DATE_EPOCH=$(date -d "2021-11-30" +%s) \
            latexmk -interaction=nonstopmode -pdf -lualatex \
            -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
            -usepretex document.tex
        ''; 
        
        installPhase = ''
          mkdir -p $out
          cp document.pdf $out/
        '';
      };
    });
}

