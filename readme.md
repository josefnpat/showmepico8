#Show Me Pico-8

The source code for the [@showmepico8](http://twitter.com/showmepico8) bot.

Thanks to @lemtzas for the ruby help.

## Requirements

These scripts require:
* bash
* imagemagick
* awk
* ruby-dev (and g++,gcc,make for gem deps)
* Ruby gems: t htmlentities yaml pry-byebug (use bundle)
* xorg
* xdotool
* pico8

## VM Config

How to set up the VM that is being used:

1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download Ubuntu 16.04 Minimal Install (~54MB)](http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/mini.iso)
3. Set up a new machine w/ 2GB of ram, 8GB dynamic VDI, set the ubuntu iso to boot. When shown the "Installer boot menu" select "Command-line install" and install ubuntu.
4. I installed a bunch of junk:
  * Required: `apt-get install imagemagick g++ gcc make ruby-dev git xdotool tmux unzip xorg`
  * Optional: `apt-get install tig vim openssh-server sudo`
5. (optional) Configure virtualbox to forward port 2222 from your host machine to your guest machine, so you can ssh in via putty/cygwin. This makes working with the VM easier IMO.
  * [![http://i.imgur.com/g7RIxAG.png](http://i.imgur.com/g7RIxAGt.png)](http://i.imgur.com/g7RIxAG.png) Hack into the matrix with `ssh -p2222 showmepico8@localhost`
6. Clone the git repo (I used `/root/repos/showmepico8/`, dotdata should be at `/root/repos/showmepico8/.git`)
7. Download and unpack pico8 into the correct location (`/root/pico-8/`, bin should be at `/root/pico-8/pico8`)
8. Use the ruby gem `bundle` to install ruby deps (`cd repos/showmepico8/ && bundle install`)
9. Run `startx` and attach a `tmux` session to the open `xterm` window (You could use `screen` too)
10. In the term session, run the ruby application (@lemtzas please add usage instructions for start/stop/error reporting)
11. `cd repos/showmepico8/ && bundle exec ruby ruby/process.rb` ?
