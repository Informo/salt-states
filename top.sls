base:
  '*':
    - base
    - users
    - sudoers
    - apt
    - shorewall

{%- for role in [
  'bind',
  'volumes',
  'shorewall.node',
  'shorewall.bounce',
  'postgresql',
  'postgresql.node',
  'synapse',
  'caddy',
  ] %}
  'I@roles:{{ role }}':
    - {{ role }}
{%- endfor %}
