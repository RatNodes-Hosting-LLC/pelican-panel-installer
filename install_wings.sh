#!/bin/bash

# Function to print messages in green
print_success() {
    echo -e "\e[32m$1\e[0m"
}

# Function to print messages in red
print_error() {
    echo -e "\e[31m$1\e[0m"
}

# Check if whiptail is installed, if not install it
if ! command -v whiptail &> /dev/null; then
    print_error "whiptail is not installed. Installing..."
    sudo apt-get update && sudo apt-get install -y whiptail
    if [ $? -ne 0 ]; then
        print_error "Failed to install whiptail."
        exit 1
    else
        print_success "whiptail installed successfully."
    fi
fi

# Prompt for the domain to secure with SSL
DOMAIN=$(whiptail --inputbox "Enter the domain to secure with SSL:" 8 39 --title "SSL Certificate" 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    print_error "Domain entry cancelled."
    exit 1
fi

# Prompt for the Wings configuration code
WINGS_CONFIG=$(whiptail --inputbox "Enter the Wings configuration code (you can copy it from the Panel administrative view):" 15 60 --title "Wings Configuration" 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    print_error "Wings configuration entry cancelled."
    exit 1
fi

# Function to install Docker
install_docker() {
    if ! command -v docker &> /dev/null; then
        print_success "Installing Docker..."
        curl -sSL https://get.docker.com/ | CHANNEL=stable sh
        if [ $? -ne 0 ]; then
            print_error "Failed to install Docker."
            exit 1
        else
            print_success "Docker installed successfully."
        fi
    else
        print_success "Docker is already installed."
    fi
}

# Function to install Docker Compose
install_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_success "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        if [ $? -ne 0 ]; then
            print_error "Failed to install Docker Compose."
            exit 1
        else
            print_success "Docker Compose installed successfully."
        fi
    else
        print_success "Docker Compose is already installed."
    fi
}

# Function to create directories and download Wings
install_wings() {
    if [ ! -f /usr/local/bin/wings ]; then
        print_success "Creating directories and downloading Wings..."
        sudo mkdir -p /etc/pelican
        curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
        sudo chmod u+x /usr/local/bin/wings
        if [ $? -ne 0 ]; then
            print_error "Failed to create directories and download Wings."
            exit 1
        else
            print_success "Directories created and Wings downloaded successfully."
        fi
    else
        print_success "Wings is already installed."
    fi
}

# Function to configure Wings
configure_wings() {
    if [ ! -f /etc/pelican/config.yml ]; then
        print_success "Configuring Wings..."
        echo "$WINGS_CONFIG" | sudo tee /etc/pelican/config.yml > /dev/null
        if [ $? -ne 0 ]; then
            print_error "Failed to configure Wings."
            exit 1
        else
            print_success "Wings configured successfully."
        fi
    else
        print_success "Wings is already configured."
    fi
}

# Function to daemonize Wings using systemd
daemonize_wings() {
    if [ ! -f /etc/systemd/system/wings.service ]; then
        print_success "Daemonizing Wings..."
        cat <<EOL | sudo tee /etc/systemd/system/wings.service
[Unit]
Description=Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pelican
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL

        sudo systemctl enable wings
        sudo systemctl start wings
        if [ $? -ne 0 ]; then
            print_error "Failed to daemonize Wings."
            exit 1
        else
            print_success "Wings daemonized successfully."
        fi
    else
        print_success "Wings is already daemonized."
        sudo systemctl restart wings
        if [ $? -ne 0 ]; then
            print_error "Failed to restart Wings."
            exit 1
        else
            print_success "Wings restarted successfully."
        fi
    fi
}

# Function to install Certbot
install_certbot() {
    if ! command -v certbot &> /dev/null; then
        print_success "Installing Certbot..."
        sudo apt-get update && sudo apt-get install -y certbot
        if [ $? -ne 0 ]; then
            print_error "Failed to install Certbot."
            exit 1
        else
            print_success "Certbot installed successfully."
        fi
    else
        print_success "Certbot is already installed."
    fi
}

# Function to obtain SSL certificate
obtain_ssl_certificate() {
    print_success "Obtaining SSL certificate for $DOMAIN..."
    sudo certbot certonly --standalone -d "$DOMAIN"
    if [ $? -ne 0 ]; then
        print_error "Failed to obtain SSL certificate for $DOMAIN."
        exit 1
    else
        print_success "SSL certificate obtained successfully for $DOMAIN."
    fi
}

# Main script execution
install_docker
install_docker_compose
install_wings
configure_wings
daemonize_wings
install_certbot
obtain_ssl_certificate

# Delete the installer script
rm -- "$0"

print_success "Wings installation, configuration, and SSL setup completed successfully!"
