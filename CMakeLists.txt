cmake_minimum_required(VERSION 3.14)
project(uWebsocketBPS)

set(CMAKE_C_STANDARD 99)



# Create a library called "Hello" which includes the source file "hello.cxx".
# The extension is already found. Any number of sources could be listed here.
add_library (UWS SHARED src/Extensions.cpp src/Group.cpp src/Networking.cpp src/Hub.cpp src/Node.cpp src/WebSocket.cpp src/HTTPSocket.cpp src/Socket.cpp src/Epoll.cpp src/Room.cpp )
#add_library (UWS STATIC src/Extensions.cpp src/Group.cpp src/Networking.cpp src/Hub.cpp src/Node.cpp src/WebSocket.cpp src/HTTPSocket.cpp src/Socket.cpp src/Epoll.cpp src/Room.cpp )

# Make sure the compiler can find include files for our Hello library
# when other libraries or executables link to Hello
#target_include_directories (Hello PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})


# Add executable called "helloDemo" that is built from the source files
# "demo.cxx" and "demo_b.cxx". The extensions are automatically found.
add_executable (BPSClient examples/BPSClient.cpp)
add_executable (client examples/client.cpp)
add_executable (echo_srv examples/echo.cpp)

find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)

# Link the executable to the Hello library. Since the Hello library has
# public include directories we will use those link directories when building
# helloDemo
target_link_libraries (BPSClient
        LINK_PUBLIC UWS OpenSSL::SSL
        LINK_PUBLIC UWS OpenSSL::Crypto
        LINK_PUBLIC ZLIB::ZLIB
        )
target_link_libraries (client
        LINK_PUBLIC UWS OpenSSL::SSL
        LINK_PUBLIC UWS OpenSSL::Crypto
        LINK_PUBLIC ZLIB::ZLIB
        )
target_link_libraries (echo_srv
        LINK_PUBLIC UWS OpenSSL::SSL
        LINK_PUBLIC UWS OpenSSL::Crypto
        LINK_PUBLIC ZLIB::ZLIB
        )