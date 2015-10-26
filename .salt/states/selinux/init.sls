selinux:
  pkg.installed:
    - pkgs:
      - selinux-policy
      - selinux-policy-targeted
      - policycoreutils-python
      - libselinux-python

selinux-state:
  selinux.mode:
    - name: permissive
    - require:
      - pkg: selinux
