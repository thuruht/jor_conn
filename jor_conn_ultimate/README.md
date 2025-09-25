# Jor Connector ULTIMATE Edition (Refactored)

This is a complete overhaul of the original Jor Connector, rebuilt from the ground up to be portable, configurable, and easy to maintain. It's a powerful command-line tool for managing network connections and remote access on Debian-based systems.

## Key Features
- **Central Configuration**: All settings are managed in a single file: `/etc/jor-conn/config.conf`. No more hardcoded values.
- **Flexible Network Profiles**: Add, remove, or modify network connections by simply creating text files in `/etc/jor-conn/networks/`.
- **Safe and Clean**: All `sudo` calls inside the scripts have been removed. The tool now prompts for root privileges only when needed.
- **Modular Code**: Common functions are stored in a shared library, making the code clean and easy to update.
- **All the Fun Stuff**: Still includes the original ASCII art, progress bars, and Easter eggs!

## Installation

1.  **Build the Package**:
    ```bash
    cd jor_conn_ultimate
    ./create_ultimate_package.sh
    ```

2.  **Install the Package**:
    ```bash
    sudo dpkg -i jor-conn-ultimate.deb
    ```

## Configuration

This is the most important step! After installing, you **must** edit the main configuration file to match your system and network.

```bash
# Open the config file for editing
sudo jor_conn edit-config
```

You will need to set your network interface, VNC server addresses, DuckDNS token, and more. The file is heavily commented to guide you.

## How to Use

### Network Profiles

The core of this tool is the network profile system. Profiles are simple text files located in `/etc/jor-conn/networks/`. Two examples (`noproxy` and `proxy`) are created automatically on installation.

You can create a new profile for any Wi-Fi network. For example, to create a profile for a network named "MyHomeWiFi":

1.  Create a new file: `sudo nano /etc/jor-conn/networks/home`
2.  Add the following content, adjusting the SSID and PSK:
    ```ini
    # Profile for home network
    WPA_CONFIG_CONTENT="""
    network={
        ssid=\\"MyHomeWiFi\\"
        psk=\\"MyPassword123\\"
    }
    """
    APPLY_PROXY="false"
    ```

### Available Commands

- `sudo jor_conn connect <profile_name>`: Connect to a network using a specific profile.
- `jor_conn status`: Display a full status of your network, proxy, and server connections.
- `jor_conn remote-vnc`: Launch a smart VNC connection that auto-detects if the server is local or remote.
- `sudo jor_conn edit-config`: A shortcut to open the main configuration file for editing.
- `jor-duckdns-update`: Manually trigger an update for your DuckDNS domain.
- `jor-troubleshoot`: Run a series of diagnostic checks.

This refactored version is designed to be a solid foundation that you can easily build upon. Enjoy!
