flutter_rust_bridge_codegen.exe --rust-input rust/src/api.rs --dart-output lib/generated/rust/bridge.dart --skip-deps-check

flutter_rust_bridge_codegen.exe --rust-input rust/src/username_registration.rs --dart-output lib/generated/rust/username_registration.dart --skip-deps-check

cargo ndk -t arm64-v8a -o ../android/app/src/main/jniLibs build


# bug requires --skip-deps-check