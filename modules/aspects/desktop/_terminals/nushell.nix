{pkgs, ...}: let
  myFastFetchOpt = "-s 'Title:Separator:OS:Host:Uptime:Separator:Packages:Kernel:Shell:WM:Terminal:TerminalFont:Separator:CPU:GPU:Memory:Swap:Disk:LocalIp'";

  nushellCfgDir = "/home/eldios/.config/nushell";
in {
  home = {
    packages = with pkgs; [
      carapace
      fastfetch
      lsd
      nnn
      nufmt
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
    alias cg = ${pkgs.cargo}/bin/cargo
    alias cgb = nice -n 19 ${pkgs.cargo}/bin/cargo build
    alias cgc = nice -n 19 ${pkgs.cargo}/bin/cargo check
    alias cgn = cg new
    alias cgr = cg run
    alias cgt = nice -n 19 ${pkgs.cargo}/bin/cargo test
    alias ff = ${pkgs.fastfetch}/bin/fastfetch ${myFastFetchOpt}
    alias g = ${pkgs.git}/bin/git
    alias hm = ${pkgs.home-manager}/bin/home-manager
    alias hm-edit = hm edit
    alias hm-update = nice -n 19 nh home switch -b backup
    alias hme = hm-edit
    alias hmu = hm-update
    alias ipcalc = ${pkgs.sipcalc}/bin/sipcalc
    alias j = ${pkgs.just}/bin/just
    alias ji = ${pkgs.jira-cli-go}/bin/jira issue
    alias jil = ji list
    alias jim = ji list -a 'lele@switchboard.xyz' --order-by STATUS
    alias k = ${pkgs.kubectl}/bin/kubectl
    alias ls = ${pkgs.lsd}/bin/lsd
    alias ll = ${pkgs.lsd}/bin/lsd -lh
    alias l = ${pkgs.lsd}/bin/lsd -lhtra
    alias la = ${pkgs.lsd}/bin/lsd -a
    alias lg = ${pkgs.lazygit}/bin/lazygit
    # Same nh commands as the zsh aliases: builds go through nix-daemon at
    # idle priority and sudo is only used for the activation step.
    alias nixU = nice -n 19 nh os switch --update
    alias nixUo = nice -n 19 nh os switch --update -- --option substituters 'https://cache.nixos.org https://nix-community.cachix.org'
    alias nixs = nice -n 19 nix search nixpkgs
    alias nixu = nice -n 19 nh os switch
    alias nixuo = nice -n 19 nh os switch -- --option substituters 'https://cache.nixos.org https://nix-community.cachix.org'

    # Command sequences are defs, not aliases: an alias body is one command
    # line, so `a and b` would hand "and b" to a as arguments. A failing
    # external stops the block, which gives these the zsh `&&` behaviour.
    def hm-cleanup [] { hm expire-generations '-7 days'; nix-store --gc }
    def hmc [] { hm-cleanup }
    def hmU [] { nixu; hm-update }
    def hma [] { hme; hmu }
    def hmA [] { hme; hmU }
    alias tf = ${pkgs.opentofu}/bin/tofu
    alias tfa = tf apply -auto-approve
    alias tfd = tf destroy -auto-approve
    alias tfp = tf plan
    alias v = ${pkgs.neovim}/bin/nvim

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
}
# EOF
# vim: set ts=2 sw=2 et ai list nu

