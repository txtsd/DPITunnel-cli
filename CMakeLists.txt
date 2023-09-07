# Set the minimum version of CMake that can be used
cmake_minimum_required(VERSION 3.24)

# Set the project name
project(DPITunnel DESCRIPTION "A program for bypassing internet censorship without a proxy server" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
cmake_policy(SET CMP0065 NEW)
cmake_policy(SET CMP0138 NEW)

set(CMAKE_CXX_FLAGS "-Wall -pedantic -fstack-protector-strong --param=ssp-buffer-size=4 ${CMAKE_CXX_FLAGS}")

# set CXXFLAGS for build targets
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -D_FORTIFY_SOURCE=2 ${CMAKE_CXX_FLAGS_RELEASE}")

option(ENABLE_LTO "Enable Link Time Optimization" off)

if (ENABLE_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT ipo_supported OUTPUT ipo_error)

    if (ipo_supported)
        if (CMAKE_BUILD_TYPE)
            if (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
                set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
                set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL TRUE)
                message(STATUS "IPO / LTO enabled")
            else ()
                message(STATUS "Not enabling IPO / LTO on debug builds")
            endif ()
        else ()
            message(STATUS "IPO / LTO will only be enabled for release builds")
        endif ()
    else ()
        message(STATUS "IPO / LTO not supported: <${ipo_error}>")
    endif ()
endif ()

if (STATIC_BINARY)
    message(STATUS "Building static portable binary with small size")
endif ()


# Add dependencies
add_subdirectory(RawSocket)
add_subdirectory(dnslib)

# Add an executable
add_executable(DPITunnel-exec
        autoconf.cpp
        desync.cpp
        dns.cpp
        dpitunnel.cpp
        netiface.cpp
        packet.cpp
        profiles.cpp
        socket.cpp
        ssl.cpp
        utils.cpp
)

if (STATIC_BINARY)
    target_link_libraries(DPITunnel-exec -static)
    target_link_options(DPITunnel-exec PRIVATE "LINKER:--gc-sections")
    target_link_options(DPITunnel-exec PRIVATE "LINKER:-s")
    target_compile_options(DPITunnel-exec PRIVATE -ffunction-sections)
endif ()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

if (STATIC_BINARY)
    set(OPENSSL_USE_STATIC_LIBS TRUE)
endif ()
find_package(OpenSSL 3.0.0 REQUIRED COMPONENTS SSL Crypto)

# Add httplib (cpp-httplib)
find_package(httplib 0.14.0 COMPONENTS OpenSSL ZLIB Brotli)
if (NOT HTTPLIB_FOUND)
    add_subdirectory(cpp-httplib)
    message(STATUS "Using bundled httplib")
endif ()

# Add libnl (libnl)
find_package(LibNL REQUIRED)

# Set the directories that should be included in the build command for this target
target_include_directories(DPITunnel-exec
        PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/RawSocket/include
        ${PROJECT_SOURCE_DIR}/dnslib/include
        ${LibNL_INCLUDE_DIR}
)

target_link_libraries(DPITunnel-exec
        RawSocket
        httplib::httplib
        dnslib
        nl-3
        nl-genl-3
        Threads::Threads
        OpenSSL::SSL
        OpenSSL::Crypto
)

if (STATIC_BINARY)
    target_link_libraries(DPITunnel-exec ${CMAKE_DL_LIBS})
endif ()
