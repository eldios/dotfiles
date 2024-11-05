{ pkgs, nixpkgs-unstable, ... }:
let
  myFastFetchOpt = "-s 'Title:Separator:OS:Host:Uptime:Separator:Packages:Kernel:Shell:WM:Terminal:TerminalFont:Separator:CPU:GPU:Memory:Swap:Disk:LocalIp'";

  binDir = "/etc/profiles/per-user/eldios/bin";

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
    ${binDir}/starship init nu | save --force /home/eldios/.cache/starship/init.nu

    $env.config = {
      show_banner: false,
    };

    $env.STARSHIP_SHELL = "nu"

    def create_left_prompt [] {
        ${binDir}/starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
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
    $env.EDITOR = "${binDir}/nvim";
    $env.VISUAL = "${binDir}/nvim";

    $env.ZELLIJ_AUTO_ATTACH = false;
    $env.ZELLIJ_AUTO_EXIT = false;

    $env.SOPS_AGE_KEY_FILE = "/etc/sops/key.txt";

    let carapace_completer = {|spans|
      ${binDir}/carapace $spans.0 nushell ...$spans | from json
    }

    zoxide init nushell | save -f ${nushellCfgDir}/zoxide.nu

    use /home/eldios/.cache/starship/init.nu

    $env.config = ($env.config? | default {})
    $env.config.hooks = ($env.config.hooks? | default {})
    $env.config.hooks.pre_prompt = (
        $env.config.hooks.pre_prompt?
        | default []
        | append {||
            let direnv = (${binDir}/direnv export json
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

    ^${binDir}/ssh-agents -c -a ~/.ssh/id_ed25519 |
      lines |
      str replace --all --regex "(.*) export.*" "''\${1}" |
      parse "{name}={value};" |
      transpose -r | into record | load-env
  '';

  xdg.configFile."nushell/config.nu".text = ''
    source ${nushellCfgDir}/zoxide.nu

    alias TF = terraform
    alias cg = cargo
    alias cgb = cg build
    alias cgc = cg check
    alias cgn = cg new
    alias cgr = cg run
    alias cgt = cg test
    alias ff = ${binDir}/fastfetch ${myFastFetchOpt}
    alias g = git
    alias hm = home-manager
    alias hm-cleanup = home-manager expire-generations '-7 days' and nix-store --gc
    alias hm-edit = home-manager edit
    alias hm-update = home-manager switch -b backup --flake $env.HOME/dotfiles
    alias hmA = hme and hmU
    alias hmU = nixu and hm-update
    alias hma = hme and hmu
    alias hmc = hm-cleanup
    alias hme = hm-edit
    alias hmu = hm-update
    alias ipcalc = sipcalc
    alias j = just
    alias ji = jira issue
    alias jil = jira issue list
    alias jim = jira issue list -a 'lele@switchboard.xyz' --order-by STATUS
    alias k = kubectl
    alias l = ls
    alias la = ls -a
    alias lg = lazygit
    alias ll = ls -l
    alias nixU = sudo nix flake update $env.HOME/dotfiles and nixu
    alias nixs = nix search nixpkgs
    alias nixu = sudo nixos-rebuild switch --impure --flake $env.HOME/dotfiles
    alias tf = tofu
    alias tfa = tf apply -auto-approve
    alias tfd = tf destroy -auto-approve
    alias tfp = tf plan
    alias y = yazi

    ${binDir}/fastfetch ${myFastFetchOpt}
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
