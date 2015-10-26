{% if grains['os_family'] == 'RedHat' %}
yum-plugin-versionlock:
  pkg.installed

redhat-lsb-core:
  pkg.installed

{% set packages = salt['pillar.get']('packages', {})|dictsort %}
{% for pkg, data in packages %}
{%   set values = [] %}
{%   set settings = {} if data is none else data %}
{%   set ensure =  settings.ensure|default('installed') %}
{%   if 'ensure' in settings %}
{%     do settings.remove('ensure') %}
{%   endif %}
{%   if not 'name' in settings %}
{%     do settings.update({ 'name': pkg }) %}
{%   endif %}
{%   if not 'fromrepo' in settings %}
{%     do settings.update({ 'fromrepo': 'base,update' }) %}
{%   endif %}
{%   for key, value in settings|dictsort %}
{%     do values.append({ key: value }) %}
{%   endfor %}
'package::{{ pkg }}':
  pkg.{{ ensure }}: {{ values|yaml }}
{% endfor %}

{% endif %}
