# (Login Shells Only): This is sourced only when you first log in (or when you explicitly start a login shell)

# ======================
# Auto-Start Logic
# ======================

# TTY Autostart
[[ "$(tty)" = "/dev/tty1" ]] && exec uwsm start hyprland
