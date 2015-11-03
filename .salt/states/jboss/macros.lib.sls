
{% macro application(
        name,
        data
    )
%}

{{ 'jboss-application:' ~ name }}:
  file.symlink:
    - name: /var/lib/jbossas/server/default/deploy/{{ salt['file.basename'](data.archive) }}
    - target: {{ data.archive }}
    - require:
      - pkg: jbossas

{% endmacro %}
