#!/bin/bash

function print_ascii_art {
    clear

    echo "      .~~~~\~~\\"
    echo "     ;       ~~ \\"
    echo "     |           ;"
    echo " ,--------,______|---."
    echo "/          \-----\    \\"
    echo "\`.__________\`-_______-'"
    echo ""
    echo "trilby"
}

print_ascii_art

sleep 1

echo "First, a couple of questions..."

sleep 1

# Prompt user if they're on a laptop
read -p "Are you using Fedora on a laptop? (y/N)" laptop_input

# Prompt user if they want to configure OhMyZsh
read -p "Would you like to have OhMyZsh set up for you? This will also install the Starship theme and make it run in your terminal by default. (y/N)" zsh_input

# Prompt user if they want to restore minimize/maximize buttons
read -p "Would you like to restore minimize/maximize buttons? (y/N)" minmax_input

# Prompt user to change hostname
read -p "Would you like to change your hostname? (y/N) " hostname_input
if [[ $hostname_input =~ ^[Yy]$ ]]; then
    # Prompt user for new hostname
    read -p "Enter new hostname: " new_hostname
fi

print_ascii_art

echo "Alright, boring part's over. Starting setup..."

sleep 1

# Create folder for downloads
mkdir ~/.trilby

# Save CPU info to variable
cpu_info=$(lspcu)

# Update dnf configuration
echo "[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=1
max_parallel_downloads=10
deltarpm=true" | sudo tee /etc/dnf/dnf.conf

# Update system
sudo dnf -y update
sudo dnf -y upgrade --refresh

# Enable RPM Fusion repositories
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core

# Install multimedia codecs
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

# Update flatpaks
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update

if [[ $laptop_input =~ ^[Yy]$ ]]; then

    # Install and run TLP and powertop to improve battery life
    sudo dnf install tlp tlp-rdw
    sudo systemctl mask power-profiles-daemon
    sudo dnf install powertop
    sudo powertop --auto-tune

    # Install auto-cpufreq for performance improvements
    cd ~/.trilby && git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    chmod +x ./auto-cpufreq/auto-cpufreq-installer
    sudo ./auto-cpufreq/auto-cpufreq-installer
    sudo auto-cpufreq --install
    cd ~

    # Check CPU for Intel or AMD and install video acceleration packages accordingly
    if echo "$cpu_info" | grep -q "Intel"; then
        echo "Installing Intel video acceleration packages..."
        sudo dnf install ffmpeg ffmpeg-libs libva libva-utils intel-media-driver
    elif echo "$cpu_info" | grep -q "AMD"; then
        echo "Installing AMD video acceleration packages..."
        sudo dnf install ffmpeg ffmpeg-libs libva libva-utils mesa-va-drivers-freeworld
    else
        echo "CPU vendor is not recognized. Video acceleration packages will not be installed."
    fi

fi

# Improve security
sudo dnf install ufw fail2ban -y
sudo systemctl enable --now ufw.service
sudo systemctl disable --now firewalld.service
cd ~/.trilby && git clone https://github.com/ChrisTitusTech/secure-linux
chmod +x ./secure-linux/secure.sh
sudo ./secure-linux/secure.sh
cd ~

# Optimize boot time
if echo "$cpu_info" | grep -q "Intel"; then
    echo -e "\nGRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1 cryptomgr.notests initcall_debug intel_iommu=igfx_off no_timer_check noreplace-smp page_alloc.shuffle=1 rcupdate.rcu_expedited=1 tsc=reliable quiet splash video=SVIDEO-1:d\"" | sudo tee -a /etc/default/grub
    if [ -f "/sys/firmware/efi" ]; 
    then
        sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    else
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
    sudo systemctl disable NetworkManager-wait-online.service
elif echo "$cpu_info" | grep -q "AMD"; then
    sudo systemctl disable NetworkManager-wait-online.service
else
    echo "CPU vendor is not recognized. Boot time optimization skipped."
fi

# Install fonts
sudo dnf install -y jetbrains-mono-fonts-all terminus-fonts terminus-fonts-console google-noto-fonts-common mscore-fonts-all fira-code-fonts
mkdir ~/.fonts && git -C ~/.fonts clone https://github.com/thelioncape/San-Francisco-family

# Configure OhMyZsh
sudo dnf -y install zsh util-linux-user
sh -c "$(curl -fsSL $OH_MY_ZSH_URL)"
chsh -s "$(which zsh)"

curl -sS https://starship.rs/install.sh | sh
echo "eval "$(starship init zsh)"" >> ~/.zshrc

# Install Extension Manager
flatpak install flathub com.mattjakeman.ExtensionManager

# Install GNOME Tweaks
sudo dnf install -y gnome-tweaks

# Restore minimize/maximize buttons
if [[ $minmax_input =~ ^[Yy]$ ]]; then
    sudo gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
fi

# Set new hostname
if [[ $hostname_input =~ ^[Yy]$ ]]; then 
    hostnamectl set-hostname $new_hostname
fi

# Clean up
sudo rm -rf ~/.trilby
sudo dnf -y update
sudo dnf -y autoremove

print_ascii_art
echo "All done. You should reboot to finalize these changes."
read -p "Would you like to reboot now? (y/N)" reboot_input

echo "See ya!"
sleep 1

if [[ $reboot_input =~ ^[Yy]$ ]]; then
    reboot
fi