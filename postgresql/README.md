# postgresql

There's two states here:

## postgresql

This state only installs PostgreSQL once its external volume has been mounted. It doesn't use any pillar.

## postgresql.node

This state calls the `postgresql` state to install PostgreSQL, then proceeds to create a PostgreSQL user and database for Synapse. In order to do that, Synapse's PostgreSQL password must be provided as a pillar:

```yaml
postgresql:
  password: xxxxxxxxxx
```
