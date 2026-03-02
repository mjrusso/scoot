# Contributing to Scoot

First off, thank you for considering contributing to Scoot! It's people like you that make Scoot such a great tool.

## Getting Started

To get started with development, you'll need to have Xcode installed. Once you've cloned the repository, you can open the `Scoot.xcodeproj` file to get started.

### Code Signing and Accessibility

Scoot uses macOS's accessibility features to control the mouse and keyboard. To run the application locally, you will need to update the project's code signing settings to use your own developer certificate.

If you do not have a developer certificate, you can create one for free in Xcode. Please follow Apple's official documentation for instructions on how to manage signing certificates:

[https://help.apple.com/xcode/mac/current/#/dev154b28f09](https://help.apple.com/xcode/mac/current/#/dev154b28f09)

In Xcode, click on the project file from the project navigation window and select "Signing and Capabilites", change the "Signing Certificate" to "Development".

After setting up your code signing certificate, you may still need to grant accessibility permissions to your new build of Scoot. You can do this in **System Settings > Privacy & Security > Accessibility**.

An Indicator that accessibility is still not working after building the project is the scoot icon will turn red in your menu bar.

<p align="left">
    <img src="./Assets/Documentation/ScootAccessibilityDisabled.png" />
</p>

#### Accessbility FAQ
macOS won't grant accessibility permission, even though I'm adding via System Prefs...

To solve... make sure that all other Scoot app builds on the system were deleted (including debug builds); to be sure, right-click Scoot in the "Allow the apps below to control your computer" listing in Accessibility section of Privacy tab of Security & Privacy in System Preferences and then select "show in Finder" and then delete the app

Then uncheck and recheck Scoot.app from the Accessibility section in Security and Privacy on every recompile

If that doesn't work, then use tccutil to reset Accessibility permissions:

$ tccutil reset Accessibility com.mjrusso.Scoot
Successfully reset Accessibility approval status for com.mjrusso.Scoot
Successfully reset Accessibility approval status for com.mjrusso.Scoot
Also need to make sure that there's only a single Scoot app bundle installed on the system, including the one automatically build for SwiftUI previews

References:

https://apple.stackexchange.com/a/360610
https://stackoverflow.com/q/63917186
https://stackoverflow.com/a/70889502
https://stackoverflow.com/a/71111650/
https://stackoverflow.com/q/69058238

## Reporting Bugs

If you've found a bug, you can help us by submitting an issue to our GitHub Repository. Please be sure to include as much information as possible, including the version of Scoot you are using, the version of macOS you are on, and the steps to reproduce the bug.

## Submitting Pull Requests

If you have a fix for a bug or a new feature you'd like to contribute, we welcome pull requests!

## Manual Testing

Some features, especially those that involve interaction with other applications or the window manager, are difficult to test automatically. For these features, we rely on manual testing.

### Tiling Window Manager Compatibility

To test that Scoot's overlay windows are not being tiled by window managers like Aerospace, follow these steps:

1.  Install a tiling window manager, such as [Aerospace](https://github.com/nikitabobko/AeroSpace).
2.  Connect at least one external monitor to your Mac.
3.  Launch Scoot.
4.  Invoke the grid-based navigation mode.
5.  Verify that the grid overlay appears on all monitors and that the windows are not tiled or resized by the window manager.
