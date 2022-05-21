from libqtile import hook, qtile
import subprocess
import os

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])

# @hook.subscribe.client_focus
# def auto_bring_to_front(window):
#     if window.wid in qtile.windows_map:
#         if hasattr(window, 'cmd_bring_to_front'):
#             window.cmd_bring_to_front()
