include:
  - apt
  - volumes
  - postgresql

{%- set pgpasswd = salt['pillar.get']('postgresql:password', '') %}
{%- set server_name = salt['pillar.get']('synapse:server_name', salt['grains.get']('fqdn', '')) %}
{%- set registration_enabled = salt['pillar.get']('synapse:registration_enabled', 'False') %}
{%- set guest_registration = salt['pillar.get']('synapse:guest_registration', 'False') %}
{%- set bind_address_fallback = salt['pillar.get']('public:ip', '127.0.0.1') %}
{%- set addresses = salt['pillar.get']('vrack_addresses', {}) %}
{%- set host = salt['grains.get']('host', '') %}
{%- set bind_address = addresses.get(host, {}).get('address', bind_address_fallback) %}
{%- set pepper = salt['pillar.get']('synapse:pepper', '') %}

python-psycopg2:
  pkg.installed:
    - refresh: True
    - require:
      - pkg: postgresql

matrix-synapse:
  pkg.installed:
    - refresh: True
    - require:
      - pkgrepo: matrix.repo
      - mount: /var/lib/matrix-synapse
  service.running:
    - restart: True
    - enable: True
    - watch:
      - file: /etc/matrix-synapse/homeserver.yaml
    - require:
      - file: /etc/matrix-synapse/homeserver.yaml
      - pkg: python-psycopg2

/etc/matrix-synapse/homeserver.yaml:
  file.managed:
    - source: salt://synapse/conf_files/homeserver.yaml
    - user: matrix-synapse
    - group: nogroup
    - mode: 600
    - template: jinja
    - context:
      postgresql_password: {{ pgpasswd }}
      registration_enabled: {{ registration_enabled }}
      guest_registration: {{ guest_registration }}
      bind_address: {{ bind_address }}
      pepper: {{ pepper }}
    - require:
      - pkg: matrix-synapse
      - file: /etc/matrix-synapse/log.yaml
      - file: /etc/matrix-synapse/conf.d
      - file: /etc/matrix-synapse/conf.d/report_stats.yaml
      - file: /etc/matrix-synapse/conf.d/server_name.yaml

/etc/matrix-synapse/log.yaml:
  file.managed:
    - source: salt://synapse/conf_files/log.yaml
    - user: matrix-synapse
    - group: nogroup
    - mode: 600
    - require:
      - pkg: matrix-synapse

/etc/matrix-synapse/conf.d:
  file.directory:
    - user: matrix-synapse
    - group: nogroup
    - mode: 700
    - require:
      - pkg: matrix-synapse

/etc/matrix-synapse/conf.d/report_stats.yaml:
  file.managed:
    - source: salt://synapse/conf_files/conf.d/report_stats.yaml
    - user: matrix-synapse
    - group: nogroup
    - mode: 600
    - require:
      - pkg: matrix-synapse
      - file: /etc/matrix-synapse/conf.d

/etc/matrix-synapse/conf.d/server_name.yaml:
  file.managed:
    - source: salt://synapse/conf_files/conf.d/server_name.yaml
    - user: matrix-synapse
    - group: nogroup
    - mode: 600
    - template: jinja
    - context:
      server_name: {{ server_name }}
    - require:
      - pkg: matrix-synapse
      - file: /etc/matrix-synapse/conf.d
