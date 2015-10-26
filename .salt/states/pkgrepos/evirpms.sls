{% if grains['os'] == 'CentOS' %}
{% set server = 'lisa.crt0.net' -%}
{% for rname in salt.pillar.get('pkgrepos:evirpms:repolist', [ 'common', 'devel', 'staging', 'stable' ]) -%}
pkgrepo-evirpms-{{ rname }}:
  pkgrepo:
    - managed
    - name: evirpms-{{ rname }}
    - humanname: EVICERTIA ({{ rname }}) RPMs Repository ($releasever - $basearch)
    - baseurl: https://{{ server }}/packages/evirpms/{{ rname }}/el$releasever/$basearch
    - gpgkey: https://{{ server }}/packages/evirpms/EVI-GPG-KEY
    - gpgcheck: 1
    - enabled: {{ 1 if salt.pillar.get('pkgrepos:evirpms-' ~ rname ~ ':enabled', False) else 0  }}
    - sslverify: 1
    - sslclientcert: /etc/pki/tls/certs/localhost.crt
    - sslclientkey: /etc/pki/tls/private/localhost.key

{% endfor %}
{% endif %}
