# ✨ Epic NixOS & Home Manager Adventure! ✨

Welcome to my personal realm of meticulously crafted NixOS configurations! This isn't just code; it's a declaration of digital independence, a symphony of systems orchestrated by the power of Nix. Prepare to dive into a world where reproducibility, customization, and sheer awesomeness converge!

<!-- TODO: Add a cool banner image here! Think neon, cyberpunk, or something that screams 'Nix-powered future!' -->

## 🚀 The Vision: Consistent, Powerful, Beautiful Systems

This repository is my command center for managing multiple machines – from beefy workstations to nimble laptops, GUI powerhouses to sleek CLI ninjas. The goal?
*   **Rock-Solid Consistency:** The same core experience, tailored where needed.
*   **Effortless Reproducibility:** Set up a new machine or restore an old one? Nix has got my back!
*   **Stunning Aesthetics:** Featuring a vibrant **Neon Dark Theme** powered by [Stylix](https://github.com/danth/stylix), ensuring a cohesive and visually striking experience across applications.
*   **Ultimate Customization:** Every tool, every setting, just the way I like it.

## 🗺️ Navigating This Universe: Repository Structure

Here's a quick map to help you find your way:

*   `flake.nix`: The master key! This is where all inputs (like Nixpkgs, Home Manager, Stylix) are defined and where system configurations are assembled.
*   `common/`: This directory is the heart of shared wisdom.
    *   `common/nixos/`: Contains common NixOS system modules applied to most, if not all, hosts (e.g., base system settings, users, common programs, our Stylix theme module!).
    *   `common/home-manager/`: Shared Home Manager configurations for my user (`eldios`), including common programs, services, and the base for our neon theme application.
*   `hosts/`: Each subdirectory here represents a unique machine, each with its own personality and specific needs!
    *   `hosts/hostname/nixos/configuration.nix`: The main NixOS configuration for that specific host.
    *   `hosts/hostname/home-manager/home.nix`: The main Home Manager configuration for my user on that host.
    *   Other files (`system.nix`, `boot.nix`, `disko.nix`, etc.) further define the host's hardware and system setup.
*   `secrets/`: (This directory is not actually in the public repo but is referenced in `flake.nix`). This is where sensitive data is managed using `sops-nix`.

## 🛠️ Getting Started & Deploying Your Own Symphony!

Ready to join the Nix-olution? Here's the high-level flight plan:

1.  **Clone this Repository:**
    ```bash
    git clone <this-repo-url> my-nixos-config
    cd my-nixos-config
    ```
2.  **Set Up for a New Host (Example: `my-new-machine`):**
    *   Duplicate an existing host's directory (e.g., `cp -r hosts/wotah hosts/my-new-machine`).
    *   Rename and update `my-new-machine/nixos/configuration.nix` and other files within to match the new hardware and desired setup.
    *   Add your new host definition to `flake.nix`, following the pattern of existing hosts.
3.  **Deploy the Configuration:**
    From within the repository directory on the target machine:
    ```bash
    # For NixOS systems
    sudo nixos-rebuild switch --flake .#my-new-machine

    # For Home Manager standalone on non-NixOS (if you adapt it for that)
    # home-manager switch --flake .#eldios@my-new-machine
    ```
4.  **Bask in the Glow:** Enjoy your beautifully configured, reproducible system! Remember to check any `# FIXME:` comments in the code for things you might need to adjust (like hardware IDs for the 'wotah' VM).

## ✨ The Neon Dream: Powered by Stylix

A significant effort has gone into making these configurations not just functional but also a joy to behold! We're rocking a custom **Neon Dark Theme** across:
*   Hyprland (with cool blurs and animations!)
*   Waybar
*   Terminals (Alacritty, Kitty, Wezterm)
*   GTK & Qt Applications
*   Rofi launcher
*   And even the cursor!

This is largely orchestrated by the magic of [Stylix](https://github.com/danth/stylix), ensuring a consistent vibe everywhere.

## 🔮 What's Next? The Adventure Continues!

This journey of a thousand lines of code began with a single `nix-init`. There's always more to explore, refine, and perfect! Future quests might involve:
*   Deeper dives into specific application ricing.
*   Exploring new Nix utilities and patterns.
*   Expanding to even more exotic hardware!

Got ideas or contributions? While this is a personal config, inspiration is always welcome!

---

May your builds be swift, your configurations robust, and your desktops forever awesome! 🚀
