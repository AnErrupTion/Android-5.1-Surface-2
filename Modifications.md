# Modifications done in the Android source code
This document explains all modifications made in the `device/nvidia` folder (and in rare cases, outside of it), done to make Android work on the Microsoft Surface 2.

**Note: Android is a very complex OS, and the Microsoft Surface 2 is a very complex device (reinforced by its also very complex Tegra 4 SoC). This means that some files may lack concrete explanation of what some things are (like QSV and the LBH)**

## build/target/product

### generic_no_telephony_no_bluetooth.mk
- A copy of `generic_no_telephony.mk` (in the same directory) that removes the inclusion of Bluetooth packages (as Bluetooth is currently broken on the Microsoft Surface 2 with Android 5.1):

```diff
 # It includes the base Android platform.
 
 PRODUCT_PACKAGES := \
-    Bluetooth \
     Camera2 \
     Gallery2 \
     Music \
```

## device/nvidia/common

### Android.mk
- Removes the inclusion of the `init.ussrd.rc` file in the same directory (see below):

```diff
 LOCAL_MODULE_TAGS := optional
 include $(NVIDIA_PREBUILT)
 
-# init.ussrd.rc
-include $(NVIDIA_DEFAULTS)
-LOCAL_SRC_FILES := init.ussrd.rc
-LOCAL_MODULE := init.ussrd
-LOCAL_MODULE_SUFFIX := .rc
-LOCAL_MODULE_CLASS := ETC
-LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
-include $(NVIDIA_PREBUILT)
-
 include $(call all-makefiles-under,$(LOCAL_PATH))
```

It initializes things related to CPU governor scaling, which we currently can't control on the Microsoft Surface 2.

### init.ussrd.rc
- Removes the file for the sake of consistency.

## device/nvidia/tegratab

### audio
- Directory which contains the source code and necessary files to make audio work on the Microsoft Surface 2.

### BoardConfig.mk
- Disables the use of DTB (device trees) in the target image since our custom Linux kernel doesn't use them directly:

```diff
 BOARD_SKIP_ANDROID_DOC_BUILD := true
 
 BOARD_BUILD_BOOTLOADER := true
-TARGET_USE_DTB := true
-TARGET_KERNEL_DT_NAME := tegra114-tegratab
-BOOTLOADER_SUPPORTS_DTB := true
+TARGET_USE_DTB := false
+# TARGET_KERNEL_DT_NAME := tegra114-tegratab
+BOOTLOADER_SUPPORTS_DTB := false
 # It can be overridden by an environment variable
 APPEND_DTB_TO_KERNEL ?= false
```

- Builds and enables our custom audio code we added above:

```diff
   TARGET_PROVIDES_INIT_RC := false
 endif
 
+BOARD_USES_TINY_ALSA_AUDIO := true
 BOARD_USES_GENERIC_AUDIO := false
 BOARD_USES_ALSA_AUDIO := true
-ifeq ($(PLATFORM_IS_NEXT),1)
-  USE_CUSTOM_AUDIO_POLICY := 1
-endif
-BOARD_SUPPORT_NVOICE := true
-BOARD_SUPPORT_NVAUDIOFX := true
+BUILD_WITH_ALSA_UTILS := true
+
+#BOARD_USES_GENERIC_AUDIO := false
+#BOARD_USES_ALSA_AUDIO := true
+#ifeq ($(PLATFORM_IS_NEXT),1)
+ USE_CUSTOM_AUDIO_POLICY := 1
+#endif
+#BOARD_SUPPORT_NVOICE := true
+#BOARD_SUPPORT_NVAUDIOFX := true
 
 TARGET_USERIMAGES_USE_EXT4 := true
 ifneq ($(TARGET_PRODUCT),flaxen)
```

- Sets a custom kernel defconfig for the Microsoft Surface 2:

```diff
   SET_DCP_CURRENT_LIMIT_2A := true
 endif
 
-TARGET_KERNEL_CONFIG := tegra_tegratab_android_defconfig
+# Surface 2 kernel defconfig
+TARGET_KERNEL_CONFIG := surface-2_android_defconfig
 
 USE_E2FSPROGS := true
 USE_OPENGL_RENDERER := true
```

- Disables TI bluetooth since the Microsoft Surface 2 doesn't have that:

```diff
 
 BOARD_HAVE_BLUETOOTH := true
 
-BOARD_HAVE_TI_BLUETOOTH := true
+#BOARD_HAVE_TI_BLUETOOTH := true
 
 USE_CAMERA_STUB := false
 
```

- Sets the device and kernel module names for the Wi-Fi chipset in the Microsoft Surface 2:

```diff
 # powerhal
 BOARD_USES_POWERHAL := true
 
-# Wifi related defines
-BOARD_WLAN_DEVICE           := wl18xx_mac80211
-BOARD_SOFTAP_DEVICE         := wl18xx_mac80211
+
+#Wifi
+BOARD_WLAN_DEVICE           := bcmdhd
+WPA_SUPPLICANT_VERSION      := VER_0_8_X
 BOARD_WPA_SUPPLICANT_DRIVER := NL80211
-WPA_SUPPLICANT_VERSION      := VER_TI_0_8_X
 BOARD_HOSTAPD_DRIVER        := NL80211
-WIFI_DRIVER_MODULE_NAME     := "wlcore_sdio"
-WIFI_FIRMWARE_LOADER        := ""
+BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
+BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
+
+# Wi-Fi module for Surface 2
+WIFI_DRIVER_MODULE_PATH := "/system/lib/modules/sd8xxx.ko"
+WIFI_DRIVER_MODULE_NAME := "sd8xxx"
+WIFI_DRIVER_MODULE_ARG  := "drv_mode=5 cfg80211_wext=0xc sta_name=wlan uap_name=wlan wfd_name=p2p max_uap_bss=1 fw_name=mrvl/sd8797_uapsta.bin"
+WIFI_DRIVER_FW_PATH_PARAM := "/proc/mwlan/config"
+WIFI_DRIVER_FW_PATH_STA := "drv_mode=5"
+WIFI_DRIVER_FW_PATH_AP :=  "drv_mode=6"
+WIFI_DRIVER_FW_PATH_P2P := "drv_mode=5"
+
+
+# Wifi related defines
+#BOARD_WLAN_DEVICE           := wl18xx_mac80211
+#BOARD_SOFTAP_DEVICE         := wl18xx_mac80211
+#BOARD_WPA_SUPPLICANT_DRIVER := NL80211
+#WPA_SUPPLICANT_VERSION      := VER_TI_0_8_X
+#BOARD_HOSTAPD_DRIVER        := NL80211
+#WIFI_DRIVER_MODULE_NAME     := "wlcore_sdio"
+#WIFI_FIRMWARE_LOADER        := ""
 
 #NFC
 #BOARD_HAVE_NFC_TI	:= true
```

- Sets the kernel base address (for the payload) and the kernel arguments:

```diff
 # Enable PRISM toggle switch in menu
 BOARD_PRISM_TOGGLE_SWITCH_ENABLED := true
 
+# Set cmdline and base for Surface 2
+BOARD_KERNEL_CMDLINE := debug buildvariant=userdebug init=/init maxcpus=1 rw rootwait video=tegra_fb:1920x1080@60 androidboot.hardware=tegratab
+BOARD_KERNEL_BASE := 0x84008000
+
 # sepolicy
 # try to detect AOSP master-based policy vs small KitKat policy
 ifeq ($(wildcard external/sepolicy/lmkd.te),)
```

### device.mk
- Removes the inclusion of the `init.ussrd.rc` file deleted previously:

```diff
   $(LOCAL_PATH)/dhcpcd.conf:system/etc/dhcpcd/dhcpcd.conf \
   $(LOCAL_PATH)/raydium_ts.idc:system/usr/idc/raydium_ts.idc \
   $(LOCAL_PATH)/sensor00fn11.idc:system/usr/idc/sensor00fn11.idc \
-  $(LOCAL_PATH)/../common/init.ussrd.rc:root/init.ussrd.rc \
   $(LOCAL_PATH)/../common/add_p2p_iface.sh:system/bin/add_p2p_iface.sh \
   $(LOCAL_PATH)/touch_fusion.idc:system/usr/idc/touch_fusion.idc \
   $(LOCAL_PATH)/../common/ussr_setup.sh:system/bin/ussr_setup.sh \
```

- Copies our custom audio config and profiles to the target system image:

```diff
 ifeq ($(PLATFORM_IS_AFTER_KITKAT),1)
 ifeq ($(NV_ANDROID_FRAMEWORK_ENHANCEMENTS),TRUE)
 PRODUCT_COPY_FILES += \
-  $(LOCAL_PATH)/media_profiles.xml:system/etc/media_profiles.xml \
+  $(LOCAL_PATH)/audio/media_profiles.xml:system/etc/media_profiles.xml \
   frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
   frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
   frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
-  $(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
-  $(LOCAL_PATH)/audio_policy.conf:system/etc/audio_policy.conf
+  $(LOCAL_PATH)/audio/media_codecs.xml:system/etc/media_codecs.xml \
+  $(LOCAL_PATH)/audio/audio_policy.conf:system/etc/audio_policy.conf
+  $(LOCAL_PATH)/audio/mixer_paths.xml:system/etc/mixer_paths.xml
+
 else
 PRODUCT_COPY_FILES += \
   $(LOCAL_PATH)/media_profiles_noenhance.xml:system/etc/media_profiles.xml \
```

```diff
 else
 ifeq ($(NV_ANDROID_FRAMEWORK_ENHANCEMENTS),TRUE)
 PRODUCT_COPY_FILES += \
-   $(LOCAL_PATH)/media_profiles.xml:system/etc/media_profiles.xml \
-   $(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
+   $(LOCAL_PATH)/audio/media_profiles.xml:system/etc/media_profiles.xml \
+   $(LOCAL_PATH)/audio/media_codecs.xml:system/etc/media_codecs.xml \
    $(LOCAL_PATH)/audio_policy_kk.conf:system/etc/audio_policy.conf
 else
 PRODUCT_COPY_FILES += \
```

- Copies the Wi-Fi firmware blob and the audio mixer settings to the target system image:

```diff
 endif
 endif
 
+# Copy Wi-Fi firmware blob and audio mixer settings for Surface 2
+PRODUCT_COPY_FILES += \
+	device/nvidia/tegratab/wifi/firmware/sd8797_uapsta.bin:system/vendor/firmware/mrvl/sd8797_upasta.bin \
+        device/nvidia/tegratab/audio/mixer_paths.xml:system/etc/mixer_paths.xml
+
 #enable Widevine drm
 PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
 PRODUCT_PACKAGES += \
```

- Includes the `libtinyalsa` package to the target system image, and the `audio.primary.tegratab` package instead of the `audio.primary.tegra` package:

```diff
 PRODUCT_PACKAGES += \
 	sensors.tegratab \
 	lights.tegratab \
-	audio.primary.tegra \
+	libtinyalsa \
+	audio.primary.tegratab \
 	audio.a2dp.default \
 	audio.usb.default \
-	libaudiopolicymanager \
 	audio.r_submix.default \
 	power.tegratab \
+	libaudiopolicymanager \
 	setup_fs \
 	drmserver \
 	Gallery2 \
```

- Sets the DPI of the Microsoft Surface 2 screen to be 140 instead of 213 (which is more appropriate for its resolution and physical size):

```diff
 PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
     persist.sys.usb.config=mtp
 
-# Set DPI
-PRODUCT_PROPERTY_OVERRIDES += ro.sf.lcd_density=213
+# Set DPI for Surface 2
+PRODUCT_PROPERTY_OVERRIDES += ro.sf.lcd_density=140
 
 # Enable secure USB debugging in user release build
 ifeq ($(TARGET_BUILD_TYPE),release)
```

### fstab.tegratab
- Modifies the entire fstab file to match the partition layout of our SD card:

```diff
 # The filesystem that contains the filesystem checker binary (typically /system) cannot
 # specify MF_CHECK, and must come before any filesystems that do specify MF_CHECK
 
-/dev/block/platform/sdhci-tegra.3/by-name/APP           /system             ext4      ro                                                                                  wait
-/dev/block/platform/sdhci-tegra.3/by-name/CAC           /cache              ext4      noatime,nosuid,nodev,data=writeback,nodelalloc,errors=panic    wait
-/dev/block/platform/sdhci-tegra.3/by-name/UDA           /data               ext4      noatime,nosuid,nodev,data=ordered,noauto_da_alloc,errors=panic    wait,check,encryptable=/dev/block/platform/sdhci-tegra.3/by-name/MDA
-/dev/block/platform/sdhci-tegra.3/by-name/FCT           /mnt/factory        ext4      ro    wait
-/devices/platform/sdhci-tegra.2/mmc_host/mmc1           auto    vfat      defaults                                                             voldmanaged=sdcard1:auto
-/devices/platform/tegra-ehci.0                          auto                vfat      defaults                                                       voldmanaged=usbdrive:auto
+
+/dev/block/mmcblk1p3           /system             ext4      ro                                                            wait
+/dev/block/mmcblk1p5           /cache              ext4      noatime,nosuid,nodev,nomblk_io_submit,errors=panic    wait,check
+/dev/block/mmcblk1p9           /data               ext4      noatime,nosuid,nodev,nomblk_io_submit,errors=panic    wait,check
+/dev/block/mmcblk1p4           /recovery           emmc      defaults                                                      defaults
+/dev/block/mmcblk1p6           /misc           emmc      defaults                                                      defaults
+/dev/block/mmcblk1p7           /sysdata           emmc      defaults                                                      defaults
+/dev/block/mmcblk1p8           /staging           emmc      defaults                                                      defaults
+#/devices/platform/tegra-ehci.0/usb*                     auto                vfat      defaults        voldmanaged=usb:auto
```

### init.tegratab_factory.rc
- Removes a 180° rotation performed on the `tegratab` devices, because they were put upside-down in the chassis. This is not the case for the Microsoft Surface 2 however, so we must remove it:

```diff
     write /sys/module/input_cfboost/parameters/boost_time 50
 
 on charger
-    setprop persist.tegra.panel.rotation 180
+    # Surface 2 doesn't need that
+    #setprop persist.tegra.panel.rotation 180
 # Power management settings
     write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/no_lp 0
```

**Note 2: This is not the file that actually performs the rotation on boot. For that, see the `system.prop` file below.**

### init.tegratab.rc
- Removes `mount` commands from partitions that don't exist on the Microsoft Surface 2:

```diff
     setprop ro.crypto.umount_sd false
     setprop ro.crypto.fuse_sdcard true
     mount_all /fstab.tegratab
-    mount ext4 /dev/block/platform/sdhci-tegra.3/by-name/LBH /lbh wait ro context=u:object_r:lbh_file:s0
 
     # Configure and enable KSM
     write /sys/kernel/mm/ksm/pages_to_scan 100
```

```diff
 on fs-charger
     setprop ro.crypto.tmpfs_options size=128m,mode=0771,uid=1000,gid=1000
     setprop ro.crypto.umount_sd false
-    mount ext4 /dev/block/platform/sdhci-tegra.3/by-name/APP /system wait ro
-    mount ext4 /dev/block/platform/sdhci-tegra.3/by-name/LBH /lbh wait ro context=u:object_r:lbh_file:s0
 
 on post-fs-data
 
```

```diff
     # enable Rt_reg_ctrl app to access device
     chmod 0660 /dev/snd/hwC1D0
 
-    mount ext4 /dev/block/platform/sdhci-tegra.3/by-name/FCT /mnt/factory rw remount
-    mkdir /mnt/factory/mpu 0777 system system
-    chmod 0644 /mnt/factory/mpu/inv_cal_data.bin
-    mount ext4 /dev/block/platform/sdhci-tegra.3/by-name/FCT /mnt/factory ro remount
-
     # export environment for touch and sensor
     export TOUCH_CONF_DIR /mnt/factory/touchscreen
     export TOUCH_DATA_DIR /data/touchscreen
```

- Removes GPS stuff since the Microsoft Surface 2 doesn't have any:

```diff
     copy /proc/last_kmsg /data/var/last_kmsg
     chown system system /data/var/last_kmsg
 
-    # Create GPS folders and set its permissions
-    mkdir /data/gnss
-    chown system system /data/gnss
-    mkdir /data/gnss/logs/
-    mkdir /data/gnss/nvs/
-    mkdir /data/gnss/log_MD/
-    chown system system /data/gnss/logs/
-    chown system system /data/gnss/nvs/
-    chown system system /data/gnss/log_MD/
-    insmod /system/lib/modules/gps_drv.ko
 
     # create lbh link folder
     mkdir /data/lbh/
```

- Removes the start up of the Local Build House (LBH) setup service:

```diff
     export MPU_CONF_DIR /mnt/factory/mpu
     export MPU_DATA_DIR /data/mpu
 
-service lbh-setup /system/bin/init_lbh.sh
-    class main
-    user root
-    group root
-    oneshot
-
 on boot
 
 # bluetooth
 ```
 
 - Removes the loading of non-existent Wi-Fi kernel modules:
 
```diff
     chown bluetooth net_bt_stack /system/etc/bluetooth
 
 # wifi
-    insmod /system/lib/modules/compat/compat.ko
-    insmod /system/lib/modules/compat/cfg80211.ko
-    insmod /system/lib/modules/compat/mac80211.ko
-    insmod /system/lib/modules/compat/wlcore.ko
-    insmod /system/lib/modules/compat/wl18xx.ko
-    insmod /system/lib/modules/compat/wlcore_sdio.ko
-    start add_p2p_iface
 
 # backlight
     chown system system /sys/class/backlight/pwm-backlight/brightness
```

- Removes commands related to CPU governor scalings (with the same reason as removing the `init.ussrd.rc` file):

```diff
 # Power management settings
     write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/no_lp 0
 
-    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor conservative
-    write /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor conservative
-    write /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor conservative
-    write /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor conservative
-
-    write /sys/devices/system/cpu/cpufreq/conservative/up_threshold 85
-    write /sys/devices/system/cpu/cpufreq/conservative/down_threshold 65
-    write /sys/devices/system/cpu/cpufreq/conservative/freq_step 1
-
-    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor interactive
-    write /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor interactive
-    write /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor interactive
-    write /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor interactive
-    write /sys/devices/system/cpu/cpufreq/interactive/boost_factor 2
-    write /sys/devices/system/cpu/cpufreq/interactive/max_boost 250000
-    write /sys/devices/system/cpu/cpufreq/interactive/sustain_load 80
-    write /sys/devices/system/cpu/cpufreq/interactive/io_busy_threshold 16
-    write /sys/devices/system/cpu/cpufreq/interactive/midrange_max_boost 250000
-    write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/enable 1
-    write /sys/devices/system/cpu/cpuquiet/current_governor runnable
-    write /sys/module/cpuidle_t11x/parameters/cpu_power_gating_in_idle 31
-    write /sys/module/cpuidle_t11x/parameters/slow_cluster_power_gating_noncpu 1
-    write /sys/module/cpuidle/parameters/power_down_in_idle 1
-
-    chown system system /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/no_lp
-    chown system system /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
-    chown system system /sys/devices/tegradc.0/enable
-    chown system system /sys/devices/tegradc.1/enable
-    chown system system /sys/devices/platform/host1x/nvavp/boost_sclk
     chown system system /sys/class/input/input0/enabled
     chown system system /sys/class/input/input1/enabled
     chown system system /sys/class/input/input2/enabled
```

```diff
-# increase idle_bottom_freq in order for LP core to get a more chance to run
-    write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/idle_bottom_freq 408000
-
-    write /sys/module/input_cfboost/parameters/boost_freq 1122000
-    write /sys/module/input_cfboost/parameters/boost_time 160
```

```diff
 # Power management settings
-    write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/no_lp 0
-
-    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor conservative
-    write /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor conservative
-    write /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor conservative
-    write /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor conservative
-
-    write /sys/devices/system/cpu/cpufreq/conservative/up_threshold 85
-    write /sys/devices/system/cpu/cpufreq/conservative/down_threshold 65
-    write /sys/devices/system/cpu/cpufreq/conservative/freq_step 1
-
-    write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/enable 1
-    write /sys/devices/system/cpu/cpuquiet/current_governor runnable
-    write /sys/module/cpuidle_t11x/parameters/cpu_power_gating_in_idle 31
-    write /sys/module/cpuidle_t11x/parameters/slow_cluster_power_gating_noncpu 1
-    write /sys/module/cpuidle/parameters/power_down_in_idle 1
 
     write /sys/class/android_usb/android0/enable 0
 #    write /sys/class/android_usb/android0/idVendor ${ro.usb.vid}
```

- Removes Wiimote-related stuff we don't need:

```diff
     write /sys/block/mmcblk0/queue/read_ahead_kb 2048
     write /sys/block/mmcblk1/queue/read_ahead_kb 2048
 
-# Wiimote connect status
-    write /data/misc/wminput/connected 0
-    chmod 0666 /data/misc/wminput/connected
 
-# increase idle_bottom_freq in order for LP core to get a more chance to run
-    write /sys/devices/system/cpu/cpuquiet/tegra_cpuquiet/idle_bottom_freq 408000
-
-    write /sys/module/input_cfboost/parameters/boost_freq 1122000
-    write /sys/module/input_cfboost/parameters/boost_time 160
 
 # decreasing cache
     write /proc/sys/vm/vfs_cache_pressure 500
```

- Removes the same 180° display rotation we don't need:

```diff
     write /proc/sys/vm/vfs_cache_pressure 500
     write /proc/sys/vm/dirty_background_ratio 2
 
-on charger
-    setprop persist.tegra.panel.rotation 180
 # Power management settings
```

- Removes the start up of a service we don't need since it's for Bluetooth (currently broken), FM and GPS (we don't have neither of those):

```diff
     write /proc/sys/kernel/dmesg_restrict 0
 
 #shared transport user space mgr service for Bluetooth, FM and GPS
-service uim /system/bin/uim-sysfs
-    class core
-    user bluetooth
-    group system
-    oneshot
 
 service dhcpcd_p2p_p2p0 /system/bin/dhcpcd p2p-p2p0-0
     class main
```

- Removes the start up of a service used for CPU power management:

```diff
     disabled
     oneshot
 
-service cpuvoltcap /system/bin/nvcpuvoltcapd -a
-    class main
-    user system
-    group system
-
 service sdcard /system/bin/sdcard -u 1023 -g 1023 -l /data/media /mnt/shell/emulated
     class late_start
```

- Removes the start up of 2 services that try to mount non-existent paths from our SD card in user-space:

```diff
 service sdcard /system/bin/sdcard -u 1023 -g 1023 -l /data/media /mnt/shell/emulated
     class late_start
 
-service fuse_sdcard1 /system/bin/sdcard -u 1023 -g 1023 -w 1023 -d /mnt/media_rw/sdcard1 /storage/sdcard1
-    class late_start
-    disabled
-
-service fuse_usbdrive /system/bin/sdcard -u 1023 -g 1023 -w 1023 -d /mnt/media_rw/usbdrive /storage/usbdrive
-    class late_start
-    disabled
-
```

- Removes the start up of a useless bug report service:

```diff
-# bugreport is triggered by the VOLUME-DOWN and VOLUME-UP keys
-service bugreport /system/bin/dumpstate -d -p -B -o /data/data/com.android.shell/files/bugreports/bugreport
-    class main
-    disabled
-    oneshot
-    keycodes 115 114
-
```

- Removes an event related to Bluetooth:

```diff
-on property:init.svc.hciattach=stopped
-    write /sys/devices/platform/reg-userspace-consumer.1/state disabled
-
```

This event turns off a regulator when Bluetooth is stopped. Not only we remove it because Bluetooth is broken, but it's also not correct for the Microsoft Surface 2 to even do that in the first place.

- Removes the inclusion of the `init.tf.rc` file, which is for Trusted Foundations:

```diff
-# Prepare TF service
-import init.tf.rc
-
```

Trusted Foundations is a high-level security platform developed by Trusted Logic for ARM devices. The Microsoft Surface 2 implements it, and we don't support it, so we just don't enable it.

- Removes the enablement and start up of a CPU power management service:

```diff
-# Enable NvCpuD, and set it to never poll config again
-on boot
-    setprop nvcpud.enabled true
-    setprop nvcpud.config_refresh_ms -1
-
-service nvcpud /system/bin/nvcpud
-    class main
-    user system
-    group system
-    oneshot
 
 # Set up HDCP
 import init.hdcp.rc
```

- Removes the start up of a service that creates file systems in non-existent paths:

```diff
 service charger /charger
 	class charger
 
-# create filesystems if necessary
-service setup_fs /system/bin/setup_fs \
-        /dev/block/platform/sdhci-tegra.3/by-name/UDA \
-        /dev/block/platform/sdhci-tegra.3/by-name/FCT \
-        /dev/block/platform/sdhci-tegra.3/by-name/CAC
-    class core
-    user root
-    group root
-    oneshot
-
```

- Removes the inclusion of the previously deleted `init.ussrd.rc` file:

```diff
-# unified scaling setup
-import init.ussrd.rc
-
 # start pbc daemon
 #service pbc /system/bin/pbc
 #    class main
```

- Removes the start up of GPS-related services:

```diff
     group root
     oneshot
 
-#gps wl18XX
-service devproxy /system/bin/devproxy
-    class main
-    disabled
-    oneshot
-    user system
-    group gps
-
-service agnss_connect /system/bin/agnss_connect -p
-    class main
-    disabled
-    oneshot
-    user system
-    group gps
-
```

- Removes the start up of 2 other LBH services:

```diff
-# make symlink to proper configuration according to lbh
-service link_lbh /system/bin/link_lbh.sh
-    class main
-    user root
-    group root
-    oneshot
-
-service camera_lbh /system/bin/camera_lbh.sh
-    class main
-    user root
-    group root
-    oneshot
-
```

- Removes the start up of a useless user guide service:

```diff
-service user_guide /system/bin/user_guide.sh
-    disabled
-    class main
-    user root
-    group root
-    oneshot
-
-on property:service.bootanim.exit=1
-   start user_guide
-
 on init
     setprop persist.tegra.cursor.enable 1
     setprop sf.async.cursor.enable 1
```

- Removes the inclusion of the `init.qvs.rc` file, which is related to QVS automation:

```diff
     setprop input.tch_blk.edgeremap_bottom 0
     setprop input.nonwhitelistedmode 0
 
-# Customers should remove this line
-import init.qvs.rc
-
```

### system.prop
- Removes the rotation performed above on boot, and also sets the DPI to be 140 instead of 1:

```diff
 persist.tegra.nvmmlite = 1
 persist.wlan.ti.calibrated = 0
 ro.ril.wake_lock_timeout=200000
-ro.sf.override_lcd_density = 1
-persist.tegra.panel.rotation = 180
+ro.sf.override_lcd_density = 140
 
 #NFC
 debug.nfc.fw_download=false
```

### tegratab.mk
- Removes the inclusion of Bluetooth APK packages in the target system image by using our custom `generic_no_telephony_no_bluetooth.mk` file from above:

```diff
 # DEV_TEGRATAB_PATH
 DEV_TEGRATAB_PATH := device/nvidia/tegratab
 
-$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony.mk)
+# Android currently has some problems with Bluetooth on the Surface 2, so we disable it
+$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony_no_bluetooth.mk)
 
 # Thse are default settings, it gets changed as per sku manifest properties
 PRODUCT_NAME := tegratab
```

### wifi/firmware
- Directory which contains the firmware blob for the Wi-Fi chipset.

## packages/apps/Settings/src/com/android/settings

### SecuritySettings.java
- Disables checking for any hardware keystore, since on the Microsoft Surface 2, it's the Trusted Foundations and we don't support it.

```diff
 
         // Credential storage
         final UserManager um = (UserManager) getActivity().getSystemService(Context.USER_SERVICE);
-        mKeyStore = KeyStore.getInstance(); // needs to be initialized for onResume()
-        if (!um.hasUserRestriction(UserManager.DISALLOW_CONFIG_CREDENTIALS)) {
-            Preference credentialStorageType = root.findPreference(KEY_CREDENTIAL_STORAGE_TYPE);
-
-            final int storageSummaryRes =
-                mKeyStore.isHardwareBacked() ? R.string.credential_storage_type_hardware
-                        : R.string.credential_storage_type_software;
-            credentialStorageType.setSummary(storageSummaryRes);
-        } else {
-            PreferenceGroup credentialsManager = (PreferenceGroup)
-                    root.findPreference(KEY_CREDENTIALS_MANAGER);
-            credentialsManager.removePreference(root.findPreference(KEY_RESET_CREDENTIALS));
-            credentialsManager.removePreference(root.findPreference(KEY_CREDENTIALS_INSTALL));
-            credentialsManager.removePreference(root.findPreference(KEY_CREDENTIAL_STORAGE_TYPE));
-        }
+        // We don't support TF on Surface 2
+        // mKeyStore = KeyStore.getInstance(); // needs to be initialized for onResume()
+        // if (!um.hasUserRestriction(UserManager.DISALLOW_CONFIG_CREDENTIALS)) {
+        //     Preference credentialStorageType = root.findPreference(KEY_CREDENTIAL_STORAGE_TYPE);
+        //
+        //     final int storageSummaryRes =
+        //         mKeyStore.isHardwareBacked() ? R.string.credential_storage_type_hardware
+        //                 : R.string.credential_storage_type_software;
+        //     credentialStorageType.setSummary(storageSummaryRes);
+        // } else {
+        PreferenceGroup credentialsManager = (PreferenceGroup)
+                root.findPreference(KEY_CREDENTIALS_MANAGER);
+        credentialsManager.removePreference(root.findPreference(KEY_RESET_CREDENTIALS));
+        credentialsManager.removePreference(root.findPreference(KEY_CREDENTIALS_INSTALL));
+        credentialsManager.removePreference(root.findPreference(KEY_CREDENTIAL_STORAGE_TYPE));
+        // }
 
         // Application install
         PreferenceGroup deviceAdminCategory = (PreferenceGroup)
```

```diff
                     Settings.System.TEXT_SHOW_PASSWORD, 1) != 0);
         }
 
-        if (mResetCredentials != null) {
-            mResetCredentials.setEnabled(!mKeyStore.isEmpty());
-        }
+        // Surface 2 patch
+        // if (mResetCredentials != null) {
+        //     mResetCredentials.setEnabled(!mKeyStore.isEmpty());
+        // }
     }
 
     @Override
```
