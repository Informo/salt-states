# Informo SaltStack states

This repository contains all of the homemade SaltStack states used in order to maintain Informo's digital infrastructure. It goes from setting up the hosts' firewalls to setting up a working Synapse instance, including managing external volumes, setting up Caddy web servers, or managing PostgreSQL.

Every state is documented in its own directory. Also, because they contain secrets and sensitive data, we don't include our SaltStack pillar files here. However, pillar examples are included in every state's documentation, if the state needs to grab specific data from the host's pillar.

The most common type of hosts in our infrastructure are nodes. Nodes are hosts with Synapse installed and running against PostgreSQL and behind a Caddy web server, with both Synapse's media store and PostgreSQL's data being located on external volumes (one for each of them).

Another important part, this time consisting in a single host, is the SSH bastion, and sometimes referred to as "bounce". As all hosts are connected to a vrack, emulating a local network, and the SSH bastion is the only one allowing external SSH access, so it's goal regarding SSH access is both to act as a proxy to access the internal network, and as a single killswitch should we ever witness an unwanted access to the whole infrastructure. On top of that, the SSH bastion hosts a DNS resolver which resolves FQDNs in an internal zone (`int.informo.network`, in our case) to addresses within the vrack, in order to provide fast access to all hosts without having to remember the whole addressing table.

Here's a rough idea of how all of these elements articulate themselves in our infrastructure:

![](https://user-images.githubusercontent.com/34184120/43662966-fc8dab54-9767-11e8-8f9e-7e21fef65fa8.png)

The infrastructure is role-driven, meaning that the SaltStack highstate of each host is defined by the list of states included in the special `roles` pillar, in addition to the default ones (listed in [top.sls](/top.sls)). For example, here are a few lines from the pillar file for a node:

```yaml
roles:
  - volumes
  - shorewall.node
  - postgresql.node
  - synapse
  - caddy
```

You might also see mentions of the `users` and `sudoers` states in the `top.sls` file, though no state in this repository has any of these names. These refer to formulas you can find [here (users)](https://github.com/saltstack-formulas/users-formula) and [here (sudoers)](https://github.com/saltstack-formulas/sudoers-formula).

Please direct any feedback or questions regarding this work to either the <core@informo.network> email address or the [#discuss:weu.informo.network](https://matrix.to/#/#discuss:weu.informo.network) Matrix room. We know this repository's documentation might not be as comprehensible as we'd like it to be, especially for people that aren't familiar with SaltStack, so we'd really like to read your feedback and ideas so we can improve it.
