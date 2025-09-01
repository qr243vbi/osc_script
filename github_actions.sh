set -e
if command -v apt; then

export SCRIPT_DIR=$PWD

mkdir -p ~/extra/home ||:
sudo mkdir -p /opensuse/{extra,script}

(
if [[ -d ~/extra/repo ]]; then
  cd ~/extra/repo
  git pull
else 
  git clone --depth 1 --single-branch https://github.com/huakim/repo-suse ~/extra/repo
fi
)

(
sudo mount --bind ~/extra /opensuse/extra
sudo mount --bind $SCRIPT_DIR /opensuse/script
sudo ls /opensuse/script
cd ~/extra/repo/pacman
sudo bash -x ./aptbk.sh
sudo bash -x ./aptat.sh
sudo apt-get install zypper systemd-container
sudo bash -x ./aptat.sh
sudo zypper --installroot=/opensuse --gpg-auto-import-keys --non-interactive install osckit coreutils bash sed
sudo systemd-nspawn -D /opensuse /bin/env OBS_USER=${OBS_USER} OBS_PASSWORD=${OBS_PASSWORD} bash -x /opensuse/script/github_action.sh
)

else

mount --bind /extra/home $HOME

(
mkdir -p ~/.config/osc ||:
oscrc="$HOME/.config/osc/oscrc"
echo '[general]' > $oscrc
echo 'apiurl=https://api.opensuse.org' >> $oscrc
echo '[https://api.opensuse.org]' >> $oscrc
echo "user=${OBS_USER}" >> $oscrc
echo "pass=${OBS_PASSWORD}" >> $oscrc
echo 'credentials_mgr_class=osc.credentials.PlaintextConfigFileCredentialsManager' >> $oscrc
)

(
cd Desktop
osc co home:juzbun:kde-plasma -o kde-plasma
cd kde-plasma
export INSTALL_ONLY=yes
source /extra/script/update_all.sh
unset INSTALL_ONLY
source /extra/script/update_all.sh
)

fi
