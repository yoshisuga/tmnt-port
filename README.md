# Teenage Mutant Ninja Turtles — port

Konami's 1989 arcade game *Teenage Mutant Ninja Turtles* as a native game for computers, the Nintendo Switch,
Android and Anbernic's handhelds, built on its decompilation,
[tmntarcade-decomp](https://github.com/cheviman/tmntarcade-decomp): the game's programs in C, checked frame by
frame against MAME in state, picture and sound. Two games come out of it:

- **TMNT Arcade**: the arcade game as it is: coins, the test mode, four players.
- **TMNT**: the console version, the arcade game made for playing at home.

This repository contains no game data: you bring your own ROM set (MAME's `tmnt`, World 4 Players), and the game
takes its assets out of it.

<p align="center">
  <img src="docs/screenshots/console_title_menu.png" width="32%" alt="TMNT's menu under the title, in 16:9: ARCADE, SPLINTER WAY, MULTIPLAYER, OPTIONS, EXIT">
  <img src="docs/screenshots/console_four_turtles_wide.png" width="32%" alt="Four players on the street in 16:9, the Foot coming in from the right">
  <img src="docs/screenshots/console_options.png" width="32%" alt="OPTIONS: controls, difficulty, lives, demo sound, region, video, volume, sound test">
  <br>
  <img src="docs/screenshots/burning_apartment.png" width="25%" alt="Four turtles in April's burning apartment">
  <img src="docs/screenshots/shredder_takes_april.png" width="25%" alt="Shredder carries April off">
  <img src="docs/screenshots/krang.png" width="25%" alt="Krang's android body">
</p>

## Playing it

Download the package for Windows, Linux or macOS from the
[releases](https://github.com/cheviman/tmnt-port/releases). Keep `tmnt.zip` beside the game, or drop it on its
window when it asks: the first time, it takes the assets out of it.

The package also has the tools that make the game for your devices, with your ROM set:

- **Nintendo Switch**: TMNT NSP makes `TMNT.nsp` and `TMNT Arcade.nsp`, for a console with Atmosphere.
- **Android**: TMNT APK makes `TMNT.apk` and `TMNT Arcade.apk`, signed with a key of yours
  ([ports/android/apk](ports/android/apk/README.md)): phones, tablets, and TVs with Android TV or Google TV (the
  Chromecast with Google TV too: its Android is 32-bit, and the APKs have both kinds), in the TV's apps with a
  banner.
- **iOS** (an iPhone or iPad, or the simulator): built from source with Xcode, with your ROM set's assets pack
  inside the app ([ports/ios](ports/ios/README.md)); SDL2 is patched for the UIScene lifecycle, which
  apps linked against the iOS 27 SDK need.
- **Anbernic's H700 handhelds** (RG40XX H...): TMNT Anbernic makes the folder for PORTS.

What a tool makes has the game's data in it: it is yours alone, never share it. The package's `README.txt` has
what each tool needs.

## The console version

- **ARCADE**: the arcade's game with no coins: START brings a player in at any time, up to four, and on a
  continue lets him pick his turtle again.
- **SPLINTER WAY**: NORMAL (5 lives and 3 continues), BOSS RUSH (from one boss to the next) and RONIN (one turtle
  against the enemies of a four-player game).
- **MULTIPLAYER**: up to four computers on the local network in one game (below).
- **OPTIONS**: controls for four players, difficulty, lives, demo sound, region (the NINJA or HERO title), video
  (window, full screen, sharp, smooth, bilinear or CRT pixels, WIDE 16:10, 16:9 or 20:9, VSYNC, FPS), volume, sound test.
- **The pause** in a game: CONTINUE, RESTART, QUIT GAME.
- And the Konami code on the menu.

## Controls

- **Keyboard**: the arrows move, Z or left Ctrl attacks, X or left Alt jumps, Enter is START; Escape pauses (and
  goes back in the menus). F11 or Alt+Enter is the full screen, F3 the next kind of pixels. OPTIONS > CONTROLS
  changes each player's keys and buttons.
- **Game controller**: the pad or the left stick moves, A attacks, B jumps, Start is START; Back or Start pauses.
  Each controller is a player, in the order they are plugged in (a TV's remote after them).
- **TMNT Arcade**: 5 to 8 put a coin in each slot (a controller's Back, its player's), 9 is the service switch,
  and a coin and the attack bring a turtle in.
- **Android**: a stick where your left thumb lands, ATTACK and JUMP at the right, START (COIN in TMNT Arcade);
  a controller hides them. Back pauses.
- **A TV's remote** (Google TV, Android TV), in TMNT: the pad moves, OK attacks (and brings in a player who is not
  playing, or continues), back jumps (and goes back in the menus); home pauses. A game controller is better.

## MULTIPLAYER

Up to four computers play one game on the same local network, a turtle each:

1. MULTIPLAYER > NAME: your name, as the rooms show it.
2. One computer picks HOST.
3. The others pick JOIN, and the room.
4. The host's START begins the game on all of them, with the host's settings.

A computer that stops being heard leaves after 3 seconds, its turtle standing, and the game goes on. A firewall
that asks about the game should let it reach the private network. The rooms and the game's datagrams are
[arcade-lan](https://github.com/cheviman/arcade-lan)'s, which the ports of other decompiled arcade games share.

## Building it

Python 3.10 or newer, CMake 3.20 or newer, a C11 / C++17 compiler and SDL2 2.30 or newer (on Windows its
development package for Visual C++ unpacked in `build/downloads/sdl2/`; elsewhere the system's, `libsdl2-dev` on
Debian and Ubuntu; or `-DTMNT_STATIC_SDL2=ON` to build it from its source). Clone it with its submodules and build
it:

```bash
git clone --recursive https://github.com/cheviman/tmnt-port
```

```bash
cmake -S . -B build/cmake
```

```bash
cmake --build build/cmake --config Release
```

Both games land in `build/bin/`, and take their assets out of `tmnt.zip` the first time (beside them, or in
`rom/`). How the port runs the game, its first run, the packages and the console version's checks are in
[docs/port.md](docs/port.md); each device's build in `ports/PLAN.md`; the console version's plan and what is done
in `console/PLAN.md`. The decompilation itself (its status, the tools, the assets' formats, the checks against
MAME) is [tmntarcade-decomp](https://github.com/cheviman/tmntarcade-decomp)'s README.

## Legal

- This project is licensed under the BSD 3-Clause License; see `LICENSE`.
- The C in `src/` is the game's programs decompiled into a new form: logic only, with names and comments written
  for this project. No ROM contents (graphics, sound, data) and no extracted assets are distributed by this
  project; they come from your own ROM set. The screenshots in `docs/screenshots/` show the game running from this
  code.
- `runtime/src/video.c`, `sound_chips.c` and `ym2151.c` follow the behaviour of MAME's `tmnt.cpp`, `k052109.cpp`,
  `k051960.cpp`, `k007232.cpp` and `upd7759.cpp` and of ymfm's OPM (all BSD-3-Clause).
- MULTIPLAYER's rooms and datagrams are [arcade-lan](https://github.com/cheviman/arcade-lan) (`lan/`, a submodule),
  BSD 3-Clause, whose terms are in `lan/LICENSE`.
- The game controllers' mappings are [SDL_GameControllerDB](https://github.com/mdqinc/SDL_GameControllerDB)'s
  (`ports/sdl2/controllerdb`, zlib License), built into the games on the computers and Android.
- The menus write with Kenney Mini and CONTROLS shows Kenney's Input Prompts (www.kenney.nl), CC0. The window
  port links SDL2 (zlib License); the packages carry it inside the executables, with its terms and the ones above
  in `licenses/`. The icon is Raphael's face from a friend's mural (`ports/sdl2/icon/raphael_mural.png`; every
  size made by `tools/make_icon.py`), nothing of the game's.
- *Teenage Mutant Ninja Turtles* is a trademark of its owner, and the arcade game is Konami's. This project is not
  affiliated with or endorsed by either, nor by Nintendo, Google or Anbernic.
