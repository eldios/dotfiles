# Overlay: Omnigent (meta-harness CLI for coding agents)
#
# Omnigent ships only as a Python package with about forty pinned
# dependencies, several of them not in Nixpkgs. Instead of packaging that
# tree, the omnigent and omni commands run the pinned release through
# `uv tool run`, which resolves it once into uv's cache. The interpreter is
# Nixpkgs' Python 3.12 (uv may not download its own), the PyPI wheels load
# through nix-ld, and tmux and bubblewrap are on PATH for the native agent
# wrappers. Telemetry stays off unless the caller sets the variables.
#
# To bump: scripts/update-versions.sh omnigent
# Releases: https://pypi.org/project/omnigent/
final: _prev: let
  version = "0.18.0";
  python = final.python312;

  wrapper = name:
    final.writeShellApplication {
      inherit name;
      runtimeInputs = [final.uv final.tmux final.bubblewrap];
      text = ''
        export UV_PYTHON_DOWNLOADS=never
        export OMNIGENT_ANALYTICS="''${OMNIGENT_ANALYTICS:-0}"
        export DO_NOT_TRACK="''${DO_NOT_TRACK:-1}"
        exec uv tool run --python ${python.interpreter} \
          --from "omnigent==${version}" ${name} "$@"
      '';
    };
in {
  omnigent = final.symlinkJoin {
    name = "omnigent-${version}";
    inherit version;
    paths = [(wrapper "omnigent") (wrapper "omni")];
    meta = {
      description = "Meta-harness CLI for coding agents, run from PyPI with uv";
      homepage = "https://github.com/omnigent-ai/omnigent";
      license = final.lib.licenses.asl20;
      mainProgram = "omnigent";
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

