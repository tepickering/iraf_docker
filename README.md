# Docker utilities and scripts to run IRAF and PyRAF

These tools help build and run Docker images containing the full [AstroConda](https://astroconda.readthedocs.io/en/latest/) python 2.7/PyRAF/IRAF legacy stack or the [IRAF Community](https://github.com/iraf-community/iraf) Debian/Ubuntu packages. The two main sticking points with running IRAF and PyRaf within a docker container are:

1. Forwarding X11 from the container into the host environment
2. Accessing files on the host and managing permissions between the host and container

The first point can be addressed when the container is run by configuring the DISPLAY variable and mapping the `/tmp/.X11-unix` directory into the container. The second point is most easily addressed by building a custom container that sets up the appropriate user with `uid` and `gid` that match those of the user that built the container.

## Instructions

First, obviously, you need to have Docker installed. The free community edition for all supported platforms can be found at [Docker Hub](https://hub.docker.com/search/?type=edition&offering=community). A set of build scripts facilitate the building of the containers:

* `build.sh` -- Pulls `tepickering/iraf-base` from Docker Hub and builds a container with the permissions and ownership set to your `uid`/`gid`. This uses the AstroConda IRAF stack and includes the STSDAS package as well as the `x11iraf` tools like `ximtool` and `xgterm`. PyRAF is also provided and runs under python 2.7.x.
* `build_community.sh` -- Pulls `tepickering/iraf-community-base` from Docker Hub and builds a personalized container from that. This uses the IRAF Community Debian/Ubuntu packages which don't include things like STSDAS that aren't ported to 64-bit, but do fix the known bugs in the final IRAF 2.16 release and make several other improvements. The PyRAF provided here runs under python 3.8.x and the `x11iraf` tools are now included. The base image for this is also significantly smaller than the base image that contains AstroConda.
* `build_vnc.sh` -- This is a work-in-progress to build a full IRAF scientific desktop that is accessible via VNC.

Once the containers are built, a set of scripts are provided to facilitate running the containers:

* `iraf` -- Runs `cl` within a `xgterm` window from the container built by `build.sh`.
* `iraf-community` -- Runs `irafcl` within a `xgterm` window from the container built by `build_community.sh`.
* `pyraf2` -- Runs PyRAF under python 2.7.x as provided by AstroConda.
* `pyraf3` -- Runs PyRAF under python 3.8.x as provided by the IRAF Community Debian/Ubuntu `python3-pyraf` package.

Each script maps the directory from which it's run into `/home/iraf/data` within the container. The scripts run `iraf`/`pyraf` in that directory and will save their configurations there (e.g. `login.cl`, `uparm`, `.iraf`, etc.). Only the directory you run the script from and any directory below it will be accessible to `iraf`/`pyraf`. If you want to work in a different directory on your host machine that is outside of that tree, you will need to run one of the scripts there to start another container.

Also note, any `ds9` or `ximtool` windows must be opened from the IRAF/PyRAF command-line so that the container's version is used. There might be a way to hack things so that a containerized IRAF can talk to `ds9` running outside of the container, but I haven't explored that. Much easier to just do `!ds9 &` from the CL...

## Known Issues

* Now that the `iraf`/`pyraf` processes are run from the directory that is mounted into the container at run-time, there is persistency in configuration and cache files between sessions. However, this is on a per-directory basis and not globally in one's home directory.

* On OS X, the `xhost` command is required to allow containers to access XQuartz's X11 display. This is not ideal and there should be a smarter way to do this, but none of the possibilities I've tried worked on all platforms. For single-user workstations/laptops this shouldn't be a huge issue since it's only opening access to `localhost`. You must also set "Allow connections from network clients" in `XQuartz->Preferences->Security` for this to work and make sure XQuartz is restarted after making this change. This has been tested under OS X Catalina (10.15.x). Docker provides the 32-bit binary support that OS X has removed.

* Testing under Windows 10 has been limited to running it under Windows Subsystem for Linux, version 2 (WSL2). This is now officially available as of the Windows 10 1904 release. With WSL2 installed and Docker Desktop configured to use it, then these build/run scripts work fine and have been tested with Ubunutu 18.04 and 20.04. They should also work with the other linux distributions supported by WSL2. An X server is required and [VcXsrv](http://vcxsrv.sourceforge.net) is recommended. It must be launched and running before the iraf or pyraf scripts are run. It does not appear to be necessary to disable access control under WSL2 so running XLaunch and accepting the defaults should be sufficient.
