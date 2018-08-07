# synapse

This state installs and configures a fully working Synapse Matrix homeserver. With this state, Synapse is configured to use a local PostgreSQL as its database engine, and to host its media store on an external volume. Both these settings are hardcoded in the state at the current time, but that might change in the future to allow more use cases.

The state currently uses the following information from the hosts' pillars:

```yaml
postgresql:
  password: xxxxxxxxxxxxxx

synapse:
  bind_address: 42.42.42.42
  server_name: matrix.example.tld # Optional
  registration_enabled: False
  guest_registration: True
  pepper: xxxxxxxxxxxxxx
```

The PostgreSQL password is used to let Synapse connect to the `synapse` postgresql user, while the `synapse` section allow one to define some settings in Synapse's configuration, such as whether registration of new users is open on the homeserver, whether registration of guest users is open on the homeserver, the pepper the homeserver will use to retrieve passwords, the IP address to force the homeserver to listen on, or the homeserver's server name. Please note that all keys in that section are optional, and default to the following:

* `bind_address`: the value for the `public:ip` pillar if defined, if not it defaults to `0.0.0.0`
* `server_name`: the host's FQDN if defined in the host's grains, if not it defaults to an empty string
* `registration_enabled`: `False`
* `guest_registration`: `False`
* `pepper`: an empty string
