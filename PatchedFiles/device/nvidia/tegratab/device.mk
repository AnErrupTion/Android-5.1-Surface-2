# NVIDIA Tegra4 "Tegratab" development system
#
# Copyright (c) 2012-2013 NVIDIA Corporation.  All rights reserved.

$(call inherit-product-if-exists, vendor/nvidia/tegra/core/nvidia-tegra-vendor.mk)
$(call inherit-product-if-exists, frameworks/base/data/videos/VideoPackage2.mk)
$(call inherit-product-if-exists, frameworks/base/data/sounds/AudioPackage3.mk)
$(call inherit-product-if-exists, vendor/nvidia/tegra/apps/tfc/tfc.mk)
$(call inherit-product, build/target/product/languages_full.mk)

#PRODUCT_LOCALES contain only locales,
#so use PRODUCT_AAPT_CONFIG for dpi config
PRODUCT_AAPT_CONFIG += mdpi hdpi xhdpi

#for GMS package selection proper apk file
#TN7 dpi is 213(tvdpi),hdpi(~240) is closed value of 213(tvdpi)
#Refering the below,gms apps mk file select proper apk file
PRODUCT_AAPT_PREF_CONFIG := hdpi

ifeq ($(wildcard vendor/nvidia/tegra/core-private),vendor/nvidia/tegra/core-private)
    NVFLASH_FILES_PATH := vendor/nvidia/tegra/customers/nvidia-partner/tegratab
else
    NVFLASH_FILES_PATH := vendor/nvidia/tegra/odm/tegratab
endif

PRODUCT_COPY_FILES += \
    $(NVFLASH_FILES_PATH)/nvflash/P1640_Micron_1GB_MT41K128M16-125_408Mhz_v9_0_Hynix_1GB_H5TC2G63FFR-PBA_408Mhz_v2_0.cfg:bct.cfg \
    $(NVFLASH_FILES_PATH)/nvflash/P1640_Micron_1GB_MT41K128M16-125_408Mhz_v9_0_Hynix_1GB_H5TC2G63FFR-PBA_408Mhz_v2_0.bct:flash.bct \
    $(NVFLASH_FILES_PATH)/nvflash/P1640_Micron_1GB_MT41K128M16-125_408Mhz_v9_0_Hynix_1GB_H5TC2G63FFR-PBA_408Mhz_v2_0.cfg:flash_tegratab_p1640.cfg \
    $(NVFLASH_FILES_PATH)/nvflash/P1640_Micron_1GB_MT41K128M16-125_408Mhz_v9_0_Hynix_1GB_H5TC2G63FFR-PBA_408Mhz_v2_0.bct:flash_tegratab_p1640.bct \
    $(NVFLASH_FILES_PATH)/nvflash/P1988_512MBx2_MT41K128M16JT-125_408Mhz_4.1.7.bct:flash_tegratab_p1988.bct \
    $(NVFLASH_FILES_PATH)/nvflash/P1988_512MBx2_MT41K128M16JT-125_408Mhz_4.1.7.cfg:flash_tegratab_p1988.cfg \
    $(NVFLASH_FILES_PATH)/nvflash/E1569_Micron_1GB_MT41K128M16-125_408Mhz.cfg:flash_tegratab_e1569.cfg \
    $(NVFLASH_FILES_PATH)/nvflash/E1569_Micron_1GB_MT41K128M16-125_408Mhz.bct:flash_tegratab_e1569.bct \
    $(NVFLASH_FILES_PATH)/nvflash/eks_nokey.dat:eks.dat \
    $(NVFLASH_FILES_PATH)/partition_data/config/nvcamera.conf:system/etc/nvcamera.conf \
    $(NVFLASH_FILES_PATH)/nvflash/lowbat.bmp:lowbat.bmp \
    $(NVFLASH_FILES_PATH)/nvflash/charging.bmp:charging.bmp \
    $(NVFLASH_FILES_PATH)/nvflash/fuse_write.txt:fuse_write.txt \
    $(NVFLASH_FILES_PATH)/nvflash/nct_gb.txt:nct_gb.txt \
    $(NVFLASH_FILES_PATH)/nvflash/nct_gp.txt:nct_gp.txt \
    $(NVFLASH_FILES_PATH)/nvflash/nct_nb.txt:nct_nb.txt \
    $(NVFLASH_FILES_PATH)/nvflash/nct_np.txt:nct_np.txt

ifneq (,$(filter $(TARGET_PRODUCT),kalamata flaxen))
    ifeq ($(TARGET_PRODUCT),kalamata)
        ifneq ($(wildcard vendor/nvidia/kalamata/media/hpLogo.bmp),)
            PRODUCT_COPY_FILES += vendor/nvidia/kalamata/media/hpLogo.bmp:nvidia.bmp
        else
            PRODUCT_COPY_FILES += $(NVFLASH_FILES_PATH)/nvflash/nvidia.bmp:nvidia.bmp
        endif
    else
        ifneq ($(wildcard vendor/nvidia/flaxen/media/hpLogo.bmp),)
            PRODUCT_COPY_FILES += vendor/nvidia/flaxen/media/hpLogo.bmp:nvidia.bmp
        else
            PRODUCT_COPY_FILES += $(NVFLASH_FILES_PATH)/nvflash/nvidia.bmp:nvidia.bmp
        endif
    endif
else
    PRODUCT_COPY_FILES += $(NVFLASH_FILES_PATH)/nvflash/nvidia.bmp:nvidia.bmp
endif

ifeq ($(APPEND_DTB_TO_KERNEL), true)
    ifneq ($(TARGET_PRODUCT),flaxen)
        ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014 tn7_114np_2014))
            PRODUCT_COPY_FILES += \
                    $(NVFLASH_FILES_PATH)/nvflash/android_fastboot_emmc_full_2014.cfg:flash.cfg
        else
            PRODUCT_COPY_FILES += \
                    $(NVFLASH_FILES_PATH)/nvflash/android_fastboot_emmc_full.cfg:flash.cfg
        endif
    else
        PRODUCT_COPY_FILES += \
                $(NVFLASH_FILES_PATH)/nvflash/android_fastboot_emmc_full.cfg_1gb_system:flash.cfg
    endif
else
    ifneq ($(TARGET_PRODUCT), flaxen)
        ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014 tn7_114np_2014))
            NVFLASH_CFG_BASE_FILE := $(NVFLASH_FILES_PATH)/nvflash/android_fastboot_dtb_emmc_full_noxusb_nosif_2014.cfg
        else
            NVFLASH_CFG_BASE_FILE := $(NVFLASH_FILES_PATH)/nvflash/android_fastboot_dtb_emmc_full_noxusb_nosif.cfg
        endif
    else
        NVFLASH_CFG_BASE_FILE := $(NVFLASH_FILES_PATH)/nvflash/android_fastboot_dtb_emmc_full_noxusb_nosif_1gb_system.cfg
    endif
endif

NVFLASH_FILES_PATH :=

#to add android.hareware.xxx permission,Please use /lbh/lbh_xxx.mk depending on sku
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml

ifneq (,$(filter $(BOARD_INCLUDES_TEGRA_JNI),display))
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/hal/frameworks/Display/com.nvidia.display.xml:system/etc/permissions/com.nvidia.display.xml
endif

ifneq (,$(filter $(BOARD_INCLUDES_TEGRA_JNI),cursor))
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/hal/frameworks/Graphics/com.nvidia.graphics.xml:system/etc/permissions/com.nvidia.graphics.xml
endif

PRODUCT_COPY_FILES += \
    $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml)

PRODUCT_COPY_FILES += \
  $(LOCAL_PATH)/ueventd.tegratab.rc:root/ueventd.tegratab.rc \
  $(LOCAL_PATH)/tegra-kbc.kl:system/usr/keylayout/tegra-kbc.kl \
  $(LOCAL_PATH)/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
  $(LOCAL_PATH)/dhcpcd.conf:system/etc/dhcpcd/dhcpcd.conf \
  $(LOCAL_PATH)/raydium_ts.idc:system/usr/idc/raydium_ts.idc \
  $(LOCAL_PATH)/sensor00fn11.idc:system/usr/idc/sensor00fn11.idc \
  $(LOCAL_PATH)/../common/add_p2p_iface.sh:system/bin/add_p2p_iface.sh \
  $(LOCAL_PATH)/touch_fusion.idc:system/usr/idc/touch_fusion.idc \
  $(LOCAL_PATH)/../common/ussr_setup.sh:system/bin/ussr_setup.sh \
  $(LOCAL_PATH)/../common/set_hwui_params.sh:system/bin/set_hwui_params.sh \

ifeq ($(PLATFORM_IS_AFTER_KITKAT),1)
ifeq ($(NV_ANDROID_FRAMEWORK_ENHANCEMENTS),TRUE)
PRODUCT_COPY_FILES += \
  $(LOCAL_PATH)/audio/media_profiles.xml:system/etc/media_profiles.xml \
  frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
  frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
  frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
  $(LOCAL_PATH)/audio/media_codecs.xml:system/etc/media_codecs.xml \
  $(LOCAL_PATH)/audio/audio_policy.conf:system/etc/audio_policy.conf
  $(LOCAL_PATH)/audio/mixer_paths.xml:system/etc/mixer_paths.xml

else
PRODUCT_COPY_FILES += \
  $(LOCAL_PATH)/media_profiles_noenhance.xml:system/etc/media_profiles.xml \
  $(LOCAL_PATH)/media_codecs_noenhance.xml:system/etc/media_codecs.xml \
  $(LOCAL_PATH)/audio_policy_noenhance.conf:system/etc/audio_policy.conf
endif
else
ifeq ($(NV_ANDROID_FRAMEWORK_ENHANCEMENTS),TRUE)
PRODUCT_COPY_FILES += \
   $(LOCAL_PATH)/audio/media_profiles.xml:system/etc/media_profiles.xml \
   $(LOCAL_PATH)/audio/media_codecs.xml:system/etc/media_codecs.xml \
   $(LOCAL_PATH)/audio_policy_kk.conf:system/etc/audio_policy.conf
else
PRODUCT_COPY_FILES += \
   $(LOCAL_PATH)/media_profiles_noenhance.xml:system/etc/media_profiles.xml \
   $(LOCAL_PATH)/media_codecs_noenhance.xml:system/etc/media_codecs.xml \
   $(LOCAL_PATH)/audio_policy_kk.conf:system/etc/audio_policy.conf
endif
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/power.tegratab.rc:system/etc/power.tegratab.rc \
    $(LOCAL_PATH)/init.tegratab.rc:root/init.tegratab.rc \
    $(LOCAL_PATH)/fstab.tegratab:root/fstab.tegratab \
    $(LOCAL_PATH)/init.tegratab.usb.rc:root/init.tegratab.usb.rc

ifeq ($(NO_ROOT_DEVICE),1)
  PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init_no_root_device.rc:root/init.rc
endif

# Face detection model
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/core/include/ft/model_frontalface.xml:system/etc/model_frontal.xml

# Test files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/../common/cluster:system/bin/cluster \
    $(LOCAL_PATH)/../common/cluster_get.sh:system/bin/cluster_get.sh \
    $(LOCAL_PATH)/../common/cluster_set.sh:system/bin/cluster_set.sh \
    $(LOCAL_PATH)/../common/dcc:system/bin/dcc \
    $(LOCAL_PATH)/../common/hotplug:system/bin/hotplug \
    $(LOCAL_PATH)/../common/mount_debugfs.sh:system/bin/mount_debugfs.sh

PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/graphics-partner/android/build/egl.cfg:system/lib/egl/egl.cfg

PRODUCT_COPY_FILES += \
    device/nvidia/tegratab/nvcms/device.cfg:system/lib/nvcms/device.cfg

PRODUCT_COPY_FILES += \
	external/alsa-lib/src/conf/alsa.conf:system/usr/share/alsa/alsa.conf \
	external/alsa-lib/src/conf/pcm/dsnoop.conf:system/usr/share/alsa/pcm/dsnoop.conf \
	external/alsa-lib/src/conf/pcm/modem.conf:system/usr/share/alsa/pcm/modem.conf \
	external/alsa-lib/src/conf/pcm/dpl.conf:system/usr/share/alsa/pcm/dpl.conf \
	external/alsa-lib/src/conf/pcm/default.conf:system/usr/share/alsa/pcm/default.conf \
	external/alsa-lib/src/conf/pcm/surround51.conf:system/usr/share/alsa/pcm/surround51.conf \
	external/alsa-lib/src/conf/pcm/surround41.conf:system/usr/share/alsa/pcm/surround41.conf \
	external/alsa-lib/src/conf/pcm/surround50.conf:system/usr/share/alsa/pcm/surround50.conf \
	external/alsa-lib/src/conf/pcm/dmix.conf:system/usr/share/alsa/pcm/dmix.conf \
	external/alsa-lib/src/conf/pcm/center_lfe.conf:system/usr/share/alsa/pcm/center_lfe.conf \
	external/alsa-lib/src/conf/pcm/surround40.conf:system/usr/share/alsa/pcm/surround40.conf \
	external/alsa-lib/src/conf/pcm/side.conf:system/usr/share/alsa/pcm/side.conf \
	external/alsa-lib/src/conf/pcm/iec958.conf:system/usr/share/alsa/pcm/iec958.conf \
	external/alsa-lib/src/conf/pcm/rear.conf:system/usr/share/alsa/pcm/rear.conf \
	external/alsa-lib/src/conf/pcm/surround71.conf:system/usr/share/alsa/pcm/surround71.conf \
	external/alsa-lib/src/conf/pcm/front.conf:system/usr/share/alsa/pcm/front.conf \
	external/alsa-lib/src/conf/cards/aliases.conf:system/usr/share/alsa/cards/aliases.conf \
	device/nvidia/tegratab/asound.conf:system/etc/asound.conf \
	device/nvidia/tegratab/nvaudio_conf.xml:system/etc/nvaudio_conf.xml \
	device/nvidia/tegratab/nvaudio_fx.xml:system/etc/nvaudio_fx.xml

PRODUCT_COPY_FILES += \
	device/nvidia/tegratab/enctune.conf:system/etc/enctune.conf

# nvcpud specific cpu frequencies config
PRODUCT_COPY_FILES += \
        device/nvidia/tegratab/nvcpud.conf:system/etc/nvcpud.conf

# Stereo API permissions file has different locations in private and customer builds
ifeq ($(wildcard vendor/nvidia/tegra/core-private),vendor/nvidia/tegra/core-private)
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/stereo/api/com.nvidia.nvstereoutils.xml:system/etc/permissions/com.nvidia.nvstereoutils.xml
else
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/prebuilt/$(REFERENCE_DEVICE)/stereo/api/com.nvidia.nvstereoutils.xml:system/etc/permissions/com.nvidia.nvstereoutils.xml
endif

# NvBlit JNI library
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/graphics-partner/android/frameworks/Graphics/com.nvidia.graphics.xml:system/etc/permissions/com.nvidia.graphics.xml

# NCT ID help file
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/core/include/nvnct.h:README.nct_id

# EULA
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/eula.html:system/etc/eula.html

# TN7 product permission
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/com.nvidia.feature.xml:system/etc/permissions/com.nvidia.feature.xml

# Promotional content
ifneq ($(TARGET_PRODUCT),kalamata)
ifneq ($(TARGET_PRODUCT),flaxen)
ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media_ad/Movies/TEGRA_NOTE_TapToTrack.mp4),)
PRODUCT_COPY_FILES += \
    vendor/nvidia/tegra/tegratab/partition-data/media_ad/Movies/TEGRA_NOTE_TapToTrack.mp4:data/media/Movies/TEGRA_NOTE_TapToTrack.mp4
endif
endif
endif

# User Manual
ifneq ($(TARGET_PRODUCT),kalamata)
ifneq ($(TARGET_PRODUCT),flaxen)
ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014))
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/../tegranote7c/user_guide.sh:system/bin/user_guide.sh
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide.pdf:system/media/TegraNOTE7LTEUserGuide.pdf
    endif
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-de.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-de.pdf:system/media/TegraNOTE7LTEUserGuide-de.pdf
    endif
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-es.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-es.pdf:system/media/TegraNOTE7LTEUserGuide-es.pdf
    endif
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-fr.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-fr.pdf:system/media/TegraNOTE7LTEUserGuide-fr.pdf
    endif
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-it.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-it.pdf:system/media/TegraNOTE7LTEUserGuide-it.pdf
    endif
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-ru.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-ru.pdf:system/media/TegraNOTE7LTEUserGuide-ru.pdf
    endif
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-pl.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7LTEUserGuide-pl.pdf:system/media/TegraNOTE7LTEUserGuide-pl.pdf
    endif
else
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/user_guide.sh:system/bin/user_guide.sh
    ifneq ($(wildcard vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7UserGuide.pdf),)
        PRODUCT_COPY_FILES += vendor/nvidia/tegra/tegratab/partition-data/media/TegraNOTE7UserGuide.pdf:system/media/TegraNOTE7UserGuide.pdf
    endif
endif
endif
endif

# Copy Wi-Fi firmware blob and audio mixer settings for Surface 2
PRODUCT_COPY_FILES += \
	device/nvidia/tegratab/wifi/firmware/sd8797_uapsta.bin:system/vendor/firmware/mrvl/sd8797_uapsta.bin \
        device/nvidia/tegratab/audio/mixer_paths.xml:system/etc/mixer_paths.xml

#enable Widevine drm
PRODUCT_PROPERTY_OVERRIDES += drm.service.enabled=true
PRODUCT_PACKAGES += \
    com.google.widevine.software.drm.xml \
    com.google.widevine.software.drm \
    libdrmwvmplugin \
    libwvm \
    libWVStreamControlAPI_L1 \
    libwvdrm_L1

# Live Wallpapers
PRODUCT_PACKAGES += \
    LiveWallpapers \
    LiveWallpapersPicker \
    HoloSpiralWallpaper \
    MagicSmokeWallpapers \
    NoiseField \
    Galaxy4 \
    VisualizationWallpapers \
    PhaseBeam \
    librs_jni

PRODUCT_PACKAGES += \
	sensors.tegratab \
	lights.tegratab \
	libtinyalsa \
	audio.primary.tegratab \
	audio.a2dp.default \
	audio.usb.default \
	audio.r_submix.default \
	power.tegratab \
	libaudiopolicymanager \
	setup_fs \
	drmserver \
	Gallery2 \
	libdrmframework_jni \
	e2fsck \
	nvidiafeedback \
        NVSS

PRODUCT_PACKAGES += \
	charger\
	charger_res_images

PRODUCT_PACKAGES += nvaudio_test

# WiiMote support
PRODUCT_PACKAGES += \
	libcwiid \
	wminput \
	acc \
	ir_ptr \
	led \
	nunchuk_acc \
	nunchuk_stick2btn

# Application to connect WiiMote with Tegra device
PRODUCT_PACKAGES += \
	WiiMote

#WiFi
PRODUCT_PACKAGES += \
		TQS_S_2.6.ini \
		iw \
		wl18xx-conf-default.bin \
		wl18xx-conf-us.bin \
		wl18xx-conf-eu.bin \
		crda \
		regulatory.bin \
		wpa_supplicant.conf \
		p2p_supplicant.conf \
		p2p_disabled.conf \
		hostapd.conf \
		ibss_supplicant.conf \
		dhcpd.conf \
		dhcpcd.conf \
		hostapd \
		wpa_supplicant.conf \
		wpa_supplicant

#Wifi firmwares
PRODUCT_PACKAGES += \
		wl1271-nvs_default.bin \
		wl128x-fw-4-sr.bin \
		wl128x-fw-4-mr.bin \
		wl128x-fw-4-plt.bin \
		wl18xx-fw-mc.bin \
		wl18xx-fw-mc_pg22.bin \
		wl18xx-fw-2.bin \
		wl1271-nvs_wl8.bin

#BT & FM packages
PRODUCT_PACKAGES += \
		uim-sysfs \
		TIInit_10.6.15.bts \
		TIInit_11.8.32.bts \
		TIInit_12.8.32.bts

#GPS
PRODUCT_PACKAGES += \
		agnss_connect \
		client_app \
		client_hwd \
		Connect_Config.txt \
		devproxy \
		dproxy.conf \
		dproxy.patch \
		gps.tegra.so \
		hwd \
		libagnss.so \
		libassist.so \
		libclientlogger.so \
		libdevproxy.so \
		libgnssutils.so \
		Log_MD \
		log_MD.txt \
		logs.txt \
		nvs.txt \
		ser2soc \
		test_server
# CPU volt cap daemon
PRODUCT_PACKAGES += \
	nvcpuvoltcapd

# promotional contents
PRODUCT_PACKAGES += \
	media_ad

# Factory test packages
PRODUCT_PACKAGES += \
	nvbdktestbl \
        pcba_testcases.xml \
        postassembly_testcases.xml \
        preassembly_testcases.xml \
        audio_testcases.xml \
        usbhostumsread \
	tdc \
	tmc \
	tst \
	camera_existence \
	factory_adbd \
	oemcrypto_api_test

PRODUCT_PACKAGES += \
    nvflash_cfg_populator \
    lbh_images

# Markers app (renamed to Tegra Draw)
PRODUCT_PACKAGES += \
        TegraDraw

# Stylus apps
PRODUCT_PACKAGES += \
        NvLauncher \
        nvlasso

# HDCP SRM Support
PRODUCT_PACKAGES += \
                hdcp1x.srm \
                hdcp2x.srm \
                hdcp2xtest.srm

# OV5693 bayer sensor calibration manager
PRODUCT_PACKAGES += otp-ov5693

PRODUCT_PACKAGES += ControllerMapper

ifeq ($(NV_ANDROID_FRAMEWORK_ENHANCEMENTS),TRUE)
PRODUCT_PACKAGES += Stats
endif

ifneq ($(filter $(TARGET_PRODUCT),kalamata flaxen),)
PRODUCT_PACKAGES += gen_tegranote_fuseblob
endif

include frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk
include $(LOCAL_PATH)/touchscreen/maxim/maxim.mk
# we have enough storage space to hold precise GC data
PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_RUNTIMES := runtime_libart_default

PRODUCT_CHARACTERISTICS := tablet

ifneq (,$(filter $(TARGET_PRODUCT),kalamata flaxen))
ifeq ($(TARGET_PRODUCT),kalamata)
    PRODUCT_PACKAGE_OVERLAYS := $(LOCAL_PATH)/../../../vendor/nvidia/kalamata/overlay
else
    PRODUCT_PACKAGE_OVERLAYS := $(LOCAL_PATH)/../../../vendor/nvidia/flaxen/overlay
endif
else
    ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014 tn7_114np_2014))
        PRODUCT_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay_tn7cw
    else
        PRODUCT_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay
    endif
endif

# Set default USB interface
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp

# Set DPI for Surface 2
PRODUCT_PROPERTY_OVERRIDES += ro.sf.lcd_density=140

# Enable secure USB debugging in user release build
ifeq ($(TARGET_BUILD_TYPE),release)
ifeq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.adb.secure=1
endif
endif

# Include ShieldTech
ifeq ($(NV_ANDROID_FRAMEWORK_ENHANCEMENTS),TRUE)
SHIELDTECH_FEATURE_NVGALLERY := false
SHIELDTECH_FEATURE_KEYBOARD := false
SHIELDTECH_FEATURE_CONSOLE_MODE := false
SHIELDTECH_FEATURE_BLAKE := false
$(call inherit-product-if-exists, vendor/nvidia/shieldtech/common/shieldtech.mk)
endif

