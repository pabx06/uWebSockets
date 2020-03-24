#include <iostream>

#include <uWS/uWS.h>

int main()
{
    uWS::Hub hub;
    uWS::Group<uWS::CLIENT> *hubGroup;
    std::unique_ptr<uS::Async> hubTrigger;


    hubGroup = hub.createGroup<uWS::CLIENT>();

    hubGroup->onConnection([](uWS::WebSocket<uWS::CLIENT> *ws, uWS::HttpRequest req) {
        std::cout << "connect, sending HELLO" << std::endl;
        std::string msg = "HELLO";
        ws->send(msg.data(), msg.size(), uWS::OpCode::TEXT);
    });

    hubGroup->onMessage([](uWS::WebSocket<uWS::CLIENT> *ws, char *message, size_t length, uWS::OpCode opCode) {
        std::cout << "Got reply: " << std::string(message, length) << std::endl;
        ws->terminate();
    });

    hubGroup->onDisconnection([](uWS::WebSocket<uWS::CLIENT> *ws, int code, char *message, size_t length) {
        std::cout << "Disconnect." << std::endl;
    });


    hub.connect("ws://localhost:9876", nullptr, { }, 5000, hubGroup);


    hub.run();
}
