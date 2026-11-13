
message("Building on Android.")
set(ANDROID_BUILD 1)

# Android (Bionic libc) uses the POSIX platform layer. pthreads are part of libc, so no extra linker libs.
set(PLATFORM_SHIM_PATH "${CMAKE_CURRENT_LIST_DIR}/../src/platform/posix" )

set(POSIX True)

# The vendored libyafl (used by the fiber POCs) can't auto-detect an Android triple.
# Its context-switch assembly follows the same ABI on Bionic as on Linux.
if(NOT DEFINED TARGET)
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        set(TARGET "aarch64-pc-linux-gnu")
    elseif(ANDROID_ABI STREQUAL "x86_64")
        set(TARGET "x86_64-unknown-linux-android")
    elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
        set(TARGET "arm-pc-linux-gnu")
    elseif(ANDROID_ABI STREQUAL "x86")
        set(TARGET "i386-pc-linux-gnu")
    endif()
endif()
