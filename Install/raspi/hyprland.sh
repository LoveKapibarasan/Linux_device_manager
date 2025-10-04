#!/bin/bash

source ../../util.sh
root_check

USER_HOME=$(get_user_home)

python3 -m venv "${USER_HOME}/venv"
source "${USER_HOME}/venv/bin/activate"
pip install --upgrade pip
pip install cmake

export PATH="${USER_HOME}/venv/bin:${PATH}"

git submodule update --init --recursive

sudo apt install meson ninja-build

sudo apt install \
  libwayland-dev \
  wayland-protocols \
  libxkbcommon-dev \
  libpixman-1-dev \
  libudev-dev \
  libseat-dev \
  libdrm-dev \
  libinput-dev \
  libxcb1-dev \
  libxcb-dri3-dev \
  libxcb-present-dev \
  libxcb-xfixes0-dev \
  libxcb-render0-dev \
  libxcb-xinput-dev \
  libgles2-mesa-dev \
  libegl1-mesa-dev \
  libgl1-mesa-dev \
  mesa-common-dev \
  pkg-config -y

git clone -o upstream --recursive https://github.com/hyprwm/Hyprland  "${USER_HOME}/Hyprland"
cd "${USER_HOME}/Hyprland"
make all && sudo make install


cd ~/Hyprland

# subprojectsを更新
meson subprojects update --reset

# ビルドディレクトリをセットアップ
meson setup build

# ビルド
ninja -C build

# インストール（オプション）
sudo ninja -C build install --tags runtime,man


https://wiki.hypr.land/Getting-Started/Installation/
head -20 meson.build | grep cpp_std
    'optimization=3',
    'buildtype=release',
    'debug=false',
    'cpp_std=c++23',
  ],

mkdir -p ~/hypr-deps
cd ~/hypr-deps
pc% 
pc% git clone https://github.com/hyprwm/hyprutils.git
cd hyprutils

