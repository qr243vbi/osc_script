git clone https://github.com/huakim/repo-suse repo
(
cd repo/pacman
sudo bash -x ./aptat.sh
apt-get install zypper
sudo bash -x ./aptat.sh
zypper install osckit

echo $HOME
)
