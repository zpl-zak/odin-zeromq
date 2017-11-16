# odin-zeromq

Odin bindings for ZeroMQ distributed messaging library.

They are based on ZeroMQ **4.2.3** version.

## Dependencies

* ZeroMQ static library [link](http://zeromq.org/)

## Build instructions (VS 2017)
1. Open project and retarget to demanded SDK version.
2. Add `ws2_32.lib;Iphlpapi.lib;Advapi32.lib;Crypt32.lib;` to your additional libraries to link against for libzmq project.
3. Done!

## License

This content is dual-licensed to either the public domain or under the following: `you are granted a perpetual, irrevocable license to copy, modify,
    publish, and distribute this content as you see fit. NO WARRANTY IS IMPLIED, USE AT YOUR OWN RISK!`
