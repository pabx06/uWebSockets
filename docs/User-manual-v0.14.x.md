##### Note
*Check out tests/main.cpp source file for tons of "examples" and do check out the Gitter chat room.*

# Chapter 1 - Introduction
## Abstract
µWS is a single threaded C++ library for implementing memory and time efficient WebSocket servers.

#### template bool isServer
Most parts of the library are split down the middle. You either operate on uWS::CLIENT or uWS::SERVER resources. Groups, WebSockets and HttpSockets are split into client/server templated parts.

#### Threading model
The library comes with some threading abilities and some thread-safe functions. However threading should be seen as the exception rather than the norm. If you rely heavily on thread safety chances are you either do something fundamentally wrong (such as trying to cheat your way out of the event-loop design) or prematurely (and with wrong assumptions about perf.) optimize your solution. In 99% of cases a single-threaded design, scaled as separate isolated Hubs (with their own per-thread resources and event-loop) is the way to go. In other cases you need to dig into the library and read comments and follow functions down the stack yourself.

Basically scale it as Node.js, but instead of per-process you can do it per-thread if you want to.

#### A word on memory
Data is given zero-copy to callback handlers and gets invalidated on return. This means you need to copy it and save it for later if you do not consume it before return. Memory is given as `char *` with an accompanying `size_t` length. This means you cannot assume a C-string but instead need to take the length into account (this should be obvious since data can contain null chars as part of the actual message).

Send is currently not zero-copy but will (as needed) perform a copy of passed data. There might be work done to allow zero-copy sends in the future.

#### User data
A common **mistake** is to attach user data using a map like so:

```
std::map<uWS::WebSocket<uWS::SERVER> *, void *> socketToUserData;

// setting
socketToUserData[mySocket] = myData;

// getting
... = socketToUserData[mySocket];
```

Instead of doing this, make use of the `WebSocket::setUserData(void *)` and `WebSocket::getUserData()` functions. The library guarantees a balance between connection and disconnection events. Attach your user data at connection event & free it on disconnection event.

A given pointer to a WebSocket is valid from connection event until-and-including disconnection event. This means you can (and should) rely heavily on these two events (see them as constructor and destructor).

I'm talking about the onConnection and onDisconnection pair of events.

# Chapter 2 - The main classes
## uS::Loop
The Loop is an event-loop blocking exactly one thread and drives the server by calling registered callbacks when their respective events occur. Callbacks are always executed on the same thread as where their event-loop runs. In other words, it behaves like any event-loop ever existed.

The library is built in three layers: event-loop <-> networking <-> application. Networking and application code is cross-platform and static while the event-loop layer is exchangeable to allow seamless integration with other parts of your app.

Remember threading is an exception and often misused to try and escape the event-loop. Instead make sure to integrate the event-loop into your project and embrace it rather than work around it with awkward and inefficient threading. Use timers, delegates ("asyncs") and other assets to integrate your application logic into the eventing design.

## uS::Async
By default this library is single threaded and not thread safe. Some functions **can** be configured to be thread safe (see below) but (you) do not assume anything unless you clearly understand and configured things this way.

Assume everything is thread unsafe. This works well for most applications which follow the evented design of one Hub (and everything that spawns from that Hub such as WebSockets) per one thread. You cannot, for instance, send a message using a WebSocket spawned by a Hub on thread A, from thread B.

This is where Async's come in. Delegates, posts, asyncs -> they all have sweet names but do the same thing. The idea is to post a signal from thread B to the Hub of thread A by triggering an Async. They are simply thread safe signals you can use to achieve thread safety of functionalities which are not thread safe on their own.

If you wish to send a message using a WebSocket that belogs to thread A, from thread B then the flow becomes like so:

* Thread A creates an Async and assignes a **callback** to it. This is thread unsafe and is done once per app and per thread. It is done long prior to ever needing the Async.
* Thread B pushes the message to some shared thread safe queue then triggers the Async. Triggering an async is always thread safe.
* Thread A will receive this thread safe triggering and execute the callback registered before. In this callback you pop from the threadsafe queue and **now** you can execute that thread unsafe function since you now are on the correct thread for doing so.

## uWS::Hub
The Hub is a shared resource blob, local to one tread and not thread-safe. It holds the event-loop, shared buffers and other shared resources.

The `uWS::Hub` consists of a client group and a server group. It also holds per-thread resources. One hub per thread, one thread per hub.

## uWS::Group
The `uWS::Group` is a group of sockets and a set of shared event handlers. A socket can only belong to one group at any given time, which means that groups are not intended to be used as "pub/sub rooms". A more suitable use of groups can be to implement subprotocols or differing behavior. There are no per-socket event handlers, all event handlers are attached to a group and all sockets belong to exactly one group.

A socket can transfer between different Groups at run-time and will thus change behavior. There are broadcasting helper functions for Groups, but again, these are not intended for pub/sub and are not even particularly efficient.

#### Setting callback handlers
With a Group (or Hub) you simply attach a lambda or function like so:

```
Hub h;
h.onMessage([](/*arguments*/) {
/*behavior*/
});
```

This is the same design all handlers are set. Different handlers exists such as onMessage, onConnection, onDisconnection, onHttpRequest, onHttpData, and more. Check out headers.

## uWS::WebSocket
The WebSocket class represents a connection between browser and server. Main functionalities include `send`, `close`, `terminate`, etc. There are more lower level features available if you dig into the code (with detailed comments), such as "frame-once, send many" `prepareMessage`, `sendPrepared`, `finalizeMessage` functions. These three represent prepare, emit, destroy of messages you might want to send to multiple recipients such as in a broadcast. But in most cases you should be just fine with send & close functions.

Sending a message involves specifying a buffer, its length and what message type to send. Memory is given as a copy to send, so you can destroy your buffer at any time. The WebSocket protocol has mainly two message types: OpCode::Binary and OpCode::TEXT. Both are "binary" for a C++ programmer, but in the browser and in other JavaScript environments these different opCodes decide whether the message ends up an ArrayBuffer (or Blob) or String client side.

If you care, make sure to dig into the code to learn more.

# Chapter 3 - Some extras
## HttpSocket & HttpResponse
Since v0.13 the lib has had basic support for HTTP 1.1 serving. This support *works* but should not be relied on for more than very basic use cases. It does work however sending large amounts of data is not properly optimized. You'll have to figure out how to use it yourself.

Note: if v0.15 ever happens HTTP will be a major focus.

## Multithreading
todo