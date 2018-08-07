include:
  - volumes

postgresql:
  pkg.installed:
    - refresh: True
    - require:
      - mount: /var/lib/postgresql
