=======
mongodb
=======

Formula to set up and configure the mongodb server based around the
packages available from the MongoDB Official Repo.

Also Handles a basic installation of the packaged mongo, in case we are
migrating from that.

** To use the Official Repo, set 'mongodb.use_native_packages: False' **



Backup and Recovery
-------------------

If backupninja is configured, this formula will automatically configure an
hourly backup of Mongo to the /var/backuups/mongodb directory.

This in turn can be backed up to a remote location -- see backupninja-formula
for how to do this.

To recover, and to dump/restore into future versions, there are various
helpers:

- initiate_replica_set
- recover_mongo_database
- reindex_mongo_database

Each tool takes a '-u {user}' and '-p {password}' option, use the admin
password detailed in the pillar data.

Full understanding of Mongo recovery and replica set recovery techniques should
be gleaned from the Mongo documentation, but in brief:

1. Ensure backup data is recovered into a local directory.

2. Salt should have ensured that a basic database is configured, and indexed

3. Add the replica set, with:

   initiate_replica_set -u {user} -p {password} {master-node-fqdn}

4. Recover the mongo databases

   # NB: The default backup location of /var/backups/mongodb is usually correct
   recover_mongo_database -u {user} -p {password} [ -d {backup_extract_location} ]

