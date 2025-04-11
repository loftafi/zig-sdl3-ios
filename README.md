## Template Zig 0.14 SDL3 iOS project

A sample app that draws a box and some text lives 
in `src/app.zig`, and a template iOS xcode template
project is in `ios/cc.xcodeproject`.

## Getting Started

`git clone` this repository, and in the top level run:

    zig build

This does several things.

 - Create a native macOS app `zig-out/bin/cc`
 - Create a iOS library and copies it into the xcode project.

## Running on iPhone

After doing `zig build` the zig code is copied into the xcode project.
Open the `ios/cc.xcodeproject`, configure for running on your phone
then press the run button. You will need basic background knowledge
of how to build and run an xcode iOS project.



