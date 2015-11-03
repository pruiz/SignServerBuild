{% if grains['os'] == 'CentOS' %}
include:
  - epel
  - .netway
  - .jpackage
  - .deprecated
{% endif %}
