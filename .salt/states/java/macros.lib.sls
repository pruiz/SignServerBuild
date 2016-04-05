{% macro properties (
        file,
        props,
        extra
    )
%}

{{ file }}:
  file.managed:
    - source: salt://java/files/properties
    - makedirs: True
    - template: jinja
    - context:
      properties: {{ props|yaml }}
{% for key, value in (extra|default({})).iteritems() %}
    - {{ key }}: {{ value|yaml }}
{% endfor %}


{% endmacro %}
