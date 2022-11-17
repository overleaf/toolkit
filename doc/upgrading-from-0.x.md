# Upgrading Server CE/Pro with a DB that was used since Server CE/Pro version 0.x

Thank you for your continued trust in Overleaf as a long term customer of Server Pro!

> **Note**
> For reference: Server CE/Pro version 1.x was released in 2017.
>
> If you are still using 0.x and plan to upgrade, please do so one major version at a time
(e.g. from 0.6.3 to 1.24, then 2.7.1, then the [latest release of `3.x.x`](https://github.com/overleaf/overleaf/wiki/Release-Notes-3.x.x)).

## Potential issues when upgrading to version 3.x

### Duplicate indexes

#### projectInvites

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
# Expected output variant 1 (use of Server CE from August 2016, changed `expireAfterSeconds` attribute):
#    [
#            ...
#            {
#                    "v" : 2,
#                    "key" : {
#                            "expires" : 1
#                    },
#                    "name" : "expires_1",
#                    "expireAfterSeconds" : 2592000,
#                    "background" : true
#            }
#            ...
#    ]

# Expected output variant 2 (use of an old mongodb version, offending `"safe":null` attribute):
#    [
#            ...
#            {
#                    "v" : 2,
#                    "key" : {
#                            "expires" : 1
#                    },
#                    "name" : "expires_1",
#                    "expireAfterSeconds" : 10,
#                    "background" : true,
#                    "safe": null
#            }
#            ...
#    ]


# Also check for completed migrations
echo 'db.migrations.count({"name":"20190912145023_create_projectInvites_indexes"})' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output:
#    0

# If the output of any of the two above commands does not match, stop here.
# Please reach out to support@overleaf.com for assistance and provide the output.


# If the output matches, continue below.
# Drop the expires_1 index
echo 'db.projectInvites.dropIndex("expires_1")' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output (NOTE: the "nIndexesWas" number may differ)
#    { "nIndexesWas" : 3, "ok" : 1 }

# Start the application again
bin/docker-compose start sharelatex
```

#### templates

> MongoError: Error during migrate "20190912145030_create_templates_indexes": Index with name: project_id_1 already exists with different options

See comment in projectInvites section.

It is safe to delete the `project_id_1` index for re-creation by the `20190912145030_create_templates_indexes` migration.
The `user_id_1` and `name_1` indexes are likely affected as well, and you can delete them right away as well.
Please make sure that the application (Server CE/Pro) is not running.

```shell
# Change the directory to the root of the toolkit checkout. E.g.:
# cd ~/toolkit

# Stop the application
bin/docker-compose stop sharelatex

# Check the existing indexes
echo 'db.templates.getIndexes()' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output (use of an old mongodb version, offending `"safe":null` attribute):
#    [
#        ...
#        {
#                "v" : 1,
#                "key" : {
#                        "name" : 1
#                },
#                "name" : "name_1",
#                "ns" : "sharelatex.templates",
#                "background" : true,
#                "safe" : null
#        },
#        {
#                "v" : 1,
#                "unique" : true,
#                "key" : {
#                        "project_id" : 1
#                },
#                "name" : "project_id_1",
#                "ns" : "sharelatex.templates",
#                "background" : true,
#                "safe" : null
#        },
#        {
#                "v" : 1,
#                "key" : {
#                        "user_id" : 1
#                },
#                "name" : "user_id_1",
#                "ns" : "sharelatex.templates",
#                "background" : true,
#                "safe" : null
#        }
#    ]

# Also check for completed migrations
echo 'db.migrations.count({"name":"20190912145030_create_templates_indexes"})' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output:
#    0

# If the output of any of the two above commands does not match, stop here.
# Please reach out to support@overleaf.com for assistance and provide the output.


# If the output matches, continue below.
# Drop the project_id_1, user_id_1 and name_1 index
echo 'db.templates.dropIndex("project_id_1")' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output (NOTE: the "nIndexesWas" number may differ)
#    { "nIndexesWas" : 4, "ok" : 1 }
echo 'db.templates.dropIndex("user_id_1")' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output (NOTE: the "nIndexesWas" number may differ)
#    { "nIndexesWas" : 3, "ok" : 1 }
echo 'db.templates.dropIndex("name_1")' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output (NOTE: the "nIndexesWas" number may differ)
#    { "nIndexesWas" : 2, "ok" : 1 }

# Start the application again
bin/docker-compose start sharelatex
```

### Users with non-unique emails

> MongoError: Error during migrate "20190912145032_create_users_indexes": E11000 duplicate      key error collection: sharelatex.users index: email_case_insensitive collation

Older versions of Server Pro did not normalize emails sufficiently to ensure that unique emails are used by different users.

Server Pro 3.x applies stricter normalization. It is possible that old databases have users with non-unique emails. 

The first step is identifying the scope of this issue:

```shell
# Change the directory to the root of the toolkit checkout. E.g.:
# cd ~/toolkit

# list emails that have more than one related user when normalized to lower case.
echo 'db.users.aggregate([{"$group":{"_id":{"$toLower":"$email"},"count":{"$sum":1}}},{"$match":{"count":{"$gt":1}}}])' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output
#    { "_id" : "foo@bar.com", "count" : 2 }
#    ...
```

There are two options to deal with a duplicate.

> **Note** Please take a DB backup before making any of these changes.

1. You can change the email address of one of these account (see query below) and deal with the project access later.
2. Do that later task now:
   1. You will need to check the contents of both accounts and decide which of these should be the primary account moving forward.
   2. The admin panel of Server Pro can help here, and you can find it under "https://<your-server-pro-domain>/admin/user" (requires an admin account).
   3. On this page you can enter the users email address, and it should display two user entries (if not, try different casing, see query below).
   4. When you click on the individual list entries you should see a user info page.
   5. The "projects" tab lists all the users projects.
   6. You will need to transfer the ownership of each of these projects into the desired account using the "Transfer ownership" button.
   7. Once all projects are migrated out of one account, you can use the "Delete User" button on the admin user info page. (The user deletion here is a soft-deletion and you can restore it later if needed.)

```shell
# Change the directory to the root of the toolkit checkout. E.g.:
# cd ~/toolkit

# Change the email of one of the accounts and deal with the project access later.
# Replace the three placeholders "foo@bar.com" with an actual email address that has two related users.
# The "^" and "$" characters around the email ensure that we do not match similar emails, e.g. "this-is-not-foo@bar.com" also contains "foo@bar.com".
echo 'db.users.updateOne({"email":/^foo@bar.com$/i},{"$set":{"email":"duplicate-foo@bar.com","emails.0.email":"duplicate-foo@bar.com"}})' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output
#    { "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
``` 

```shell
# Change the directory to the root of the toolkit checkout. E.g.:
# cd ~/toolkit
# Find exact casing of the email addresses
# Replace the placeholder "foo@bar.com" with an actual email address that has two related users.
# The "^" and "$" characters around the email ensure that we do not match similar emails, e.g. "this-is-not-foo@bar.com" also contains "foo@bar.com".
echo 'db.users.find({"email":/^foo@bar.com$/i},{"email":1})' | bin/docker-compose exec -T mongo mongo --quiet sharelatex
# Expected output
#    { "_id" : ObjectId("637276cd42fab6008ec8c88c"), "email" : "foo@bar.com" }
#    { "_id" : ObjectId("637276cd42fab6008ec8c88d"), "email" : "FOO@bar.com" }
```

Please do not hesitate to reach out to [support@overleaf.com](mailto:support@overleaf.com) if you have any questions or concerns about this process. We are happy to help!
