include:
  - shorewall

{%- set public_ip = salt['pillar.get']('public:ip', '127.0.0.1') %}
{%- set synapse_host = salt['pillar.get']('caddy:synapse', '') %}
{%- set addresses = salt['pillar.get']('vrack_addresses', {}) %}
{%- set int_ip = addresses.get(synapse_host, {}).get('address', '127.0.0.1') %}

/etc/shorewall/rules.d/synapse.rules:
  file.managed:
    - source: salt://shorewall/files/rules.d/synapse.rules
    - mode: 440
    - user: root
    - group: root
    - template: jinja
    - context:
      int_ip: {{ int_ip }}
