# (Login Shells Only): This is sourced only when you first log in (or when you explicitly start a login shell)

# ======================
# Auto-Start Logic
# ======================

# TTY Autostart
[ "$(tty)" = "/dev/tty1" ] && exec uwsm start hyprland
[ "$(tty)" = "/dev/tty2" ] && gamescope --backend drm -w 3840 -h 2160 -r 165 -- steam -gamepadui
