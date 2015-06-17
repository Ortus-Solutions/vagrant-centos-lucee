# Vagrant Lucee  Development VM 
> (CentOS+Nginx+Tomcat+Lucee+CommandBox)

Vagrant box for local development with Lucee/CommandBox and several utilities.

## Requirements

It is assumed you have Virtual Box and Vagrant installed. If not, then grab the latest version of each at the links below:
* [Virtual Box and Virtual Box Guest Additions](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)

### Vagrant Plugins

Once Vagrant is installed, or if it already is, it's highly recommended that you install the following Vagrant plugins:

* [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
```$ vagrant plugin install vagrant-hostsupdater```
* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)
```$ vagrant plugin install vagrant-vbguest```

---

## What's Included
* [CentOS 7.1 64bit](https://www.centos.org)
	* https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box
* [Nginx Latest](www.nginx.org)
	* Set up to serve all static content and reverse-proxy cfm/cfc/jsp requests to Lucee with URL rewrites enabled
	* Self-signed SSL certificate can be found under `/etc/nginx/ssl` and every site is configured for SSL as well.
	* Nginx configured with high timeouts for development purposes
* [CommandBox v2.1.0](http://www.ortussolutions.com/products/commandbox)
	* Set up to do build processes, REPL, package management or a-la-carte servers if required
	* CommandBox home configured at `/root/.CommandBox`
* [Lucee 4.5.1.000](www.lucee.org)
	* Set up via reverse-proxy in Nginx and with a control port on 8888
* [Oracle JDK v8u45](http://www.oracle.com/technetwork/java/javase/downloads/)
	* Installed globally under `/usr/lib/jvm/current`
* [FakeSMTP](https://nilhcem.github.io/FakeSMTP/)
	* Lucee is configured with a Fake SMTP server that will output all outbound emails to `/opt/fakeSMTP/output` for convenience
	* This is installed under `/opt/fakeSMTP`
* [Webmin](http://www.webmin.com)
	* Webmin is configured on port 10000 in order to allow for web-based management.

---

## Files
The repository is divded in two parts:
-  `vagrant` : Where associated vagrant files reside
	- `artifacts` : Where downloaded installers will be placed
	- `bash-scripts` : The provisionning bash scripts for the box
	- `configs` : Configuration files for Nginx, Lucee, etc
	- `Vagrantfile` : The vagrant configuration file
- `www` : Where you put you CFML site

## Installation
The first time you clone the repo and bring the box up, it may take several minutes. If it doesn't explicitly fail/quit, then it is still working.

```
$ git clone git@github.com:Ortus-Solutions/vagrant-centos-lucee.git
$ cd vagrant-centos-lucee && vagrant up
```

Once the Vagrant box finishes and is ready, you should see something like this in your terminal:

```
==> default: Lucee-Dev-v0.1.0
==> default:
==> default: ========================================================================
==> default:
==> default: http://www.lucee.dev (192.168.50.25)
==> default:
==> default: Lucee Server/Web Context Administrators
==> default:
==> default: http://www.lucee.dev:8888/lucee/admin/server.cfm
==> default: http://www.lucee.dev:8888/lucee/admin/web.cfm
==> default:
==> default: Password (for each admin): password
==> default:
==> default:
==> default: Webmin
==> default: " "
==> default: https://www.lucee.dev:10000
==> default: User: root
==> default: Password: vagrant
==> default: " "
==> default: " "
========================================================================
```

> **Mac Note** : You might be required your administrator password in order to modify the `hosts` file. Unless you run the command with `sudo vagrant up`

Once you see that, you should be able to browse to [http://www.lucee.dev/](http://www.lucee.dev/)
or [http://192.168.50.25/](http://192.168.50.25/)
(it may take a few minutes the first time a page loads after bringing your box up, subsequent requests should be much faster).

### Notes
* On Windows (host machines) you should run your terminal as an Administrator; you will also need to make sure your Hosts file isn't set to read-only if you want to take advantage of the hostname functionality. Alternatively, simply use the IP address anywhere you would use the hostname (connecting to database server, etc).
* The VM is configured to share a `www` folder from your computer into the webroot of the VM at `/var/www/sites`.

---

## References
* Thanks to Dan Skaggs, as this is a fork of his vagrant box
* Thanks to Mike Sprague for his work on the Ubuntu version which this project used as a starting point [vagrant-lemtl](https://github.com/mikesprague/vagrant-lemtl)

---

## License
The MIT License (MIT)

Copyright (c) 2015 Dan Skaggs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
