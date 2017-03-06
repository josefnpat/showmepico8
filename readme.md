#Show Me Pico-8

The source code for the [@showmepico8](http://twitter.com/showmepico8) bot.

Thanks to @lemtzas for the ruby help.

## Requirements

These scripts require:
* bash
* imagemagick
* awk
* ruby-dev
* xdotool
* gem t
* gem htmlentities
* gem bundle
* pico8

## VM Config

How to set up the VM that is being used:

1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download Ubuntu 16.04 Minimal Unstall (~54MB)](http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/mini.iso)
3. Set up a new machine w/ 2GB of ram, 8GB dynamic VDI, set the ubuntu iso to boot. When shown the "Installer boot menu" select "Command-line install" and install ubuntu.
4. I installed a bunch of apps. I used: `apt-get install tig imagemagick g++ gcc make ruby-dev git xdotool tmux unzip vim openssh-server xorg `
5. Git clone the repo, download and unpack pico8 into the correct location and use gem bundle to install ruby stuff.
6. Run `startx` and attach a `tmux` session to the open xterm window (You could use screen too)
7. In the term session, run the ruby application (please add instructions on how to use ruby app here)
