#!/bin/bash

source ../../util.sh
root_check

USER_HOME=$(get_user_home)

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
  libgbm-dev \
  libxcb-composite0-dev \
  libxcb-render-util0-dev \
  libxcb-res0-dev \
  mesa-common-dev \
  pkg-config -y

git clone -o upstream --recursive https://github.com/hyprwm/Hyprland  "${USER_HOME}/Hyprland"
cd "${USER_HOME}/Hyprland"

version=$(cmake --version)
sed -n '1p' CMakeLists.txt
echo "Your System CMake:${version}"


read -p "Downgrade??(y/N)" ans

if [ "$ans" == "y" ] || [ "$ans" == "Y" ]; then
    read -p "Enter version.(e.g. 3.10)" version
    sed -i "s/cmake_minimum_required(VERSION [0-9.]*)/cmake_minimum_required(VERSION $new_version)/" CMakeLists.txt
fi
make all && sudo make install



### Dependencies 


# 1. hyprutils-git
mkdir -p "${USER_HOME}/Hyprland_ecosystem/hyprutils"
git clone -o upstream  https://github.com/hyprwm/hyprutils.git "${USER_HOME}/Hyprland_ecosystem/hyprutils"

cd "${USER_HOME}/Hyprland_ecosystem/hyprutils/"
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
sudo cmake --install build


# 2. hyprlang-git（hyprutils-git）
# 3. hyprcursor-git（hyprlang-git）
# 4. hyprgraphics-git（hyprutils-git）
# 5. aquamarine-git（hyprutils-gitとhyprwayland-scanner-gitに）

### Failed
# python3 -m venv "${USER_HOME}/venv"
# source "${USER_HOME}/venv/bin/activate"
# pip install --upgrade pip
# pip install cmake

# export PATH="${USER_HOME}/venv/bin:${PATH}"


### Memo
### === Error 1 ===
# grep -n "GLES" /usr/share/cmake-3.25/Modules/FindOpenGL.cmake
# sed -n '/GLES/,+10p' /usr/share/cmake-3.25/Modules/FindOpenGL.cmake

# Linking should use the ``OpenGL::OpenGL OpenGL::EGL`` targets. Using GLES* libraries is theoretically possible in place of ``OpenGL::OpenGL``, but this module does not currently support that; contributions welcome.
## Solution 
# 元のコード（動かない）
# set(GLES_VERSION "GLES3")
# find_package(OpenGL REQUIRED COMPONENTS ${GLES_VERSION})

# 手動設定（動く）
# find_package(OpenGL REQUIRED COMPONENTS EGL)
# set(OPENGL_gles3_LIBRARY /lib/aarch64-linux-gnu/libGLESv2.so)




### Snap
sudo apt update
sudo apt install snapd
sudo systemctl enable --now snapd.socket

# GCC 13をインストール
sudo snap install gcc-13

# PATHを確認（snapのbinディレクトリが含まれているか）
echo $PATH
