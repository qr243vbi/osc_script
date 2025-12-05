set -e
if command -v apt; then

export SCRIPT_DIR=$PWD

mkdir -p $SCRIPT_DIR/extra/home ||:
sudo mkdir -p /opensuse/{extra,script}

(
if [[ -d $SCRIPT_DIR/extra/repo ]]; then
  cd $SCRIPT_DIR/extra/repo
  git pull
else 
  git clone --depth 1 --single-branch https://github.com/huakim/repo-suse $SCRIPT_DIR/extra/repo
fi
)

(
chmod 777 -Rfv $SCRIPT_DIR/extra
sudo mount --bind $SCRIPT_DIR/extra /opensuse/extra
sudo mount --bind $SCRIPT_DIR /opensuse/script
cd $SCRIPT_DIR/extra/repo/pacman
sudo bash -x ./aptbk.sh
sudo bash -x ./aptat.sh
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y zypper systemd-container
sudo bash -x ./aptat.sh
sudo zypper --installroot=/opensuse --gpg-auto-import-keys --non-interactive install osckit coreutils bash sed obs-tools-zypper-pkg
sudo systemd-nspawn -D /opensuse /bin/env "OBS_PROJECTS=${OBS_PROJECTS}" "OBS_USER=${OBS_USER}" "OBS_PASSWORD=${OBS_PASSWORD}" bash -x /script/github_actions.sh

sudo chown `whoami` -Rfv $SCRIPT_DIR/extra
sudo chgrp `whoami` -Rfv $SCRIPT_DIR/extra
)

else

mount --bind /extra/home $HOME

(
mkdir -p "$HOME/.config/osc" ||:
oscrc="$HOME/.config/osc/oscrc"
echo '[general]' > $oscrc
echo 'apiurl=https://api.opensuse.org' >> $oscrc
echo '[https://api.opensuse.org]' >> $oscrc
echo "user=${OBS_USER}" >> $oscrc
echo "pass=${OBS_PASSWORD}" >> $oscrc
echo 'credentials_mgr_class=osc.credentials.PlaintextConfigFileCredentialsManager' >> $oscrc
)

(
cd /extra/repo/pacman
bash -x ./aptat.sh
mkdir $HOME/Desktop ||:
cd $HOME/Desktop
OBS_PROJECTS="${OBS_PROJECTS:-gram}"
rpmdb --rebuilddb
zypper --gpg-auto-import-keys --non-interactive ref
for i in $OBS_PROJECTS
do
set +e
(
if [[ ! -d "$i" ]]; then
osc co "home:${OBS_USER}:$i" -o $i
fi
cd $i
osc update
export INSTALL_ONLY=yes
source /script/update_all.sh
unset INSTALL_ONLY
source /script/update_all.sh
)
set -e
done
)

fi
