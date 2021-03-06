include:
  - base

{%- set public_ip = salt['pillar.get']('network:public_ip', '127.0.0.1') %}
{%- set domain = salt['pillar.get']('caddy:domain', '') %}
{%- set caddy_tag = salt['pillar.get']('caddy:tag', '') %}
{%- set caddy_checksum = salt['pillar.get']('caddy:tar_sha512sum', '') %}
{%- set synapse_host = salt['pillar.get']('caddy:synapse_host', '') %}
{%- set addresses = salt['pillar.get']('int_network:addresses', {}) %}
{%- set synapse_ip = addresses.get(synapse_host, {}).get('address', '127.0.0.1') %}

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
    - name: setcap cap_net_bind_service=+ep /usr/local/bin/caddy-{{ caddy_tag }}
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

/etc/caddy/caddy.conf.d/synapse.conf:
  file.managed:
    - source: salt://caddy/conf_files/synapse.conf
    - user: http
    - group: http
    - mode: 0755
    - template: jinja
    - context:
      public_ip: {{ public_ip }}
      public_fqdn: {{ domain }}
      synapse_ip: {{ synapse_ip }}
    - require:
      - file: /etc/caddy/caddy.conf.d

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

/srv/http:
  file.directory:
    - user: root
    - group: root
    - mode: 0755

{% for dir in [ 'static', 'static/.well-known', 'static/.well-known/matrix' ] %}
/srv/http/{{ dir }}:
  file.directory:
    - user: http
    - group: http
    - mode: 0755
    - require:
      - user: http
{%- endfor %}

{% for file in [ 'server', 'client' ] %}
/srv/http/static/.well-known/matrix/{{ file }}:
  file.managed:
    - source: salt://caddy/well-known/{{ file }}
    - user: http
    - group: http
    - mode: 0644
    - template: jinja
    - context:
      public_domain: {{ domain }}
    - require:
      - file: /srv/http/static/.well-known/matrix
{%- endfor %}
