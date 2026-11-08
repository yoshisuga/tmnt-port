# Name:        ios.cmake
# Description: the iOS build (Xcode's generator, the iOS SDK): TMNT and TMNT Arcade as .apps, SDL2 built from its
#              source with the UIScene patch
# Version:     0.1.0
# Created:     08-11-2026
# Modified:    08-11-2026
# Author:      Sebastian Toyos
#
# Included by CMakeLists.txt when CMAKE_SYSTEM_NAME is iOS. Configure and build, for the simulator or for a device:
#   cmake -S . -B build/ios -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphonesimulator \
#         -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 -DTMNT_REFERENCE_TOOLS=OFF -DTMNT_BIN_DIR=build/ios/bin
#   cmake --build build/ios --config Release
# (CMAKE_OSX_SYSROOT=iphoneos and TMNT_IOS_TEAM, your Apple developer team's ID, for a device.) Both games are the
# computers' builds with their picture fixed (TMNT's WIDE follows the screen's shape, as Android's), no EXIT in TMNT's
# menu (the home gesture leaves it) and the touch screen's controls (TMNT_TOUCH, ports/sdl2/touch.c). As on Android,
# the app makes nothing from the ROM set: it carries the assets pack taken out of the player's ROM set on a computer
# (TMNT --write-pack FILE, build/bin/tmnt.assets by default: TMNT_IOS_PACK), so an app with a pack is its player's
# alone and never shared.
#
# SDL2's UIKit driver as released starts the app from application:didFinishLaunching: and makes windows without a
# scene. An app linked against the iOS 27 SDK is terminated at launch unless it adopts the UIScene lifecycle, so SDL2
# is patched (ports/ios/sdl2-uiscene.patch: a scene delegate, windows made in the scene, the orientation from the
# scene) and each Info.plist (ports/ios/Info.plist.in) declares the scene manifest.

target_compile_definitions(tmnt_console_game PUBLIC TMNT_HANDHELD TMNT_SYSTEM_EXIT TMNT_SCREEN_WIDE TMNT_TOUCH TMNT_IOS)

set(TMNT_IOS_TEAM "" CACHE STRING "The Apple developer team's ID the apps are signed with (a device needs one)")
set(TMNT_IOS_BUNDLE_PREFIX "io.github.cheviman" CACHE STRING "The apps' bundle identifiers start with this")
set(TMNT_IOS_PACK ${TMNT_BIN_DIR}/../tmnt.assets CACHE FILEPATH "The assets pack of the player's ROM set (TMNT --write-pack)")
# The apps a release shares are built with TMNT_IOS_NO_PACK: no pack in them, whatever is on this computer
# (ports/ios/add_pack.sh puts the player's own in)
option(TMNT_IOS_NO_PACK "Build the apps without an assets pack (the release's: the player adds their own)" OFF)
if(TMNT_IOS_NO_PACK)
	set(TMNT_IOS_PACK "")
else()
	if(NOT EXISTS ${TMNT_IOS_PACK} AND EXISTS ${CMAKE_SOURCE_DIR}/build/bin/tmnt.assets)
		set(TMNT_IOS_PACK ${CMAKE_SOURCE_DIR}/build/bin/tmnt.assets)
	endif()
	get_filename_component(TMNT_IOS_PACK ${TMNT_IOS_PACK} ABSOLUTE)
	if(NOT EXISTS ${TMNT_IOS_PACK})
		message(STATUS "No assets pack at ${TMNT_IOS_PACK}: the apps are built without one and say so when they start")
	endif()
endif()

# SDL2 from its source, static, with the UIScene patch (applied as FetchContent populates it, and not again where it is; a copy picked with
# FETCHCONTENT_SOURCE_DIR_SDL2 is used as it is, so it must have the patch)
include(FetchContent)
find_program(TMNT_GIT git REQUIRED)
FetchContent_Declare(SDL2 GIT_REPOSITORY https://github.com/libsdl-org/SDL.git GIT_TAG release-2.32.10 GIT_SHALLOW TRUE
	PATCH_COMMAND sh -c "${TMNT_GIT} apply -R --check '${CMAKE_SOURCE_DIR}/ports/ios/sdl2-uiscene.patch' 2>/dev/null \
		|| ${TMNT_GIT} apply '${CMAKE_SOURCE_DIR}/ports/ios/sdl2-uiscene.patch'")    # (again on a patched tree: no-op)
set(SDL_SHARED OFF CACHE BOOL "" FORCE)
set(SDL_STATIC ON CACHE BOOL "" FORCE)
set(SDL_TEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL2)
set(TMNT_SDL2 SDL2::SDL2-static)
if(TARGET SDL2::SDL2main)
	list(APPEND TMNT_SDL2 SDL2::SDL2main)
endif()

set(TMNT_IOS_ICONS ${CMAKE_SOURCE_DIR}/ports/ios/Assets.xcassets)

# An app: 'target' (its executable and display name 'name'), the window port's main.c and the sources after 'program'
# besides, on 'program'
function(tmnt_ios_app target program name identifier)
	add_executable(${target} MACOSX_BUNDLE ports/sdl2/main.c ports/sdl2/letters.c ports/sdl2/touch.c
		ports/sdl2/font/font.bmp ${TMNT_IOS_ICONS} ${ARGN})
	target_link_libraries(${target} PRIVATE ${program} tmnt_controller_db ${TMNT_SDL2})
	target_compile_definitions(${target} PRIVATE TMNT_HANDHELD TMNT_SYSTEM_EXIT TMNT_TOUCH TMNT_IOS)
	target_include_directories(${target} PRIVATE ports/sdl2)
	set(resources ports/sdl2/font/font.bmp ${TMNT_IOS_ICONS})
	if(TMNT_IOS_PACK AND EXISTS ${TMNT_IOS_PACK})
		target_sources(${target} PRIVATE ${TMNT_IOS_PACK})
		list(APPEND resources ${TMNT_IOS_PACK})
	endif()
	if(TARGET tmnt_console_game AND program STREQUAL "tmnt_console_game")
		target_sources(${target} PRIVATE ports/sdl2/prompts/input_prompts.bmp)
		list(APPEND resources ports/sdl2/prompts/input_prompts.bmp)
	endif()
	set_source_files_properties(${resources} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
	set_target_properties(${target} PROPERTIES OUTPUT_NAME "${name}"
		MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/ports/ios/Info.plist.in
		MACOSX_BUNDLE_BUNDLE_NAME "${name}" MACOSX_BUNDLE_GUI_IDENTIFIER ${TMNT_IOS_BUNDLE_PREFIX}.${identifier}
		MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION} MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
		XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME AppIcon
		XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
		XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET 15.0
		XCODE_ATTRIBUTE_CODE_SIGN_STYLE Automatic
		XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER ${TMNT_IOS_BUNDLE_PREFIX}.${identifier})
	if(TMNT_IOS_TEAM)
		set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ${TMNT_IOS_TEAM})
	endif()
endfunction()

# TMNT, the console version, and TMNT Arcade
tmnt_ios_app(tmnt_console tmnt_console_game "TMNT" tmnt ports/sdl2/controls.c)
tmnt_ios_app(tmnt tmnt_game "TMNT Arcade" tmnt-arcade)
