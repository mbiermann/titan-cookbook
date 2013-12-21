# Titan graph DB Chef Cookbook

Installs Titan embedded within cassandra + connects to elastic search as index backend

## Tested OS Distributions

Ubuntu Precise 64 bit.

## Recipes

Default: Install Titan embedded with Cassandra.


## Dependencies

Cookbook dependecies managed by Berkshelf (see Berskfile)

##Vagrant test cluster usage

1. Install [Vagrant](http://www.vagrantup.com/)
2. Install [Berkshelf](http://berkshelf.com/)
3. Add vm image to vagrant: cookbook_root$  vagrant box add precise64 http://files.vagrantup.com/precise64.box
4. cookbook_root$ vagrant plugin install vagrant-omnibus
5. cookbook_root$ vagrant plugin install vagrant-berkshelf
6. cookbook_root$ berks install
7. cookbook_root$ vagrant up

Vagrant should launch titan

## ToDo

* Make Cassandra start/stop with Titan

## Copyright & License

Original by Brian Cajes, 2013
Martin Biermann, 2013

Released under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).
