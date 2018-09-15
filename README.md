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

See the [API.md](API.md) file, there is a description of data collected by SystemMonitor and how to use it.

Note that you need to disable Application Sandboxing in the Xcode project.

Furthermore in the test file [SystemMonitorTests.swift](SystemMonitorTests/SystemMonitorTests.swift) is a function call **testNiceDisplay** that display the following output, you can use it to inspirate yourself.

```
System Infos:
	Hostname: MacBookPro
	Kernel: Darwin
	Kernel Version: 18.0.0
	Boottime: 2018-08-10 22:14:25 +0000
Processor/CPU Infos:
	CPU Usage:	 User	 System	 Idle	 Nice
		CPU0:	 18.8%	 15.4%	 65.8%	 0.0%	 (1135580, 934299, 3986371, 0)
		CPU1:	 2.0%	 1.8%	 96.2%	 0.0%	 (118735, 109779, 5827165, 0)
		CPU2:	 16.4%	 10.8%	 72.8%	 0.0%	 (990105, 656607, 4408970, 0)
		CPU3:	 2.0%	 1.6%	 96.4%	 0.0%	 (121302, 97873, 5836502, 0)
		CPU4:	 14.4%	 8.8%	 76.8%	 0.0%	 (871645, 534731, 4649304, 0)
		CPU5:	 2.1%	 1.5%	 96.4%	 0.0%	 (124725, 90699, 5840253, 0)
		CPU6:	 12.1%	 7.1%	 80.8%	 0.0%	 (733247, 427107, 4895326, 0)
		CPU7:	 2.1%	 1.4%	 96.5%	 0.0%	 (129104, 83747, 5842824, 0)
		Total:	 8.7%	 6.1%	 85.2%	 0.0%	 (4224443, 2934842, 41286715, 0)
Memory Infos:
	RAM Usage:
		Active:      5.07 GB ( 1329325 pages )
		Wired:       2.87 GB ( 751900 pages )
		Application: 5.59 GB ( 1464431 pages )
		Compressed:  2.81 GB ( 737906 pages )
		Availablbe:  5.24 GB ( 1374820 pages )
	Swap Usage:
		Total: 1.0 GB ( 1073741824 bytes )
		Used:  0.03 GB ( 33554432 bytes )
		Free:  0.97 GB ( 1040187392 bytes )
Disks/Volumes Infos:
	Volumes Infos:
		/dev/disk2s2 [hfs] /Volumes/Sauvegarde 	 58.07GB available on 372.53GB (58.07GB free)
		/dev/disk1s1 [apfs] / 	 21.4GB available on 233.47GB (28.05GB free)
		/dev/disk2s3 [exfat] /Volumes/Données 	 187.68GB available on 558.52GB (187.68GB free)
	Disks Infos:
		disk0 	 233.76GB (read: 35.04GB, writen: 41.76GB)
		disk2 	 931.51GB (read: 1.65GB, writen: 5.25GB)
Network Infos:
	Interface lo0 (send: 1444864, received: 1444864)
		[ipv4]	127.0.0.1	255.0.0.0	127.0.0.1
		[ipv6]	::1	ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff	::1
		[ipv6]	fe80::1%lo0	ffff:ffff:ffff:ffff::	
	Interface gif0 (send: 0, received: 0)
	Interface stf0 (send: 0, received: 0)
	Interface XHC1 (send: 0, received: 0)
	Interface XHC20 (send: 0, received: 0)
	Interface XHC0 (send: 0, received: 0)
	Interface en0 (send: 726126592, received: 637428736)
		[ether]	78:4f:43:7d:f9:fb		
	Interface p2p0 (send: 0, received: 0)
	Interface awdl0 (send: 1024, received: 0)
	Interface en3 (send: 0, received: 0)
		[ether]	62:00:f1:70:6b:01		
	Interface en1 (send: 0, received: 0)
		[ether]	62:00:f1:70:6b:00		
	Interface en4 (send: 0, received: 0)
		[ether]	62:00:f1:70:6b:05		
	Interface en2 (send: 0, received: 0)
		[ether]	62:00:f1:70:6b:04		
	Interface bridge0 (send: 0, received: 0)
	Interface utun0 (send: 0, received: 0)
		[ipv6]	fe80::70a3:5717:dc05:d917%utun0	ffff:ffff:ffff:ffff::	
	Interface utun1 (send: 0, received: 0)
		[ipv6]	fe80::957:2672:7b62:49c5%utun1	ffff:ffff:ffff:ffff::	
	Interface en5 (send: 57344, received: 397312)
		[ether]	ac:de:48:00:11:22		
		[ipv6]	fe80::aede:48ff:fe00:1122%en5	ffff:ffff:ffff:ffff::	
	Interface en8 (send: 445117440, received: 1055318016)
		[ether]	9c:eb:e8:48:f9:d3		
		[ipv6]	fe80::1884:5522:fed2:35d8%en8	ffff:ffff:ffff:ffff::	
		[ipv4]	129.12.131.172	255.255.252.0	129.12.131.255
Graphics/GPU Infos:
	AMD Radeon Pro 450 [OFF]
	Intel HD Graphics 530 [ON]
		18% core (@0MHz), 0MB free VRAM of 1536MB (@0MHz), 0°C
Battery Infos:
	Serial number: D867046B0QFHDWCAA
	Manufacture date: 2017-01-29 00:00:00 +0000
	Cycle count: 251
	Design capacity: 6669
	Maximum capacity: 6359 (95.35% of design capacity)
	Current capacity: 6293 (98.96% of maximum capacity)
	Usage: 13014mV 598mA 7.78W
	Charging: true @ 28.67W (fully charged: true)
	Time remaining: 0 hours 8 minutes
Sensors Infos:
	Fans:
		2228.0 RPM (min: 2000.0, max: 5489.0)
		2408.0 RPM (min: 2160.0, max: 5927.0)
	Temperatures:
		TA0V: 26.3°C
		TM0P: 55.6°C
		TTRD: 53.1°C
		TG0D: 35.0°C
		TBXT: 37.4°C
		TGVP: 48.8°C
		TPCD: 44.0°C
		TH0c: 46.3°C
		TC0E: 69.1°C
		TB2T: 37.4°C
		TaRC: 48.7°C
		TG0F: 35.0°C
		TTLD: 48.8°C
		Th2H: 56.5°C
		TC0P: 48.4°C
		TH0C: 46.3°C
		TH0a: 46.9°C
		TC2C: 68.0°C
		Ts0P: 33.9°C
		TC3C: 69.0°C
		TG0P: 55.2°C
		TB1T: 35.1°C
		TCTD: 0.3°C
		TaLC: 38.4°C
		TCGC: 64.0°C
		Ts1P: 30.7°C
		TC4C: 67.0°C
		TGDD: 59.0°C
		TCXC: 68.8°C
		TCSA: 66.0°C
		TH0B: 44.5°C
		Th1H: 58.9°C
		TC0F: 70.4°C
		Ts2S: 43.4°C
		Ts0S: 40.7°C
		TH0b: 44.5°C
		TB0T: 37.4°C
		TW0P: 54.3°C
		Ts1S: 42.9°C
		TH0A: 46.9°C
		TC1C: 67.0°C
	Voltage:
		VCSC: 0.91V
		VD0R: 19.84V
		VCAC: 0.97V
		VP0R: 13.0V
		VCTC: 0.61V
	Amperages:
		ID0R: 2.3A
		IPBR: 0.12A
		IC0R: 1.79A
		IG0R: 0.01A
		IBSC: 0.02A
	Wattages:
		PZ2E: 13.0W
		PZ2F: 0.12W
		PHPC: 23.32W
		PPBR: 1.62W
		PDTR: 45.62W
		PC0R: 23.24W
		PG0R: 0.08W
		PZ1E: 45.0W
		PZ1G: 0.08W
		PZ3G: 0.02W
		PZ0E: 70.0W
		PZ2G: 0.12W
		PZ1F: 0.08W
		PZ3F: 0.02W
		PZ3E: 135.49W
		PZ0G: 23.32W
		PZ0F: 21.99W
```

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