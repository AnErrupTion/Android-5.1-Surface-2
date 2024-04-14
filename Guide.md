# Installation Guide
In this guide, we'll show you how to compile and flash Android 5.1 on a Microsoft Surface 2 device. Let's get started!

## Pre-requisites
To follow along, you'll need:
- A 32 MB (or more) USB flash drive (for booting the payload)
- An 8 GB (or more) SD card (for flashing Android to)
- A Linux distribution with the following programs:
	- `git`
	- `repo`
	- `docker`
	- `dd`
	- `simg2img`
		- Debian/Ubuntu: `android-sdk-libsparse-utils`
		- Fedora: `android-tools`
- [SurfaceRT2-android_6.0.1_sdcard_beta-v2-package.zip](https://files.open-rt.party/android/SurfaceRT2-android_6.0.1_sdcard_beta-v2-package.zip) (the base image we'll use for flashing onto our SD card)

This guide will assume the current working directory contains all required files.

**Note: You can see all modifications that were done on the source code to make it build for the Microsoft Surface 2 [`here`](Modifications.md).**

## Initializing the repository
First, we'll create the directory which will contain the Android source code:

```console
$ mkdir Android4RT2
$ cd Android4RT2
```

Then, we'll initialize the git repository containing the source code we want (though we'll have to patch it later on):

```console
$ repo init --depth=1 -u git://nv-tegra.nvidia.com/manifest/android/binary.git -b rel-tegranote-r8-partner -m secureos/kk_tegratab.xml
```

## Using a custom manifest and Git config
A manifest is an XML file mapping remote repositories to local paths. For example, the `android/platform/external/android-clat` repository is mapped to the local path `external/android-clat`.

We'll have to use a custom manifest because some repositories no longer exists, and/or we don't need some:

```console
$ cp -f ../PatchedFiles/.repo/manifests/.git/config .repo/manifests/.git/
$ cp -f ../PatchedFiles/.repo/manifest.xml .repo/
```

As you can see, we're also overwriting the Git config of the repository. This is done mainly to change the tracking branch.

## Cloning the Android source code
In order to actually clone the source code, we'll have to "synchronize" the source code using our custom manifest:

```console
$ repo sync -j$(nproc --all)
```

This can take quite some time depending on your Internet connection speed and your PC specifications.

## Patching the Android source code
Remember when we said we'll have to patch the source code? Well the `device` directory is essentially what needs to be patched (though in our case we'll have to patch more directories). The `device` directory contains all device-specific files required for making a working Android build on specific devices. While the source code we cloned contains a lot of things for our Tegra 4 chip, it doesn't contain everything, and certainly not for the Microsoft Surface 2. Fortunately, we don't have to modify everything manually, as we can just overwrite everything from the `PatchedFiles` directory's subdirectories into the source code:

```console
$ rm -rf device/nvidia/tegranote7c
$ cp -af ../PatchedFiles/build/* build/
$ cp -af ../PatchedFiles/device/* device/
$ cp -af ../PatchedFiles/packages/* packages/
$ rm -f device/nvidia/common/init.ussrd.rc
```

Additionally, we're removing the `device/nvidia/tegranote7c` directory, because we won't use it.

## Using a custom Linux kernel
However, modifying just the `device` directory isn't *quite* enough. We'll have to make one last modification before we can build Android, and that is to use a custom Linux kernel tailored for the Microsoft Surface 2:

```console
$ rm -rf kernel
$ git clone https://github.com/Open-Surface-RT/android_kernel_nvidia_tegra3 -b microsoft-surface-2 kernel
```

Don't be fooled by the repository name containing `tegra3`, we're cloning a branch containing a kernel specifically designed for the Microsoft Surface 2 (assuming we're building it with the correct defconfig).

## Building an Ubuntu 14.04 container
Well, okay, we lied. There's *one* last step required before building Android.

Unfortunately, Android 5.1, as well as the Linux kernel we're using, are quite old today (both were released sometime in 2014), and that means they won't build on modern Linux distributions without lots of hacks.

But, fortunately for us, we can solve this by creating a container (using Docker for example) with a distribution of the era. We're choosing Ubuntu 14.04 because it was fairly standard at the time, and contains everything we need to build both Android and our custom Linux kernel:

```console
$ cd TrustyDocker
$ cp ~/.gitconfig gitconfig
$ docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) --build-arg username=$(id -un) -t android-build-trusty .
```

This step can take quite some time as it'll download and install lots of packages.

**Note 2: We're copying the current user's gitconfig (make sure you have one!) because it's required by the Android build system.**

## Building Android
*Finally*, we can get around to building Android. This is by far the longest step of the entire guide (obviously). We'll start by going inside our freshly built Docker container:

```console
$ cd ../Android4RT2
$ docker run -it --rm -v "$(pwd)":/src:Z android-build-trusty
```

**Note 3: the `:Z` after the `:src` tells Docker that the directory is private and unshared. This gets around SELinux restrictions for example, particularly on distributions like Fedora.**

Next, we'll export an environment variable telling the Android build system the root of the Android source code:

```console
$ cd /src
$ export TOP=`pwd`
```

Then, we'll extract the NVIDIA driver binaries. This step only needs to be run once:

```console
$ cd vendor/nvidia/licensed-binaries
$ ./extract-nv-bins.sh
$ cd $TOP
```

Finally, let's prepare our environment and build Android:

```console
$ . build/envsetup.sh
$ setpaths
$ lunch tegratab-userdebug
$ mp dev -j$(nproc --all)
$ exit
```

This step *will* take a long time (for example, it takes around 1 hour for a fresh build on an Intel Core i5-11400H laptop with 16 GB of RAM). **Be patient.**

## Copying the target images
After Android finished building, we'll have to prepare our USB flash drive and flash Android to our SD card. But first, we'll copy the required files and unsparse the root system image:

```console
$ cd ..
$ cp -f Android4RT2/out/target/product/tegratab/boot.img .
$ cp -f Android4RT2/out/target/product/tegratab/system.img .
$ simg2img system.img system.unsparse.img
```

**Note 4: We need to "unsparse" the image to get the full raw image, necessary for flashing it wth something like `dd`.**

## Extracting the base image files
We previously downloaded the base Android 6.0.1 image for the Microsoft Surface 2 that we're going to use for flashing, but we first need to extract the files:

```
$ unzip SurfaceRT2-android_6.0.1_sdcard_beta-v2-package.zip -d SurfaceRT2-android_6.0.1_sdcard_beta-v2-package
$ cd SurfaceRT2-android_6.0.1_sdcard_beta-v2-package
$ unxz SurfaceRT2-android_6.0.1_sdcard_beta-v2.img.xz
$ cd ..
```

## Preparing the USB flash drive
The Microsoft Surface 2 is a particularly locked down device, and that's only reinforced by its even more locked down Tegra 4 chip. This is why we're preparing a bootable USB flash drive with a UEFI payload. This UEFI payload exploits a vulnerability in the firmware which allows us to inject and run arbitrary code on the device. This, in turn, allows us to run Linux or, in this case, Android. With that said, let's prepare said USB flash drive:

```console
# mount USB1 /mnt
# cp -a SurfaceRT2-android_6.0.1_sdcard_beta-v2-package/usb-boot/* /mnt/
# cp -f boot.img /mnt/ramdisk.img
# umount /mnt
# eject USB
```

Where `USB` refers to our USB flash drive (with a GPT!), and `USB1` to its FAT32-formatted partition.

## Preparing the SD card and flashing Android
Android is a complex operating system, and so is its installation procedure. To simplify things up, we're going to use an already prepared Android 6.0.1 image for the Microsoft Surface 2.

Don't fret though, we're not installing Marshmallow on our tablet. We're simply going to flash the unsparsed system image to a certain partition on the SD card (and additionally wipe the data partition if needed), because that's where the actual OS files reside. With that said, let's prepare said SD card:

```console
# dd if=SurfaceRT2-android_6.0.1_sdcard_beta-v2-package/SurfaceRT2-android_6.0.1_sdcard_beta-v2.img of=SDCARD bs=512 status=progress
```

And finally, we'll flash said unsparsed system image onto our SD card:

```console
# dd if=system.unsparse.img of=SDCARD3 bs=512 status=progress
```

Where `SDCARD3` refers to the 3rd partition of our SD card, which contains the system partition.

## Booting Android on the Microsoft Surface 2
Booting Android is now as simple as inserting the SD card and plugging the USB flash drive into the tablet, pressing Power while holding Volume Down for 2 to 3 seconds, and waiting until it boots by itself.

However, when arriving at the boot selection menu, you can still select other entries by using the Volume Up/Down buttons to navigate, and pressing Power to select. The first entry should boot right into Android.

## Optional: Wiping the data partition
If you keep reflashing Android for testing purposes, there may be times where you'd like to start fresh, without having to reflash the entire base image again. Fortunately, there's a partition on Android which, if erased, restores the entire system to its factory settings and deletes all user files (think of it as reinstalling your entire OS). This partition is called the `data` partition, and on our SD card, is the 9th partition. If you want to wipe it, you can simply mount it and remove everything inside it:

```console
# mount SDCARD9 /mnt
# rm -rf /mnt/*
# umount /mnt
# eject SDCARD
```

## Optional: Integrating APKs
Although optional, integrating APKs (like those of a file manager or Termux for example) can prove extremely useful for debugging or just for general usage of the device.

Fortunately, integrating APKs at the system level is quite easy. Indeed, just move any APK you want into the `app` directory of the system partition:

```console
# cp MyApp.apk SDCARD3/app
```

Then, upon booting Android, it'll automatically install the APK. However, beware that some apps don't like being installed as a system APK, and will refuse to launch (like Termux for example). In this case, you can install a file manager like [this one](https://f-droid.org/packages/com.github.axet.filemanager) at the system level, and sideload from there.
