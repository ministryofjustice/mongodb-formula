{% from "mongodb/map.jinja" import mongodb with context %}

mongodb-server:
  pkg:
    - installed

python-pymongo:
  pkg:
    - installed
    - require:
      - pkg: mongodb-server

mongod:
  service:
    - name: mongodb
    - running
    - enable: True
    - watch:
      - pkg: mongodb-server
      - file: /etc/mongodb.conf

/etc/mongodb.conf:
  file:
    - managed
    - source: salt://mongodb/mongodb.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644


{{ mongodb.dbpath }}:
  file:
    - directory
    - user: mongodb
    - group: mongodb
    - mode: 750
    - require:
      - pkg: mongodb-server

wait-for-mongodb-server:
  cmd:
    - run
    - name: 'while ! [ -e /tmp/mongodb-27017.sock ]; do sleep 1; done'
    - unless: 'test -e /tmp/mongodb-27017.sock'
    - require:
      - service: mongod
      - file: {{ mongodb.dbpath }}

{% if 'mongodb' in pillar %}
{% for service, definition in pillar['mongodb'].iteritems() %}

{{definition['user']}}_on_{{service}}:
  mongodb_user:
    - present
    - name: {{definition['user']}}
    - host: {{definition['servers'].keys()[0]}}
    - port: {{definition['servers'].values()[0]}}
    - passwd: {{definition['password']}}
    - database: {{definition['dbname']}}
    - require:
      - pkg: python-pymongo
      - service: mongod
      - cmd: wait-for-mongodb-server

{% endfor %}
{% endif %}

{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('mongodb',27017,'tcp') }}
