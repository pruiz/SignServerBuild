{% if grains['os'] == 'CentOS' %}
{% set server = 'dev.crt0.net' -%}
{% for rname in 'extras', 'backports', 'mono' -%}
pkgrepo-netway-{{ rname }}:
  pkgrepo:
    - managed
    - name: netway-{{ rname }}
    - humanname: NetWay ({{ rname }}) RPMs Repository ($releasever - $basearch)
    - baseurl: https://{{ server }}/packages/netway/{{ rname }}/el$releasever/$basearch
    - gpgkey: https://{{ server }}/packages/netway/NW-GPG-KEY
    - gpgcheck: 1

{% endfor %}
{% endif %}
