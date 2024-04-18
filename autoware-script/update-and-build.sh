#!/bin/bash

TARGET_DIR=$1  # ex. /home/horibe/workspace/pilot-auto.latest
CHECKOUT_TYPE=$2  # 'main' or 'latest-tag'

source /home/horibe/.bashrc
source /opt/ros/humble/setup.bash

cd $TARGET_DIR

# checkout to the target branch
if [ "$CHECKOUT_TYPE" = "main" ]; then
    CHECKOUT_BRANCH="origin/main"
elif [ "$CHECKOUT_TYPE" = "latest-tag" ]; then
    CHECKOUT_BRANCH=$(git fetch --tags; git tag --sort=-version:refname | head -1)  # latest tag
else
    echo "Invalid argument: choose 'main' or 'latest-tag'"
    exit 1
fi

echo "============= update-and-build: start ==============="
echo " -- target directory = $TARGET_DIR"
echo " -- target branch = $CHECKOUT_BRANCH"
echo "====================================================="

git checkout $CHECKOUT_BRANCH
git reset --hard $CHECKOUT_BRANCH

if [ ! -d "src" ]; then
    mkdir src
fi

# vcs import
echo "============= vcs import: start ====================="

rm -rf ./src/* ./install ./build ./log
vcs import src < autoware.repos
vcs import src < simulator.repos
vcs import src < tools.repos

echo "============= vcs import: done ======================"


# rosdep
echo "============= rosdep install: start ================="

rosdep update
rosdep install -iy --from-paths src

echo "============= rosdep install: done =================="


# colcon build
echo "============= colcon build: start ==================="

source /opt/ros/humble/setup.bash
colcon build --symlink-install --continue-on-error --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

echo "============= colcon build: done ===================="


# add git remote 
cd $TARGET_DIR/src/autoware/universe
git remote add tier4 git@github.com:tier4/autoware.universe.git
git fetch tier4

cd $TARGET_DIR/src/autoware/launcher
git remote add tier4 git@github.com:tier4/autoware_launch.git
git fetch tier4

# apply patch
cd $TARGET_DIR
patch -p1 < ./disable-src-ignore.patch

echo "============= update-and-build: done ================"
