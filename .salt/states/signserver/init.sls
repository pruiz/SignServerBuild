{% import "java/macros.lib.sls" as java %}
{% import "jboss/macros.lib.sls" as jboss %}

{% set data = salt['pillar.get']('signserver', {}) %}
{% set version = salt['pillar.get']('signserver:version', none) %}
{% set config = salt['pillar.get']('signserver:config', {}) %}

{% if config|length > 0 %}
{% set extra = { 
     'require_in': [{ 
      'service': 'jbossas'
     }] 
   } 
%}
{{ java.properties('/etc/signserver/signserver.conf', config, extra) }}
{% endif %}
