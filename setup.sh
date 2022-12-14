#!/usr/bin/env bash
# https://github.com/newaetech/chipwhisperer-vagrant/blob/4485766ac6648e18d1bdca8f1856d23504a9b0fb/setup.sh

# system
setup-keymap fi fi-winkeys
setup-hostname compsec-chipwhisperer

# packages
apk update
sed 's http: https: ' -i /etc/apk/repositories
sed 's ^#\(https://[^/]*/alpine/v[^/]*/community\)$ \1 ' -i /etc/apk/repositories
sed 's XKBLAYOUT=\"\w*" XKBLAYOUT=\"fi\" g' -i /etc/default/keyboard
apk update
apk add python3 py3-pip git gcc-avr avr-libc gcc-arm-none-eabi make nano udev busybox-initscripts sudo bash py3-wheel py3-matplotlib py3-scipy py3-numpy py3-pandas py3-psutil libusb mpfr-dev gmp-dev mpc1-dev

# repo
git clone --depth=1 $REPO_URL chipwhisperer
cd chipwhisperer

# files
mkdir -p /home/vagrant/.jupyter
cp run.sh /home/vagrant/run.sh
cp jupyter_notebook_config.py /home/vagrant/.jupyter/
chmod +x /home/vagrant/run.sh
chown vagrant:vagrant -R /home/vagrant/

# cron
echo "@reboot /home/vagrant/run.sh" | crontab -u vagrant -

# usb
cp *-newae.rules /etc/udev/rules.d/
addgroup -S plugdev
addgroup vagrant plugdev
addgroup vagrant dialout
udevadm control --reload-rules

# START
sudo --preserve-env=NOTEBOOK_PASS -Hu vagrant bash <<EOF

# git
git config --global user.name "example"
git config --global user.email "example@example.com"

# setup python
python3 -m pip install --upgrade pip
pip3 install --no-warn-script-location -r requirements.txt

# setup jupyter
export PATH="/home/vagrant/.local/bin:$PATH"
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main

# jupyter password
python3 -c "import os; from notebook.auth import passwd; print('\nc.NotebookApp.password=\'' + passwd(os.getenv('NOTEBOOK_PASS')) + '\'')" >> /home/vagrant/.jupyter/jupyter_notebook_config.py

# END
EOF

# done
reboot