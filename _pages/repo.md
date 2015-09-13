---
title: Repo
layout: page
position: 2

jumbo-title: Arch User Repository
jumbo-subtitle: Highly customized builds of my favorite packages
---
You\'ve reached my **Arch User Repository**. This page contains 
a set of guidelines regarding the usage of this repository. Packages 
are for x86_64 systems only. Builds for x86 are available upon request.
Please report all issues and requests to [nepherte@gmail.com](mailto:nepherte@gmail.com).

# Package Guidelines
All packages are built in a clean chroot environment. This prevents 
missing dependencies, whether due to unwanted linking or an incomplete
dependency array. Should you still encounter a problem due to packaging,
don\'t hesitate to contact me for assistance.

The packages and database are signed. To enable signature verification, 
import my public key with the command-line tool pacman-key. More info 
about package signing is published on the [Arch Wiki](https://wiki.archlinux.org/index.php/Pacman-key).
All pkgbuilds are available up for review on [GitHub](https://github.com/Nepherte/Pkgbuilds).

# Usage Instructions
To enable the repository, add the snippet below to /etc/pacman.conf. 
To avoid any conflicts with the official repositories, add the entry 
before the official [extra] repository. Note that signature verification
is recommended, but still remains optional.

{% highlight bash %}
[nepherte]
Signature = Required
Server = http://www.nepherte.be/repo/x86_64
{% endhighlight %}

Now import my public key to the pacman keyring and sign it. Be advised to 
verify the fingerprint, as you would with a master key, or any other key 
which you are going to sign. Once signed, all packages in the repository 
will be trusted. Use at your own risk.

{% highlight bash %}
$ pacman-key -r 0xF8840B25
$ pacman-key --lsign-key 0xF8840B25
{% endhighlight %}

# Package List
See [[nepherte]](http://www.nepherte.be/repo/x86_64/) for an exhaustive 
list of available packages.