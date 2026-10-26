set -x
cd ~
(apt-get install -y -qq mesa-vulkan-drivers xvfb libxi6 libxxf86vm1 libxfixes3 libxrender1 libgl1 libsm6 libxkbcommon0 >/dev/null 2>&1 || (apt-get update -qq && apt-get install -y -qq mesa-vulkan-drivers xvfb libxi6 libxxf86vm1 libxfixes3 libxrender1 libgl1 libsm6 libxkbcommon0 >/dev/null 2>&1)) && echo APT OK
uv venv -p 3.13 ~/bl && timeout 900 uv pip install -p ~/bl/bin/python bpy==5.2.3 numpy pillow && echo BPY OK
mkdir -p ~/godot && cd ~/godot && curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip && unzip -q g.zip && mv Godot_v4.7.2-stable_linux.x86_64 godot && rm g.zip && echo GODOT OK
cd /home/user/androidapp_rpg_bornim && bash tools/blender348/v3/cc0_laden.sh ~/cc0 && echo CC0 OK
