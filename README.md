# Unofficial Pelican Panel Installer Beta 0.0.1
A shell script to install Pelican Panel on a VPS or Virtual Machine. (Still in development but working) 🚧

#### Pelican Panel is the successor to Pterodactyl Game Panel. Used for hosting game servers in your home network or online.  

Pelican Panel can be found at https://pelican.dev/ and the GitHub repo is [HERE](https://github.com/pelican-dev/panel)

Follow the install scripts below **in order**.  

- Install Pelican and Wings on seperate servers or Virtual Machines.  
- Run `webserver_config_nginx.sh` on the **Pelican server** to set up nginx.

### Requirements:   
- 🐧 Ubuntu 24.04 (Recommended) ✅  
- 💻 VPS or Virtual Machine ✅  
- 🌐 IP Address ✅  
- 🔒 SSL SUPPORT ❌  

## Usage  

**Only IP Addresses are supported at the moment because another script will need to be used for SSL creation**

Download and run the installer to your VM or VPS. The installer will ask you some questions.

### Download and set executable
```shell
wget https://raw.githubusercontent.com/dazeb/pelican-installer/main/install_pelican.sh
chmod +x install_pelican.sh
```

### Run the script
```shell
./install_pelican.sh
```

### What the script installs:
- 📦 Adds the `ondrej/php` repository.
- 📥 Installs dependencies including:
  - PHP 8.2 and required PHP extensions (`gd`, `mysql`, `mbstring`, `bcmath`, `xml`, `curl`, `zip`, `intl`, `sqlite3`, `fpm`).
  - MySQL server.
  - `curl`, `tar`, and `composer`.
  - NGINX or Apache webserver (based on user selection).
  - Redis server.
- 📂 Creates necessary directories and downloads the Pelican Panel files.
- 🛠 Installs composer dependencies.
- ⚙️ Configures the environment using artisan commands.
- ✉️ Sets up mail configuration (optional).
- 🗄 Initializes the database.
- 👤 Creates an admin user (optional).
- ⏲ Configures crontab for scheduled tasks.
- 🔒 Sets appropriate file permissions.
- 🌐 Configures NGINX (if selected as the webserver).
- 🐬 Installs MariaDB and sets up MySQL user and database.
- 🔄 Configures Redis queue worker.

You can run the script more than once. For instance, if you want to create a new admin user after forgetting to create one initially, you can run the script again without negative consequences.  

## Run Webserver Config (nginx support)  

### Download and set executable
```shell
wget https://raw.githubusercontent.com/dazeb/pelican-installer/main/webserver_config_nginx.sh
chmod +x webserver_config_nginx.sh
```

### Run the config script
```shell
./webserver_config_nginx.sh
```

### What the script does:
- 🌐 Prompts the user to enter their domain or IP address.
- 🗑 Removes the default NGINX configuration.
- 📝 Creates a new NGINX configuration file for the Pelican Panel.
- 🔗 Enables the new NGINX configuration by creating a symbolic link.
- 🔄 Restarts NGINX to apply the new configuration.

# Wings Installer  

### Requirements:   
- 🐧 Ubuntu 24.04 (Recommended) ✅  
- 💻 VPS, Virtual Machine, LXC with nesting enabled ✅  
- 🌐 IP Address ✅  
- 🔒 SSL SUPPORT ❌  

Same as before, download and run the script.  

### Download and set executable then run the script
```shell
wget https://raw.githubusercontent.com/RatNodes-Hosting-LLC/pelican-panel-installer/main/install_wings.sh
chmod +x install_wings.sh
./install_wings.sh
```

### What the script does:
- 🐳 Checks and installs Docker if not already installed.
- 🐙 Checks and installs Docker Compose if not already installed.
- 📂 Creates necessary directories and downloads the Wings executable.
- ⚙️ Configures Wings by prompting the user to paste the configuration from the Pelican host.
- 🐞 Starts Wings in debug mode to ensure it runs without errors.
- 👻 Daemonizes Wings using systemd to run it as a background service.

The script will ask you to copy the configuration from your Pelican host. Paste the config in the file and press `ctrl+x`, then `y`, then `enter` and the script will proceed.

Go into your admin panel, add the node, and create the server.

### Updating Wings
To update Wings, simply run the `install_wings.sh` script again. The script will check for the latest version of Wings and update it if necessary.

```shell
./install_wings.sh
```

(To be completed)
