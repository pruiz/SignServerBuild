{% import "jboss/macros.lib.sls" as macros %}
{% set data = salt.pillar.get('jboss', {}) %}
{% set version = salt.pillar.get('jboss:version', none) %}
{% set config = salt.pillar.get('jboss:config', none) %}
{% set server = salt.pillar.get('jboss:server', none) %}
{% set apps = salt.pillar.get('jboss:applications', {})|dictsort %}

jbossas:
  pkg.installed:
{% if version != None %}
    - version: {{ version }}
{% endif %}
    - fromrepo: jpackage-generic-free
    - requires:
      - pkgrepo: pkgrepo-jpackage-generic-free
  service.running:
    - enable: True
    - require:
      - pkg: jbossas

/etc/init.d/jbossas:
  file.managed:
    - source: salt://jboss/files/jbossas.initrd
    - user: root
    - group: root
    - mode: 755
    - require_in:
      - service: jbossas
    - watch:
      - pkg: jbossas

{% if config != None %}

/etc/jbossas/jbossas.conf:
  file.managed:
    - source: salt://jboss/files/jboss.settings
    - user: jboss
    - group: jboss
    - mode: 644
    - template: jinja
    - context:
      settings: {{ config|yaml }}
    - watch_in:
      - service: jbossas

{% endif %}

{% if server != None %}
/var/lib/jbossas/server/default/deploy/jbossweb.sar/server.xml:
  file.managed:
    - source: salt://jboss/files/server.xml
    - user: jboss
    - group: jboss
    - mode: 644
    - template: jinja
    - context:
      settings: {{ server|yaml }}
    - watch_in:
      - server: jbossas

{% if server.ssl|default(False) %}

/etc/jbossas/default/server.p12:
  cmd.wait:
    - name: >
       openssl pkcs12 -export \
         -passout "pass:changeit" \
         -out /etc/jbossas/default/server.p12 \
         -inkey /etc/pki/tls/private/localhost.key \
         -in /etc/pki/tls/certs/localhost.crt
    - require_in:
      - file: /var/lib/jbossas/server/default/deploy/jbossweb.sar/server.xml
    - require:
      - pkg: openssl
      - file: /etc/pki/tls/certs/localhost.crt
      - file: /etc/pki/tls/private/localhost.key
    - watch:
      - file: /etc/pki/tls/certs/localhost.crt
      - file: /etc/pki/tls/private/localhost.key
      
{% endif %}
{% endif %}

{% for name, data in apps %}
{{ macros.deploy_link(name, data) }}
{% endfor %}

