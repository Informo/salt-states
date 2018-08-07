{%- set distro = grains.get('oscodename') %}

{%- if 'synapse' in pillar.get('roles', []) %}
  {%- set repos = [ 'matrix' ] %}
{%- else %}
  {%- set repos = [ ] %}
{%- endif %}

{%- if repos|length > 0 %}
include:
{% for repo in repos %}
  - apt.{{ distro }}.{{ repo }}
{% endfor %}
{%- endif %}

apt-transport-https:
  pkg.installed
