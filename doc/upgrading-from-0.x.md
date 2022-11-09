# Upgrading Server CE/Pro with a DB that was used since Server CE/Pro version 0.x

Thank you for your continued trust in Overleaf as a long term customer of Server Pro!

> **Note**
> For reference Server CE/Pro version 1.x was released in 2017.
>
> If you are still using 0.x and plan to upgrade, please do so one major version at a time
(e.g. from 0.6.3 to 1.24, then 2.7.1, then the [latest release of `3.x.x`](https://github.com/overleaf/overleaf/wiki/Release-Notes-3.x.x)).

## Potential issues when upgrading to version 3.x

### Duplicate indexes

> MongoError: Error during migrate "20190912145023_create_projectInvites_indexes": Index      with name: expires_1 already exists with different options

Early versions of Server CE/Pro had their indexes defined inline in the model layer of the application.
The indexes were automatically created/updated as needed by an application framework.

We have since moved to explicit creation/removal of indexes as part of migration scripts.
Some of these very early indexes were not taken into account when writing these new migrations.

The `expires_1` index in the `projectInvites` collection is one of these old indexes that needs to be recreated with different parameters.
It is safe to delete it when the application (Server CE/Pro) is not running.

```shell
# Change the directory to the root of the toolkit checkout. E.g.:
# cd ~/toolkit

# Stop the application
bin/docker-compose stop sharelatex

# Check the existing indexes
echo 'db.projectInvites.getIndexes()' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output:
#    [
#            {
#                    "v" : 2,
#                    "key" : {
#                            "_id" : 1
#                    },
#                    "name" : "_id_"
#            },
#            {
#                    "v" : 2,
#                    "key" : {
#                            "expires" : 1
#                    },
#                    "name" : "expires_1",
#                    "expireAfterSeconds" : 2592000,
#                    "background" : true
#            }
#    ]

# Also check for completed migrations
echo 'db.migrations.count({"name":"20190912145023_create_projectInvites_indexes"})' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output:
#    0

# If the output of any of the two above commands does not match, stop here.
# Please reach out to support@overleaf.com for assistance and provide the output.


# If the output matches, continue below.
# Drop the expires_1 index
echo 'db.projectInvites.dropIndex("expires_1")' | bin/docker-compose exec -T mongo mongo sharelatex

# Start the application again
bin/docker-compose start sharelatex
```
