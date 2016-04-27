# FreeBSD notes
## Updating

Based on FreeBSD handbook, [Using the Ports Collection](https://www.freebsd.org/doc/handbook/ports-using.html)
### Update ports
```bash
# Update ports
portsnap fetch update

# Show ports out of date
pkg version -l "<"

# list these categories and search for updates
portmaster -L

# Upgrade all outdated ports
portmaster -a

```

## Cleanup
```bash
# Cleanup
portmaster --clean-distfiles

```
