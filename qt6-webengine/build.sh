#!/bin/bash
export CC=clang
export CXX=clang++
mkdir cmake-build
cd cmake-build
cmake .. -G Ninja -DQT_BUILD_EXAMPLES=ON -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DBUILD_qtquick3dphysics=OFF
ninja
