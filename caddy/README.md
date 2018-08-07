# caddy

This state installs and configures the Caddy web server, by downloading the archive from GitHub, extracting it (moving the required files at the right locations) and enabling + starting its systemd service. The version of Caddy is pinned in the host's pillar along with a checksum of the archive for the desired version. It installs Caddy's binary as `/usr/local/bin/caddy-VERSION`, where `VERSION` is the version tag (e.g. `v0.11.0`), and a symlink named `/usr/local/bin/caddy` is created, targetting the latest version to be installed (and not the one with highest version number). It also creates a configuration directory in `/etc/caddy`, which itself only contains a `caddy.conf.d` directory and a `caddy.conf` file including every `*.conf` file located in `caddy.conf.d`, and, if `synapse` is present in the host's `roles` pillar, installs a configuration file in `caddy.conf.d` that configures Caddy to act as a reverse proxy in front of Synapse.

Regarding pillars other than the `roles` one, here are the pillars this state uses:

```yaml
caddy:
  tag: v0.11.0
  tar_sha512sum: ae9502c86347a0b33ec9acfbfb3f5125c0bba6e76c02c7c302c27e14c506317952532149b6641063433835025329e18a90a8a87e516c2240b25f0759ab34976b

public:
  fqdn: xxx.informo.network
  ip: xxx.xxx.xxx.xxx
```

The `caddy` section contains the tag for the desired Caddy version, along with the SHA512 checksum corresponding to the version's `_linux_amd64.tar.gz` archive on [Caddy's GitHub releases page](https://github.com/mholt/caddy/releases). By the way, the checksum provided in the example above is the real SHA512 checksum for Caddy v0.11.0's `linux_amd64` archive.

The `public` section is used in the Caddy configuration file that's installed in `caddy.conf.d`, and includes the FQDN the Caddy vhost must target, and the public IP to bind it to. We (Informo) force this binding because our hosts usually have more than one public IP attached and we want to make sure the right one gets used.
