It doesnt appear easy to build and link sdl3 statically for ios. So the
workaround for ios is to download the mac dmg files from the SDL3
distros and extract the following folders which contain object files
for all architectures/platforms:

 - SDL3_ttf.xcframework
 - SDL3.xcframework

SDL may sometimes combine architectures into a "fat" file, which makes
it hard for zig to link. Use `lipo -info` to check if the object file is
a fat file:

    lipo -info libs/SDL3.xcframework/ios-arm64-x86/SDL3.framework/SDL3
    Architectures in the fat file: SDL3 are: x86_64 arm64

Extract the individual libraries from the "fat" file:

    lipo -extract_family arm64 libs/SDL3.xcframework/ios-arm64/SDL3.framework/SDL3 -output libsdl3-ios-arm64.a
    lipo -extract_family arm64 libs/SDL3_ttf.xcframework/ios-arm64/SDL3_ttf.framework/SDL3 -output libsdl3ttf-ios-arm64.a
