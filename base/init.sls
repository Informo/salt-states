core:
  group.present

ubuntu:
  user.absent:
    - purge: True

{%- if 'synapse' in pillar.get('roles', []) %}
synapse_user:
  user.present:
    - name: matrix-synapse
    - uid: 113
    - gid: nogroup
    - home: /var/lib/matrix-synapse
{%- endif %}

{%- if ('postgresql' in pillar.get('roles', []) or
        'postgresql.node' in pillar.get('roles', [])) %}
postgres:
  user.present:
    - uid: 112
    - home: /var/lib/postgresql
    - optional_groups:
      - ssl-cert
{%- endif %}

{%- if 'caddy' in pillar.get('roles', []) %}
http:
  user.present
{%- endif %}
