include:
  - base

{%- if 'synapse' in pillar.get('roles', []) %}
{%- set synapse_uuid = salt['pillar.get']('volumes_uuid:synapse', '') %}
/var/lib/matrix-synapse:
  file.directory:
    - user: matrix-synapse
    - group: nogroup
    - mode: 700
    - require:
      - user: matrix-synapse
  mount.mounted:
    - device: UUID={{ synapse_uuid }}
    - fstype: ext4
    - require:
      - file: /var/lib/matrix-synapse
{%- endif %}

{%- if ('postgresql' in pillar.get('roles', []) or
        'postgresql.node' in pillar.get('roles', [])) %}
{%- set postgresql_uuid = salt['pillar.get']('volumes_uuid:postgresql', '') %}
/var/lib/postgresql:
  file.directory:
    - user: postgres
    - group: postgres
    - mode: 700
    - makedirs: true
    - require:
      - user: postgres
  mount.mounted:
    - device: UUID={{ postgresql_uuid }}
    - fstype: ext4
    - require:
      - file: /var/lib/postgresql
{%- endif %}
