# trilby

## A Fedora post-install utility and guide

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
fastestmirror=0
max_parallel_downloads=10 
deltarpm=true
``` 
You can easily access this file with the following command:

```bash
sudo nano /etc/dnf/dnf.conf
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

Only follow these steps if you have an NVIDIA GPU. Also, don't follow these if you have a GPU which has dropped support for newer driver releases, i.e. anything earlier than NVIDIA GT/GTX 600, 700, 800, 900, 1000, 1600 and RTX 2000, 3000 series. Fedora comes preinstalled with NOUVEAU drivers which may or may not work better older GPUs. 

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

Helps decrease load on the CPU when watching videos online by alloting the rendering to the dGPU/iGPU. Quite helpful in increasing battery life on laptops.

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


## 10. (Optional) Set hostname

Fedora is a bit narcissistic and sets your hostname by default to be `fedora`. You can rename your system with the following command:

```bash
hostnamectl set-hostname YOUR_HOSTNAME
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

If your system has less than 16GB of RAM, you can enable `zswap` to act as virtual memory.

- Navigate to the "General Settings" tab and add `zswap.enabled=1` in "Kernel Parameters".
- Press save.

<br>

## Gnome Extensions
* Don't install these if you are using a different spin of Fedora.
* Pop Shell - `sudo dnf install -y gnome-shell-extension-pop-shell xprop`
* [GSconnect](https://extensions.gnome.org/extension/1319/gsconnect/) - do `sudo dnf install nautilus-python` for full support.
* [Gesture Improvements](https://extensions.gnome.org/extension/4245/gesture-improvements/)
* [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
* [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
* [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
* [Quick Settings Tweaker](https://extensions.gnome.org/extension/5446/quick-settings-tweaker/)
* [Blur My Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
* [Bluetooth Quick Connect](https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/)
* [App Indicator Support](https://extensions.gnome.org/extension/615/appindicator-support/)
* [Clipboard Indicator](https://extensions.gnome.org/extension/779/clipboard-indicator/)
* [Legacy (GTK3) Theme Scheme Auto Switcher](https://extensions.gnome.org/extension/4998/legacy-gtk3-theme-scheme-auto-switcher/)
* [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
* [Vitals](https://extensions.gnome.org/extension/1460/vitals/)

## Apps [Optional]

* Packages for Rar and 7z compressed files support:
 `sudo dnf install -y unzip p7zip p7zip-plugins unrar`

* Gnome-Tweaks for GNOME customization: `sudo dnf install -y gnome-tweaks`

## Theming [Optional]

### GTK Themes
* Don't install these if you are using a different spin of Fedora.
* https://github.com/lassekongo83/adw-gtk3
* https://github.com/vinceliuice/Colloid-gtk-theme
* https://github.com/EliverLara/Nordic
* https://github.com/vinceliuice/Orchis-theme
* https://github.com/vinceliuice/Graphite-gtk-theme


### Icon Packs
* https://github.com/vinceliuice/Tela-icon-theme
* https://github.com/vinceliuice/Colloid-gtk-theme/tree/main/icon-theme

### Wallpapers
* https://github.com/manishprivet/dynamic-gnome-wallpapers

### Firefox Theme
* Install Firefox Gnome theme by: `curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash`

### Starship
* Configure starship to make your terminal look good

### Grub Theme
* https://github.com/vinceliuice/grub2-themes

---

## Sources

README forked from [devangshekhawat's guide](https://github.com/devangshekhawat/Fedora-38-Post-Install-Guide).

https://github.com/hmthien050209/fedora-post-install-script

https://github.com/osiris2600/fedora-setup

https://itsfoss.com/things-to-do-after-installing-fedora/