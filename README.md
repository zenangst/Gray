# Gray

Ever wanted to have light and dark apps live side-by-side in harmony, well now you can. With **Gray** you can pick which apps should use the light and dark appearance with a click of a button.

To quote the late Michael Jackon:
> It don't matter if you're black or white

### Instructions

Go into `System Preferences > General` and set your Mac to use dark appearance.

### How it works

Under the hood, **Gray** simply configures which app should be forced to use the light aqua appearance. You can achieve this without installing the **Gray** by merely running a terminal command.

```
defaults write com.apple.dt.Xcode NSRequiresAquaSystemAppearance -bool YES
```

The command creates a new entry in the user's configuration file for the specific application. It does not alter the system in any way. So when you are done configuring, you can toss **Gray** in the trash if you like (I hope you don't :) )
