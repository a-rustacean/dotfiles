#!/bin/bash

dotfiles_path=$(pwd)

# utility functions

create_dir() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

install_font() {
  font_name="$1.ttf"
  font_path=$2

  curl -L -o $font_name "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/$font_path.ttf"

  create_dir "$HOME/.fonts"
  create_dir "$HOME/.local/share/fonts"

  cp $font_name $HOME/.fonts/
  cp $font_name $HOME/.local/share/fonts/
  sudo cp $font_name /usr/local/share/fonts/
  sudo cp $font_name /usr/share/fonts/

  sudo fc-cache -fv
  rm -rf $font_name
}

# apt

sudo add-apt-repository ppa:maveonair/helix-editor -y
sudo apt update -y
sudo apt upgrade -y

sudo apt install zsh helix git tmux git-lfs gh cmake pkg-config \
  libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
  python3 gzip scdoc -y

# tmux

rm -rf $HOME/.tmux.conf

sudo ln -s $dotfiles_path/.tmux.conf $HOME/.tmux.conf

# zsh & omz

rm -rf $HOME/.oh-my-zsh
rm -rf $HOME/.zshrc
rm -rf $HOME/.zshenv
rm -rf $HOME/.p10k.zsh
rm -rf $HOME/.zfunc

git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

rm -rf $HOME/.zshrc
rm -rf $HOME/.zshenv

sudo ln -s $dotfiles_path/.zshrc $HOME/.zshrc
sudo ln -s $dotfiles_path/.zshenv $HOME/.zshenv
sudo ln -s $dotfiles_path/.p10k.zsh $HOME/.p10k.zsh

mkdir $HOME/.zfunc

# helix

sudo apt install helix -y

# .config/

rm -rf $HOME/.config/cava
rm -rf $HOME/.config/helix
rm -rf $HOME/.config/neofetch
rm -rf $HOME/.config/alacritty
rm -rf $HOME/.config/helix-lite

sudo ln -s $dotfiles_path/.config/cava $HOME/.config/cava
sudo ln -s $dotfiles_path/.config/helix $HOME/.config/helix
sudo ln -s $dotfiles_path/.config/neofetch $HOME/.config/neofetch
sudo ln -s $dotfiles_path/.config/alacritty $HOME/.config/alacritty
sudo ln -s $dotfiles_path/.config/helix-lite $HOME/.config/helix-lite

# nvm, node & npm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

nvm install --lts

# git

rm -rf $HOME/.gitconfig

sudo ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig

# git lfs

git-lfs install

# rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

. $HOME/.cargo/env

rustup toolchain install nightly
rustup completions zsh cargo > $HOME/.zfunc/_cargo
rustup component add rust-analyzer

# installing font

cd $HOME

install_font "JetBrainsMono-Nerd-Font" "JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular"

# firefox for devs

rm -rf firefox
wget "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" -O firefox-dev.tar.bz2
tar xjf firefox-dev.tar.bz2 -C $HOME
rm -r firefox-dev.tar.bz2
sudo rm -rf /usr/local/bin/firefox-dev
sudo ln -s $HOME/firefox/firefox /usr/local/bin/firefox-dev

sudo cat <<EOT > $HOME/firefox/firefox-dev.desktop
[Desktop Entry]
Name=Firefox Developer Edition
Exec=/usr/local/bin/firefox-dev
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Comment=browser
Type=Application
Terminal=false
Encoding=UTF-8
Categories=Utility;
EOT

sudo desktop-file-install $HOME/firefox/firefox-dev.desktop

# alacritty

rm -rf alacritty
git clone https://github.com/alacritty/alacritty.git
cd alacritty
cargo build --release --no-default-features --features=x11
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info

sudo cp target/release/alacritty /usr/local/bin/
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null

cp extra/completions/_alacritty $HOME/.zfunc/_alacritty

# github cli

gh completion -s zsh > $HOME/.zfunc/_gh
gh extension install yusukebe/gh-markdown-preview
gh extension install dlvhdr/gh-dash
gh extension install vilmibm/gh-screensaver
gh extension install meiji163/gh-notify

# cleanup

sudo apt autoremove -y
