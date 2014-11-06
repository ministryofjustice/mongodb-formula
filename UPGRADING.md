Upgrading
=========

v1.x to v2.x
------------

** HUGE WARNING **

This formula makes a very specific assumption:

* If you're deploying to Ubuntu 14.04, you are deploying afresh.
* If you're deploying to Ubuntu 12.04, you already have Mongo deployed from native packages.

If you fit into one of the above scenarios, all is well initially.

However:

In moving to the v2.x formula, if you are already using the native packages on Ubuntu 14.04
then you *MUST* set 'mongo.use_native_packages' to True. Otherwise, initial deployment will
uninstall your mongo-server.

If deploying to Ubuntu 12.04, and wish to deploy from the official mongo repo, ensure that
you set 'mongo.use_native_packages' to be False. This is to protect most existing deployments
of mongodb.

We recommend deploying new Mongo clusters to Ubuntu 14.04

