# Onion Surf

![](icon_small.png)

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/onion-surf.collaproductions)

Onion Surf is a private browser for Ubuntu Touch that routes all internet traffic through the Tor network. It is a fork of the most recent version of [Morph](https://github.com/ubports/morph-browser) with [nanu-c's modifications](https://github.com/nanu-c/onion-browser) and some quality-of-life improvements, like a [hiding address bar](https://github.com/ubports/morph-browser/pull/333/commits/2df8ced9232fea2b6de6fc10e250b6839bdd084e) (experimental, still not merged upstream) and some custom flags to increase privacy.

All changes upstream will be merged to the extent possible and the browser will be updated with every Tor release. Minor changes (like additional custom flags) might be added in the future.

### WARNING: Not an anonymous browser!

This browser, like the browser it is a clone of, is [QtWebEngine-based](https://wiki.qt.io/QtWebEngine). It lacks all the features that make a "real" Tor browser (based on Firefox) secure and private, and (as usual with any project vaguely involving Google) it is easily fingerprintable. On top of that, it is running on a small platform. How many Ubuntu Touch users can you find in the wild? How many of those UT users will be running Tor? This is yet another bit of information that could be used to identify you. Your DNS requests will leak, which means **your ISP will probably know what websites you are visiting** (this will be possible to fix in the future when Ubuntu Touch upgrades Qt to =< 5.15).

Use this browser if:

* You want to hide your real IP from websites.
* You want to confuse ad networks.
* You want a (small) additional layer of privacy.

Don't use this browser if:

* You need to blend in with other Tor users (use the [Tor Browser](https://www.torproject.org/download/) for that).
* You are a whistleblower.
* You want to hide from a three-letter agency (good luck with that).

Only a PC running [a free BIOS](https://www.coreboot.org/) and [Tails](https://tails.boum.org/) will be able to give you any real semblance of anonymity. Act accordingly.

### Building instructions (Ubuntu-based distros)

Install [clickable](https://clickable-ut.dev/en/latest/install.html):

```
$ sudo add-apt-repository ppa:bhdouglass/clickable
$ sudo apt-get install clickable
```

Clone this repository and build, specifying your target architecture (in this case, arm64):

```
$ git clone https://github.com/nicolascolla/onion-surf.git
$ cd onion-surf
$ sed -i 's/MYCOMPUTERSARCH/arm64/g' clickable.json
$ clickable --arch=arm64
```

### Screenshots

![](screenshot1.png) ![](screenshot2.png)

### TODO:

* Block ads (Tor will ignore your /etc/hosts file, so [uAdblock](https://open-store.io/app/uadblock.mariogrip) is not an option).
* Find a way to stop leaking DNS requests in the current Ubuntu Touch version.
