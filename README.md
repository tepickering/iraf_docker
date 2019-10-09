# Docker utilities and scripts to run IRAF and PyRAF

These tools help build and run Docker images containing the full [AstroConda](https://astroconda.readthedocs.io/en/latest/) python 2.7/PyRAF/IRAF legacy stack or the [IRAF Community](https://github.com/iraf-community/iraf) Debian/Ubuntu packages. The two main sticking points with running IRAF and PyRaf within a docker container are:

1. Forwarding X11 from the container into the host environment
2. Accessing files on the host and managing permissions between the host and container

The first point can be addressed when the container is run to configure the DISPLAY variable and map the `/tmp/.X11-unix` directory into the container. The second point is most easily addressed by building a custom container that sets up the appropriate user with uid and gid that match those of the user that built the container.

## Instructions

First, obviously, you need to have Docker installed. The free community edition for all supported platforms can be found at [Docker Hub](https://hub.docker.com/search/?type=edition&offering=community). A set of build scripts facilitate the building of the containers:

* `build.sh` -- Pulls `tepickering/iraf-base` from Docker Hub and builds a container with the permissions and ownership set to your uid/gid. This uses the AstroConda IRAF stack and includes the STSDAS package as well as the `x11iraf` tools like `ximtool` and `xgterm`. PyRAF is also provided and runs under python 2.7.x.
* `build_community.sh` -- Pulls `tepickering/iraf-community` from Docker Hub and builds a personalized container from that. This uses the IRAF Community Debian/Ubuntu packages which don't include things like STSDAS or `x11iraf`, but does fix some of the known bugs in the final IRAF 2.16.2 release. The PyRAF provided here runs under python 3.6.x.
* `build_vnc.sh` -- This is a work-in-progress to build a full IRAF scientific desktop that is accessible via VNC.

Once the containers are built, a set of scripts are provided to facilitate running the containers:

* `iraf` -- Runs `cl` within a `xgterm` window from the container built by `build.sh`.
* `iraf-community` -- Runs `irafcl` within a `xterm` window from the container built by `build.sh`.
* `pyraf2` -- Runs PyRAF under python 2.7.x as provided by AstroConda.
* `pyraf3` -- Runs PyRAF under python 3.6.x as provided by the IRAF Community Debian/Ubuntu `python3-pyraf` package.

Each script maps the directory from which it's run into `/home/iraf/data` within the container. Anything you want to save must be saved there. All other directories within the container are reset every time the container is run. If you want to work in a different directory on your host machine, you will need to run one of the scripts there to start another container.

## Known Issues

* Because `/home/iraf` in the container is reset every time the container is run, the `epar` settings are not saved between sessions. This is either a blessing or a curse depending on your use case. One advantage of this scheme is that every IRAF/PyRAF session you run is completely separate from any other. Thus `epar` done in one session does not affect any others. Having been bitten by that several times in the past, I rather consider it a blessing.

* The `xhost` command is required to allow containers to access the host's X11 display. This is not ideal and there should be a smarter way to do this, but none of the possibilities I've tried worked on all platforms. For single-user workstations/laptops this shouldn't be a huge issue since it's only opening access to `localhost`. On OS X you must also set "Allow connections from network clients" in `XQuartz->Preferences->Security`.
