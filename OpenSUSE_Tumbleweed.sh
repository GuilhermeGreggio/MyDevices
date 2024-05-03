#! /bin/bash

#--------------------------------------------------------- Checking for system updates
    sudo hostnamectl set-hostname tumbleweed
    sudo zypper update -y

#--------------------------------------------------------- Removing pre-installed applications

    sudo sudo zypper remove \
        libreoffice -y \
        evolution -y \
        file-roller -y \
        geary -y \
        gimp -y \
        iagno -y \
        lightsoff -y \
        quadrapassel -y \
        opensuse-welcome -y \
        tigervnc -y \
        swell-foop -y \
        vinagre -y \
        polari -y \
        transmission-gtk -y \
        xterm -y \
        xscreensaver -y \
        gnome-contacts -y \
        gnome-calendar -y \
        gnome-extensions -y \
        gnome-maps -y \
        gnome-weather -y \
        gnome-photos -y \
        gnome-videos -y \
        gnome-terminal -y \
        gnome-chess -y \
        gnome-mahjongg -y \
        gnome-mines -y \
        gnome-sudoku -y \
        gnome-system-monitor -y \
        gnome-tetravex -y \
        gnome-klotski -y \
        gnome-robots -y \
        gnome-nibbles -y \
        gnome-2048 -y

#--------------------------------------------------------- Snap install
    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
    sudo zypper --gpg-auto-import-keys refresh
    sudo zypper dup --from snappy
    sudo zypper install snapd
    sudo systemctl enable --now snapd

#--------------------------------------------------------- Installing applications

# CLI Tools
    sudo zypper install \
        bat -y \
        ncdu -y \
        tmux -y \
        fastfetch -y \
        btop -y \
        nvtop -y \
        tldr -y \
        curl -y \
        wget -y

# Development
    sudo zypper install \
        git -y \
        virtualbox -y \
        distrobox -y \
        podman -y \
        gnome-console -y
    sudo usermod -aG vboxusers $USER
    flatpak install flathub \
        io.github.dvlv.boxbuddyrs -y \
        io.podman_desktop.PodmanDesktop -y \
        io.github.shiftey.Desktop -y \
        org.remmina.Remmina -y
    sudo snap install \
        code --classic -y

# Tools
    sudo zypper install \
        gnome-tweaks -y

    flatpak install flathub \
        io.missioncenter.MissionCenter -y \
        org.gnome.Extensions -Y \
        org.signal.Signal -y \
        org.videolan.VLC -y \
        it.mijorus.gearlever -y \
        org.gnome.NetworkDisplays -y \
        com.github.tenderowl.frog -y \
        org.qbittorrent.qBittorrent -y \
        com.github.finefindus.eyedropper -y \
        com.github.tchx84.Flatseal -y \
        org.pulseaudio.pavucontrol -y

# Bottles
    flatpak install flathub com.usebottles.bottles -y
    flatpak override com.usebottles.bottles --user --filesystem=xdg-data/applications
        #! Winbox
        #! Rufus
        #! Anydesk


# Office
    flatpak install flathub \
        com.vivaldi.Vivaldi -y \
        org.onlyoffice.desktopeditors -y \
        com.github.xournalpp.xournalpp -y \
        com.jgraph.drawio.desktop -y

# Fun
    flatpak install flathub \
        com.stremio.Stremio -y

# Editing
    flatpak install flathub \
        com.obsproject.Studio -y \
        org.kde.kdenlive -y \
        org.gimp.GIMP -y \
        org.inkscape.Inkscape -y \
        com.github.huluti.Curtail -y \
        org.upscayl.Upscayl -y \
        com.github.maoschanz.drawing -y \
        com.github.unrud.VideoDownloader -y

# Files
    flatpak install flathub \
        org.cryptomator.Cryptomator -y \
        org.gnome.World.PikaBackup -y \
        fr.romainvigier.MetadataCleaner -y \
        io.github.cboxdoerfer.FSearch -y \
        dev.geopjr.Collision -y \
        io.github.peazip.PeaZip -y
    #! Filen Drive (Manual - Appimage)


# Network
    flatpak install flathub \
        com.protonvpn.www -y
    sudo zypper install \
        nmap -y \
        telnet -y \
        tcpdump -y \
        wireshark -y
    sudo usermod -a -G wireshark $USER
    #! NextDNS

#--------------------------------------------------------- Terminal Configuration

    # Installing fzf
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

    # Installing zsh
        sudo zypper install zsh -y

    # Instalar oh-my-zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Installing powerlevel10k theme
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        # Use the command "zsh" to enter the shell and then type the command "p10k configure" to configure the theme

    # Installing zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Installing zsh-auto-suggestions
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # Installing zsh-ssh
        git clone https://github.com/sunlei/zsh-ssh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-ssh

    # Editing the zsh configuration file
        sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

        sed -i '/plugins=(/,/)/c\
        plugins=(\
            ##internal plugins\
            \tgit\
            \tvscode\
            \tzsh-ssh\
            \tnmap\
            \tjump\
            \tsudo\
            \ttmux\
            \tzsh-interactive-cd\
            ##external plugins\
            \tzsh-syntax-highlighting\
            \tzsh-autosuggestions\
            \tfzf\
        )' ~/.zshrc


    # Installing Github Copilot CLI
        sudo zypper install \
            python3-pip -y \
            gh -y
        
        gh auth login
        gh extension install github/gh-copilot
        gh extension upgrade gh-copilot
            # Test using command "gh copilot"


#--------------------------------------------------------- GNOME Extensions

    #! Caffeine
    #! Extension List
    #! Clipboard Indicator
    #! Tray Icons: Reloaded
    #! Dash to Panel
