# FreeBSD notes
## Updating
### Update system
Based on FreeBSD handbook, [FreeBSD Update](https://www.freebsd.org/doc/handbook/updating-upgrading-freebsdupdate.html)
```bash
freebsd-update fetch
freebsd-update install

# Update the jails using ezjail
ezjail-admin update -u
```
### Update packages
Based on FreeBSD handbook, [Using pkg for Binary Package Management](https://www.freebsd.org/doc/handbook/pkgng-intro.html)
```bash
# Installed packages can be upgraded to their latest versions by running
pkg upgrade
```
### Update ports
Based on FreeBSD handbook, [Using the Ports Collection](https://www.freebsd.org/doc/handbook/ports-using.html)
```bash
# Update ports
portsnap fetch update
##jail ports tree
ezjail-admin update -P

# Next per host and per jail...

# Show ports out of date
pkg version -l "<"
# list these categories and search for updates
portmaster -L

# Upgrade all outdated ports
portmaster -aD

# possibly outside of jails:
# To build the world from source on the host, then install it in the basejail
ezjail-admin update -b
# Update the basejail to the latest patched release
ezjail-admin update -u


# Use mergemaster to update jails
mergemaster -U -D /usr/jails/jailname

```

## Cleanup
```bash
pkg clean

```
```bash
# Cleanup
portmaster --clean-distfiles

```
