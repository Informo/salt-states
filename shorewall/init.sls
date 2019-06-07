{%- set public = salt['pillar.get']('network:interfaces:public', 'ens3') %}
{%- set vrack = salt['pillar.get']('network:interfaces:vrack', 'ens6') %}
{%- set public_ip = salt['pillar.get']('network:public_ip', '127.0.0.1') %}

shorewall:
    pkg.installed:
      - refresh: True
    service.running:
      - enable: True
      - watch:
        - file: /etc/default/shorewall
        - file: /etc/shorewall/masq
        - file: /etc/shorewall/interfaces
        - file: /etc/shorewall/policy
        - file: /etc/shorewall/shorewall.conf
        - file: /etc/shorewall/zones
        - file: /etc/shorewall/params
        - file: /etc/shorewall/rules
        - file: /etc/shorewall/rules.d/*

/etc/default/shorewall:
  file.replace:
    - pattern: "^startup=.*$"
    - repl: "startup=1"
    - prepend_if_not_found: True

{% for file in [ 'shorewall.conf', 'masq', 'policy', 'rules',
'zones', 'params' ] %}
/etc/shorewall/{{ file }}:
  file.managed:
    - source: salt://shorewall/files/{{ file }}
    - mode: 640
    - user: root
    - group: root
    - require:
      - pkg: shorewall
{% endfor %}

/etc/shorewall/interfaces:
  file.managed:
    - source: salt://shorewall/files/interfaces
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - context:
      public: {{ public }}
      vrack: {{ vrack }}
    - require:
      - pkg: shorewall

/etc/shorewall/rules.d:
  file.directory:
    - user: root
    - group: root
    - mode: 750
    - makedirs: True
    - require:
      - pkg: shorewall

/etc/shorewall/rules.d/rules-readme.md:
  file.managed:
    - source: salt://shorewall/files/rules-readme.md
    - mode: 0640
    - user: root
    - group: root
    - require:
      - file: /etc/shorewall/rules.d

{%- if 'caddy' in pillar.get('roles', []) %}
/etc/shorewall/rules.d/caddy.rules:
  file.managed:
    - source: salt://shorewall/files/rules.d/caddy.rules
    - mode: 440
    - user: root
    - group: root
    - template: jinja
    - context:
      public_ip: {{ public_ip }}
{%- endif %}

{%- if 'synapse' in pillar.get('roles', []) %}
/etc/shorewall/rules.d/synapse.rules:
  file.managed:
    - source: salt://shorewall/files/rules.d/synapse.rules
    - mode: 440
    - user: root
    - group: root
    - template: jinja
    - context:
      int_ip: {{ int_ip }}
{%- endif %}

restart_minion_after_firewall_update:
  cmd.run:
    - name: |
        exec 0>&- # close stdin
        exec 1>&- # close stdout
        exec 2>&- # close stderr
        nohup /bin/sh -c 'sleep 2 && salt-call --local service.restart salt-minion' &
    - order: last
    - onchanges:
      - service: shorewall
