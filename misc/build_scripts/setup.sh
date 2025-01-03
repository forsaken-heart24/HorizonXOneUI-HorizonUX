# ok, fbans dropped!
echo -e "'\033[0;31m'########################################################################"
echo -e "   _  _     _   _            _                _   ___  __"
echo -e " _| || |_  | | | | ___  _ __(_)_______  _ __ | | | \\ \/ /"
echo -e "|_  ..  _| | |_| |/ _ \\| '__| |_  / _ \\| '_ \\| | | |\\  / "
echo -e "|_      _| |  _  | (_) | |  | |/ / (_) | | | | |_| |/  \\ "
echo -e "  |_||_|   |_| |_|\___/|_|  |_/___\\___/|_| |_|\___//_/\\_\\"
echo -e "                                                         "
echo -e "   _  _     ____        _ _     _                           _       _   "
echo -e " _| || |_  | __ ) _   _(_) | __| | ___ _ __   ___  ___ _ __(_)_ __ | |_ "
echo -e "|_  ..  _| |  _ \\| | | | | |/ _\` |/ _ \\ '__| / __|/ __| '__| | '_ \\| __|"
echo -e "|_      _| | |_) | |_| | | | (_| |  __/ |    \\__ \\ (__| |  | | |_) | |_ "
echo -e "  |_||_|   |____/ \\__,_|_|_|\\__,_|\\___|_|    |___/\\___|_|  |_| .__/ \\__|"
echo -e "                                                             |_|"
echo -e "'\033[0;33m'########################################################################'\033[0m'"
console_print "Starting to build HorizonUX ${CODENAME} - v${CODENAME_VERSION_REFERENCE_ID} on $(id -un)'s computer..."
console_print "Build started by $(id -un) at $(date +%I:%M%p) on $(date +%d\ %B\ %Y)"
console_print "The Current Username : $(id -un)"
console_print "CPU Architecture : $(lscpu | grep Architecture | awk '{print $2}')"
console_print "CPU Manufacturer and model : $(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)"
console_print "L2 Cache Memory Size : $(lscpu | grep L2 | awk '{print $3}')"
console_print "Available RAM Memory : $(free -h | grep Mem | awk '{print $7}')B"
console_print "The Computer is turned on since : $(uptime --pretty | awk '{print substr($0, 4)}')"

################ boom
if $TARGET_BUILD_IS_FOR_DEBUGGING; then
	echo -e "\n############ WARNING, EXPERIMENTAL FLAGS AHEAD!\nlogcat.live=enable\nsys.lpdumpd=1\npersist.debug.atrace.boottrace=1\npersist.device_config.global_settings.sys_traced=1\npersist.traced.enable=1\nlog.tag.ConnectivityManager=V\nlog.tag.ConnectivityService=V\nlog.tag.NetworkLogger=V\nlog.tag.IptablesRestoreController=V\nlog.tag.ClatdController=V\npersist.sys.lmk.reportkills=false\nsecurity.dsmsd.enable=true\npersist.log.ewlogd=1\nsys.config.freecess_monitor=true\npersist.heapprofd.enable=1\ntraced.lazy.heapprofd=1\ndebug.enable=true\nsys.wifitracing.started=1\nsecurity.edmaudit=false\nro.sys.dropdump.on=On\npersist.systemserver.sa_bindertracker=false\n############ WARNING, EXPERIMENTAL FLAGS AHEAD!" >> $HORIZON_SYSTEM_PROPERTY_FILE 
	echo -e "\n############ WARNING, EXPERIMENTAL FLAGS AHEAD!\nsetprop log.tag.snap_api::snpe VERBOSE\nsetprop log.tag.snap_api::V3 VERBOSE\nsetprop log.tag.snap_api::V2 VERBOSE\nsetprop log.tag.snap_compute::V3 VERBOSE\nsetprop log.tag.snap_compute::V2 VERBOSE\nsetprop log.tag.snaplite_lib VERBOSE\nsetprop log.tag.snap_api::snap_eden::V3 VERBOSE\nsetprop log.tag.snap_api::snap_ofi::V1 VERBOSE\nsetprop log.tag.snap_hidl_v3 VERBOSE\nsetprop log.tag.snap_service@1.2 VERBOSE\n############ WARNING, EXPERIMENTAL FLAGS AHEAD!" > $HORIZON_HORIZON_SYSTEM_DIR/etc/init/init.debug_castleprops.rc
	warns "Debugging stuffs are enabled in this build, please proceed with caution and do remember that your device will heat more due to debugging process running in the background.." "DEBUGGING_ENABLER"
	# change the values to enable debugging without authorization.
	for i in "ro.debuggable 1" "ro.adb.secure 0"; do 
		setprop --system "$(echo $i | awk '{print $1}')" "$(echo $i | awk '{print $2}')"
	done
	for i in $HORIZON_PRODUCT_PROPERTY_FILE $HORIZON_HORIZON_SYSTEM_DIR/product/*/build.prop;
		[ -f "${i}" ] && setprop --product "persist.sys.usb.config" "mtp,adb"
	done
	chmod 644 $HORIZON_HORIZON_SYSTEM_DIR/etc/init/init.debug_castleprops.rc
	chown 0 $HORIZON_HORIZON_SYSTEM_DIR/etc/init/init.debug_castleprops.rc
	chgrp 0 $HORIZON_HORIZON_SYSTEM_DIR/etc/init/init.debug_castleprops.rc
fi

if [ "$BUILD_TARGET_ANDROID_VERSION" == "14" ]; then
	console_print "removing some bloats, thnx Salvo!"
	rm -rf $HORIZON_SYSTEM_DIR/etc/permissions/privapp-permissions-com.samsung.android.kgclient.xml \
	$HORIZON_SYSTEM_DIR/etc/public.libraries-wsm.samsung.txt \
	$HORIZON_SYSTEM_DIR/lib/libhal.wsm.samsung.so \
	$HORIZON_SYSTEM_DIR/lib/vendor.samsung.hardware.security.wsm.service-V1-ndk.so \
	$HORIZON_SYSTEM_DIR/lib64/libhal.wsm.samsung.so \
	$HORIZON_SYSTEM_DIR/lib64/vendor.samsung.hardware.security.wsm.service-V1-ndk.so \
	$HORIZON_SYSTEM_DIR/priv-app/KnoxGuard
fi

if $TARGET_REMOVE_USELESS_SAMSUNG_APPLICATIONS_STUFFS; then
	. ${SCRIPTS[5]}
fi

if $TARGET_INCLUDE_UNLIMITED_BACKUP; then
	console_print "Adding unlimited backup feature...."
	mkdir -p ./build/system/product/etc/sysconfig/
	. ${SCRIPTS[0]}
	mv ./build/system/product/etc/sysconfig/* $HORIZON_SYSTEM_DIR/etc/sysconfig/
fi

if $TARGET_REQUIRES_BLUETOOTH_LIBRARY_PATCHES; then
	console_print "Patching bluetooth...."
	# initial checks.
	if [ ! -f "$HORIZON_SYSTEM_DIR/lib64/libbluetooth_jni.so" ]; then
		abort "The \"libbluetooth_jni.so\" file from the system/lib64 wasn't found, copy and put them in a random directory and try again.."
	fi
	# patch this weird device lib.
	HEX_PATCH "$HORIZON_SYSTEM_DIR/lib64/libbluetooth_jni.so" "6804003528008052" "2b00001428008052"
fi

if $TARGET_INCLUDE_FASTBOOTD_PATCH_BY_RATCODED; then
	console_print "Patching recovery image..."
	. ${SCRIPTS[2]}
fi

if $TARGET_INCLUDE_CUSTOM_SETUP_WELCOME_MESSAGES; then
	console_print "adding custom setup wizard text...."
	custom_setup_finished_messsage
	build_and_sign --overlay ./horizon/packages/sec_setup_wizard_horizonux_overlay/
fi

if $TARGET_REMOVE_NONE_SECURITY_OPTION; then
	warns_api_limitations "11"
	console_print "removing none security option from lockscreen settings..."
	echo -e "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<resources>\n\t<bool name=\"config_hide_none_security_option\">true</bool>\n" > ./horizon/packages/settings/oneui3/remove_none_option_on_security_tab/res/values/bools.xml
fi

if $TARGET_REMOVE_SWIPE_SECURITY_OPTION; then
	console_print "removing swipe security option from lockscreen settings..."
	warns_api_limitations "11"
	echo -e "\t<bool name=\"config_hide_swipe_security_option\">true</bool>\n</resources>" >> ./horizon/packages/settings/oneui3/remove_none_option_on_security_tab/res/values/bools.xml
else
	echo "</resources>" >> ./horizon/packages/settings/oneui3/remove_none_option_on_security_tab/res/values/bools.xml
fi

if $TARGET_REMOVE_SWIPE_SECURITY_OPTION; then
	warns_api_limitations "11"
	build_and_sign --overlay ./horizon/packages/settings/oneui3/remove_none_option_on_security_tab/
fi

if $TARGET_ADD_EXTRA_ANIMATION_SCALES; then
	console_print "cooking extra animation scales.."
	build_and_sign --overlay ./horizon/packages/settings/oneui3/extra_animation_scales/
fi

if $TARGET_ADD_ROUNDED_CORNERS_TO_THE_PIP_WINDOWS; then
	console_print "cooking rounded corners on pip window...."
	warns_api_limitations "11"
	build_and_sign --overlay ./horizon/packages/systemui/oneui3/rounded_corners_on_pip/
fi

if $TARGET_FLOATING_FEATURE_INCLUDE_GAMELAUNCHER_IN_THE_HOMESCREEN; then
	console_print "Enabling Game Launcher..."
	change_xml_values "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_DEFAULT_GAMELAUNCHER_ENABLE" "TRUE"
elif ! $TARGET_FLOATING_FEATURE_INCLUDE_GAMELAUNCHER_IN_THE_HOMESCREEN; then
	warns "Disabling Game Launcher..." "TARGET_FEATURE_CONFIGURATION"
	change_xml_values "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_DEFAULT_GAMELAUNCHER_ENABLE" "FALSE"
fi

if $BUILD_TARGET_HAS_HIGH_REFRESH_RATE_MODES; then
	console_print "Switching the default refresh rate to ${BUILD_TARGET_DEFAULT_SCREEN_REFRESH_RATE}Hz..."
	change_xml_values "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" "${BUILD_TARGET_DEFAULT_SCREEN_REFRESH_RATE}"
elif ! $BUILD_TARGET_HAS_HIGH_REFRESH_RATE_MODES; then
	warns "Switching the default refresh rate to 60Hz (due to the BUILD_TARGET_HAS_HIGH_REFRESH_RATE_MODES variable being set to false)." "TARGET_FEATURE_CONFIGURATION"
	change_xml_values "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE" "60"
fi

if $TARGET_FLOATING_FEATURE_INCLUDE_SPOTIFY_AS_ALARM; then
	console_print "Adding spotify as an option in the clock app.."
	add_float_xml_values "SEC_FLOATING_FEATURE_CLOCK_CONFIG_ALARM_SOUND" "spotify"
fi

if $TARGET_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS; then
	console_print "This feature needs some patches to work on some roms, if you dont"
	console_print "see anything in the battery settings, please remove this on the next build."
	add_float_xml_values "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS" "TRUE"
fi

# the live clock icon in the OneUI launcher.
if $TARGET_FLOATING_FEATURE_INCLUDE_CLOCK_LIVE_ICON; then
	console_print "Disabling the live clock icon from the launcher, great move!"
	change_xml_values "SEC_FLOATING_FEATURE_LAUNCHER_SUPPORT_CLOCK_LIVE_ICON" "TRUE"
elif ! $TARGET_FLOATING_FEATURE_INCLUDE_CLOCK_LIVE_ICON; then
	console_print "Enabling the live clock icon from the launcher, bad move!"
	change_xml_values "SEC_FLOATING_FEATURE_LAUNCHER_SUPPORT_CLOCK_LIVE_ICON" "FALSE"
fi

if $TARGET_FLOATING_FEATURE_INCLUDE_EASY_MODE; then
	console_print "Enabling Easy Mode..."
	change_xml_values "SEC_FLOATING_FEATURE_SETTINGS_SUPPORT_EASY_MODE" "TRUE"
elif ! $TARGET_FLOATING_FEATURE_INCLUDE_EASY_MODE; then
	console_print "Disabling Easy Mode..."
	change_xml_values "SEC_FLOATING_FEATURE_SETTINGS_SUPPORT_EASY_MODE" "FALSE"
fi

if $TARGET_FLOATING_FEATURE_DISABLE_BLUR_EFFECTS; then
	console_print "Disabling blur effects..."
	for blur_effects in SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_PARTIAL_BLUR SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_CAPTURED_BLUR SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_3D_SURFACE_TRANSITION_FLAG; do
		change_xml_values "$blur_effects" "FALSE" 
	done
fi

if $TARGET_FLOATING_FEATURE_ENABLE_ENHANCED_PROCESSING; then
	console_print "Enabling Enhanced Processing.."
	for enhanced_gaming in SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_LOW_HEAT_MODE SEC_FLOATING_FEATURE_COMMON_SUPPORT_HIGH_PERFORMANCE_MODE SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS; do
		change_xml_values "$enhanced_gaming" "TRUE"
	done
fi

if $TARGET_FLOATING_FEATURE_ENABLE_EXTRA_SCREEN_MODES; then
	console_print "Adding support for extra screen modes...."
	for led_modes in SEC_FLOATING_FEATURE_LCD_SUPPORT_MDNIE_HW SEC_FLOATING_FEATURE_LCD_SUPPORT_WIDE_COLOR_GAMUT; do
		change_xml_values "${led_modes}" "FALSE"
	done
fi

if $TARGET_FLOATING_FEATURE_SUPPORTS_WIRELESS_POWER_SHARING; then
	console_print "Enabling Wireless powershare...."
	for wireless_power_sharing_lore in SEC_FLOATING_FEATURE_BATTERY_SUPPORT_HV SEC_FLOATING_FEATURE_BATTERY_SUPPORT_WIRELESS_HV SEC_FLOATING_FEATURE_BATTERY_SUPPORT_WIRELESS_NIGHT_MODE \
		SEC_FLOATING_FEATURE_BATTERY_SUPPORT_WIRELESS_TX; do
		add_float_xml_values "${i}" "TRUE"
	done
fi

if $TARGET_FLOATING_FEATURE_ENABLE_ULTRA_POWER_SAVING; then
	console_print "Enabling Ultra Power Saver mode...."
	add_float_xml_values "SEC_FLOATING_FEATURE_COMMON_SUPPORT_ULTRA_POWER_SAVING" "TRUE"
fi

if $TARGET_FLOATING_FEATURE_DISABLE_SMART_SWITCH; then
	console_print "Disabling Smart Switch feature in setup...."
	change_xml_values "SEC_FLOATING_FEATURE_COMMON_SUPPORT_SMART_SWITCH" "FALSE"
fi

if $TARGET_FLOATING_FEATURE_SUPPORTS_DOLBY_IN_GAMES; then
	console_print "Enabling dolby encoding in games...."
	for dolby_in_games in SEC_FLOATING_FEATURE_AUDIO_SUPPORT_DEFAULT_ON_DOLBY_IN_GAME SEC_FLOATING_FEATURE_AUDIO_SUPPORT_DOLBY_GAME_PROFILE; do
		add_float_xml_values "${dolby_in_games}" "TRUE"
	done
fi

# let's download goodlook modules from corsicanu's repo.
[ "${TARGET_INCLUDE_SAMSUNG_THEMING_MODULES}" == "true" ] && check_internet_connection "GOODLOCK_MODULES" && download_glmodules

# installs audio resampler.
if $TARGET_INCLUDE_HORIZON_AUDIO_RESAMPLER; then
	console_print "Enabling HorizonUX audio resampler..."
	echo -e "\n# HorizonUX Audio resampler manager prop\npersist.horizonux.audio.resampler=available\n" >> $HORIZON_SYSTEM_PROPERTY_FILE
else
	console_print "Disabling HorizonUX audio resampler..."
	echo -e "\n# HorizonUX Audio resampler manager prop\npersist.horizonux.audio.resampler=unavailable\n" >> $HORIZON_SYSTEM_PROPERTY_FILE
fi

if $TARGET_INCLUDE_HORIZON_TOUCH_FIX; then
	console_print "Adding brotherboard's GSI touch fix..."
	echo -e "persist.horizonux.brotherboard.touch_fix=available\n" >> $HORIZON_SYSTEM_PROPERTY_FILE
	cp -af ./horizon/rom_tweaker_script/brotherboard_touch_fix.sh $HORIZON_SYSTEM_DIR/bin/
	chmod 755 $HORIZON_SYSTEM_DIR/bin/brotherboard_touch_fix.sh
	chown 0 $HORIZON_SYSTEM_DIR/bin/brotherboard_touch_fix.sh
	chgrp 0 $HORIZON_SYSTEM_DIR/bin/brotherboard_touch_fix.sh
fi

# L, see the dawn makeconfigs.prop file :\
if $TARGET_INCLUDE_HORIZON_OEMCRYPTO_DISABLER_PLUGIN; then
	for part in $HORIZON_SYSTEM_DIR $HORIZON_VENDOR_DIR; do
		for libdir in $part/lib $part/lib64; Do
			if [ -f $part/$libdir/liboemcrypto.so ]; then
				touch $part/$libdir/liboemcrypto.so
			fi
		done
	done
fi

# custom wallpaper-res resources_info.json generator.
if $CUSTOM_WALLPAPER_RES_JSON_GENERATOR; then
	console_print "Opening resources_info.json generator....."
	. ${SCRIPTS[3]}
fi

# removes useless samsung stuffs from the vendor partition.
if $TARGET_REMOVE_USELESS_VENDOR_STUFFS; then
	console_print "Nuking useless vendor stuffs..."
	mkdir -p ./build/vendor/etc/init/
    nuke_stuffs
	console_print "Finished removing stuffs from wifi.rc file, checkout patched_resources/vendor/etc/init/ folder"
	console_print " and yeah besure to copy that into your actual vendor/etc/init folder and try if it works or not!"
fi

# nukes display refresh rate overrides on some video platforms.
if $DISABLE_DISPLAY_REFRESH_RATE_OVERRIDE; then
	console_print "Disabling Refresh rate override from surfaceflinger..."
	sed -i \
		"/max_frame_buffer_acquired_buffers/a ro.surface_flinger.enable_frame_rate_override=false" \
		"$HORIZON_VENDOR_DIR/default.prop"	
fi

# disable's DRC shit
if $DISABLE_DYNAMIC_RANGE_COMPRESSION; then
	console_print "Disabling Dynamic Range Compression..."
	sed -i 's/speaker_drc_enabled="true"/speaker_drc_enabled="false"/' $HORIZON_VENDOR_DIR/etc/audio_policy_configuration.xml
fi

if $DISABLE_SAMSUNG_ASKS_SIGNATURE_VERFICATION; then
	console_print "Disabling Samsung's ASKS..."
	check_existence_of_property "ro.build.official.release" > $TMPFILE && setprop --$(absolute_path --$(cat $TMPFILE)) "ro.build.official.release" "false"
fi

if $FORCE_HARDWARE_ACCELERATION; then
	warns "Enabling hardware acceleration..." "MISC"
	for i in "debug.hwui.renderer skiagl" "video.accelerate.hw 1" "debug.sf.hw 1" \
	"debug.performance.tuning 0" "debug.egl.hw 1" "debug.composition.type gpu"; do
		# use echo to null-terminate the var value.
		setprop --system "$(echo "${i}" | awk '{printf $1}')" "$(echo "${i}" | awk '{printf $2}')"
	done
fi

# let's extend audio offload buffer size to 256kb and plug some of our things.
console_print "Running misc jobs..."
default_language_configuration ${NEW_DEFAULT_LANGUAGE_ON_PRODUCT} ${NEW_DEFAULT_LANGUAGE_COUNTRY_ON_PRODUCT}
change_xml_values "SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE" "${TARGET_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE}"
setprop --vendor "vendor.audio.offload.buffer.size.kb" "256"
rm -rf $HORIZON_SYSTEM_DIR/hidden $HORIZON_SYSTEM_DIR/preload $HORIZON_SYSTEM_DIR/recovery-from-boot.p $HORIZON_SYSTEM_DIR/bin/install-recovery.sh
cp -af ./misc/etc/ringtones_and_etc/media/audio/* $HORIZON_SYSTEM_DIR/media/audio/
cp -af ./horizon/rom_tweaker_script/init.ishimiiiiiiiiiiiiiii.rc $HORIZON_SYSTEM_DIR/etc/init/
cp -af ./horizon/rom_tweaker_script/ishimiiiiiiiiii.sh $HORIZON_SYSTEM_DIR/bin/
$TARGET_INCLUDE_HORIZON_TOUCH_FIX && echo -e "\nservice brotherboard_touch_fix /system/bin/sh -c /system/bin/brotherboard_touch_fix.sh\n\tuser root\n\tgroup root\n\toneshot" >> $HORIZON_SYSTEM_DIR/etc/init/init.ishimiiiiiiiiiiiiiii.rc
chmod 755 $HORIZON_SYSTEM_DIR/bin/ishimiiiiiiiiii.sh
chmod 644 $HORIZON_SYSTEM_DIR/etc/init/init.ishimiiiiiiiiiiiiiii.rc
chown 0 $HORIZON_SYSTEM_DIR/bin/ishimiiiiiiiiii.sh $HORIZON_SYSTEM_DIR/etc/init/init.ishimiiiiiiiiiiiiiii.rc
chgrp 0 $HORIZON_SYSTEM_DIR/bin/ishimiiiiiiiiii.sh $HORIZON_SYSTEM_DIR/etc/init/init.ishimiiiiiiiiiiiiiii.rc
change_xml_values "SEC_FLOATING_FEATURE_COMMON_SUPPORT_SAMSUNG_MARKETING_INFO" "FALSE"
# let's remove the flash recovery service on android 11, idk how to remove those in android 12+
# i guess we can use diff for that.
#if [ "$BUILD_TARGET_SDK_VERSION" == "30" ] && grep -q "flash_recovery_sec" "$HORIZON_SYSTEM_DIR/etc/init/uncrypt.rc"; then
	#grep -v "flash_recovery_sec" "$HORIZON_SYSTEM_DIR/etc/init/uncrypt.rc" > ./tmp/uncrypt.rc
	#mv ./tmp/uncrypt.rc "$HORIZON_SYSTEM_DIR/etc/init/uncrypt.rc"
#fi
$TARGET_INCLUDE_CUSTOM_BRAND_NAME && change_xml_values "SEC_FLOATING_FEATURE_SETTINGS_CONFIG_BRAND_NAME" "${BUILD_TARGET_CUSTOM_BRAND_NAME}"
[ -f "$HORIZON_SYSTEM_DIR/$(fetch_rom_arch --libpath)/libhal.wsm.samsung.so" ] && touch $HORIZON_SYSTEM_DIR/$(fetch_rom_arch --libpath)/libhal.wsm.samsung.so
# let's patch restart_radio_process for my own will. PLEASE LET THIS SLIDE OUTT!!!!
if [ "${BUILD_TARGET_SDK_VERSION}" -ge "29" ] && [ "${BUILD_TARGET_SDK_VERSION}" -le "33" ]; then
	apply_diff_patches "$HORIZON_SYSTEM_DIR/etc/restart_radio_process.sh" "${DIFF_UNIFED_PATCHES[0]}"
fi
# again, let's patch wifi init files :/
if [ "${BUILD_TARGET_SDK_VERSION}" -eq "29" ]; then
	apply_diff_patches "$HORIZON_VENDOR_DIR/etc/init/wifi.rc" "${DIFF_UNIFED_PATCHES[1]}"
elif [ "${BUILD_TARGET_SDK_VERSION}" -eq "30" ] && [ "${BUILD_TARGET_SDK_VERSION}" -le "31" ]; then
	apply_diff_patches "$HORIZON_VENDOR_DIR/etc/init/wifi.rc" "${DIFF_UNIFED_PATCHES[2]}"
elif [ "${BUILD_TARGET_SDK_VERSION}" -eq "32" ] && [ "${BUILD_TARGET_SDK_VERSION}" -le "33" ]; then
	apply_diff_patches "$HORIZON_VENDOR_DIR/etc/init/wifi.rc" "${DIFF_UNIFED_PATCHES[3]}"
fi
for i in "logcat.live disable" "sys.dropdump.on Off" "profiler.force_disable_err_rpt 1" "profiler.force_disable_ulog 1" \
		 "sys.lpdumpd 0" "persist.device_config.global_settings.sys_traced 0" "persist.traced.enable 0" "persist.sys.lmk.reportkills false" \
		 "log.tag.ConnectivityManager S" "log.tag.ConnectivityService S" "log.tag.NetworkLogger S" \
		 "log.tag.IptablesRestoreController S" "log.tag.ClatdController S"; do
			# use echo to null-terminate the var value.
			setprop --system "$(echo "${i}" | awk '{printf $1}')" "$(echo "${i}" | awk '{printf $2}')"
done
# send off message.
console_print "Check the /build folder for the items you have built."
console_print "Please sign the built overlay or application packages manually with your own private keys;"
console_print "Do not use any public keys provided by any application building software. "
console_print "script errors are moved to the ./error_ring.log file, please consider checking it out! "
if [ "${BATTLEMAGE_BUILD}" == "true" ]; then
	console_print "Please review the image for the changes, if the changes aren't applied you can always extract and mod them"
    umount $HASH_KEY_FOR_SUPER_BLOCK_PATH &>/dev/null
    rmdir $HASH_KEY_FOR_SUPER_BLOCK_PATH &>/dev/null
fi