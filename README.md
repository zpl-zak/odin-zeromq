# odin-zeromq

Odin bindings for ZeroMQ distributed messaging library.

They are based on ZeroMQ **4.2.3** version.

**NOTE:** This repo is out-of-date and requires updating to the latest Odin's version. However, due to my time constraint, I am not able to perform such an action. If you're willing to update it, I'd be happy to assist and accept any changes.

## Dependencies

* ZeroMQ static library [link](http://zeromq.org/)

## Tested platforms
* Windows using Microsoft Visual Studio 2017 64-bit.
* GNU/Linux Ubuntu 16.04.3 LTS.


## Build instructions (VS 2017)
1. Open project and retarget to demanded SDK version.
2. Add `ws2_32.lib;Iphlpapi.lib;Advapi32.lib;Crypt32.lib;` to your additional libraries to link against for libzmq project.
3. Done!

## Build instructions (GNU/Linux)
```sh
./autogen.sh
./configure    
make -j 4
make check 
sudo make install && ldconfig
```
You will need `build-essentials`, `libtool`, `autoconf`, `automake` and `uuid-dev` or equivalent.


## License

Apache License 2.0
