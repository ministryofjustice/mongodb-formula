=======
mongodb
=======

Formula to set up and configure the mongodb server based around the
packages available from the MongoDB Official Repo.

Also Handles a basic installation of the packaged mongo, in case we are
migrating from that.

**Please note that:**

- **To use the MongoDB Official Repo on Ubuntu 12.04, set 'mongodb.use_native_packages: False'**
- **To use the Ubuntu Repo on Ubuntu 14.04, set 'mongodb.use_native_packages: True'**

**See UPGRADING.md for more info on this**


Backup and Recovery
-------------------

If backupninja is configured, this formula will automatically configure an
hourly ``mongodump`` backup of Mongo to the /var/backuups/mongodb directory.

This in turn can be backed up to a remote location -- see backupninja-formula
for how to do this.

To recover, and to dump/restore into future versions, there are various
helpers:

- ``mongo_initiate_replica_set`` - wrapper around replicaSet create/add
- ``mongo_restore_database`` - wrpper around mongorestore
- ``mongo_reindex_database`` - wrapper around db.<collection>.createIndex

Each tool takes a '-u {user}' and '-p {password}' option: use the admin
account for ``mongo_initiate_replica_set`` and ``mongo_restore_database``. Use the
per-database owner account for ``mongo_reindex_database``.

Full understanding of Mongo recovery and replica set recovery techniques should
be gleaned from the Mongo documentation, but in brief:

1. Ensure backup data is recovered into a local directory.

2. Salt should have ensured that a basic database is configured, and indexed

3. Add the replica set, with

::

   mongo_initiate_replica_set -u {user} -p {password} {replica-set-name} {master-node-fqdn}

4. Recover the mongo databases

::

   # NB: The default backup location of /var/backups/mongodb is usually correct
   #     Without a list of database bson dump files to recover, the tool will
   #     recover all bson files found under the backup dir, excluding
   #     system.indexes and system.users (which should be recovered via salt)
   mongo_restore_database -u {user} -p {password} [ -d {backup_extract_location} ]

5. Re-run Salt to add users and indexes

6. Re-add replica set nodes with

::

   mongo_initiate_replica_set -u {user} -p {password} -a {replica-set-name} {master-node-fqdn} {secondary-node-fqdn} {teritary-node-fqdn} ...

Automated Setup for Dev/Test
----------------------------

This Salt Formula by design does not set up a replica set by default. This is
because its setup is typically order dependent -- you would generally set up
a basic replica set, then restore data, then add indexes et al.

Hence, the formula effectively pauses the salt configuration until a basic
replica set is added.

In the case of dev/test setups though, where an empty dataset can be used, it
can be useful to get MongoDB completely set up.

In this case, set the `mongodb.configuration.auto_initiate_replica_set_params`
to be the options needing to be passed to `mongo_initiate_replica_set`. eg::

    mongodb:
      configuration:
        auto_initiate_replica_set_params: '-d 3 mongodb-01.local'

NB: typically a small delay (the '-d 3' should be used, to give the replica set
time to initiate.
