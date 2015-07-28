/etc/logrotate.d/mongodb:
  file:
    - managed
    - source: salt://mongodb/files/logrotate_mongodb
