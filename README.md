# Gray

<div align="center">

[![CI Status](https://travis-ci.com/zenangst/Gray.svg?branch=master)](https://travis-ci.com/zenangst/Gray)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-orange.svg)
[![macOS](https://img.shields.io/badge/macOS-10.14-green.svg)](https://www.apple.com/macos/mojave/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

<img src="https://github.com/zenangst/Gray/blob/master/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png?raw=true" alt="Gray Icon" align="right" />

Current version: 0.16.0 [[Download](https://github.com/zenangst/Gray/releases/download/0.16.0/Gray.zip)]

Ever wanted to have light and dark apps live side-by-side in harmony? Well, now you can. With **Gray** you can pick between the light appearance and the dark appearance on a per-app basis with the click of a button.

To quote the late Michael Jackson:
> It don't matter if you're black or white

### Instructions

Go into `System Preferences > General` and set your Mac to use dark appearance.

**Note** the application that you want to change the appearance of will have to restart before you see the changes. This is currently handled by **Gray** but be sure to not have any unsaved changes before you start tailoring your macOS experience.

<img alt="Gray" src="https://github.com/zenangst/Gray/blob/master/Images/Screenshot.png">

### How it works

Under the hood, **Gray** simply configures which app should be forced to use the light aqua appearance. You can achieve this without installing **Gray** by merely running a terminal command.

```fish
defaults write com.apple.dt.Xcode NSRequiresAquaSystemAppearance -bool YES
```

The command creates a new entry in the user's configuration file for the specific application. It does not alter the system in any way. So when you are done configuring, you can toss **Gray** in the trash if you like (I hope you don't :) )

## Building

If you want to build `Gray` using Xcode, you can follow these instructions.

```fish
git clone git@github.com:zenangst/Gray.git
cd Gray
pod install
open Gray.xcworkspace
```

Happy coding!

## Author

Christoffer Winterkvist, christoffer@winterkvist.com

## License

**Gray** is available under the MIT license. See the [LICENSE](https://github.com/zenangst/Gray/blob/master/LICENSE.md) file for more info.
