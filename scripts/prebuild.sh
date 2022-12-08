brew install ninja rustup-init llvm
rustup-init -y
source "$HOME/.cargo/env"
cargo install cargo-xcode
cargo install cargo-ndk
cargo install flutter_rust_bridge_codegen
rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi

flutter_rust_bridge_codegen --rust-input rust/src/username_registration.rs --dart-output lib/generated/rust/username_registration.dart --skip-deps-check
cd rust
cargo ndk -t arm64-v8a -t armeabi-v7a -o ../android/app/src/main/jniLibs build
cd ..

touch .env
echo "ONRAMPER_API_KEY=$ONRAMPER_API_KEY" >> .env
echo "INFURA_API_KEY=$INFURA_API_KEY" >> .env
echo "UD_API_KEY=$UD_API_KEY" >> .env
echo "MESSAGES_API_KEY=$MESSAGES_API_KEY" >> .env
echo "CAPTCHA_SITE_KEY=$CAPTCHA_SITE_KEY" >> .env
echo "HCAPTCHA_SITE_KEY=$HCAPTCHA_SITE_KEY" >> .env
echo "NANSWAP_API_KEY=$NANSWAP_API_KEY" >> .env
echo "MAGIC_SDK_KEY=$MAGIC_SDK_KEY" >> .env
echo "FIREBASE_WEB_API_KEY=$FIREBASE_WEB_API_KEY" >> .env
echo "FIREBASE_ANDROID_API_KEY=$FIREBASE_ANDROID_API_KEY" >> .env
echo "FIREBASE_IOS_API_KEY=$FIREBASE_IOS_API_KEY" >> .env
echo "FIREBASE_MACOS_API_KEY=$FIREBASE_MACOS_API_KEY" >> .env