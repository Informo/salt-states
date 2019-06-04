include:
  - base

{%- set public_ip = salt['pillar.get']('public:ip', '127.0.0.1') %}
{%- set public_fqdn = salt['pillar.get']('public:fqdn', '') %}
{%- set caddy_tag = salt['pillar.get']('caddy:tag', '') %}
{%- set caddy_checksum = salt['pillar.get']('caddy:tar_sha512sum', '') %}
{%- set synapse_vrack_ip = salt['pillar.get']('synapse_vrack_ip', '127.0.0.1') %}

/home/http/caddy:
  file.directory:
    - user: http
    - group: http
    - mode: 0700
    - require:
      - user: http
  archive.extracted:
    - name: /home/http/caddy
    - source: https://github.com/mholt/caddy/releases/download/{{ caddy_tag }}/caddy_{{ caddy_tag }}_linux_amd64.tar.gz
    - source_hash: {{ caddy_checksum }}
    - enforce_toplevel: False
    - user: http
    - group: http
    - mode: 0600
    - if_missing: /usr/local/bin/caddy-{{ caddy_tag }}
    - require:
      - file: /home/http/caddy

/usr/local/bin/caddy-{{ caddy_tag }}:
  file.copy:
    - source: /home/http/caddy/caddy
    - user: http
    - group: http
    - mode: 0755
    - require:
      - archive: /home/http/caddy

/usr/local/bin/caddy:
  file.symlink:
    - target: /usr/local/bin/caddy-{{ caddy_tag }}
    - force: True
    - user: http
    - group: http
    - mode: 0755
    - require:
      - file: /usr/local/bin/caddy-{{ caddy_tag }}

caddy_cap_net:
  cmd.run:
    - name: setcap cap_net_bind_service=+ep /usr/local/bin/caddy
    - require:
      - file: /usr/local/bin/caddy

/var/lib/caddy:
  file.directory:
    - user: http
    - group: http
    - mode: 0700
    - require:
      - user: http

{% for dir in [ 'caddy', 'caddy/caddy.conf.d' ] %}
/etc/{{ dir }}:
  file.directory:
    - user: http
    - group: http
    - mode: 0755
    - require:
      - user: http
{%- endfor %}

/etc/caddy/caddy.conf:
  file.managed:
    - source: salt://caddy/conf_files/caddy.conf
    - user: http
    - group: http
    - mode: 0755
    - require:
      - file: /etc/caddy

{%- if 'synapse' in pillar.get('roles', []) or 'ha' in pillar.get('roles', []) %}
/etc/caddy/caddy.conf.d/synapse.conf:
  file.managed:
    - source: salt://caddy/conf_files/synapse.conf
    - user: http
    - group: http
    - mode: 0755
    - template: jinja
    - context:
      public_ip: {{ public_ip }}
      public_fqdn: {{ public_fqdn }}
      synapse_vrack_ip: {{ synapse_vrack_ip }}
    - require:
      - file: /etc/caddy/caddy.conf.d
{%- endif %}

/usr/lib/systemd/system/caddy.service:
  file.managed:
      - source: salt://caddy/conf_files/caddy.service
      - makedirs: True

caddy:
  service.running:
    - enable: True
    - watch:
      - file: /etc/caddy/caddy.conf
      - file: /etc/caddy/caddy.conf.d/*
      - file: /usr/local/bin/caddy
    - require:
      - file: /usr/local/bin/caddy
      - file: /usr/lib/systemd/system/caddy.service
      - file: /var/lib/caddy
      - file: /etc/caddy/caddy.conf
      - cmd: caddy_cap_net
