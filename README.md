<p align="center"><img src="blockheroes-logo.png"/></p>

# Block Heroes

Multiplayer Tetrix like game written in [Beef](https://www.beeflang.org/) lang with [Ariyana](https://github.com/kochol/ariyana) game engine

Join our [Discord](https://discord.gg/RmKWW45) channel

[![Discord](https://img.icons8.com/fluent/1x/discord-logo.png)](https://discord.gg/RmKWW45)
[![Game jolt](https://upload.wikimedia.org/wikipedia/en/thumb/c/c4/Game-jolt-logo.svg/200px-Game-jolt-logo.svg.png)](https://gamejolt.com/games/blockheroes/515039)
[![Twitter](https://cdn2.iconfinder.com/data/icons/social-media-2285/512/1_Twitter_colored_svg-64.png)](https://twitter.com/BlockHeroes)
[![Twitch](https://cdn2.iconfinder.com/data/icons/social-media-2285/512/1_Twitch_colored_svg-64.png)](https://www.twitch.tv/blockheroes)
[![Youtube](https://cdn2.iconfinder.com/data/icons/social-icon-3/512/social_style_3_youtube-64.png)](https://www.youtube.com/channel/UClMLFY20jWjCuZhvrhqLWew)

## Build from source

### Requirements

- **Python** (2.7.x or 3.x)
- **CMake** (3.6+)
- **A working C/C++ development environment**:
    - on **OSX**: Xcode + command line tools
    - on **Linux**: make/gcc (or clang)
    - on **Windows**: Visual Studio 2017 or better
- **Beef** Download the latest [nightly build](http://nightly.beeflang.org/BeefSetup.exe)

### Build for windows

```
mkdir ari
cd ari
git clone https://github.com/kochol/blockheroes.git
cd blockheroes
fips build
cd ..\ariyana\Beef\dist
make_cari.bat
```

Now you can open the blockheroes workspace with Beef IDE and run the game.

### Build server for linux

```
./BeefBuild_d -config=ServerDebug -run -workspace=/mnt/d/my/fips/block-heroes -verbosity=diagnostic
```