# Overlay: use unstable's gitbutler (newer than stable). Separate file so the
# version can be customized later. Upstream tags:
#   https://github.com/gitbutlerapp/gitbutler/tags
self: super:
{
  gitbutler = super.unstable.gitbutler;
}
# vim: set ts=2 sw=2 et ai list nu
