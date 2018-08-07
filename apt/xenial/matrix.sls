matrix.repo:
  pkgrepo.managed:
    - humanname: matrix.org
    - name: deb https://matrix.org/packages/debian xenial main
    - dist: xenial
    - keyid: C35EB17E1EAE708E6603A9B3AD0592FE47F0DF61
    - keyserver: keys.gnupg.net
    - refresh_db: true
    - require:
      - pkg: apt-transport-https
