# SystemMonitor
Swift Library for macOS to monitor your system https://github.com/jacqueslorentz/SystemMonitor

## Requirements

- Xcode 10.0 or higher (usage of Swift 4)
- macOS 10.9 or higher (usage of Swift)
  - Tested on macOS 10.14 beta 5 (on a MacBookPro13,3)

## Installation

You can build the project with Xcode and add the compiled framework to your project.

### Carthage

You can install the framework with [Carthage](https://github.com/Carthage/Carthage) ([here](https://github.com/Carthage/Carthage#installing-carthage) for installation).

To integrate the framework into your Xcode project using Carthage, specify it in your Cartfile:

```
github "jacqueslorentz/SystemMonitor"
```

And build the SystemMonitor.framework:

```
carthage update
```

Do not forget to add the framework to your macOS project ([see Carthage documentation](https://github.com/Carthage/Carthage#if-youre-building-for-os-x)).

## Usage

[WORK IN PROGRESS]

## Tests

Open the project in Xcode and run tests.

You can also use the Makefile to run tests with:

```makefile
make test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

Special thanks to https://github.com/beltex/ for his work which inspired me a lot ! 

Thanks to these projects:

- https://github.com/beltex/SystemKit
- https://github.com/beltex/SMCKit
- https://github.com/hholtmann/smcFanControl/tree/master/smc-command
- https://github.com/theopolis/smc-fuzzer
- https://github.com/xythobuz/JSystemInfoKit

Apple useful open-source code:

- https://opensource.apple.com/source/PowerManagement/PowerManagement-703.30.3/
- https://opensource.apple.com/source/top/top-111.20.1/
- https://github.com/apple/darwin-xnu/tree/master/iokit/IOKit
- https://opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/sys/sysctl.h.auto.html 
- https://opensource.apple.com/source/xnu/xnu-4570.1.46/osfmk/mach/vm_statistics.h.auto.html 

Useful topics:

- https://stackoverflow.com/questions/44744372/get-cpu-usage-ios-swift
- https://apple.stackexchange.com/questions/16102/how-to-retrieve-current-wattage-info-on-os-x
- https://www.exploit-db.com/exploits/40952/
- https://stackoverflow.com/questions/3887309/mapping-iokit-ioreturn-error-code-to-string
- https://stackoverflow.com/questions/10110658/programmatically-get-gpu-percent-usage-in-os-x
- https://stackoverflow.com/questions/18077639/getting-graphic-card-information-in-objective-c

Other resources:

- http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/host_statistics.html 
- http://man7.org/linux/man-pages/man3/getifaddrs.3.html 
- `/usr/include/net/if.h` and `/usr/include/sys/socket.h`  from macOS 10.14 beta 5