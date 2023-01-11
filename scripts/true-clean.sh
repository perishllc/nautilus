#!/bin/bash
flutter clean
# build / cache
rm -rf ./build
rm -rf ./android/app/build
# rust
rm -rf ./rust/src/*_generated*
rm -rf ./rust/target
rm -rf ./rust/Cargo.lock
