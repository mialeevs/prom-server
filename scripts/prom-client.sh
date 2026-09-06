#!/bin/bash


# Variables
NODE_EXPORTER_VERSION=v1.12.1
NODE_EXPORTER_AMD64=node_exporter-1.12.1.linux-amd64
NODE_EXPORTER_ARM64=node_exporter-1.12.1.linux-arm64
UBUNTU_MAN_VERSION=noble

clear -x


# Install node_exporter
echo
printf "\n\033[7;32mSTARTING PROMETHEUS NODE_EXPORTER %s INSTALLATION IN 3 SECONDS! \033[0m" "$NODE_EXPORTER_VERSION"
echo;sleep 3;echo
mkdir temp 
cd temp || exit 1

### Determine CPU architecture using 'uname -m'
arch=$(uname -m)

## Download, extract, and copy Prometheus Node Exporter files
### if statement to install corresponding package based on architecture determination
if [ "$arch" == "x86_64" ]; then
    echo "Installing package for x86_64 architecture..."
    # Replace "package_name_x86_64" with the actual package name for x86_64
    wget https://github.com/prometheus/node_exporter/releases/download/$NODE_EXPORTER_VERSION/$NODE_EXPORTER_AMD64.tar.gz
    tar -xvf $NODE_EXPORTER_AMD64.tar.gz
    cp ./$NODE_EXPORTER_AMD64/node_exporter /usr/local/bin
elif [ "$arch" == "aarch64" ]; then
    echo "Installing package for ARM64 architecture..."
    # Replace "package_name_arm64" with the actual package name for ARM64
    wget https://github.com/prometheus/node_exporter/releases/download/$NODE_EXPORTER_VERSION/$NODE_EXPORTER_ARM64.tar.gz
    tar -xvf $NODE_EXPORTER_ARM64.tar.gz
    cp ./$NODE_EXPORTER_ARM64/node_exporter /usr/local/bin
else
    echo "Unsupported architecture: $arch"
    printf "Go to https://prometheus.io/download/ to download other binaries."
    printf '%.0s\n' {1..2}
    exit 1
fi

# Build node_exporter service
useradd -rs /bin/false node_exporter
cat << "EOF" > "/lib/systemd/system/node_exporter.service"
[Unit]
Description=Node Exporter 
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start node_exporter service
systemctl daemon-reload
systemctl --now enable node_exporter

# Install man page - From Ubuntu
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/prometheus-node-exporter.1.gz
cp prometheus-node-exporter.1.gz /usr/share/man/man1

# Clean UP!
cd .. || exit 1
rm -rf temp/
sleep 2

# Completion messages
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! NODE_EXPORTER SHOULD NOW BE RUNNING AS A SERVICE AND LISTENING ON PORT 9100.\033[0m"
printf '%.0s\n' {1..2}
echo -e "Note: To analyze this system from your main Prometheus server, \nadd this system's IP address and port 9100 in prometheus.yml > scrape_configs > targets. \nFor example: '- targets: ['<ip_address>:9100']'"
printf '%.0s\n' {1..2}
printf "\n\033[7;36m ENJOY! \033[0m"

printf '%.0s\n' {1..2}
