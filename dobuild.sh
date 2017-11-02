#! /bin/bash

mkdir -p buildDir
pushd buildDir
meson ..
ninja
popd