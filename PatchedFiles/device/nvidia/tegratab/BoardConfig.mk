TARGET_BOARD_PLATFORM := tegra
TARGET_TEGRA_VERSION := t114
TARGET_TEGRA_FAMILY := t11x
TARGET_CPU_VARIANT := cortex-a15

# CPU options
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_SMP := true
TARGET_USE_TEGRA_BIONIC_OPTIMIZATION := true
TARGET_USE_TEGRA11_MEMCPY_OPTIMIZATION := true
ARCH_ARM_HAVE_TLS_REGISTER := true

# Skip droiddoc build to save build time
BOARD_SKIP_ANDROID_DOC_BUILD := true

BOARD_BUILD_BOOTLOADER := true
TARGET_USE_DTB := false
# TARGET_KERNEL_DT_NAME := tegra114-tegratab
BOOTLOADER_SUPPORTS_DTB := false
# It can be overridden by an environment variable
APPEND_DTB_TO_KERNEL ?= false

ifeq ($(NO_ROOT_DEVICE),1)
  TARGET_PROVIDES_INIT_RC := true
else
  TARGET_PROVIDES_INIT_RC := false
endif

BOARD_USES_TINY_ALSA_AUDIO := true
BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := true
BUILD_WITH_ALSA_UTILS := true

#BOARD_USES_GENERIC_AUDIO := false
#BOARD_USES_ALSA_AUDIO := true
#ifeq ($(PLATFORM_IS_NEXT),1)
 USE_CUSTOM_AUDIO_POLICY := 1
#endif
#BOARD_SUPPORT_NVOICE := true
#BOARD_SUPPORT_NVAUDIOFX := true

TARGET_USERIMAGES_USE_EXT4 := true
ifneq ($(TARGET_PRODUCT),flaxen)
  ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014 tn7_114np_2014))
      BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1073741824
  else
      BOARD_SYSTEMIMAGE_PARTITION_SIZE := 805306368
  endif
else
  BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1702887424
endif

ifeq ($(TARGET_PRODUCT),kalamata)
  BOARD_USERDATAIMAGE_PARTITION_SIZE := 13704888320
else
  ifneq ($(TARGET_PRODUCT),flaxen)
    ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014 tn7_114np_2014))
       BOARD_USERDATAIMAGE_PARTITION_SIZE := 13352566784
    else
       BOARD_USERDATAIMAGE_PARTITION_SIZE := 13600030720
    endif
  else
    BOARD_USERDATAIMAGE_PARTITION_SIZE := 11804868608
  endif
endif
BOARD_FLASH_BLOCK_SIZE := 4096

ifeq ($(TARGET_PRODUCT),flaxen)
  HEADSET_AMP_TPA6130A2 := true
endif

ifneq (,$(filter $(TARGET_PRODUCT),kalamata flaxen))
  SET_DCP_CURRENT_LIMIT_2A := false
else
  SET_DCP_CURRENT_LIMIT_2A := true
endif

# Surface 2 kernel defconfig
TARGET_KERNEL_CONFIG := surface-2_android_defconfig

USE_E2FSPROGS := true
USE_OPENGL_RENDERER := true

# OTA
TARGET_RECOVERY_UPDATER_LIBS += libnvrecoveryupdater
TARGET_RECOVERY_UPDATER_EXTRA_LIBS += libfs_mgr

BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/nvidia/tegratab/bluetooth

BOARD_HAVE_BLUETOOTH := true

#BOARD_HAVE_TI_BLUETOOTH := true

USE_CAMERA_STUB := false

# mediaplayer
BOARD_USES_HW_MEDIAPLUGINS := false
BOARD_USES_HW_MEDIASCANNER := false
BOARD_USES_HW_MEDIARECORDER := false

# powerhal
BOARD_USES_POWERHAL := true


#Wifi
BOARD_WLAN_DEVICE           := bcmdhd
WPA_SUPPLICANT_VERSION      := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER        := NL80211
BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# Wi-Fi module for Surface 2
WIFI_DRIVER_MODULE_PATH := "/system/lib/modules/sd8xxx.ko"
WIFI_DRIVER_MODULE_NAME := "sd8xxx"
WIFI_DRIVER_MODULE_ARG  := "drv_mode=5 cfg80211_wext=0xc sta_name=wlan uap_name=wlan wfd_name=p2p max_uap_bss=1 fw_name=mrvl/sd8797_uapsta.bin"
WIFI_DRIVER_FW_PATH_PARAM := "/proc/mwlan/config"
WIFI_DRIVER_FW_PATH_STA := "drv_mode=5"
WIFI_DRIVER_FW_PATH_AP :=  "drv_mode=6"
WIFI_DRIVER_FW_PATH_P2P := "drv_mode=5"


# Wifi related defines
#BOARD_WLAN_DEVICE           := wl18xx_mac80211
#BOARD_SOFTAP_DEVICE         := wl18xx_mac80211
#BOARD_WPA_SUPPLICANT_DRIVER := NL80211
#WPA_SUPPLICANT_VERSION      := VER_TI_0_8_X
#BOARD_HOSTAPD_DRIVER        := NL80211
#WIFI_DRIVER_MODULE_NAME     := "wlcore_sdio"
#WIFI_FIRMWARE_LOADER        := ""

#NFC
#BOARD_HAVE_NFC_TI	:= true

# Default HDMI mirror mode
# Crop (default) picks closest mode, crops to screen resolution
# Scale picks closest mode, scales to screen resolution (aspect preserved)
# Center picks a mode greater than or equal to the panel size and centers;
#     if no suitable mode is available, reverts to scale
BOARD_HDMI_MIRROR_MODE := Scale

# NVDPS can be enabled when display is set to continuous mode.
BOARD_HAS_NVDPS := true

# This should be set to true for boards that support 3DVision.
BOARD_HAS_3DV_SUPPORT := false

# Double buffered display surfaces reduce memory usage, but will decrease performance.
# The default is to triple buffer the display surfaces.
# BOARD_DISABLE_TRIPLE_BUFFERED_DISPLAY_SURFACES := true

BOARD_ROOT_DEVICE := emmc
#include frameworks/base/data/sounds/AudioPackage3.mk
include device/nvidia/common/BoardConfig.mk
include vendor/nvidia/build/definitions.mk

# Use CMU-style config with Nvcms
NVCMS_CMU_USE_CONFIG := true

-include 3rdparty/trustedlogic/samples/hdcp/tegra3/build/arm_android/config.mk

# BOARD_WIDEVINE_OEMCRYPTO_LEVEL
# The security level of the content protection provided by the Widevine DRM plugin depends
# on the security capabilities of the underlying hardware platform.
# There are Level 1/2/3. To run HD contents, should be Widevine level 1 security.
BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 1

# Dalvik option
DALVIK_ENABLE_DYNAMIC_GC := true

# NCT related defines
# bootloader/kernel
TARGET_USE_NCT := true

# enable factory bundle
TARGET_BUILD_FACTORY := true

# FRD(Factory RamDisk) is used
# FRD depends on NCT feature
TARGET_USE_FACTORY_RAMDISK := true

# LBH related defines
# use LBH partition and resources in it
BOARD_HAVE_LBH_SUPPORT := true

#Use tegra health HAL library
BOARD_HAL_STATIC_LIBRARIES := libhealthd.tegra

# Recovery pixel format
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# Factory Test related defines
BOARD_HAVE_NV_FACTORY_TEST := true

# This should be set to true for boards that have promotional media files
BOARD_HAVE_AD_MEDIA := true

# Max panel brightness in the first device boot for OOBE
# BOARD_FIRST_MAX_BRIGHTNESS_FOR_OOBE := true

# Charger disable init blank
BOARD_CHARGER_DISABLE_INIT_BLANK := true

# CMU enable forcibly from Android
BOARD_CMU_ENABLE_FROM_ANDROID_BOOT := true

# Charger show animation when key down
BOARD_CHARGER_KEYDOWN_KICK_ANIMATION := true

# Charger immediatley power down when chager unplug
BOARD_CHARGER_UNPLUGGED_SHUTDOWN_PROMPTLY := true

# Enable PRISM toggle switch in menu
BOARD_PRISM_TOGGLE_SWITCH_ENABLED := true

# Set cmdline and base for Surface 2
BOARD_KERNEL_CMDLINE := debug buildvariant=userdebug init=/init maxcpus=1 rw rootwait video=tegra_fb:1920x1080@60 androidboot.hardware=tegratab
BOARD_KERNEL_BASE := 0x84008000

# sepolicy
# try to detect AOSP master-based policy vs small KitKat policy
ifeq ($(wildcard external/sepolicy/lmkd.te),)
# KitKat based board specific sepolicy
BOARD_SEPOLICY_DIRS := device/nvidia/$(TARGET_DEVICE)/sepolicy
BOARD_SEPOLICY_UNION := healthd.te \
    installd.te \
    netd.te \
    untrusted_app.te \
    vold.te \
    file_contexts \
    file.te
else
# AOSP master based board specific sepolicy
BOARD_SEPOLICY_DIRS := device/nvidia/common/sepolicy_aosp
BOARD_SEPOLICY_UNION := \
	te_macros
BOARD_SEPOLICY_UNION += \
	app.te \
	bluetooth.te \
	bootanim.te \
	camera_lbh.te \
	cpuvoltcap.te \
	debuggerd.te \
	device.te \
	dex2oat.te \
	domain.te \
	drmserver.te \
	dumpstate.te \
	file_contexts \
	file.te \
	genfs_contexts \
	gpload.te \
	gpsd.te \
	healthd.te \
	hostapd.te \
	init.te \
	installd.te \
	lbh-setup.te \
	link_lbh.te \
	mediaserver.te \
	netd.te \
	platform_app.te \
	property_contexts \
	property.te \
	service_contexts \
	setup_fs.te \
	set_hwui.te \
	shell.te \
	surfaceflinger.te \
	system_app.te \
	system_server.te \
	tee.te \
	ueventd.te \
	untrusted_app.te \
	usb.te \
	usdwatchdog.te \
	ussrd.te \
	ussr_setup.te \
	vold.te \
	wifi_loader.te \
	wl18xx.te \
	wpa.te \
	zygote.te

BOARD_SEPOLICY_DIRS += device/nvidia/$(TARGET_DEVICE)/sepolicy_aosp
BOARD_SEPOLICY_UNION += \
	file_contexts \
	user_guide.te

# Maxim touch sepolicy
include device/nvidia/$(TARGET_DEVICE)/touchscreen/maxim/BoardConfigMaxim.mk

endif

# ALS LUX conversion factor
ifneq (,$(filter $(NV_TN_SKU),tn7_114gp_2014 tn7_114np_2014))
BOARD_LUX_CONV_FACTOR := 8.407
endif

#Enable power hint for Auido playback with speaker
AUDIO_SPEAKER_POWER_HINT := true

VSYNC_EVENT_PHASE_OFFSET_NS := 7500000
SF_VSYNC_EVENT_PHASE_OFFSET_NS := 5000000
