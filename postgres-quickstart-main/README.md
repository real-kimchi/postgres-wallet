# Postgres Playground
This is docker-compose I used to set up the Postgres playground I was using in class.  You should be able to use this environment to reproduce the steps we performed in class, and to test out your SQL code as you work through the database project.

# Quickstart

## Start the Server
Open a new command terminal = terminal-1.

In terminal 1, run the following:

```
docker-compose up pgserver
```
This starts up the centralized Postgres server.  This runs on a virtual subnet with the hostname pgserver with a default admin account set up: username `postgres`; password `secret`.

## Start the first client
In another terminal -- terminal 2 -- run the following:

```
docker-compose run pgclient
```
This runs `psql`, the postgres command-line client and connects to the `pgserver` host.

When prompted for the password enter `secret`

## (Optional) Start the second client
You can connect from multiple clients simultaneously.  This is helpful 
for demonstrating how the Postgres server handles concurrent requests.

To do this, open another terminal -- we'll call it terminal 3 -- and repeat the steps you performed in terminal 2: run `docker-compose run pgclient`, enter the password.

You should be able to reproduce the transaction exercises we did in class.


# Caveat
The database server running in the `pgserver` container is storing to the container's local disk. When you shut down your container, this will be lost.
