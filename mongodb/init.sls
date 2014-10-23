{% from 'mongodb/map.jinja' import mongodb with context %}
{% from 'logstash/lib.sls' import logship with context %}
{% from 'firewall/lib.sls' import firewall_enable with context %}

mongodb-org-apt-key:
  cmd.run:
    - name: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    - unless: apt-key list | grep '7F0CEB10'

mongodb-org-deb:
  pkgrepo.managed:
    - humanname: Official MongoDB Org Repo
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - file: /etc/apt/sources.list.d/mongodb-org.list
    - require:
      - cmd: mongodb-org-apt-key

mongodb-org:
  pkg.installed:
    - require:
      - pkgrepo: mongodb-org-deb

/usr/local/bin/preconfigure_mongodb_database:
  file.managed:
    - mode: 755
    - user: root
    - group: root 
    - source: salt://mongodb/files/preconfigure_mongodb_database

preconfigure-mongodb-database:
  cmd.run:
    {% if 'mongodb_admin_password' in pillar %}
    - name: "/usr/local/bin/preconfigure_mongodb_database {{mongodb.dbpath}} {{ pillar['mongodb_admin_password']}}"
    {% else %}
    - name: "/usr/local/bin/preconfigure_mongodb_database {{mongodb.dbpath}}"
    {% endif %}
    - unless: test -f {{mongodb.dbpath}}/DB_IS_CONFIGURED
    - require:
      - pkg: mongodb-org
      - file: /usr/local/bin/preconfigure_mongodb_database
      - file: {{mongodb.dbpath}}

mongod:
  service.running:
    - name: mongod
    - enable: True
    - require:
      - cmd: preconfigure-mongodb-database
      - file: {{mongodb.dbpath}}
    - watch:
      - file: /etc/mongod.conf

/etc/mongod.conf:
  file:
    - managed
    - source: salt://mongodb/templates/mongod.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: preconfigure-mongodb-database

{{mongodb.dbpath}}:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 750
    - makedirs: True
    - require:
      - pkg: mongodb-org

{% if mongodb.key_string %}
/etc/mongodb.key:
  file.managed:
   - user: mongodb
   - group: mongodb
   - mode: 600
   - contents_pillar: mongodb:key_string
{% endif %}

/usr/local/bin/initiate_replica_set:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/initiate_replica_set

/usr/local/bin/reindex_mongo_database:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/reindex_mongo_database

/usr/local/bin/restore_mongo_database:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/restore_mongo_database

/usr/local/bin/create_mongo_user:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://mongodb/files/create_mongo_user

{% for dbname, definition in mongodb.databases.iteritems() %}
{{ definition.user }}_on_{{ dbname }}:
  cmd.run:
    {% if 'mongodb_admin_password' in pillar %}
    - name: "create_mongo_user -u admin -p {{ pillar['mongodb_admin_password'] }} {{ definition.dbname }} {{ definition.user }} {{ definition.password }}"
    {% else %}
    - name: "create_mongo_user {{ definition.dbname }} {{ definition.user }} {{ definition.password }}"
    {% endif %}
    - require:
      - service: mongod
      - file: /usr/local/bin/create_mongo_user

{% endfor %}


{{ firewall_enable('mongodb',27017,'tcp') }}
