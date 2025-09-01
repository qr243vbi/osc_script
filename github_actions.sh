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
cd ~/extra/repo/pacman
sudo bash -x ./aptbk.sh
sudo bash -x ./aptat.sh
sudo apt-get install zypper systemd-container
sudo bash -x ./aptat.sh
sudo zypper --installroot=/opensuse --gpg-auto-import-keys --non-interactive install osckit coreutils bash sed
sudo systemd-nspawn -D /opensuse /bin/env OBS_USER=${OBS_USER} OBS_PASSWORD=${OBS_PASSWORD} bash -x /script/github_actions.sh
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
mkdir $HOME/Desktop
cd $HOME/Desktop
for i in 'kde-plasma' 'gram'
do
set +e
(
osc co home:juzbun:$i -o $i
cd $i
export INSTALL_ONLY=yes
source /script/update_all.sh
unset INSTALL_ONLY
source /script/update_all.sh
)
set -e
done
)

fi
