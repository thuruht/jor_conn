# Jor-Conn
Jor-Conn is a command-line tool for managing network connections and remote access on Debian-based systems. It is designed to be portable, configurable, and easy to use, especially for developers working behind corporate proxies.

## Key Features
- **Central Configuration**: All settings are managed in a single file: `/etc/jor-conn/config.conf`.
- **Flexible Network Profiles**: Easily add or modify Wi-Fi connections by creating simple text files in `/etc/jor-conn/networks/`.
- **Developer-Focused Proxy Support**: When a proxy is enabled, the tool automatically configures `apt` and provides clear instructions for tunneling `git` and `ssh` traffic.
- **Clean and Safe**: The tool prompts for root privileges only when necessary for system-wide changes.
- **Modular Code**: Common functions are stored in a shared library, making the code clean and easy to maintain.

## Installation

1.  **Build the Package**:
    Navigate to the `jor-conn` project directory and run the build script.
    ```bash
    ./build.sh
    ```
2.  **Install the Package**:
    The build script will generate a `.deb` file. Install it using `dpkg`.
    ```bash
    sudo dpkg -i jor-conn_*.deb
    ```

## Configuration
This is the most important step. After installing, you **must** edit the main configuration file to match your system and network. A shortcut is provided to make this easy:
```bash
sudo jor_conn edit-config
```
You will need to set your network interface, VNC server addresses, DuckDNS token, and proxy server address. The file is commented to guide you.

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