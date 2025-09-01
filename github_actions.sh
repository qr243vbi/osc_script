export SCRIPT_DIR=$PWD

mkdir -p ~/extra/home ||:

(
if [[ -d ~/extra/repo ]]; then
  cd ~/extra/repo
  git pull
else 
  git clone --depth 1 --single-branch https://github.com/huakim/repo-suse ~/extra/repo
fi
)

(
cd ~/extra/repo/pacman
sudo bash -x ./aptbk.sh
sudo bash -x ./aptat.sh
sudo apt-get install zypper
sudo bash -x ./aptat.sh
sudo zypper --gpg-auto-import-keys --non-interactive install osckit
)

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
cd ~/extra/home
rm ./txt.sh
ln ~/extra/repo/pacman/txt.sh ./txt.sh
bash -x ./txt.sh
cd Desktop
osc co home:juzbun:kde-plasma -o kde-plasma
cd kde-plasma
ln $SCRIPT_DIR/*.sh ./
INSTALL_ONLY=yes ./update_all.sh
./update_all.sh
)
