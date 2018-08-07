# volumes

This state mounts external volumes used to host PostgreSQL's database(s) and Synapse's media store. It's a pretty basic state that first only grabs information from the `roles` pillar, then:

* if `synapse` is present, grabs a volume UUID from the `volumes_uuid:synapse` pillar and mounts it on `/var/lib/matrix-synapse` (which is first created if it doesn't exist)
* if `postgresql` or `postgresql.node` is present, grabs a volume UUID from the `volumes_uuid:postgresql` pillar and mounts it on `/var/lib/postgresql` (which is first created if it doesn't exist)

The state also creates an entry in the `/etc/fstab` file for every mounted volume.

Basically, all this means that if you have both Synapse and PostgreSQL running on the host, the state expects the host to provide the following pillars:

```yaml
volumes_uuid:
  synapse: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  postgresql: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Both UUIDs must refer to an existing `ext4` partition.
