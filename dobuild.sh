#! /bin/bash

mkdir -p buildDir
pushd buildDir
meson --buildtype debug ..
ninja
popd