# --------------------------------------------------

rm scripts/ffmpeg.sh
cp variants/default.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

ln -sf "$(pwd)/app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/arm64-v8a"
ln -sf "$(pwd)/app/build/outputs/apk/release/lib/armeabi-v7a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/armeabi-v7a"
ln -sf "$(pwd)/app/build/outputs/apk/release/lib/x86/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/x86"
ln -sf "$(pwd)/app/build/outputs/apk/release/lib/x86_64/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/x86_64"

cd ../..

# --------------------------------------------------

cd deps/media_kit/media_kit_native_event_loop

flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

if ! grep -q android "pubspec.yaml"; then
  printf "      android:\n        ffiPlugin: true\n" >> pubspec.yaml
fi

flutter pub get

cp -a ../../mpv/libmpv/. src/include/

cd example/android

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o ../build/app/outputs/apk/release/app-release.apk -d ../build/app/outputs/apk/release

cd ../build/app/outputs/apk/release/

# --------------------------------------------------

rm -r lib/*/libapp.so
rm -r lib/*/libflutter.so

zip -r "default-arm64-v8a.jar"                lib/arm64-v8a
zip -r "default-armeabi-v7a.jar"              lib/armeabi-v7a
zip -r "default-x86.jar"                      lib/x86
zip -r "default-x86_64.jar"                   lib/x86_64

rm -r lib/*/libavcodec.so
rm -r lib/*/libavdevice.so
rm -r lib/*/libavfilter.so
rm -r lib/*/libavformat.so
rm -r lib/*/libavutil.so
rm -r lib/*/libswresample.so
rm -r lib/*/libswscale.so

zip -r "no-ffmpeg-default-arm64-v8a.jar"      lib/arm64-v8a
zip -r "no-ffmpeg-default-armeabi-v7a.jar"    lib/armeabi-v7a
zip -r "no-ffmpeg-default-x86.jar"            lib/x86
zip -r "no-ffmpeg-default-x86_64.jar"         lib/x86_64

mkdir ../../../../../../../../../../output

cp *.jar ../../../../../../../../../../output

md5sum *.jar

cd ../../../../../../../../..

# --------------------------------------------------

zip -r debug-symbols-default.zip prefix/*/lib
cp debug-symbols-default.zip ../output
