matrix.repo:
  pkgrepo.managed:
    - humanname: matrix.org
    - name: deb https://packages.matrix.org/debian/ bionic main
    - dist: bionic
    - keyid: AAF9AE843A7584B5A3E4CD2BCF45A512DE2DA058
    - keyserver: keys.gnupg.net
    - refresh_db: true
    - require:
      - pkg: apt-transport-https
