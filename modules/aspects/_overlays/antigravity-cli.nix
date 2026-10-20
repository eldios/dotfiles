final: _prev: let
  # Google Antigravity CLI (prebuilt, unfree). Follows upstream by bumping
  # `version` and refreshing the two hashes:
  #   nix store prefetch-file --json <asset-url> | jq -r .hash
  # Releases: https://github.com/google-antigravity/antigravity-cli/releases
  version = "1.4.3";
  baseUrl = "https://github.com/google-antigravity/antigravity-cli/releases/download/${version}";
  sources = {
    x86_64-linux = {
      url = "${baseUrl}/agy_cli_linux_x64.tar.gz";
      hash = "sha256-MZsssyQNJEkwvQdwM7RmlB/Xum8IgdeD7ugB29L7k3E=";
    };
    aarch64-linux = {
      url = "${baseUrl}/agy_cli_linux_arm64.tar.gz";
      hash = "sha256-BFqnES9XTvl/gyCmXTClVcTOm91ePVbUD85+JiypjNo=";
    };
  };
  source =
    sources.${final.stdenv.hostPlatform.system}
      or (throw "antigravity-cli is not packaged for ${final.stdenv.hostPlatform.system}");
in {
  antigravity-cli = final.stdenvNoCC.mkDerivation {
    pname = "antigravity-cli";
    inherit version;

    src = final.fetchurl {
      inherit (source) url hash;
    };

    nativeBuildInputs = [
      final.autoPatchelfHook
    ];

    buildInputs = [
      final.glibc
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 antigravity $out/bin/agy
      runHook postInstall
    '';

    meta = {
      description = "Google Antigravity CLI";
      homepage = "https://github.com/google-antigravity/antigravity-cli";
      license = final.lib.licenses.unfree;
      mainProgram = "agy";
      platforms = builtins.attrNames sources;
    };
  };
}
