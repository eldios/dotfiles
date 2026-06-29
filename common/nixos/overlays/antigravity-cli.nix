final: _prev: let
  sources = {
    x86_64-linux = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.13-5758107482193920/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "f8be088ceb90e77503b04039eb8657f1ffac29bab37f9058c2587faf364105900e7b72fe9311744c83fb19f6f9f0b2036b63bc01c7a3fff7a6abfe9c02164a6f";
    };
    aarch64-linux = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.13-5758107482193920/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "16718ea58bd16036e77080514d4ec4b9e37a25503298364400d9b9261eafbb28bb36312479c9fd56e4a8802e6f989ae73a3f25c355dfd450b4499319ba48e1fa";
    };
  };
  source =
    sources.${final.stdenv.hostPlatform.system}
      or (throw "antigravity-cli is not packaged for ${final.stdenv.hostPlatform.system}");
in {
  antigravity-cli = final.stdenvNoCC.mkDerivation {
    pname = "antigravity-cli";
    version = "1.0.13";

    src = final.fetchurl {
      inherit (source) url sha512;
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
      homepage = "https://antigravity.google/product/antigravity-cli";
      license = final.lib.licenses.unfree;
      mainProgram = "agy";
      platforms = builtins.attrNames sources;
    };
  };
}
