# bind

This state installs and configures the Bind DNS server to resolve any FQDN in the infrastructure's internal zone (which, in our case, is `int.informo.network`) to an address in the infrastructure's local network. We usually include this state in the SSH bastion's highstate. Here are the pillars it grabs its data from:

```yaml
int_net: xxx.xxx.xxx.xxx/xx
int_zone: int.informo.network

bind:
  soa:
    admin: admin.informo.network
    serial: xxxxxx
    refresh: xxxxxx
    retry: xxxxxx
    expire: xxxxxx
    minimum: xxxxxx
  ttl: 60
  records:
    - subdomain: foo
      type: A
      target: xxx.xxx.xxx.1
    - subdomain: bar
      type: A
      target: xxx.xxx.xxx.2

```

The value for the `int_net` pillar is the infrastructure's local network address with its mask, e.g. `10.0.0.0/24`. The values to fill in the `bind:soa` pillar match the values to pass in a DNS SOA record. Finally, the `bind:records` pillar contains a list of all records to set in Bind's configuration. In our example, it will create a A record for `foo.int.informo.network` pointing to `xxx.xxx.xxx.1`, and a A record for `bar.int.informo.network` pointing to `xxx.xxx.xxx.2`.
