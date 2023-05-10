# trilby

## A Fedora Linux post-install utility and guide

Congratulations on installing Fedora 38! Fedora is an awesome operating system, but it requires a bit of configuration to get the most out of your experience with it. This guide will provide you with essential steps to ensure that your system is up-to-date and optimized for your needs. Follow these instructions carefully to get the full potential out of your Fedora installation.

<br>

# Basic Fixes

These are highly recommended configuration steps to run right after you finish installing Fedora.

## 1. Faster updates

Replace the configuration in `/etc/dnf/dnf.conf` with the following text:

```
[main] 
gpgcheck=1 
installonly_limit=3 
clean_requirements_on_remove=True 
best=False 
skip_if_unavailable=True 
fastestmirror=1
max_parallel_downloads=10 
deltarpm=true
``` 
Note some users experience mixed results when setting `fastestmirror=1`. You can revert it back to `fastestmirror=0` if you find you're experiencing worse-than-expected download speeds, or skip changing it altogether.

You can easily access the `dnf` configuration file with the following command:

```bash
sudo nano /etc/dnf/dnf.conf
```

Alternatively, you can run this command:

```bash
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
```

<br>

## 2. Update your system

Now's a good time to update your Fedora install with the following command:

```bash
sudo dnf -y update
sudo dnf -y upgrade --refresh
```

You may need to restart your computer to finish an update. You can do that in the terminal simply with the command `reboot`.

<br>

## 3. Enable RPM Fusion repositories

Fedora has disabled the repositories for a lot of free and non-free .rpm packages by default. Follow this if you want to use non-free software like Steam, Discord and some multimedia codecs. As a general rule of thumb its advised to do this get access to many useful programs.

Enable RPM Fusion repositories with the following command:

```bash
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core
```

<br>

## 4. Update your firmware

If your system supports firmware update delivery through `lvfs`, update your device firmware with the following command:

```bash
sudo fwupdmgr get-devices 
sudo fwupdmgr refresh --force 
sudo fwupdmgr get-updates 
sudo fwupdmgr update
```

<br>

## 5. Install media codecs

You'll need some additional media codecs to get proper multimedia playback. Install them with the following command:

```bash
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
```

<br>

## 6. Update flatpaks

Flatpaks are a type of software package that is designed to run securely and independently of the underlying operating system. On Fedora, flatpaks are managed using the Flatpak package manager. 

It's important to keep your flatpaks up to date, just like any other software, as updates often include important bug fixes, security patches, and new features. You can do so with the following command:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update
```

<br>

## 7. (Optional) Install NVIDIA drivers

Only follow these steps if you have an NVIDIA GPU. Also, don't follow these if you have a GPU which has dropped support for newer driver releases, i.e. anything earlier than NVIDIA GT/GTX 600, 700, 800, 900, 1000, 1600 and RTX 2000, 3000 series. Fedora comes preinstalled with NOUVEAU drivers which may or may not work better for older GPUs. 

If you're not sure, you can check out GPU information with the following command:

```bash
lspci | grep VGA
```

If you're still not sure, it's probably best to skip these steps.

- Disable Secure Boot in your BIOS.
- Update your system with the command `sudo dnf update`
- Reboot.
- Run this command: `sudo dnf install akmod-nvidia`
* Run this command if you use applications that use CUDA, i.e. Davinci Resolve, Blender etc: `sudo dnf install xorg-x11-drv-nvidia-cuda`
* Wait for atleast 5 mins before rebooting, to let the kermel module finish building. Go grab a snack.
* Check if the kernel module is built with this command: `modinfo -F version nvidia`
* Reboot.

<br>

## 8. (Optional) Improve battery life

If you installed Fedora on a laptop, you can improve battery performance with the `tlp` and `powertop` packages. Install and implement them with the following command:

```bash
sudo dnf install tlp tlp-rdw
sudo systemctl mask power-profiles-daemon
sudo dnf install powertop
sudo powertop --auto-tune
```

<br>

## 9. (Optional) H/W Video Acceleration

Helps decrease load on the CPU when watching videos online by alloting the rendering to the dGPU/iGPU. It can be quite helpful in increasing battery life on laptops.

If you have an Intel CPU, run the following command:

```bash
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
sudo dnf install inte-media-driver
```

If you have an AMD CPU, run the following command:

```bash
sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
```

If you're not sure, you can check out CPU information with the following command: 

```bash
lscpu | grep 'Model name'
```

<br>
<br>

# Advanced Fixes

These are optional configuration steps to further enhance your Fedora experience. Recommended for advanced users only.

## 1. GRUB customization

Get a little more performance from your system via `grub-customizer`. Do not follow this if you share services and files through your network, or are using Fedora in a virtual machine.

- Install GRUB customizer with this command: `sudo dnf install grub-customizer`
- Open the program with the app menu or with this command: `grub-customizer`
  
You can increase performance in multithreaded systems by disabling mitigations. Not recommended for host systems on some networks due to increased risk of security vulnerabilities.

- Navigate to the "General Settings" tab and add `mitigations=off` in "Kernel Parameters".
- Press save. 

If your system has less than 16GB of RAM, you may want to enable `zswap` to act as virtual memory.

- Navigate to the "General Settings" tab and add `zswap.enabled=1` in "Kernel Parameters".
- Press save.

<br>

## 2. auto-cpufreq

Laptop users may see some performance improvements after installing the [auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq) tool.

```bash
cd ~/Downloads && git clone https://github.com/AdnanHodzic/auto-cpufreq.git
chmod +x ./auto-cpufreq/auto-cpufreq-installer
sudo ./auto-cpufreq/auto-cpufreq-installer
sudo auto-cpufreq --install
```

<br>

## 3. Optimize boot time

There are some slow processes that happen during boot. You can get a slightly faster boot time if your trim the fat.

If you have an Intel CPU, run the following command:

```bash
echo -e "\nGRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1 cryptomgr.notests initcall_debug intel_iommu=igfx_off no_timer_check noreplace-smp page_alloc.shuffle=1 rcupdate.rcu_expedited=1 tsc=reliable quiet splash video=SVIDEO-1:d\"" | sudo tee -a /etc/default/grub
if [ -f "/sys/firmware/efi" ]; 
then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi
sudo systemctl disable NetworkManager-wait-online.service
```

If you have an AMD CPU, run the following command:

```bash
sudo systemctl disable NetworkManager-wait-online.service
```

## 4. Improve security

Fedora is pretty great at security out of the box. [ChrisTitusTech](https://christitus.com/secure-linux/) has some additional recommendations, though:

```bash
sudo dnf install ufw fail2ban -y
sudo systemctl enable --now ufw.service
sudo systemctl disable --now firewalld.service
cd ~/Downloads && git clone https://github.com/ChrisTitusTech/secure-linux
chmod +x ./secure-linux/secure.sh
sudo ./secure-linux/secure.sh
```

<br>
<br>

# GNOME Customization

Fedora uses the GNOME Desktop Environment by default. There are a number of ways to customize GNOME to your liking. Skip this section if you are using a Fedora spin with a different desktop environment.

Note that most of these are not officially supported by GNOME, and alterations may break aspects of your desktop. These breakages won't be hard to fix, just know your mileage may vary.

The full depth to which you can customize the GNOME desktop is outside the scope of this guide. A good source for inspiration is the [/r/unixporn](https://www.reddit.com/r/unixporn/search/?q=%5BGNOME%5D&restrict_sr=1&sr_nsfw=) subreddit.

## 1. GNOME extensions

Extensions extend and build on your desktop's functionality. A useful tool for managing extensions is the [Extension Manager](https://flathub.org/apps/com.mattjakeman.ExtensionManager) app. It's available in your app store if you enabled flatpaks following the above steps, or you can manually install the flatpak with this command:

```bash
flatpak install flathub com.mattjakeman.ExtensionManager
```

Afterwards, you can access it as the "Extension Manager" app, or by running this command:

```bash
flatpak run com.mattjakeman.ExtensionManager
```

Some recommended extensions to try are:
* Pop Shell - intall with `sudo dnf install -y gnome-shell-extension-pop-shell xprop`
* [GSconnect](https://extensions.gnome.org/extension/1319/gsconnect/) - run `sudo dnf install nautilus-python` for full support
* [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
* [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
* [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
* [Blur My Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
* [Bluetooth Quick Connect](https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/)
* [AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)
* [TopHat](https://extensions.gnome.org/extension/5219/tophat/)

You can find more extensions [here](https://extensions.gnome.org/).

<br>

## 2. GTK themes

Themes are a good way to personalize your desktop. They come in a huge variety of flavors. Some popular and well-maintained options are:

* [Colloid](https://github.com/vinceliuice/Colloid-gtk-theme)
* [Nordic](https://github.com/EliverLara/Nordic)
* [Orchis](https://github.com/vinceliuice/Orchis-theme)
* [Graphite](https://github.com/vinceliuice/Graphite-gtk-theme)
* [Catppuccin](https://github.com/catppuccin/gtk)

You can find more themes [here](https://www.gnome-look.org/browse?cat=135&ord=rating).

<br>

## 3. Icon packs

Icon packs are used to customize the icon sets used by GNOME. Some popular and well-maintained options are:

* [Tela](https://github.com/vinceliuice/Tela-circle-icon-theme)
* [Candy](https://github.com/EliverLara/candy-icons)
* [Reversal](https://github.com/yeyushengfan258/Reversal-icon-theme)
* [Papirus](https://git.io/papirus-icon-theme)
* [WhiteSur](https://github.com/vinceliuice/WhiteSur-icon-theme)

You can find more icon packs [here](https://www.gnome-look.org/browse?cat=132&ord=rating).

<br>

## 4. GNOME Tweaks

GNOME Tweaks is an application that allows you to easily control these cosmetic alterations. You can install it with this command:

```bash
sudo dnf install -y gnome-tweaks
```

Afterwards, you can access it in as the "Tweaks" app, or by running `gnome-tweaks` in your terminal.

<br>
<br>

# Misc Customization

## 1. Additional installs

Install packages for .rar and .7z compressed files support with this command:

```
sudo dnf install -y unzip p7zip p7zip-plugins unrar
```

Developers might want to install these additional tools:

```
sudo dnf install code gh github-desktop
```

Install any of the following CLI goofs to impress your friends:

```bash
sudo dnf install cmatrix asciiquarium aafire
```

<br>

## 2. Terminal

You can easily modify your gnome-terminal theme using the [Gogh](https://github.com/Gogh-Co/Gogh) CLI tool. Run it with this command:

```
bash -c "$(wget -qO- https://git.io/vQgMr)"
```

Note that you need to have set up a profile before Gogh can create one on your behalf. Do so in your terminal's "Preferences" settings page.

If you'd like further customization to your terminal, you might want to check out [Oh-My-Zsh]()! You can install and enable it as your default shell with this command:

```bash
sudo dnf -y install zsh util-linux-user
sh -c "$(curl -fsSL $OH_MY_ZSH_URL)"
chsh -s "$(which zsh)"
```
You can then install any Oh-My-Zsh theme you'd like. To install and configure the popular [Starship]() theme, run this command:

```bash
curl -sS https://starship.rs/install.sh | sh
echo "eval "$(starship init zsh)"" >> ~/.zshrc
```

<br>

## 3. Fonts

You might find Fedora missing a number of fonts. You can run this command to install some of the most common ones:

```bash
sudo dnf install -y jetbrains-mono-fonts-all terminus-fonts terminus-fonts-console google-noto-fonts-common mscore-fonts-all fira-code-fonts
```

You can also install proprietary [Apple fonts](https://github.com/thelioncape/San-Francisco-family). Run this command to do so:

```bash
mkdir ~/.fonts && git -C ~/.fonts clone https://github.com/thelioncape/San-Francisco-family
```

<br>

## 4. Firefox GTK theme

Fedora ships with Firefox by default. To make it look like your other GTK-themed applications, you can use this command:

```bash
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
```

Follow [these instructions](https://github.com/rafaelmardojai/firefox-gnome-theme#uninstalling) for uninstalling this change.

<br>

## 5. Wallpapers

Here are some resources for getting a cool wallpaper:

* [Dynamic GNOME Wallpapers](https://github.com/manishprivet/dynamic-gnome-wallpapers)
* [Minimalist Wallpapers](https://github.com/DenverCoder1/minimalistic-wallpaper-collection)
* [Aesthetic Wallpapers](https://github.com/D3Ext/aesthetic-wallpapers)

<br>

## 6. Minimize/Maximize buttons

These are turned off by default. To re-enable minimize and maximize buttons for all of your windows, run this command:

```bash
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
```

<br>


## 7. (Optional) Set hostname

Fedora is a bit narcissistic and sets your hostname by default to be `fedora`. You can rename your system with the following command:

```bash
hostnamectl set-hostname YOUR_HOSTNAME
```

<br>
<br>

---

## Sources

README forked from [devangshekhawat's guide](https://github.com/devangshekhawat/Fedora-38-Post-Install-Guide).

[osiris2600's guide](https://github.com/osiris2600/fedora-setup) on Fedora setup

[hmthien050209's script](https://github.com/hmthien050209/fedora-post-install-script) on Fedora post-installation

[itsFOSS article](https://itsfoss.com/things-to-do-after-installing-fedora/) on Fedora post-installation
