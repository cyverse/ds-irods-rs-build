# docker-cyverse-irods-rs

An iRODS resource server that runs in a Docker container. The container is
configured for the CyVerse Data Store.

## Generating the Docker Image

The `build` program can be used to generate a Docker image containing an iRODS
resource server that is configured to serve a given resource within the CyVerse
Data Store. When `build` is executed, it writes a script to stardard output.
This script can be used to start a container from the generated image.  

As its only command line argument, `build` expects the tag that will be assigned
to the generated imaged.

The program expects several environment variables to be set when it is executed.

Environment Variable           | Required | Default       | Description
------------------------------ | -------- | ------------- | -----------
`CYVERSE_DS_CLERVER_USER`      | no       | ipc_admin     | the name of the rodsadmin user representing the resource server within the zone
`CYVERSE_DS_CONTROL_PLANE_KEY` | yes      |               | the encryption key required for communicating over the relevant iRODS grid control plane
`CYVERSE_DS_NEGOTIATION_KEY`   | yes      |               | the encryption key shared by the iplant zone for advanced negotiation during client connections
`CYVERSE_DS_RES_NAME`          | yes      |               | the name of the storage resource that will be served
`CYVERSE_DS_RES_SERVER`        | yes      |               | the FQDN or address used by the rest of the grid to communicate with this server
`CYVERSE_DS_RES_VAULT`         | no       | `$HOME`/vault | the host directory where the container will mount the vault, for the default, `$HOME` is evaluated at container start time
`CYVERSE_DS_ZONE_KEY`          | yes      |               | the shared secret used during server-to-server communication

Here's an example.

```
CYVERSE_DS_CONTROL_PLANE_KEY=SECRET_____32_byte_ctrl_plane_key \
CYVERSE_DS_NEGOTIATION_KEY=SECRET____32_byte_negotiation_key \
CYVERSE_DS_RES_NAME=rs \
CYVERSE_DS_RES_SERVER=rs.domain.net \
CYVERSE_DS_ZONE_KEY=SECRET_zone_key \
./build rs-tag > start-script
```

## Prerequisites

Before this a generated image can be used, there are a few things that need to
be done first.

First, the storage resource needs to be defined within the CyVerse Data Store.
The vault path within the container will be a subdirectory of `/irods_vault`
with the same name as the storage resource being served, i.e.,
`/irods_vault/"$CYVERSE_DS_RES_NAME"`. This can be done with a command like the
following.

```
iadmin mkresc "$CYVERSE_DS_RES_NAME" 'unix file system' \
              "$CYVERSE_DS_RES_SERVER":/irods_vault/"$CYVERSE_DS_RES_NAME"
```

Next, the corresponding coordinating resource needs to be created for the
storage resource. The name of the coordinate resource needs to be the name of
the storage resource with `Res` appended, i.e., `"$CYVERSE_DS_RES_NAME"Res`.
This will be the default resource served by the resource server. This can be
done with a set of commands like the following.

```
coordRes="$CYVERSE_DS_RES_NAME"Res
iadmin mkresc "$coordRes" passthru
iadmin addchildtoresc "$coordRes" "$CYVERSE_DS_RES_NAME"
```

Finally, the vault directory on the server hosting the container needs to
exist and be writable by the user that will be running the container.
