git clone https://github.com/huakim/repo-suse repo
(
cd repo/pacman
sudo bash -x ./aptbk.sh
sudo bash -x ./aptat.sh
sudo apt-get install zypper
sudo bash -x ./aptat.sh
sudo zypper --gpg-auto-import-keys --non-interactive install osckit

echo $HOME
)
