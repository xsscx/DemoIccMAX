Hello and welcome to Hoyt's Fork of the DemoIccMAX project.

### My Code
| Build OS & Device Info           | Build   |  Install  | IDE | CLI |
| -------------------------------- | ------------- | ------------- | ------------- | ------------- |
| macOS 14.5 X86_64       | ✅          | ✅          |     ✅          |   ✅          |
| macOS 14.5 arm  | ✅          | ✅          | ✅  | ✅          |
| Ubuntu       | ✅          | ✅          |    ✅     | ✅          |
| Windows 11  | ✅          | ✅          | ✅   | ✅          |
  
## Build 
Commit [ed4ee6](https://github.com/InternationalColorConsortium/DemoIccMAX/tree/f891074a0f1c9d61a3dfa53749265f8c14ed4ee6).

### Reproduction
```
cd /tmp
wget https://github.com/InternationalColorConsortium/DemoIccMAX/archive/f891074a0f1c9d61a3dfa53749265f8c14ed4ee6.zip
unzip f891074a0f1c9d61a3dfa53749265f8c14ed4ee6.zip
cd DemoIccMAX-f891074a0f1c9d61a3dfa53749265f8c14ed4ee6/Build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-g -fsanitize=address,undefined -fno-omit-frame-pointer -Wall" -Wno-dev  Cmake
make -j$(nproc) 2>&1 | grep 'error:'
```

### Build Log
```
-- The C compiler identification is AppleClang 15.0.0.15000309
-- The CXX compiler identification is AppleClang 15.0.0.15000309
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring build for X86_64 architecture.
-- Info build "Debug"
-- Found LibXml2: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.4.sdk/usr/lib/libxml2.tbd (found version "2.9.4")
-- Found TIFF: /usr/local/lib/libtiff.dylib (found version "4.6.0")
Configured RefIccMAX-Darwin64-2.1.17.hoyt
-- Configuring done (1.4s)
-- Generating done (0.1s)
-- Build files have been written to: DemoIccMAX-master/Build
make -j
...
[ 50%] Built target IccProfLib2
[ 66%] Built target IccProfLib2-static
[ 67%] Built target iccDumpProfile
[ 70%] Built target iccApplyProfiles
[ 73%] Built target iccSpecSepToTiff
[ 76%] Built target iccApplyNamedCmm
[ 78%] Built target iccRoundTrip
[ 81%] Built target iccTiffDump
[ 88%] Built target IccXML2
[ 95%] Built target IccXML2-static
[100%] Built target iccFromXml
[100%] Built target iccToXml
```
### Xcode + Visual Studio
  - Build
  - Run

### Docs
https://xss.cx/public/docs/DemoIccMAX/
