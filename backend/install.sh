#!/bin/bash

if ! [[ "8 9 10 11 12" == *"$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2 | cut -d '.' -f 1)"* ]];
then
    echo "Debian $(grep VERSION_ID /etc/os-release | cut -d '"' -f 2 | cut -d '.' -f 1) is not currently supported.";
    exit;
fi

# Download the package to configure the Microsoft repo
curl -sSL -O https://packages.microsoft.com/config/debian/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2 | cut -d '.' -f 1)/packages-microsoft-prod.deb
# Install the package
dpkg -i packages-microsoft-prod.deb
# Delete the file
rm packages-microsoft-prod.deb

apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql17
# optional: for bcp and sqlcmd
ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
# optional: for unixODBC development headers
apt-get install -y unixodbc-dev
# optional: kerberos library for debian-slim distributions
apt-get install -y libgssapi-krb5-2