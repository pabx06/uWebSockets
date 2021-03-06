W        = -Wall
OPT      = -O2 -g
STD      = -std=c++11
CXXFLAGS = $(STD) $(OPT) $(W) -fPIC $(XCXXFLAGS)
INCS     = -Isrc/

SRCS = src/Extensions.cpp src/Group.cpp src/Networking.cpp src/Hub.cpp src/Node.cpp src/WebSocket.cpp src/HTTPSocket.cpp src/Socket.cpp src/Epoll.cpp src/Room.cpp

OBJS := $(SRCS:.cpp=.o)


.PHONY: clean all install examples


all: libuWS.a libuWS.so examples

examples: BPSClient client echo_srv
	mkdir -p includes/uWS
	cp src/*.h includes/uWS
	echo "remember to sudo cp libuWS.so /usr/lib"

BPSClient:examples/BPSClient.cpp
	$(CXX) -ggdb examples/BPSClient.cpp -o BPSClient -I includes -lssl -lcrypto -lz -luWS

client: examples/client.cpp libuWS.so
	$(CXX) -ggdb examples/client.cpp -o client -I includes -lssl -lcrypto -lz -luWS

echo_srv: examples/echo.cpp libuWS.so
	$(CXX) -ggdb examples/echo.cpp -o echo_srv -I includes -lssl -lcrypto -lz -luWS

clean:
	rm -f src/*.o libuWS.a libuWS.so echo_srv client BPSClient

install:
	$(eval PREFIX ?= /usr/local)
	cp libuWS.a libuWS.so $(PREFIX)/lib/
	mkdir -p $(PREFIX)/include/uWS
	cp src/*.h $(PREFIX)/include/uWS/

%.o : %.cpp %.d Makefile
	$(CXX) $(CXXFLAGS) $(INCS) -c $< -o $@

libuWS.a: $(OBJS)
	$(AR) rs $@ $(OBJS)

libuWS.so: $(OBJS)
	$(CXX) $(LDFLAGS) -shared -o $@ $(OBJS) -lssl -lcrypto
