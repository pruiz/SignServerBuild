/etc/pki/tls/certs/localhost.crt:
  file.managed:
    - source: salt://core/files/localhost.crt

/etc/pki/tls/private/localhost.key:
  file.managed:
    - source: salt://core/files/localhost.key

