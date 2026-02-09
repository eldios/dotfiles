# Overlay for Claude Code version override
#
# === CLAUDE-CODE UPDATE ===
# Get latest version (npm is authoritative, stable channel lags):
#   curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version
#
# Get hash + convert to SRI (one-liner):
#   V=2.1.32 && nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url --unpack "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-$V.tgz" 2>/dev/null)
#
self: super:
let
  claudeCodeOverride = oldAttrs: rec {
    version = "2.1.37";

    src = super.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-ijyZCT4LEEtXWOBds8WzizcfED9hVgaJByygJ4P4Yss=";
    };
  };
in
{
  claude-code = super.claude-code.overrideAttrs claudeCodeOverride;

  unstable = (super.unstable or { }) // {
    claude-code = super.unstable.claude-code.overrideAttrs claudeCodeOverride;
  };
}
# vim: set ts=2 sw=2 et ai list nu
