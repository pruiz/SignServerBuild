salt-minion:
  pkg.installed: []
  service.dead:
    - enable: False
