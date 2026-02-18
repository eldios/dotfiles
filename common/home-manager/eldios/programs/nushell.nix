{ pkgs, ... }:
let
  myFastFetchOpt = "-s 'Title:Separator:OS:Host:Uptime:Separator:Packages:Kernel:Shell:WM:Terminal:TerminalFont:Separator:CPU:GPU:Memory:Swap:Disk:LocalIp'";

  nushellCfgDir = "/home/eldios/.config/nushell";
in
{

  home = {
    packages = with pkgs; [
      carapace
      fastfetch
      nnn
      nufmt
      yazi
      zoxide
    ];
  }; # EOM nushell deps

  xdg.configFile."nushell/env.nu".text = ''
    $env.GPG_TTY = (tty)

    let starship_cache = "/home/eldios/.cache/starship"
    if not ($starship_cache | path exists) {
      mkdir $starship_cache
    }
    ${pkgs.starship}/bin/starship init nu | save --force /home/eldios/.cache/starship/init.nu

    $env.config = {
      show_banner: false,
    };

    $env.STARSHIP_SHELL = "nu"

    def create_left_prompt [] {
        ${pkgs.starship}/bin/starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
    }

    # Use nushell functions to define your right and left prompt
    $env.PROMPT_COMMAND = { || create_left_prompt }
    $env.PROMPT_COMMAND_RIGHT = ""

    # The prompt indicators are environmental variables that represent
    # the state of the prompt
    $env.PROMPT_INDICATOR = ""
    $env.PROMPT_INDICATOR_VI_INSERT = ": "
    $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
    $env.PROMPT_MULTILINE_INDICATOR = "::: "

    $env.TERM = "xterm-256color";
    $env.EDITOR = "$(which nvim)";
    $env.VISUAL = "$(which nvim)";

    $env.ZELLIJ_AUTO_ATTACH = false;
    $env.ZELLIJ_AUTO_EXIT = false;

    $env.SOPS_AGE_KEY_FILE = "/etc/sops/key.txt";

    let carapace_completer = {|spans|
      ${pkgs.carapace}/bin/carapace $spans.0 nushell ...$spans | from json
    }

    zoxide init nushell | save -f ${nushellCfgDir}/zoxide.nu

    use /home/eldios/.cache/starship/init.nu

    $env.config = ($env.config? | default {})
    $env.config.hooks = ($env.config.hooks? | default {})
    $env.config.hooks.pre_prompt = (
        $env.config.hooks.pre_prompt?
        | default []
        | append {||
            let direnv = (${pkgs.direnv}/bin/direnv export json
            | from json
            | default {})
            if ($direnv | is-empty) {
                return
            }
            $direnv
            | items {|key, value|
                {
                    key: $key
                    value: (do (
                        $env.ENV_CONVERSIONS?
                        | default {}
                        | get -i $key
                        | get -i from_string
                        | default {|x| $x}
                    ) $value)
                }
            }
            | transpose -ird
            | load-env
        }
    )

  '';

  xdg.configFile."nushell/config.nu".text = ''
    source ${nushellCfgDir}/zoxide.nu

    alias TF = ${pkgs.terraform}/bin/terraform
    alias cg = ${pkgs.cargo}/bin/cargo # FIXME: Or from pkgs.rustc
    alias cgb = cg build
    alias cgc = cg check
    alias cgn = cg new
    alias cgr = cg run
    alias cgt = cg test
    alias ff = ${pkgs.fastfetch}/bin/fastfetch ${myFastFetchOpt}
    alias g = ${pkgs.git}/bin/git
    alias hm = ${pkgs.home-manager}/bin/home-manager
    alias hm-cleanup = hm expire-generations '-7 days' and nix-store --gc # nix-store is usually in PATH
    alias hm-edit = hm edit
    alias hm-update = hm switch -b backup --flake $env.HOME/dotfiles
    alias hmA = hme and hmU
    alias hmU = nixu and hm-update
    alias hma = hme and hmu
    alias hmc = hm-cleanup
    alias hme = hm-edit
    alias hmu = hm-update
    alias ipcalc = ${pkgs.sipcalc}/bin/sipcalc
    alias j = ${pkgs.just}/bin/just
    alias ji = ${pkgs.jira-cli-go}/bin/jira issue
    alias jil = ji list
    alias jim = ji list -a 'lele@switchboard.xyz' --order-by STATUS
    alias k = ${pkgs.kubectl}/bin/kubectl # FIXME: Verify package name, could be pkgs.kubectl
    alias l = ${pkgs.coreutils}/bin/ls # Using coreutils ls as lsd is not in nushell packages
    alias la = l -a
    alias lg = ${pkgs.lazygit}/bin/lazygit
    alias ll = l -l
    alias nixU = sudo nix flake update $env.HOME/dotfiles and nixu # 'nix' assumed in PATH
    alias nixUo = sudo nix flake update $env.HOME/dotfiles and nixuo # outside network - skip local cache
    alias nixs = nix search nixpkgs # 'nix' assumed in PATH
    alias nixu = sudo nixos-rebuild switch --flake $env.HOME/dotfiles # nixos-rebuild assumed in PATH
    alias nixuo = sudo nixos-rebuild switch --flake $env.HOME/dotfiles --option substituters 'https://cache.nixos.org https://nix-community.cachix.org' # outside - skip local cache
    alias tf = ${pkgs.opentofu}/bin/tofu
    alias tfa = tf apply -auto-approve
    alias tfd = tf destroy -auto-approve
    alias tfp = tf plan
    alias v = ${pkgs.neovim}/bin/nvim
    alias y = ${pkgs.yazi}/bin/yazi

    ${pkgs.fastfetch}/bin/fastfetch ${myFastFetchOpt}
  '';

  programs = {

    starship = {
      enable = true;
    };

    nushell = {
      enable = true;
    }; # EOM nushell

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
