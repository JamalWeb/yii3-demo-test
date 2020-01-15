#!/usr/bin/env bash

source /app/vagrant/provision/common.sh

#== Import script args ==

timezone=$(echo "$1")

#== Provision script ==

info "Provision-script user: `whoami`"

export DEBIAN_FRONTEND=noninteractive

info "Configure timezone"
timedatectl set-timezone ${timezone} --no-ask-password

info "Configure locales"
apt-get install -y locales
localedef ru_RU.UTF-8 -i ru_RU -f UTF-8

info "Add PHP 7.4 repository"
add-apt-repository ppa:ondrej/php -y

info "Update OS software"
apt-get update
apt-get upgrade -y

info "Install additional software"
apt-get install -y php7.4-curl php7.4-cli php7.4-intl php7.4-gd php7.4-fpm php7.4-mbstring php7.4-xml php7.4-zip php7.4-pgsql php.xdebug unzip nginx
apt-get install -y postgresql-10 postgresql-contrib-10

info "Configure PHP-FPM"
sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's/owner = www-data/owner = vagrant/g' /etc/php/7.4/fpm/pool.d/www.conf
echo "Done!"

info "Configure PostgreSQL"
sudo -u postgres psql -c "CREATE USER vagrant WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD 'vagrant'"
sudo -u postgres psql -c "CREATE DATABASE demo"
sudo /etc/init.d/postgresql restart
echo "Done!"

cat << EOF > /etc/php/7.4/mods-available/xdebug.ini
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_autostart=1
EOF
echo "Done!"

info "Configure NGINX"
sed -i 's/user www-data/user vagrant/g' /etc/nginx/nginx.conf
echo "Done!"

info "Enabling site configuration"
ln -s /app/vagrant/nginx/app.conf /etc/nginx/sites-enabled/app.conf
echo "Done!"

info "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
