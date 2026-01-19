clone_repo(){
  git clone https://github.com/huakim/repo-suse "$1" ||:
  (
    cd "$1"
    git pull ||:
  )
  bash "$1"/pacman/copy.sh ||:
  bash "$1"/pacman/setup.sh ||:
  bash "$1"/pacman/aptat.sh ||:
}

if [[ "$CONTAINER_RUN" != "yes" ]]
then

mkdir -p "$PWD/cache/pod/"{storage,run}

cat << EOF > "$PWD/cache/pod/storage.conf"
[storage]
driver = "overlay"
graphroot = "$PWD/cache/pod/storage"
runroot = "$PWD/cache/pod/run"
EOF

export CONTAINERS_STORAGE_CONF="$PWD/cache/pod/storage.conf"

if [[ -z `command -v podman` ]]
then  
  clone_repo cache/repo
  if [[ -n `command -v zypper` ]]
  then
     zypper --gpg-auto-import-keys -v -v -v ref
     zypper -n install python3-podman-compose podman 
  else
     apt-get update
     apt-get install -y podman-compose podman
  fi
fi
systemctl start --user podman ||:
podman compose up

else
export HOME="/extra/workdir"
mkdir -p $HOME

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
clone_repo /extra/repo

rpmdb --rebuilddb
zypper --gpg-auto-import-keys -v -v -v --non-interactive ref
zypper --gpg-auto-import-keys -v -v -v install -y osckit coreutils bash sed obs-tools-zypper-pkg

cd /extra/repo/pacman

mkdir "$HOME/Desktop" ||:
cd "$HOME/Desktop"
OBS_PROJECTS="${OBS_PROJECTS:-kde-plasma}"

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
