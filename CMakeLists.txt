# Set the minimum version of CMake that can be used
cmake_minimum_required(VERSION 3.18)

set(CMAKE_CXX_STANDARD 14)
cmake_policy(SET CMP0065 NEW)

if (STATIC_BINARY)
    message(STATUS "Building static portable binary with small size")
endif ()


# Set the project name
project(DPITunnel-cli)

# Add dependencies
add_subdirectory(RawSocket)
add_subdirectory(dnslib)

# Add an executable
add_executable(DPITunnel-cli-exec
        autoconf.cpp
        desync.cpp
        dns.cpp
        dpitunnel-cli.cpp
        netiface.cpp
        packet.cpp
        profiles.cpp
        socket.cpp
        ssl.cpp
        utils.cpp
        )

if (STATIC_BINARY)
    target_link_libraries(DPITunnel-cli-exec -static)
    target_link_options(DPITunnel-cli-exec PRIVATE "LINKER:--gc-sections")
    target_link_options(DPITunnel-cli-exec PRIVATE "LINKER:-s")
    target_compile_options(DPITunnel-cli-exec PRIVATE -ffunction-sections)
endif ()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

if (STATIC_BINARY)
    set(OPENSSL_USE_STATIC_LIBS TRUE)
endif ()
find_package(OpenSSL 3.0.0 REQUIRED COMPONENTS SSL Crypto)

# Add httplib (cpp-httplib)
find_package(httplib 0.13.3 COMPONENTS OpenSSL ZLIB Brotli)
if (NOT HTTPLIB_FOUND)
    add_subdirectory(cpp-httplib)
    message(STATUS "Using bundled httplib")
endif()

# Add libnl (libnl)
find_package(LibNL REQUIRED)

# Set the directories that should be included in the build command for this target
target_include_directories(DPITunnel-cli-exec
        PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/RawSocket/include
        ${PROJECT_SOURCE_DIR}/dnslib/include
        ${LibNL_INCLUDE_DIR}
        )

target_link_libraries(DPITunnel-cli-exec
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
    target_link_libraries(DPITunnel-cli-exec ${CMAKE_DL_LIBS})
endif ()
