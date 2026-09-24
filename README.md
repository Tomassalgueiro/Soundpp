# Sound++

Music player written in C++ and using the Qt 6 Quick and MPD (`libmpdclient`).

## Features

- **MPD Integration**: Real-time playback status and timeline seeking.
- **Three Queue Modes**:
  - **In-Order**: Plays through a folder sequentially.
  - **Shuffle Current**: Shuffles all tracks within the current directory and auto-reshuffles upon queue completion.
  - **Shuffle Selected Folders**: Mixes multiple selected music genres/directories into a unified randomized queue.
- **Dynamic Cover Art**: Automatic embedded picture extraction and directory artwork lookup with fallback support.
- **Up Next Visualizer**: Previews upcoming songs queued in MPD.

## Prerequisites

- **CMake** (>= 3.16)
- **C++17** compatible compiler (GCC / Clang)
- **Qt 6** (Core, Gui, Quick, Qml, Network)
- **libmpdclient** 
- A running **MPD** instance (default: `127.0.0.1:6600`)

### Install Dependencies 

Ubuntu/Debian
```bash
sudo apt update
sudo apt install cmake g++ qt6-base-dev qt6-declarative-dev libmpdclient-dev pkg-config mpd
```

Fedora/RHEL
```bash
sudo dnf install cmake gcc-c++ qt6-qtbase-devel qt6-qtdeclarative-devel libmpdclient-devel mpd
```

Arch
```bash
sudo pacman -S cmake gcc qt6-base qt6-declarative libmpdclient pkgconf mpd
```

### Build the program and link it to your binaries

```bash
# build and compile the program
mkdir build
cd build
cmake ..
cmake --build .

# Ensure ~/.local/bin exists
mkdir -p ~/.local/bin

# Create a symlink to your compiled executable
ln -sf /home/guinhas/projects/music-player/build/Soundpp ~/.local/bin/soundpp

# Open the program
soudnpp 
```
### Create your mpd config

For this step you should check out mpd documentation, however my simple config just in case.
You should add it to ~/config/mpd/mpd.conf and start the mpd service to update the config file.
Save your songs at ~/Music, feel free to create folders to separte by genre/artist or whatever your sorting method is.

```conf
    music_directory    "$HOME/Music"
    playlist_directory "$HOME/.local/state/mpd/playlists"
    db_file            "$HOME/.local/state/mpd/mpd.db"
    log_file           "$HOME/.local/state/mpd/mpd.log"
    pid_file           "$HOME/.local/state/mpd/mpd.pid"
    state_file         "$HOME/.local/state/mpd/mpdstate"

    # Explicitly bind to local IPv4 loopback
    bind_to_address    "127.0.0.1"
    port               "6600"

    audio_output {
        type        "pipewire"
        name        "PipeWire Sound Server"
    }
```

### Custom config

You can customize this app by opening up the src/ui/ directory and modifying the Theme.qml file with the desired colors. After that you just need to recompile using the same commands as before and the changes will be made.  

### To-Do

- [ ] Volume Control 
- [ ] Add songs to queue manually
- [ ] Make customization easier
- [ ] Stop the audio after program is killed (mpd side)
- [ ] Create .desktop file (for launchers to be able to see the program)
