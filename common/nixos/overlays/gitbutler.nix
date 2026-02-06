# Overlay: GitButler from unstable channel
#
# Uses unstable's gitbutler as-is (currently 0.15.10).
# Kept as separate file for future version customization.
#
# === GITBUTLER UPDATE ===
# Check latest version:
#   https://github.com/gitbutlerapp/gitbutler/tags
#
# NOTE: Building from source is blocked by a nixpkgs bug where
# fetchCargoVendor / importCargoLock can't handle file-id 0.2.3
# existing from both crates.io and a git dep (notify-rs/notify).
# Revisit when nixpkgs fixes this upstream.
#
self: super:
{
  gitbutler = super.unstable.gitbutler;
}
# vim: set ts=2 sw=2 et ai list nu
