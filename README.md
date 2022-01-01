# Scoot

_Meet **Scoot**, your friendly cursor teleportation and actuation tool._

<img src="https://github.com/mjrusso/scoot/actions/workflows/main_test.yml/badge.svg" alt="build status"></a>

<a href="https://twitter.com/mjrusso" title="@mjrusso on Twitter"><img src="https://img.shields.io/badge/twitter-@mjrusso-blue.svg" alt="@mjrusso on Twitter"></a>

<p align="center">
  <img src="./Assets/card.png" alt="Scoot, MacOS Cursor Actuator" />
</p>

---

<img align="right" width="128" alt="Scoot App Icon" src="./Scoot/Assets.xcassets/AppIcon.appiconset/512.png" />

Scoot is a tiny utility app that provides fast, keyboard-driven control over the mouse pointer. Scoot lets you move your mouse—and click and drag, too—all from the comfort of your keyboard!

---

## About

* Scoot is experimental. Is it possible to craft a keyboard-driven mouse movement utility that's _actually_ efficient? Something that you'll actually _want_ to use? This is going to take some trial and error.

* Scoot is in the early proof of concept + prototyping stage.

* Scoot runs on MacOS, versions 10.15 (Catalina), 11 (Big Sur), and 12 (Monterey).

* Scoot is an AppKit app, written in Swift. (There's still [some][carbon-events] [Carbon][carbon-accessibility] in here, too!)

* Scoot complements mouse-related accessibility tools that ship as part of MacOS, such as [Mouse Keys][mouse-keys] and other [accessibility shortcuts][mac-accessibility-shortcuts].

## Usage

Scoot supports two navigation modes: **element-based**, and **grid-based**.

* **Element-based navigation:** MacOS accessibility APIs are used to find user interface elements, such as buttons and links, on the user's screen. (In this mode, Scoot will look for elements in the focused window of the frontmost app.)
* **Grid-based navigation:** all connected screens are subdivided into aa grid of equally-sized cells.

Each location is identified by a unique character sequence, making each element (or cell) uniquely addressable with the keyboard.

To activate Scoot in element-based navigation mode, use the ⇧⌘J global keyboard shortcut.

To activate Scoot in grid-based navigation mode, use the ⇧⌘K global keyboard shortcut.

(As long as Scoot is running, either hotkey will bring the app to the foreground, and activate the requested navigation mode.)

When Scoot is in the foreground:

* You can jump directly to a cell (a UI element, or a location in the grid, depending on the active navigation mode). Each cell is marked with a label (e.g. “aaa”, “aas”, “aad”); type the characters, one letter at a time, and, as soon as a complete sequence is entered, the mouse cursor will move directly to the center of the corresponding cell. (This approach, including the use of a char-based decision tree, is heavily inspired by [avy][avy].)
  * If you make a mistake while entering a label, hit the escape key (⎋) to cancel and start over. (Alternatively, you can type ⌘. or C-G.)

* You can _also_ move the cursor via the standard Mac keyboard shortcuts for [moving the insertion point][mac-keyboard-shortcuts-text]. (This means that keyboard shortcuts intended for navigating around in a document have been re-purposed to control movement on a 2-dimensional grid. Some liberties have been taken with this mapping; hopefully you find these keybindings intuitive.)
    * The equivalent standard Emacs keybindings should also work out-of-the-box, if you have them configured system-wide (for example, via [Karabiner-Elements][karabiner-elements] [[complex modification][karabiner-elements-emacs-mod]], or by augmenting the [system defaults][emacs-keyboard-shortcuts-osx] [[DefaultKeyBinding.dict][defaultkeybinding.dict], [Cocoa Text System][cocoa-text-system], [Text System Defaults and Key Bindings][apple-dev-text-system]]).

* You can click with the left mouse button (at the current cursor location) by hitting the Return (↵) key.

* You can hold the left mouse button down by hitting ⌘↵. (To release the button, type ⌘↵ again, or, alternatively, just press ↵ on its own.)
  * To perform a drag-and-drop operation: situate the cursor above the object you want to drag and press ⌘↵, then move the mouse cursor to the desired drag destination (using one or more of the mechanisms that Scoot makes available), and then press ⌘↵ again to perform the drop.

* You can double-click with the left mouse button (at the current cursor location) by hitting the Shift and Return keys together (⇧↵).

* You can scroll, by pressing the Shift key in conjunction with the arrow key (↑, ↓, ←, →) pointing in the desired scroll direction.

After clicking, the grid will automatically hide. You can also hide the grid at any time by pressing ⌘H.

### Keybindings

_Not sure what these symbols mean? See the [symbol reference][what-are-those-mac-symbols], and [Emacs key notation][emacs-key-notation]._


| Shortcut  | Emacs | Description                                                                                                       |
|-----------|-------|-------------------------------------------------------------------------------------------------------------------|
| ⇧⌘J       |       | Use element-based navigation (bring Scoot to foreground)                                                          |
| ⇧⌘K       |       | Use grid-based navigation (bring Scoot to foreground)                                                             |
| ⌘H        |       | Hide UI (bring Scoot to background)                                                                               |
| ⎋ (or ⌘.) | C-g   | Cancel: if currently typing a label, clears all currently-typed characters; otherwise, brings Scoot to background |

_Note:_ ⎋ signifies the Escape key.

#### Cursor Movement

| System | Emacs | Description                                                 |
|--------|-------|-------------------------------------------------------------|
| ↑      | C-p   | Move cursor up (partial step)                               |
| ↓      | C-n   | Move cursor down (partial step)                             |
| ←      | C-b   | Move cursor left (partial step)                             |
| →      | C-f   | Move cursor right (partial step)                            |
| ⌥↑     | M-a   | Move cursor up (full step)                                  |
| ⌥↓     | M-e   | Move cursor down (full step)                                |
| ⌥←     | M-b   | Move cursor left (full step)                                |
| ⌥→     | M-f   | Move cursor right (full step)                               |
| ⌘↑     | M-<   | Move cursor to top edge of screen                           |
| ⌘↓     | M->   | Move cursor to bottom edge of screen                        |
| ⌘←     | C-a   | Move cursor to left edge of screen                          |
| ⌘→     | C-e   | Move cursor to right edge of screen                         |
| ⌃L     | C-l   | Move cursor to center, and (on repeat) cycle around corners |

#### Clicking

| Shortcut | Description                                                                 |
|----------|-----------------------------------------------------------------------------|
| ↵        | Click left mouse button (at current cursor location)                        |
| ⌘↵       | Press and hold left mouse button (once activated, type ⌘↵ again to release) |
| ⇧↵       | Double-click left mouse button (at current cursor location) |

_Note:_ ↵ signifies the Return (a.k.a Enter) key. (Technically, Return and Enter are [two different keys][return-and-enter-are-two-different-keys].)

#### Scrolling

| System | Alt | Description                              |
|--------|-----|------------------------------------------|
| ⇧↑     | ⇧-p | Scroll up (at current cursor location) |
| ⇧↓     | ⇧-n | Scroll down (at current cursor location) |
| ⇧←     | ⇧-b | Scroll left (at current cursor location) |
| ⇧→     | ⇧-f | Scroll right (at current cursor location) |

#### Presentation

| Shortcut | Description                                |
|----------|--------------------------------------------|
| ⌃=       | Toggle visibility of grid lines            |
| ⌃⇧=      | Toggle visibility of grid labels           |
| ⇧⌘=      | Increase size of grid cells                |
| ⇧⌘-      | Decrease size of grid cells                |
| ⌘=       | Increase contrast of user interface |
| ⌘-       | Decrease contrast of user interface |

## Installation

To install Scoot:

1. Download and extract the latest build of [Scoot][latest-scoot-binary].
2. Drag the extracted _Scoot.app_ into your computer's _Applications_ folder.
3. Double-click on _Scoot.app_ (from the _Applications_ folder) to launch it.

On first run, you'll be presented with a prompt like the following:

<p align="center">
  <img width="450" src="./Assets/Documentation/accessibility-prompt.png" alt="Scoot.app would like to control this computer using accessibility features" />
</p>

**Scoot will not work unless access is granted.**

To grant this permission, click _“Open System Preferences”_. Next, click the lock in the bottom left corner (_“Click the lock to make changes”_).

<p align="center">
  <img width="550" src="./Assets/Documentation/privacy-locked.png" alt="Locked accessibility settings" />
</p>

Finally, check _“Scoot.app”_ to give Scoot the ability to move your cursor, and to click, drag, and scroll.

<p align="center">
  <img width="550" src="./Assets/Documentation/accessibility-access-granted.png" alt="Scoot.app granted accessibility access" />
</p>

See the [usage documentation](#usage) for details on how to use Scoot.

If you're finding Scoot helpful, you may want to configure the app to launch automatically when you log in. To set this up, open System Preferences again, click _“Users & Groups”_, and then _“Login Items”_:

<p align="center">
  <img width="550" src="./Assets/Documentation/login-items-locked.png" alt="Locked login items settings" />
</p>

As before, you'll need to click the lock in the bottom left corner to unlock this preference pane. Once unlocked, click the “+” button, and select _“Scoot.app”_ from the _Applications_ folder. Checking the _“Hide”_ checkbox is recommended.

<p align="center">
  <img width="550" src="./Assets/Documentation/start-automatically.png" alt="Scoot configured to start automatically" />
</p>

If you encounter any problems, feel free to [file an issue][scoot-issues].

## Demos

### Drag and Drop

Here's what it's like to drag and drop with Scoot:

https://user-images.githubusercontent.com/100451/118299332-9e6a2e00-b4ae-11eb-901d-79a212ce1d37.mp4

For reference, the following key sequence was used to grab the file and drop it in a new location:

- `⇧⌘J` to activate Scoot
- `kh` to jump cursor to cell
- `⌘↵` to press and hold the left mouse button
- `fd` to jump cursor to cell
- `↵` to release the left mouse button

### Move and Click

An example of using Scoot to control an app running in the iOS simulator:

https://user-images.githubusercontent.com/100451/118299409-b772df00-b4ae-11eb-93ae-3cc67e3ce2b8.mp4

## Feature Backlog

- Improve legibility of grid labels, particularly when rendering on top of light backgrounds with dark text.
  - Is there a (performant) way to modify the colours of the grid based on the content immediately underneath it?
- Ability to simulate gestures, such as swipe, pinch, spread, and rotation.
- Ability to record, save, and run macros.
- Enable global keyboard shortcuts to be overridden.
- Enable non-global keyboard shortcuts to customized.
- Enable grid colours, opacity, etc. to be customized.
- CI ([example](https://betterprogramming.pub/indie-mac-app-devops-with-github-actions-b16764a3ebe7)).

## License

Scoot is released under the terms of the [BSD 3-Clause License](LICENSE).

Copyright (c) 2021, [Michael Russo](https://mjrusso.com).


[latest-scoot-binary]: https://github.com/mjrusso/scoot/releases/latest/download/Scoot.app.zip
[latest-scoot-release]: https://github.com/mjrusso/scoot/releases/latest
[scoot-issues]: https://github.com/mjrusso/scoot/issues

[carbon-events]: https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/Carbon_Event_Manager/Intro/CarbonEventsIntro.html
[carbon-accessibility]: https://developer.apple.com/documentation/applicationservices/carbon_accessibility
[avy]: https://github.com/abo-abo/avy
[mouse-keys]: https://support.apple.com/en-ca/guide/mac-help/mh27469/mac
[mac-accessibility-shortcuts]: https://support.apple.com/en-ca/HT204434
[mac-keyboard-shortcuts]: https://support.apple.com/en-ca/HT201236
[mac-keyboard-shortcuts-text]: https://support.apple.com/en-ca/HT201236#text
[what-are-those-mac-symbols]: https://support.apple.com/en-ca/guide/mac-help/cpmh0011/mac
[emacs-key-notation]: https://www.emacswiki.org/emacs/EmacsKeyNotation
[karabiner-elements]: https://karabiner-elements.pqrs.org
[karabiner-elements-emacs-mod]: https://ke-complex-modifications.pqrs.org/#emacs_key_bindings
[emacs-keyboard-shortcuts-osx]: https://jblevins.org/log/kbd
[defaultkeybinding.dict]: https://github.com/nileshk/mac-configuration/blob/99eef47cd434fd3d6f4f1f9e2f50321f32179b88/Library/KeyBindings/DefaultKeyBinding.dict
[cocoa-text-system]: https://www.hcs.harvard.edu/~jrus/site/cocoa-text.html
[apple-dev-text-system]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html
[return-and-enter-are-two-different-keys]: https://daringfireball.net/2020/07/return_and_enter
