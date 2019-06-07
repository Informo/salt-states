# shorewall

This state installs and configure the [shorewall](http://www.shorewall.net/) firewall configuration tool. So far, only IPv4 traffic is supported (we're working towards supporting IPv6 though). On all hosts, it defines two interfaces in shorewall's configuration, which match the interface to the infrastructure's private network (int in our case) and the public interface. By default it only allows ICMP incoming connections on the public interface, and SSH incoming connections on the private one. It requires both interfaces to be mentioned in the hosts' pillars as such:

```yaml
network:
  interfaces:
    public: ens3
    int: ens6
```

Two more specific states are also present and must be included in a host's `roles` pillar to be executed.

## shorewall.bounce

This state installs a firewall rule that allows all incoming SSH (TCP) traffic on the public interface on a given port, along with DNS traffic. This state is designed to be executed on the SSH bastion. It requires the host's public IP to be mentioned in the host's pillar as such:

```yaml
public:
  ip: xxx.xxx.xxx.xxx
```

## shorewall.node

This state installs a firewall rule that allows incoming HTTP (TCP) traffic on port 8448 (which is used by Synapse for federation). It also installs a firewall rule that allows incoming HTTP(S) (TCP) traffic on ports 80 and 443, which are to be used by Caddy, acting as a reverse proxy in front of Synapse. This state is designed to be executed on a node. It requires the host's public IP to be mentioned in the host's pillar as such:

```yaml
public:
  ip: xxx.xxx.xxx.xxx
```
