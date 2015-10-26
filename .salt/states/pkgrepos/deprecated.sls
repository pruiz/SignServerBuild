{% for name in [ 'home_crt0solutions_mono', 'home_crt0solutions_boxbackup' ] %}
pkgrepo-{{ name }}-absent:
  pkgrepo.absent:
    - name: {{ name }}
{% endfor %}
