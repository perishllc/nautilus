flutter_rust_bridge_codegen.exe --rust-input rust/src/api.rs --dart-output lib/generated/rust/bridge.dart --skip-deps-check

flutter_rust_bridge_codegen.exe --rust-input rust/src/username_registration.rs --dart-output lib/generated/rust/username_registration.dart --skip-deps-check

cargo ndk -t arm64-v8a -o ../android/app/src/main/jniLibs build


# bug requires --skip-deps-check


# brew install rustup-init llvm
# rustup-init -y
# cargo install cargo-xcode
# export PATH="/Users/builder/.cargo/bin:$PATH"
# cargo install cargo-ndk
# rustup target add \
#     aarch64-linux-android \
#     armv7-linux-androideabi

# flutter_rust_bridge_codegen --rust-input rust/src/username_registration.rs --dart-output lib/generated/rust/username_registration.dart --skip-deps-check
# cargo ndk -t arm64-v8a -t armeabi-v7a -o ../android/app/src/main/jniLibs build
