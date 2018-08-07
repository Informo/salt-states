# base

This state makes sure the right users and groups exist (or don't exist) on hosts so no other state fail because of missing users and/or groups. It is recommended to place this state at the very beginning of every host's highstate (as shown in the `top.sls` file at the root of this repository).

The only pillar this state grabs data from is the `roles` one in order to determine which users/groups to create. If `postgresql` or `postgresql.node` is present in the host's roles, it creates the `postgresql` user, member of the `ssl-cert` group (if it exists), and with `/var/lib/postgresql` as its home directory. If `synapse` is present in the host's roles, it creates the `matrix-synapse` user, member of the `nogroup` group, and with `/var/lib/matrix-synapse` as its home directory. If `caddy` is present in the host's roles, it creates the `http` user, with `/home/http` as its home directory. If either one of the home directories (or both) doesn't exist, it is created.

In any case, it creates the `core` group, which we use to identify users from the Informo core team. It also makes sure the `ubuntu` user is absent from the system, which is a default user on the Ubuntu images we spawn new hosts with, deleting it (with its home directory and files) if necessary.
