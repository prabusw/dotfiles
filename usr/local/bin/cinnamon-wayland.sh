export XDG_CURRENT_DESKTOP=Cinnamon # xdg-desktop-portal
export XDG_SESSION_DESKTOP=Cinnamon # systemd
export XDG_SESSION_TYPE=Wayland # xdg/systemd

# Source Wayland stuff 
source /usr/local/bin/wayland_enablement.sh

if command -v dbus-update-activation-environment >/dev/null; then
    dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
fi
    # without this, systemd starts xdg-desktop-portal without these environment variables,
    # and the xdg-desktop-portal does not start xdg-desktop-portal-wrl as expected
    # https://github.com/emersion/xdg-desktop-portal-wlr/issues/39#issuecomment-638752975
# systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
    
    # use systemd-run here, because systemd units inherit variables from ~/.config/environment.d
    # true: ignore errors here so we always do the teardown afterwards
    # shellcheck disable=SC2068
    # systemd-run --quiet --unit=sway --user --wait sway $@ || true
    #systemd-run --user --wait cinnamon --wayland $@ || true
cinnamon --wayland $@

