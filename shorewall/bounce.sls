include:
  - shorewall

{%- set public_ip = salt['pillar.get']('network:public_ip', '127.0.0.1') %}
{%- set ssh_port = salt['pillar.get']('network:public_ssh_port', 22) %}

/etc/shorewall/rules.d/bounce.rules:
  file.managed:
    - source: salt://shorewall/files/rules.d/bounce.rules
    - mode: 440
    - user: root
    - group: root
    - template: jinja
    - context:
      public_ip: {{ public_ip }}
      ssh_port: {{ ssh_port }}
