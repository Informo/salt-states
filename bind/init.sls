{%- set vrack_net = salt['pillar.get']('int_network:ip_range', '127.0.0.1/24') %}
{%- set netip = vrack_net.split('/')[0].split('.') %}
{%- set rev_zone_list = [] %}
{%- for byte in netip[0:3]|reverse %}
  {%- set tmp = rev_zone_list.append(byte) %}
{%- endfor %}
{%- set rev_zone = rev_zone_list|join('.') %}
{%- set int_zone = salt['pillar.get']('int_network:dns_zone', '') %}
{%- set soa = salt['pillar.get']('bind:soa', {}) %}
{%- set ttl = salt['pillar.get']('bind:ttl', 60) %}
{%- set records = salt['pillar.get']('bind:records', []) %}
{%- set fqdn = salt['grains.get']('fqdn', '') %}

bind9:
  pkg.installed:
    - refresh: True
  service.running:
    - enable: True
    - watch:
      - /etc/bind/named.conf.local
      - /etc/bind/named.conf.options
      - /var/lib/bind/{{ int_zone }}
      - /var/lib/bind/{{ rev_zone }}.in-addr.arpa

/etc/bind/named.conf.local:
  file.managed:
    - source: salt://bind/conf_files/named.conf.local
    - mode: 440
    - user: bind
    - group: bind
    - template: jinja
    - context:
      int_zone: {{ int_zone }}
      rev_zone: {{ rev_zone }}
    - require:
      - pkg: bind9

/etc/bind/named.conf.options:
  file.managed:
    - source: salt://bind/conf_files/named.conf.options
    - mode: 440
    - user: bind
    - group: bind
    - template: jinja
    - context:
      vrack_net: {{ vrack_net }}
    - require:
      - pkg: bind9

/var/lib/bind/{{ int_zone }}:
  file.managed:
    - source: salt://bind/conf_files/zones/internal
    - mode: 440
    - user: bind
    - group: bind
    - template: jinja
    - context:
      int_zone: {{ int_zone }}
      soa: {{ soa }}
      ttl: {{ ttl }}
      records: {{ records }}
      fqdn: {{ fqdn }}
    - require:
      - pkg: bind9

/var/lib/bind/{{ rev_zone }}.in-addr.arpa:
  file.managed:
    - source: salt://bind/conf_files/zones/reverse
    - mode: 440
    - user: bind
    - group: bind
    - template: jinja
    - context:
      rev_zone: {{ rev_zone }}
      int_zone: {{ int_zone }}
      soa: {{ soa }}
      ttl: {{ ttl }}
      records: {{ records }}
      fqdn: {{ fqdn }}
    - require:
      - pkg: bind9
