# Completely ignore non-RHEL based systems
{% if grains['os_family'] == 'RedHat' %}

jpackage-gpg-key:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage
    - source: 'salt://pkgrepos/files/RPM-GPG-KEY-jpackage'
    - template: jinja
    - mode: 644

{% set repolist = [ 'generic-free', 'generic-non-free', 'generic-devel'  ] -%}
{% for rname in salt.pillar.get('pkgrepos:jpackage:repolist', repolist ) -%}
{% set dist = rname.split('-', 1)[0] %}
{% set type = rname.split('-', 1)[1] %}
pkgrepo-jpackage-{{ rname }}:
  pkgrepo:
    - managed
    - name: jpackage-{{ rname }}
    - humanname: JPackage ({{ rname }}) RPMs Repository ($releasever - $basearch)
    - mirrorlist: http://www.jpackage.org/mirrorlist.php?dist={{ dist }}&type={{ type }}&release=6.0
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jpackage
    - gpgcheck: 0
    - enabled: {{ 1 if salt.pillar.get('pkgrepos:jpackage-' ~ rname ~ ':enabled', False) else 0  }}
    - require:
      - file: jpackage-gpg-key
      - pkg: epel-release

{% endfor %}

{% endif %}
