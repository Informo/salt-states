include:
  - postgresql

{%- set synapse_passwd = salt['pillar.get']('postgresql:password', '') %}

synapse:
  postgres_user.present:
    - password: {{ synapse_passwd }}
    - require:
      - pkg: postgresql
  postgres_database.present:
    - owner: synapse
    - require:
      - postgres_user: synapse
