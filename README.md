# Informo SaltStack states

This repository contains all of the homemade [SaltStack](https://saltstack.com/salt-open-source/) states used in order to maintain Informo's digital infrastructure. It goes from setting up the hosts' firewalls to setting up a working Synapse instance, including managing external volumes, setting up Caddy web servers, or managing PostgreSQL.

Every state is documented in its own directory. Also, because they contain secrets and sensitive data, we don't include our SaltStack pillar files here. However, pillar examples are included in every state's documentation if that specific state needs to grab data from the host's pillar.

## What does our infrastructure look like?

The most common type of hosts in our infrastructure are nodes. Nodes are hosts with [Synapse](https://github.com/matrix-org/synapse) installed and running against [PostgreSQL](https://www.postgresql.org/) and behind a [Caddy](https://caddyserver.com/) web server, with both Synapse's media store and PostgreSQL's data being located on external volumes (one for each of them).

Another important part, this time consisting in a single host, is the SSH bastion, and sometimes referred to as "bounce". As all hosts are connected to a int, emulating a local network, and the SSH bastion is the only one allowing external SSH access, its goal regarding SSH access is both to act as a proxy to access the internal network, and as a single killswitch should we ever witness an unwanted access to the infrastructure. On top of that, the SSH bastion hosts a DNS resolver which resolves FQDNs in an internal zone (`int.informo.network`, in our case) to addresses within the int, in order to provide fast access to all hosts without having to remember the whole addressing table.

Here's a rough idea of how all of these elements articulate themselves in our infrastructure:

![Schema of Informo's architecture](https://user-images.githubusercontent.com/34184120/43662966-fc8dab54-9767-11e8-8f9e-7e21fef65fa8.png)

The infrastructure is role-driven, meaning that the SaltStack highstate of each host is defined by the list of states included in the special `roles` pillar, in addition to the default ones (listed in [top.sls](/top.sls)). For example, here is the `roles` pillar for a node:

```yaml
roles:
  - volumes
  - shorewall.node
  - postgresql.node
  - synapse
  - caddy
```

You might also see mentions of the `users` and `sudoers` states in the `top.sls` file, though no state in this repository has any of these names. These refer to formulas you can find [here (users)](https://github.com/saltstack-formulas/users-formula) and [here (sudoers)](https://github.com/saltstack-formulas/sudoers-formula).

## Why are we sharing this work?

We are strop believers in openness, along with free software and its philosophy. On top of that, we believe that this work could be useful to some communities, especially the one orbiting around the Matrix ecosystem, because these states allows us to easily deploy efficient Matrix homeservers in a secure infrastructure. Since the Informo project is based on Matrix and the work done by its community, we want to give back to that community and help the Matrix ecosystem develop. All of the material you'll find in this repository is licensed under the GPLv3 license (see the [LICENSE](/LICENSE) file).

## Help us make it better

Please direct any feedback or questions regarding this work to either the <core@informo.network> email address or the [#discuss:weu.informo.network](https://matrix.to/#/#discuss:weu.informo.network) Matrix room. We know this repository's documentation might not be as comprehensible as we'd like it to be, especially for people that aren't familiar with SaltStack, so we'd really like to read your feedback and ideas so we can improve it.

## Who are we?

Informo is work in progress of a project that aims at using [Matrix](https://matrix.org) in order to bypass censorship of information on the Internet, by basically having news items go through a decentralised and federated network made of Matrix homeservers. There isn't much more to say at the current time, because most of the specifics are still being discussed, but you can have a look at the repositories in [Informo's GitHub organisation](https://github.com/Informo) which should give you a broad idea of how the project would articulate itself around the Matrix ecosystem.
