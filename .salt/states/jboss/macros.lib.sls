
{% macro deploy_link(
        name,
        data
    )
%}

{{ 'jboss-deploy:' ~ name }}:
  file.symlink:
    - name: /var/lib/jbossas/server/default/deploy/{{ name }}
    - target: {{ data.archive }}
    - require:
      - pkg: jbossas

{% endmacro %}

{% macro deploy_template(
        name,
        data
    )
%}

{{ 'jboss-deploy:' ~ name }}:
  file.managed:
    - name: /var/lib/jbossas/server/default/deploy/{{ name }}
    - source: {{ data.source }}
{% for key,value in (data.context|default({}))|dictsort %}
      {{ key }}: {{ value|yaml }}
{% endfor %}
    - require:
      - pkg: jbossas

{% endmacro %}
