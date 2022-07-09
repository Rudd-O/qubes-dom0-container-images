# Qubes dom0 `mock` and Docker container images

This repository contains buildable container and Fedora `mock` configuration
files you can use to create both Docker container images and Toolbox container
images (they are the same thing).  These are truly minimal images -- the only
three things we install explicitly are bash, systemd and dnf.

The usefulness of this package derives from the fact that creating these
images allows you to build clean-room RPM packages for Qubes OS dom0s without
having to install a separate full (and hard-to-maintain) Qubes OS system plus
its build system.

(I myself had the need to build a Go program that links to Xen 4.15 -- not
available in Fedora 32 but available in its descendant Qubes OS 4.1, available
in Fedora 33 but with a binary that would not run in Qubes OS 4.1 because the
`glibc` package it was compiled against was simply too new.)

That convenience notwithstanding, this setup is obviously not as secure to
build packages as what the Qubes OS people recommend in their documentation.
In addition to that, this project does *not* have as a goal to actually build
fully functional chroots of Qubes OS which you can deploy and then run on
bare metal hardware.

Each subdirectory contains files corresponding to the Qubes OS release named
after the subdirectory name.

## Instructions

### Using the mock files

* `cd` into any version subdirectory.
* `mock -r qubes-*-*.cfg init`.

This will initialize a `mock` jail you can use to build RPMs for that Qubes
OS version.  You can then use `mock -r <command> <parameters>` as normal.

`mock` on your system may fail to run if your user is not part of the `mock`
group.  You can fix that by:

* either running everything as root, or
* adding yourself to the `mock` group, logging out, and logging back in.

Your call.

## Creating an exploded tree of a Qubes OS system you can chroot into

Note this requires your user to have access to `mock` (see prior heading).
You will almost certainly have to run this `make` target through `sudo`
because the exploded tree has special device files, and those cannot be
created as a regular user.

* Run `make <version>/tree`.

The folder `<version>/tree` will contain the exploded tree.  Not all files
will be able to be restored (in particular device files won't work) unless
you run this as root.

## Creating a container image

This requires `podman` and `make` installed on your local machine.

* Run `make docker/qubes/<version>`.

When done, you'll have a new `podman` OCI container named
`localhost/qubes/<version>`, which you can then use as you see fit.

## Creating a Fedora toolbox

Follow the previous heading, then run:

`toolbox create --image localhost/qubes/<version> myqubesdom0`

You will now have a Toolbox container named `myqubesdom0` based on the Qubes
OS version (`<version>`) you specified.  Enter it with
`toolbox enter myqubesdom0`.
