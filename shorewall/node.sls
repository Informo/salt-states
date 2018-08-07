include:
  - shorewall

{%- set public_ip = salt['pillar.get']('public:ip', '127.0.0.1') %}

/etc/shorewall/rules.d/synapse.rules:
  file.managed:
    - source: salt://shorewall/files/rules.d/synapse.rules
    - mode: 440
    - user: root
    - group: root
    - template: jinja
    - context:
      public_ip: {{ public_ip }}

/etc/shorewall/rules.d/caddy.rules:
  file.managed:
    - source: salt://shorewall/files/rules.d/caddy.rules
    - mode: 440
    - user: root
    - group: root
    - template: jinja
    - context:
      public_ip: {{ public_ip }}
