# irods-netcdf-build
The build and packaging logic for the iRODS NetCDF plugins,

It builds the NetCDF plugins in the repo https://github.com/irods/irods_netcdf for the iRODS 4.1.10. It creates packages suitable for CentOS 6 and 7, OpenSUSE 13, and Ubuntu 12.04 and 14.04.

## Requirements

Docker 1 or newer.

## Building

Run the script `build.sh` to buidn the packages for the various operating systems.  The resulting packages will be the appropriate subdirectories under `packages`.

    ? ./build.sh

    ? tree packages
    packages/
    ├── centos-6
    │   ├── irods-api-plugin-netcdf-1.0-centos6.rpm
    │   ├── irods-icommands-netcdf-1.0-centos6.rpm
    │   └── irods-microservice-plugin-netcdf-1.0-centos6.rpm
    ├── centos-7
    │   ├── irods-api-plugin-netcdf-1.0-centos7.rpm
    │   ├── irods-icommands-netcdf-1.0-centos7.rpm
    │   └── irods-microservice-plugin-netcdf-1.0-centos7.rpm
    ├── opensuse-13
    │   ├── irods-api-plugin-netcdf-1.0-suse.rpm
    │   ├── irods-icommands-netcdf-1.0-suse.rpm
    │   └── irods-microservice-plugin-netcdf-1.0-suse.rpm
    ├── ubuntu-12
    │   ├── irods-api-plugin-netcdf-1.0-ubuntu12.deb
    │   ├── irods-icommands-netcdf-1.0-ubuntu12.deb
    │   └── irods-microservice-plugin-netcdf-1.0-ubuntu12.deb
    └── ubuntu-14
        ├── irods-api-plugin-netcdf-1.0-ubuntu14.deb
        ├── irods-icommands-netcdf-1.0-ubuntu14.deb
        └── irods-microservice-plugin-netcdf-1.0-ubuntu14.deb

