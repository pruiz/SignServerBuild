{% if grains['os'] == 'CentOS' %}
include:
  - epel
  - .netway
  - .evirpms
  - .jpackage
  - .deprecated
{% endif %}
