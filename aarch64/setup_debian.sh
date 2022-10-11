#!/usr/bin/env bash
# https://github.com/newaetech/chipwhisperer-vagrant/blob/4485766ac6648e18d1bdca8f1856d23504a9b0fb/setup.sh


# export DEBIAN_FRONTEND=noninteractive
# packages
# sudo apt-get update
# sudo apt-get install --no-install-recommends -y keyboard-configuration
# sudo apt-get install --no-install-recommends -y ca-certificates gcc-avr avr-libc gcc-arm-none-eabi
# sudo apt-get install --no-install-recommends -y python3 python3-dev python3-pip python3-wheel git make nano libusb-dev libmpfr-dev libgmp-dev libmpc-dev libusb-1.0-0

# repo
cloud-init status --wait
git clone --depth=1 https://github.com/joniumGit/chipwhisperer-compsec /home/vagrant/chipwhisperer
cd /home/vagrant/chipwhisperer

# files
mkdir -p /home/vagrant/.jupyter
cp run.sh /home/vagrant/run.sh
cp jupyter_notebook_config.py /home/vagrant/.jupyter/
chmod +x /home/vagrant/run.sh
chown vagrant:vagrant -R /home/vagrant/

# cron
echo "@reboot /home/vagrant/run.sh" | crontab -u vagrant -

# usb
sudo cp *-newae.rules /etc/udev/rules.d/
sudo addgroup vagrant plugdev
sudo addgroup vagrant dialout
sudo udevadm control --reload-rules

# START
sudo -Hu vagrant bash <<EOF

# git
git config --global user.name "example"
git config --global user.email "example@example.com"

# setup python
python3 -m pip install --upgrade pip
pi3 install libusb1
pip3 install --no-warn-script-location -r requirements.txt

# setup jupyter
export PATH="/home/vagrant/.local/bin:$PATH"
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main

# jupyter password
python3 -c "import os; from notebook.auth import passwd; print('\nc.NotebookApp.password=\'' + passwd('jupyter') + '\'')" >> /home/vagrant/.jupyter/jupyter_notebook_config.py

# END
EOF

sudo touch /etc/cloud/cloud-init.disabled

# done
# usermod --password $(echo vagrant | openssl passwd -1 -stdin) vagrant
# reboot