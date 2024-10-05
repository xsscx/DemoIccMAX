# Research

Hello and welcome to Hoyt's Fork of the DemoIccMAX project.

## Patches
- Patched the Compile Error:
	- IccUtil.cpp:2085:8: error: integer value 4294967295 is outside the valid range
- I corrected the return value of: 
    - `bool CIccTagXmlProfileSequenceId::ParseXml(xmlNode *pNode, std::string &parseStr)` 
      - to `return true;` 
        - assuming the function should indicate successful parsing when it completes the entire process without hitting the initial `return false`.
- I made other quick, defensive changes


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

Open an Issue if you have any questions.

## Fix for [CVE-2024-38427](https://nvd.nist.gov/vuln/detail/CVE-2024-38427)

Overview of changes for Incorrect Function Return Value in [`CIccTagXmlProfileSequenceId::ParseXml`](https://github.com/InternationalColorConsortium/DemoIccMAX/blob/c0ab97ddd1a0f792c8afb7a061135bc7c87f5854/IccXML/IccLibXML/IccTagXml.cpp#L4164)

### Call Graph for [`CIccTagXmlProfileSequenceId::ParseXml`](https://github.com/InternationalColorConsortium/DemoIccMAX/blob/c0ab97ddd1a0f792c8afb7a061135bc7c87f5854/IccXML/IccLibXML/IccTagXml.cpp#L4164)

When the return value was set to [`false`](https://github.com/InternationalColorConsortium/DemoIccMAX/blame/d4770471b38d24961e09740dda166e2f342ed787/IccXML/IccLibXML/IccTagXml.cpp#L4202) unconditionally, the [`ParseXml`](https://github.com/InternationalColorConsortium/DemoIccMAX/blob/c0ab97ddd1a0f792c8afb7a061135bc7c87f5854/IccXML/IccLibXML/IccTagXml.cpp#L4164) helper function did not complete its intended parsing process. As a result, the ICC profile was left in an incomplete or inconsistent state. When the caller proceed with the validation process, there were erroneous validation results or crashes due to incomplete or corrupt data when processing nodes.

<img src="https://xss.cx/2024/06/11/img/class_c_icc_tag_xml_profile_sequence_id_afbaaee340011d5bd09960d699d352e14_cgraph.png" alt="Call Graph for bool CIccTagXmlProfileSequenceId::ParseXml	(	xmlNode *	pNode, std::string &	parseStr )" style="height:348px; width:649px;"/> 

#### Understanding the Call Graph Nodes 

The nodes in the call graph represent function calls made within [CIccTagXmlProfileSequenceId::ParseXml](https://github.com/InternationalColorConsortium/DemoIccMAX/blob/c0ab97ddd1a0f792c8afb7a061135bc7c87f5854/IccXML/IccLibXML/IccTagXml.cpp#L4164).

Functions & Purposes:

- [`CIccUTF16String::c_str`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX%20CIccUTF16String&type=code) Retrieves a C-style string from a UTF-16 string.
- [`icGetSigVal`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+icGetSigVa&type=code): Extracts a signature value.
- [`icXmlAttrValue`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+icXmlAttrValue&type=code): Retrieves an attribute value from an XML node.
- [`icXmlFindAttr`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+icXmlFindAttr&type=code): Finds an attribute within an XML node.
- [`icXmlFindNode`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+icXmlFindNode&type=code): Finds a child node within an XML node.
- [`icXmlGetHexData`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+icXmlGetHexData&type=code): Converts hex data from a string to a binary format.
- [`CIccTagMultiLocalizedUnicode::SetText`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+CIccTagMultiLocalizedUnicode%3A%3ASetText&type=code): Sets a localized text value.
- [`CIccLocalizedUnicode::SetText`](https://github.com/search?q=repo%3AInternationalColorConsortium%2FDemoIccMAX+CIccLocalizedUnicode%3A%3ASetText&type=code): Sets text for a localized Unicode object.

### Call Graph for [`CIccTagXmlDict::ParseXml`](https://github.com/InternationalColorConsortium/DemoIccMAX/blob/c0ab97ddd1a0f792c8afb7a061135bc7c87f5854/IccXML/IccLibXML/IccTagXml.cpp#L4267)
When [`ParseXml`](https://github.com/InternationalColorConsortium/DemoIccMAX/blob/c0ab97ddd1a0f792c8afb7a061135bc7c87f5854/IccXML/IccLibXML/IccTagXml.cpp#L4164) returns [`true`](https://github.com/InternationalColorConsortium/DemoIccMAX/pull/66) correctly, the profile is fully parsed, and tags are processed. The Validate function can assess the profile, producing meaningful warnings and errors.

<img src="https://xss.cx/2024/06/11/img/class_c_icc_tag_xml_dict_a88c29060c9f89f8b6033dcb3a535d4d4_cgraph.png" alt="Call Graph for bool CIccTagXmlProfileSequenceId::ParseXml	(	xmlNode *	pNode, std::string &	parseStr )" style="height:644px; width:655px;"/> 

[DemoIccMAX Documentation](https://xss.cx/public/docs/DemoIccMAX/)

## Bug Samples

### Overflow Examples
```
DemoIccMAX-master/Build/Tools/IccFromXml/iccFromXml DemoIccMAX-master/Testing/CMYK-3DLUTs/CMYK-3DLUTs2.xml DemoIccMAX-master/Testing/CMYK-3DLUTs/CMYK-3DLUTs2.icc
DemoIccMAX-master/Build/Tools/IccFromXml/iccFromXml DemoIccMAX-master/Testing/ICS/Rec2100HlgFull-Part1.xml DemoIccMAX-master/Testing/ICS/Rec2100HlgFull-Part1.icc
DemoIccMAX-master/Build/Tools/IccFromXml/iccFromXml DemoIccMAX-master/Testing/ICS/Rec2100HlgFull-Part2.xml DemoIccMAX-master/Testing/ICS/Rec2100HlgFull-Part2.icc
DemoIccMAX-master/Build/Tools/IccFromXml/iccFromXml DemoIccMAX-master/Testing/Overprint/17ChanPart1.xml DemoIccMAX-master/Testing/Overprint/17ChanPart1.icc
```

### Runtime Errors
```
DemoIccMAX-master/Tools/CmdLine/IccApplyNamedCmm/iccApplyNamedCmm.cpp:297:101: runtime error: load of value 20, which is not a valid value for type 'icXformInterp'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior DemoIccMAX-master/Tools/CmdLine/IccApplyNamedCmm/iccApplyNamedCmm.cpp:297:101 in
/Users/xss/dmax/DemoIccMAX-master/IccProfLib/IccCmm.cpp:10079:48: runtime error: load of value 20, which is not a valid value for type 'icXformInterp'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior DemoIccMAX-master/IccProfLib/IccCmm.cpp:10079:48 in
/Users/xss/dmax/DemoIccMAX-master/IccProfLib/IccCmm.cpp:10188:66: runtime error: load of value 20, which is not a valid value for type 'icXformInterp'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior DemoIccMAX-master/IccProfLib/IccCmm.cpp:10188:66 in
/Users/xss/dmax/DemoIccMAX-master/IccProfLib/IccCmm.cpp:1272:75: runtime error: load of value 20, which is not a valid value for type 'icXformInterp'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior DemoIccMAX-master/IccProfLib/IccCmm.cpp:1272:75 in
/Users/xss/dmax/DemoIccMAX-master/IccProfLib/IccCmm.cpp:1413:15: runtime error: load of value 20, which is not a valid value for type 'icXformInterp'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior DemoIccMAX-master/IccProfLib/IccCmm.cpp:1413:15 in
Error 6 - Unable to begin profile application - Possibly invalid or incompatible profiles
```
#### Casting Errors
```
mcs % ../Build/Tools/IccApplyProfiles/iccApplyProfiles CMYKSS-Numbered-Overprint.tif prev.tif 1 0 0 0 1 ../SpecRef/RefIncW.icc 0

DemoIccMAX-master/IccProfLib/IccMpeCalc.cpp:4562:37: runtime error: downcast of address 0x604000001550 which does not point to an object of type 'CIccMpeCalculator'
0x604000001550: note: object is of type 'CIccMpeMatrix'
 00 00 00 00  50 67 93 05 01 00 00 00  00 00 00 00 1f 00 03 00  c0 03 00 00 30 61 00 00  f0 06 00 00
              ^~~~~~~~~~~~~~~~~~~~~~~
              vptr for 'CIccMpeMatrix'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior /Users/xss/dmax/DemoIccMAX-master/IccProfLib/IccMpeCalc.cpp:4562:37 in
Number of samples 6 in image[CMYKSS-Numbered-Overprint.tif] doesn't match device samples 31 in first profile
```
### Stack Buffer & Global Overflow Patches

Summary
------
There is a stack buffer overflow at the icFixXml function has been assigned [CVE-2023-46602](https://nvd.nist.gov/vuln/detail/CVE-2023-46602) and there is a global buffer overflow in the `CIccPRMG::GetChroma` function has been assigned [CVE-2023-46603](https://nvd.nist.gov/vuln/detail/CVE-2023-46603).

#### CVE-2023-44602 `icFixXml`
There is a stack buffer overflow at the `icFixXml` function, which is defined in `IccUtilXml.cpp` at line 330. The overflow occurs on a ***variable named 'fix'***, which is defined in `IccTagXml.cpp` at line 337.
```
Error Details:
Error Type: Stack buffer overflow.
File: IccUtilXml.cpp
Function: icFixXml
Line: 330
Variable Affected: 'fix' (defined in IccTagXml.cpp at line 337)
Memory Affected: Address 0x7ff7b129ad20
```
CVE-2023-44602 PoC
-----
```
 ./iccToXml ~/Documents/colorsync-0x10ef92785-0x10ef8f000-hoyt-03172023-baseline-poc-003333.icc new.xml

ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ff7b129ad20 at pc 0x00010f569ed9 bp 0x7ff7b129ab70 sp 0x7ff7b129ab68
WRITE of size 1 at 0x7ff7b129ad20 thread T0
    #0 0x10f569ed8 in icFixXml(char*, char const*) IccUtilXml.cpp:330
    #1 0x10f4ff381 in CIccTagXmlTextDescription::ToXml(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>) IccTagXml.cpp:353
    #2 0x10f4eb22a in CIccProfileXml::ToXmlWithBlanks(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>) IccProfileXml.cpp:264
    #3 0x10f4e632c in CIccProfileXml::ToXml(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccProfileXml.cpp:79
    #4 0x10ec6821f in main IccToXml.cpp:38
    #5 0x7ff80dee53a5 in start+0x795 (dyld:x86_64+0xfffffffffff5c3a5)

Address 0x7ff7b129ad20 is located in stack of thread T0 at offset 288 in frame
    #0 0x10f4fed5f in CIccTagXmlTextDescription::ToXml(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>) IccTagXml.cpp:336

  This frame has 7 object(s):
    [32, 288) 'fix' (line 337) <== Memory access at offset 288 overflows this variable
    [352, 608) 'buf' (line 338)
    [672, 928) 'data' (line 339)
    [992, 1016) 'datastr' (line 340)
    [1056, 1080) 'agg.tmp'
    [1120, 1144) 'ref.tmp' (line 351)
    [1184, 1208) 'ref.tmp45' (line 360)

SUMMARY: AddressSanitizer: stack-buffer-overflow IccUtilXml.cpp:330 in icFixXml(char*, char const*)

(lldb) fr se 5
frame #5: 0x00000001009697d9 libIccXML2.2.dylib`icFixXml(szDest="Copyright 2022 David Hoyt &quot;print hello world&quot; &lt;script&gt;alert(666)&lt;/script&gt;&quot;aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \xc9\xef\xbf\xf7\U0000007f", szStr="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaCopyright 2022 David Hoyt \"print hello world\" <script>alert(666)</script>\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"...) at IccUtilXml.cpp:330:16
   327 	      m_ptr += 4;
   328 	      break;
   329 	    default:
-> 330 	      *m_ptr++ = *szStr;
   331 	    }
   332 	    szStr++;
   333 	  }
```
The function doesn't seem to check if m_ptr has exceeded the bounds of the szDest buffer, leading to a buffer overflow when a particularly large szStr is passed to the function.
## Expected Output
```
./iccToXml ~/Documents/colorsync-0x10ef92785-0x10ef8f000-hoyt-03172023-baseline-poc-003333.icc new.xml
XML successfully created
```
## CIccPRMG::GetChroma function | CVE-2023-46603
There is a global buffer overflow, that can potentially be exploited to execute arbitrary code or lead to undefined behavior.
```
Error Details:
Error Type: Global buffer overflow.
File: IccPrmg.cpp
Function: CIccPRMG::GetChroma
Line: 163
Affected Variable: 'icPRMG_Chroma' defined in IccPrmg.cpp
Memory Affected: Address 0x000103847bf0
```

PoC
------
```
./iccRoundTrip ~/Documents/colorsync-0x10ef92785-0x10ef8f000-hoyt-03172023-baseline-poc-003333.icc

ERROR: AddressSanitizer: global-buffer-overflow on address 0x000103847bf0 at pc 0x00010365ce45 bp 0x7ff7bd5f1a80 sp 0x7ff7bd5f1a78
READ of size 4 at 0x000103847bf0 thread T0
    #0 0x10365ce44 in CIccPRMG::GetChroma(float, float) IccPrmg.cpp:163
    #1 0x10365cefd in CIccPRMG::InGamut(float, float, float) IccPrmg.cpp:170
    #2 0x10365d151 in CIccPRMG::InGamut(float*) IccPrmg.cpp:183
    #3 0x10365de40 in CIccPRMG::EvaluateProfile(CIccProfile*, icRenderingIntent, icXformInterp, bool) IccPrmg.cpp:240
    #4 0x10365ea4e in CIccPRMG::EvaluateProfile(char const*, icRenderingIntent, icXformInterp, bool) IccPrmg.cpp:288
    #5 0x102913176 in main iccRoundTrip.cpp:177
    #6 0x7ff80dee53a5 in start+0x795 (dyld:x86_64+0xfffffffffff5c3a5)

0x000103847bf0 is located 0 bytes after global variable 'icPRMG_Chroma' defined in '/Users/xss/Downloads/DemoIccMAX-master/IccProfLib/IccPrmg.cpp' (0x103847060) of size 2960
SUMMARY: AddressSanitizer: global-buffer-overflow IccPrmg.cpp:163 in CIccPRMG::GetChroma(float, float)

(lldb) fr se 5
frame #5: 0x0000000100d57e55 libIccProfLib2.2.dylib`CIccPRMG::GetChroma(this=0x00007ff7bfefeeb0, L=95.9999389, h=353.795837) at IccPrmg.cpp:163:73
   160 	  icFloatNumber dInvLFraction = (icFloatNumber)(1.0 - dLFraction);
   161
   162 	  icFloatNumber ch1 = icPRMG_Chroma[nHIndex][nLIndex]*dInvLFraction + icPRMG_Chroma[nHIndex][nLIndex+1]*dLFraction;
-> 163 	  icFloatNumber ch2 = icPRMG_Chroma[nHIndex+1][nLIndex]*dInvLFraction + icPRMG_Chroma[nHIndex+1][nLIndex+1]*dLFraction;
   164
   165 	  return (icFloatNumber)(ch1*(1.0-dHFraction) + ch2 * 1.0*dHFraction);
   166 	}
 ```

The code at IccPrmg.cpp:163 is trying to access the icPRMG_Chroma global buffer using indices [nHIndex+1][nLIndex] and [nHIndex+1][nLIndex+1]. One or both of these indices seem to be exceeding the buffer's dimensions, leading to the overflow.
## Expected Output
```
./iccRoundTrip ~/Documents/colorsync-0x10ef92785-0x10ef8f000-hoyt-03172023-baseline-poc-003333.icc

Profile:          '/Users/xss/Documents/colorsync-0x10ef92785-0x10ef8f000-hoyt-03172023-baseline-poc-003333.icc'
Rendering Intent: Relative Colorimetric
Specified Gamut:  Not Specified

Round Trip 1
------------
Min DeltaE:        0.00
Mean DeltaE:       1.46
Max DeltaE:        7.05

Max L, a, b:   32.481213, 7.808893, 7.558380

Round Trip 2
------------
Min DeltaE:        0.00
Mean DeltaE:       0.64
Max DeltaE:        2.81

Max L, a, b:   39.559242, 7.503039, -29.157310

PRMG Interoperability - Round Trip Results
------------------------------------------------------
DE <= 1.0 (   25388):  12.6%
DE <= 2.0 (   33627):  16.7%
DE <= 3.0 (   36466):  18.1%
DE <= 5.0 (   42342):  21.0%
DE <=10.0 (   58679):  29.1%
Total     (  201613)
```
## Build
```
cmake -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-g -fsanitize=address -fno-omit-frame-pointer -Wall -std=c++17" ../Build/Cmake
make
```

## Testing
### OS
```
ProductName:		macOS
ProductVersion:		14.0
BuildVersion:		23A344
```
### Platform
```
arm64e
X86_64 
```
### Data

Various inputs from [CVE-2022-26730](https://srd.cx/cve-2022-26730/)  and [CVE-2023-32443](https://srd.cx/cve-2023-32443/) were used  as PoC's

## Crash Reports
### icFixXml(char*, char const*) + 410
```
Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       KERN_INVALID_ADDRESS at 0x00007ff7b34d7000
Exception Codes:       0x0000000000000001, 0x00007ff7b34d7000

Termination Reason:    Namespace SIGNAL, Code 11 Segmentation fault: 11
Terminating Process:   exc handler [9557]

VM Region Info: 0x7ff7b34d7000 is not in any region.  Bytes after previous region: 1  Bytes before following region: 1519771648
      REGION TYPE                    START - END         [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      Stack                    7ff7b2cd7000-7ff7b34d7000 [ 8192K] rw-/rwx SM=SHM  thread 0
--->  GAP OF 0x5a95e000 BYTES
      unused __TEXT            7ff80de35000-7ff80de9d000 [  416K] r-x/r-x SM=COW  ...ed lib __TEXT

Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   iccToXml                      	       0x10cadb4fa icFixXml(char*, char const*) + 410
1   iccToXml                      	       0x10ca90027 CIccTagXmlTextDescription::ToXml(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>) + 1431
2   ???                           	0x6161616161616161 ???


Thread 0 crashed with X86 Thread State (64-bit):
  rax: 0x00007ff7b34d7000  rbx: 0x000000010d301bf0  rcx: 0x0000000000000061  rdx: 0x00007ff7b34d7001
  rdi: 0x00007ff7b34d6e62  rsi: 0x00007ff7b34d6e68  rbp: 0x00007ff7b34d4310  rsp: 0x00007ff7b34d42b0
   r8: 0x0000000000000006   r9: 0x0000000000000000  r10: 0x000000000000000d  r11: 0x00007ff6a68674fd
  r12: 0x00007ff7b34d6600  r13: 0x0000000000000000  r14: 0x000000010ca2b650  r15: 0x00007ff7b34d6780
  rip: 0x000000010cadb4fa  rfl: 0x0000000000010202  cr2: 0x00007ff7b34d7000
  
Logical CPU:     0
Error Code:      0x00000006 (no mapping for user data write)
Trap Number:     14

Thread 0 instruction stream:
  44 19 00 e8 42 52 17 00-48 8b 75 e8 48 81 c6 04  D...BR..H.u.H...
  00 00 00 48 89 75 e8 48-89 45 a8 e9 42 00 00 00  ...H.u.H.E..B...
  48 8b 7d e8 48 8d 35 ac-44 19 00 e8 1a 52 17 00  H.}.H.5.D....R..
  48 8b 75 e8 48 81 c6 04-00 00 00 48 89 75 e8 48  H.u.H......H.u.H
  89 45 a0 e9 1a 00 00 00-48 8b 45 f0 8a 08 48 8b  .E......H.E...H.
  45 e8 48 89 c2 48 81 c2-01 00 00 00 48 89 55 e8  E.H..H......H.U.
 [88]08 48 8b 45 f0 48 05-01 00 00 00 48 89 45 f0  ..H.E.H.....H.E.	<==
  e9 69 fe ff ff 48 8b 45-e8 c6 00 00 48 8b 45 f8  .i...H.E....H.E.
  48 83 c4 60 5d c3 55 48-89 e5 48 83 ec 20 48 89  H..`].UH..H.. H.
  7d f8 48 89 75 f0 89 55-ec 48 8b 7d f8 48 8b 75  }.H.u..U.H.}.H.u
  f0 48 63 55 ec e8 ac f0-ff ff 48 8b 7d f8 88 45  .HcU......H.}..E
  eb e8 76 33 17 00 48 83-c4 20 5d c3 66 2e 0f 1f  ..v3..H.. ].f...
```
### CIccPRMG::GetChroma(float, float) + 1093 (IccPrmg.cpp:163)
```
Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_CRASH (SIGABRT)
Exception Codes:       0x0000000000000000, 0x0000000000000000

Termination Reason:    Namespace SIGNAL, Code 6 Abort trap: 6
Terminating Process:   iccRoundTrip [12888]

Application Specific Information:
abort() called


Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	    0x7ff80e2357a6 __pthread_kill + 10
1   libsystem_pthread.dylib       	    0x7ff80e26df30 pthread_kill + 262
2   libsystem_c.dylib             	    0x7ff80e18ca4d abort + 126
3   libclang_rt.asan_osx_dynamic.dylib	       0x103b39516 __sanitizer::Abort() + 70
4   libclang_rt.asan_osx_dynamic.dylib	       0x103b38c74 __sanitizer::Die() + 196
5   libclang_rt.asan_osx_dynamic.dylib	       0x103b1cf2a __asan::ScopedInErrorReport::~ScopedInErrorReport() + 1178
6   libclang_rt.asan_osx_dynamic.dylib	       0x103b1c1dd __asan::ReportGenericError(unsigned long, unsigned long, unsigned long, unsigned long, bool, unsigned long, unsigned int, bool) + 1773
7   libclang_rt.asan_osx_dynamic.dylib	       0x103b1d448 __asan_report_load4 + 40
8   libIccProfLib2.2.1.15.dylib   	       0x10365ce45 CIccPRMG::GetChroma(float, float) + 1093 (IccPrmg.cpp:163)
9   libIccProfLib2.2.1.15.dylib   	       0x10365cefe CIccPRMG::InGamut(float, float, float) + 46 (IccPrmg.cpp:170)
10  libIccProfLib2.2.1.15.dylib   	       0x10365d152 CIccPRMG::InGamut(float*) + 498 (IccPrmg.cpp:183)
11  libIccProfLib2.2.1.15.dylib   	       0x10365de41 CIccPRMG::EvaluateProfile(CIccProfile*, icRenderingIntent, icXformInterp, bool) + 3169 (IccPrmg.cpp:240)
12  libIccProfLib2.2.1.15.dylib   	       0x10365ea4f CIccPRMG::EvaluateProfile(char const*, icRenderingIntent, icXformInterp, bool) + 111 (IccPrmg.cpp:288)
13  iccRoundTrip                  	       0x102913177 main + 1063 (iccRoundTrip.cpp:177)
14  dyld                          	    0x7ff80dee53a6 start + 1942


Thread 0 crashed with X86 Thread State (64-bit):
  rax: 0x0000000000000000  rbx: 0x0000000000000006  rcx: 0x00007ff7bd5f0ce8  rdx: 0x0000000000000000
  rdi: 0x0000000000000103  rsi: 0x0000000000000006  rbp: 0x00007ff7bd5f0d10  rsp: 0x00007ff7bd5f0ce8
   r8: 0x00001ffef7abe1a0   r9: 0x0000000000000000  r10: 0x0000000000000000  r11: 0x0000000000000246
  r12: 0x0000000000000103  r13: 0x2000000000000000  r14: 0x00007ff851846e80  r15: 0x0000000000000016
  rip: 0x00007ff80e2357a6  rfl: 0x0000000000000246  cr2: 0x0000000103ac44b0
  
Logical CPU:     0
Error Code:      0x02000148 
Trap Number:     133


Binary Images:
       0x1034bb000 -        0x103836fff libIccProfLib2.2.1.15.dylib (*) <f2dc6eae-a665-30af-bc63-7f6b8c876dad> /Users/USER/Downloads/*/libIccProfLib2.2.1.15.dylib
       0x103a37000 -        0x103b66fff libclang_rt.asan_osx_dynamic.dylib (*) <b5a35b2f-2e39-33dc-88c4-cd4db0ffc80b> /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/lib/darwin/libclang_rt.asan_osx_dynamic.dylib
       0x10290d000 -        0x102914fff iccRoundTrip (*) <a4db0180-b77f-39cc-bc80-71c3e8b6bbb3> /Users/USER/Downloads/*/iccRoundTrip
    0x7ff80e22d000 -     0x7ff80e267ff7 libsystem_kernel.dylib (*) <3690c1fc-599f-39ff-bbdb-85422e9a996c> /usr/lib/system/libsystem_kernel.dylib
    0x7ff80e268000 -     0x7ff80e273fff libsystem_pthread.dylib (*) <33c43114-85f0-3f32-86d7-8e6a2403d38c> /usr/lib/system/libsystem_pthread.dylib
    0x7ff80e10d000 -     0x7ff80e194fff libsystem_c.dylib (*) <3e9a5bfa-50c0-3a96-9291-4826c62d1182> /usr/lib/system/libsystem_c.dylib
    0x7ff80dedf000 -     0x7ff80df7b2ff dyld (*) <1289b60a-4980-342d-b1a4-250bbee392f1> /usr/lib/dyld
               0x0 - 0xffffffffffffffff ??? (*) <00000000-0000-0000-0000-000000000000> ???

```

### CIccCLUT::Interp2d Patch Summary | CVE-2023-48736
- Calculate indices for the interpolation
- Check if any index is out of bounds
- Handle the out-of-bounds situation
- Fill with zeros or another default value
- Bail Out Early
- Bumps the Minor Version to .17
- Fixes the C11 typo from PR 53

#### CIccCLUT::Interp2d Expected Output
```
 CalcTest %  ../iccApplyNamedCmm -debugcalc rgbExercise8bit.txt 0 1 calcExercizeOps.icc 1
...
End Calculator Apply

   0.9505    1.0000    1.0891 	;  255.0000  255.0000  255.0000
```
#### Patch Validation
~~~
Patches for IccTagLut.cpp in CIccCLUT::Interp2d and CIccCLUT::Interp3d functions were Fuzzed with a corpus of .icc color profiles based on CVE-2022-26730, CVE-2023-32443 and other Inputs.
~~~

### CIccCLUT::Interp3d Patch Summary | CVE-2023-46866

Description of Overflow in https://github.com/InternationalColorConsortium/DemoIccMAX/issues/54

#### CVE-2023-46866 PoC
```
REDACTED
```
This Patch seeks to avoid Overflows a la PR 53.
- Calculate indices for the interpolation
- Check if any index is out of bounds
- Handle the out-of-bounds situation
- Fill with zeros or another default value
- Bail Out Early

#### Patch Validation
~~~
Patches for IccTagLut.cpp in CIccCLUT::Interp2d and CIccCLUT::Interp3d functions were Fuzzed with a corpus of .icc color profiles based on CVE-2022-26730, CVE-2023-32443 and other Inputs.
~~~

## Bugs 3 - 6
Bug Report: Undefined Behavior in IccTagLut.cpp and IccProfileXml.cpp

Severity: Reference Implementation | High

The UndefinedBehaviorSanitizer tool has identified multiple instances of undefined behavior within the IccTagLut.cpp and IccProfileXml.cpp files.

### Bug 3 Description
File: IccTagLut.cpp
Line: 1798
Issue: Index -1 is being used to access an array of type icUInt32Number[16], which results in out-of-bounds access.

### Bug 4 Description

File: IccTagLut.cpp
Line: 1799
Issue: Index -1 is being used to access an array of type icUInt8Number[16], which results in out-of-bounds access.

### Bug 5 Description

File: IccProfileXml.cpp
Line: 128
Issue: Loading a value 2543294359 which is not a valid value for the type icPlatformSignature.

### Bug 6 Description

File: IccProfileXml.cpp
Line: 129
Issue: Loading a value 2543294359 which is not a valid value for the type icPlatformSignature.

## Bug 7 -  Heap Buffer Overflow in CIccXmlArrayType::ParseText | CVE-2023-47249
Severity: Reference Implementation | High 

### Description
A heap buffer overflow has been identified in the function CIccXmlArrayType::ParseText at IccUtilXml.cpp:1003:10. This function is designed to parse text into an array, with a specific instantiation for unsigned short. The buffer overflow occurs during the parsing process, specifically in a loop condition where a buffer bound check fails, leading to an out-of-bounds read.

Variables at Crash Time:
pBuf: A pointer to the buffer where parsed data is stored.
nSize: The size of the buffer (4096).
szText: A pointer to the text being parsed.
n: Counter variable, which is also 4096 at the time of the crash.
Crash Location in Code:

The crash occurs in the loop: while (*szText && n<nSize) {.
The error indicates that when n equals nSize, the loop still attempts to read *szText, which is beyond the allocated buffer.


### Steps to Reproduce
#### PoC
```
Testing % ./iccFromXML mcs/17ChanWithSpots-MVIS.xml mcs/17ChanWithSpots-MVIS.icc
```
#### Crash Details
```
mcs % ../iccFromXML 17ChanWithSpots-MVIS.xml 17ChanWithSpots-MVIS.icc
...
SUMMARY: AddressSanitizer: heap-buffer-overflow IccUtilXml.cpp:1003 in CIccXmlArrayType<unsigned short, (icTagTypeSignature)1969828150>::ParseText(unsigned short*, unsigned int, char const*)
```


## Bug 8 - Floating Point Error in iccSpecSepToTiff.cpp at line 120
Patch in PR https://github.com/InternationalColorConsortium/DemoIccMAX/pull/64
### Reproduction
```
./iccSpecSepToTiff out.tif 0 0 Overprint/17ChanData.txt 1 2 ~/Documents/2225-original.icc
```

#### Description

Arithmetic Error:

The crashing line (-> 0x100006251 <+1585>: idivl 0x230(%rbx)) suggests a division operation.
The corresponding source code line (120 n = (end-start)/step + 1;) is performing a division operation. If step is zero, this operation will cause a division by zero error, leading to an FPE.

### Bug 9 SUMMARY: AddressSanitizer: heap-buffer-overflow IccUtilXml.cpp:1062 in CIccXmlArrayType<float, (icTagTypeSignature)1717793824>::ParseText(float*, unsigned int, char const*) 
```
mcs % lldb -- ../../Build/Tools/IccFromXml/iccFromXML 18ChanWithSpots-MVIS.xml 18ChanWithSpots-MVIS.icc
(lldb) target create "../../Build/Tools/IccFromXml/iccFromXML"
Current executable set to 'DemoIccMAX-master/Build/Tools/IccFromXml/iccFromXML' (x86_64).
(lldb) settings set -- target.run-args  "18ChanWithSpots-MVIS.xml" "18ChanWithSpots-MVIS.icc"
(lldb) r
Process 79070 launched: 'DemoIccMAX-master/Build/Tools/IccFromXml/iccFromXML' (x86_64)
=================================================================
==79070==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x00010040340c at pc 0x000100990dc5 bp 0x7ff7bfefac70 sp 0x7ff7bfefac68
READ of size 1 at 0x00010040340c thread T0
    #0 0x100990dc4 in CIccXmlArrayType<float, (icTagTypeSignature)1717793824>::ParseText(float*, unsigned int, char const*) IccUtilXml.cpp:1062
    #1 0x100992462 in CIccXmlArrayType<float, (icTagTypeSignature)1717793824>::ParseTextArrayNum(char const*, unsigned int, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccUtilXml.cpp:818
    #2 0x10094e784 in icCLutFromXml(_xmlNode*, int, int, icConvertType, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccTagXml.cpp:3544
    #3 0x1008b46ff in CIccMpeXmlExtCLUT::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccMpeXml.cpp:1935
    #4 0x1008bf990 in CIccMpeXmlCalculator::ParseImport(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccMpeXml.cpp:2577
    #5 0x1008d170f in CIccMpeXmlCalculator::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccMpeXml.cpp:3094
    #6 0x10095561d in CIccTagXmlMultiProcessElement::ParseElement(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccTagXml.cpp:4081
    #7 0x1009567b9 in CIccTagXmlMultiProcessElement::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccTagXml.cpp:4141
    #8 0x10090b119 in CIccProfileXml::ParseTag(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccProfileXml.cpp:711
    #9 0x10090c924 in CIccProfileXml::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccProfileXml.cpp:820
    #10 0x10090cd5b in CIccProfileXml::LoadXml(char const*, char const*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>*) IccProfileXml.cpp:877
    #11 0x10000406c in main IccFromXml.cpp:68
    #12 0x7ff816e9f365 in start+0x795 (dyld:x86_64+0xfffffffffff5c365)

0x00010040340c is located 0 bytes after 2259980-byte region [0x0001001db800,0x00010040340c)
allocated by thread T0 here:
    #0 0x101743a20 in wrap_malloc+0xa0 (libclang_rt.asan_osx_dynamic.dylib:x86_64h+0xdca20)
    #1 0x10094d4f1 in icCLutFromXml(_xmlNode*, int, int, icConvertType, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccTagXml.cpp:3439
    #2 0x1008b46ff in CIccMpeXmlExtCLUT::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccMpeXml.cpp:1935
    #3 0x1008bf990 in CIccMpeXmlCalculator::ParseImport(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccMpeXml.cpp:2577
    #4 0x1008d170f in CIccMpeXmlCalculator::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccMpeXml.cpp:3094
    #5 0x10095561d in CIccTagXmlMultiProcessElement::ParseElement(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccTagXml.cpp:4081
    #6 0x1009567b9 in CIccTagXmlMultiProcessElement::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccTagXml.cpp:4141
    #7 0x10090b119 in CIccProfileXml::ParseTag(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccProfileXml.cpp:711
    #8 0x10090c924 in CIccProfileXml::ParseXml(_xmlNode*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>&) IccProfileXml.cpp:820
    #9 0x10090cd5b in CIccProfileXml::LoadXml(char const*, char const*, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>*) IccProfileXml.cpp:877
    #10 0x10000406c in main IccFromXml.cpp:68
    #11 0x7ff816e9f365 in start+0x795 (dyld:x86_64+0xfffffffffff5c365)

SUMMARY: AddressSanitizer: heap-buffer-overflow IccUtilXml.cpp:1062 in CIccXmlArrayType<float, (icTagTypeSignature)1717793824>::ParseText(float*, unsigned int, char const*)
Shadow bytes around the buggy address:
  0x000100403180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x000100403200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x000100403280: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x000100403300: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x000100403380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x000100403400: 00[04]fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x000100403480: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x000100403500: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x000100403580: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x000100403600: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x000100403680: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==79070==ABORTING
```

## Clang Static Analyzer Report
#### Logic Error	| Count
- Assigned value is garbage or undefined	2	
- Called C++ object pointer is null	3	
- Dereference of null pointer	13	
- Garbage return value	1	
- Result of operation is garbage or undefined	4	
- Uninitialized argument value	6	
- Unix API	4	

#### Memory error	
- Bad deallocator	7	
- Double free	2	
- Memory leak	10	
- Use-after-free	8	

#### Unix API	
- Allocator sizeof operand mismatch	1	

#### Unused code	
- Dead assignment	28	
- Dead increment	3	
- Dead initialization	20	
- Dead nested assignment	1

### IccEval.cpp at Line 139 - 172
```
    //  * Modified by @h02332 | David Hoyt
    // determine granularity
    if (!nGran) {
      CIccTag* tag = pProfile->FindTag(icSigAToB0Tag + (nIntent == icAbsoluteColorimetric ? icRelativeColorimetric : nIntent));

      if (!tag) {
          std::cerr << "Tag is nullptr!" << std::endl;
          return icCmmStatColorNotFound;
      }
      
      try {
          if (dynamic_cast<CIccTagLut16*>(tag) != nullptr) {
              std::cerr << "Unexpected object type detected!" << std::endl;
              // If there's a method to get more details about the tag, use it. If not, skip this line.
              // std::cerr << "Tag details: " << tag->GetDetails() << std::endl;
              std::cerr << "Actual object type: " << typeid(*tag).name() << std::endl;
          } else {
              std::cerr << "Tag is not of expected type!" << std::endl;
              std::cerr << "Actual object type: " << typeid(*tag).name() << std::endl;
          }
      } catch (const std::bad_typeid& e) {
          std::cerr << "Caught bad_typeid exception: " << e.what() << std::endl;
          return icCmmStatBadLutType;
      }

      CIccTagLutAtoB* pTag = dynamic_cast<CIccTagLutAtoB*>(tag);

      // Check if pTag is valid. If it's not, we set nGran to default value and skip further checks.
      if (!pTag || ndim == 3) {
          nGran = 33;
      } else {
          CIccCLUT* pClut = pTag->GetCLUT();
          nGran = pClut ? (pClut->GridPoints() + 2) : 33;
      }
    }
```
### IccTagLut.cpp at Line 2523 - 2666
```
/**
 ******************************************************************************
 * Name: CIccCLUT::Interp3d
 * 
 * Purpose: Three dimensional interpolation function
 *
 * Args:
 *  Pixel = Pixel value to be found in the CLUT. Also used to store the result.
 * Modified by @h02332 | David Hoyt
 *******************************************************************************
 */
void CIccCLUT::Interp3d(icFloatNumber *destPixel, const icFloatNumber *srcPixel) const
{
    icUInt8Number mx = m_MaxGridPoint[0];
    icUInt8Number my = m_MaxGridPoint[1];
    icUInt8Number mz = m_MaxGridPoint[2];

    icFloatNumber x = UnitClip(srcPixel[0]) * mx;
    icFloatNumber y = UnitClip(srcPixel[1]) * my;
    icFloatNumber z = UnitClip(srcPixel[2]) * mz;

    icUInt32Number ix = (icUInt32Number)x;
    icUInt32Number iy = (icUInt32Number)y;
    icUInt32Number iz = (icUInt32Number)z;

    icFloatNumber u = x - ix;
    icFloatNumber t = y - iy;
    icFloatNumber s = z - iz;

    if (ix == mx) {
        ix--;
        u = 1.0;
    }
    if (iy == my) {
        iy--;
        t = 1.0;
    }
    if (iz == mz) {
        iz--;
        s = 1.0;
    }

    icFloatNumber ns = (icFloatNumber)(1.0 - s);
    icFloatNumber nt = (icFloatNumber)(1.0 - t);
    icFloatNumber nu = (icFloatNumber)(1.0 - u);

    icUInt32Number maxIndex = (mx + 1) * (my + 1) * (mz + 1) * m_nOutput - 1;

    icFloatNumber dF0 = ns * nt * nu;
    icFloatNumber dF1 = ns * nt * u;
    icFloatNumber dF2 = ns * t * nu;
    icFloatNumber dF3 = ns * t * u;
    icFloatNumber dF4 = s * nt * nu;
    icFloatNumber dF5 = s * nt * u;
    icFloatNumber dF6 = s * t * nu;
    icFloatNumber dF7 = s * t * u;

     icFloatNumber *pStart = &m_pData[ix * n001 + iy * n010 + iz * n100];

     for (int i = 0; i < m_nOutput; i++) {
         icFloatNumber *p = pStart + i;

         // Logging statements before the problematic line:
              std::cout << "Pointer p: " << p << std::endl;
              std::cout << "n000: " << n000 << ", Value: " << p[n000] << std::endl;
              std::cout << "n001: " << n001 << ", Value: " << p[n001] << std::endl;
              std::cout << "n010: " << n010 << ", Value: " << p[n010] << std::endl;
              std::cout << "n011: " << n011 << ", Value: " << p[n011] << std::endl;
              std::cout << "n100: " << n100 << ", Value: " << p[n100] << std::endl;
              std::cout << "n101: " << n101 << ", Value: " << p[n101] << std::endl;
              std::cout << "n110: " << n110 << ", Value: " << p[n110] << std::endl;
              std::cout << "n111: " << n111 << ", Value: " << p[n111] << std::endl;
         
          // ... Similarly for other indices ...
         
         // Log the maximum possible index and the current index
         std::cout << "Max Index: " << maxIndex << ", Current Index: " << (p + n111 - m_pData) << std::endl;

         if (p + n111 > m_pData + maxIndex) {
             std::cerr << "Potential overflow detected. Aborting." << std::endl;
             return;
         }

         // Try to safely access the value at p[n000]
         if (p + n000 > m_pData + maxIndex) {
             std::cerr << "Potential overflow detected. Aborting." << std::endl;
             return;
         } else {
             std::cout << "Value at (p + n000): " << p[n000] << std::endl;
         }

         if ((p + n001) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n001." << std::endl;
         }

         if ((p + n010) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n010." << std::endl;
         }

         if ((p + n011) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n011." << std::endl;
         }
         
         if ((p + n100) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n100." << std::endl;
         }
        
         if ((p + n101) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n101." << std::endl;
         }
         
         if ((p + n110) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n110." << std::endl;
         }
         
         if ((p + n111) >= (m_pData + maxIndex)) {
             std::cerr << "Out-of-bounds access detected for n111." << std::endl;
         }
         // Add logging statements before the problematic line:
          std::cout << "n000: " << n000 << std::endl;
          std::cout << "n001: " << n001 << std::endl;
          std::cout << "n010: " << n010 << std::endl;
          std::cout << "n011: " << n011 << std::endl;
          std::cout << "n100: " << n100 << std::endl;
          std::cout << "n101: " << n101 << std::endl;
          std::cout << "n110: " << n110 << std::endl;
          std::cout << "n111: " << n111 << std::endl;
         std::cout << "ix: " << ix << std::endl;
             std::cout << "iy: " << iy << std::endl;
             std::cout << "iz: " << iz << std::endl;
             std::cout << "n001: " << n001 << std::endl;
             std::cout << "n010: " << n010 << std::endl;
             std::cout << "n100: " << n100 << std::endl;
             std::cout << "pStart address: " << pStart << std::endl;
         
         // Before the problematic line
         std::cout << "Pointer p: " << p << std::endl;
         std::cout << "n000: " << n000 << std::endl;
         std::cout << "Address (p + n000): " << p + n000 << std::endl;

         
         destPixel[i] = p[n000] * dF0 + p[n001] * dF1 + p[n010] * dF2 + p[n011] * dF3 +
                        p[n100] * dF4 + p[n101] * dF5 + p[n110] * dF6 + p[n111] * dF7;
     }
 }
```
## IccUtilXml.cpp at Line 421 - 491
```
//  * Modified by @h02332 | David Hoyt
class CIccDumpXmlCLUT : public IIccCLUTExec
{
public:
  CIccDumpXmlCLUT(std::string *xml, icConvertType nType, std::string blanks, icUInt16Number nSamples, icUInt8Number nPixelsPerRow)
  {
    m_xml = xml;
    m_nType = nType;
    m_blanks = blanks;
    m_nSamples = nSamples;
    m_nPixelsPerRow = nPixelsPerRow;
    m_nCurPixel = 0;
  }

    virtual void PixelOp(icFloatNumber* pGridAdr, icFloatNumber* pData)
    {
        if (!pData) {
            std::cerr << "Error: pData is nullptr." << std::endl;
            return;  // Early return if pData is null
        }

        int i;
        char buf[128];

        if (!(m_nCurPixel % m_nPixelsPerRow))
            *m_xml += m_blanks;

        switch(m_nType) {
            case icConvert8Bit:
                for (i=0; i<m_nSamples; i++) {
                    if (&pData[i] == nullptr) {  // Check if accessing pData[i] is valid
                        std::cerr << "Error: pData[i] is out of bounds." << std::endl;
                        return;
                    }
                    sprintf(buf, " %3d", (icUInt8Number)(pData[i]*255.0 + 0.5));
                    *m_xml += buf;
                }
                break;
            case icConvert16Bit:
                for (i=0; i<m_nSamples; i++) {
                    sprintf(buf, " %5d", (icUInt16Number)(pData[i]*65535.0 + 0.5));
                    *m_xml += buf;
                }
                break;
            case icConvertFloat:
            default:
                for (i=0; i<m_nSamples; i++) {
                    sprintf(buf, " %13.8f", pData[i]);
                    *m_xml += buf;
                }
                break;
        }
        m_nCurPixel++;
        if (!(m_nCurPixel % m_nPixelsPerRow)) {
            *m_xml += "\n";
        }
    }

    void Finish()
    {
        if (m_nCurPixel % m_nPixelsPerRow) {
            *m_xml += "\n";
        }
    }

    std::string *m_xml;
    icConvertType m_nType;
    std::string m_blanks;
    icUInt16Number m_nSamples;
    icUInt8Number m_nPixelsPerRow;
    icUInt32Number m_nCurPixel;
};
```
## DORKs for IccXmlLib or IccProfLib
```
intext:"libiccxml" OR intext:"iccproflib" "International Color Consortium" filetype:pdf OR filetype:txt OR filetype:md OR filetype:xml OR filetype:txt OR filetype:cpp
"Libiccxml" OR "iccproflib"
"iccxmllib" OR "iccproflib"
```

## Knowledgebase
https://bugs.chromium.org/p/project-zero/issues/detail?id=2225
https://bugs.chromium.org/p/project-zero/issues/detail?id=2226
https://srd.cx/cve-2022-26730/
https://srd.cx/cve-2023-32443/
Clang Static Analyzer Report [https://xss.cx/2023/10/29/src/demomax-clang-static-analysis/](https://xss.cx/2023/10/29/src/demomax-clang-static-analysis/)


