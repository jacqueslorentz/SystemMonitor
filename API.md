# SystemMonitor API

After the installation, to use the SystemMonitor framework, you must import it first in your code with:

```swift
import SystemMonitor
```

Then you can call function to get informations from your system (see below for structures description):

```swift
// To initialize the monitor instance
let monitor = try SystemMonitorInstance()

// Returns SystemInfos struct with all informations
let infos = try monitor.getInfos() 



// Returns SystemSpecificInfos struct with system specific informations
let systemInfos = try monitor.getSystemInfos()

// Returns CPUInfos struct with processor specific informations
let cpuInfos = try monitor.getProcessorInfos()

// Returns MemoryUsage struct with memory specific informations
let memoryInfos = try monitor.getMemoryInfos()

// Returns VolumesDisksInfos struct with volumes and disks specific informations
let disksVolumesInfos = try monitor.getDiskInfos()

// Returns NetworkInterfaceInfos struct array with network interfaces specific informations
let networkInfos = try monitor.getNetworkInfos()

// Returns GPUInfos struct array with graphics specific informations
let gpuInfos = try monitor.getGPUInfos()

// Returns BatteryInfos struct with power and bbattery specific informations
let batteryInfos = try monitor.getBatteryInfos()

// Returns SensorsInfos struct with sensors specific informations
let sensorsInfos = try monitor.getSensorsInfos()
```

## Informations structures description

#### General

```swift
// Structure with contains all informations
public struct SystemInfos {
    let memory: MemoryUsage
    let processor: CPUInfos
    let disk: VolumesDisksInfos
    let network: [NetworkInterfaceInfos]
    let graphics: [GPUInfos]
    let system: SystemSpecificInfos
    let battery: BatteryInfos
    let sensors: SensorsInfos
}
```

#### System

```swift
// System specifics informations
public struct SystemSpecificInfos {
    let boottime: Int
    let hostname: String
    let kernel: String
    let kernelVersion: String
}
```

#### Processor

```swift
// All processor informations
public struct CPUInfos {
    let usage: CPUUsage
}
// Processor usage
public struct CPUUsage {
    let cores: [CPUCoreUsage]
    let total: CPUCoreUsage
    
    func toPercent(unixLike: Bool) -> CPUUsagePercent
}
// Processor usage in percents
public struct CPUUsagePercent {
    let cores: [CPUCoreUsagePercent]
    let total: CPUCoreUsagePercent
}
// Single CPU core usage
public struct CPUCoreUsage {
    let user: UInt32
    let system: UInt32
    let idle: UInt32
    let nice: UInt32
    
    func toPercent() -> CPUCoreUsagePercent
}
// Single CPU core usage in percents
public struct CPUCoreUsagePercent {
    let user: Float
    let system: Float
    let idle: Float
    let nice: Float
}
```

#### Memory

```swift
// RAM and swap informations
public struct MemoryUsage {
    let swapUsage: SwapUsage
    let ramUsage: RAMUsage
}
// Swap usage in bytes
public struct SwapUsage {
    let total: UInt64
    let used: UInt64
    let free: UInt64
    
    func convertTo(unit: String) throws -> ConvertedSwapUsage
}
// RAM usage in memory pages (4096 bytes)
public struct RAMUsage {
    let wired: UInt
    let active: UInt
    let appMemory: UInt
    let compressed: UInt
    let available: UInt
    
    func convertTo(unit: String) throws -> ConvertedRAMUsage
}
// Swap usage in human a readable unit
public struct ConvertedSwapUsage {
    let total: Float
    let used: Float
    let free: Float
    let unit: String
}
// RAM usage in human a readable unit
public struct ConvertedRAMUsage {
    let wired: Float
    let active: Float
    let appMemory: Float
    let compressed: Float
    let available: Float
    let unit: String
}
```

#### Disks and Volumes

```swift
// All disks and volumes informations
public struct VolumesDisksInfos {
    let volumes: [VolumeInfos]
    let disks: [DiskInfos]
}
// Disk informations
public struct DiskInfos {
    let name: String
    let blocksize: UInt32
    let size: UInt64
    let usage: DiskUsage
}
// Disk usage in bytes
public struct DiskUsage {
    let bytesread: UInt64
    let byteswritten: UInt64
    let operationsread: UInt64
    let operationswritten: UInt64
}
// Volume informations
public struct VolumeInfos {
    let filesystem: String
    let mountpoint: String
    let mountname: String
    let usage: VolumeUsage
}
// Volume usage in volume block
public struct VolumeUsage {
    let blocksize: UInt32
    let iosize: Int32
    let blocks: UInt64
    let free: UInt64
    let available: UInt64
    let files: UInt64
    let filesfree: UInt64
    
    func convertTo(unit: String) throws -> ConvertedVolumeUsage
}
// Volume usage in human a readable unit
public struct ConvertedVolumeUsage {
    let total: Float
    let free: Float
    let available: Float
    let unit: String
}
```

#### Network interfaces

```swift
// All informations for a network interface
public struct NetworkInterfaceInfos {
    let name: String
    let bytessend: UInt
    let bytesreceived: UInt
    let addresses: [InterfaceAddress]
}
// Informations for a network interface address
public struct InterfaceAddress {
    let address: String
    let netmask: String
    let destaddress: String
    let type: String
    let flags: InterfaceAddressFlags
}
// Flags for a network interface address
public struct InterfaceAddressFlags {
    let iff_up: Bool
    let iff_broadcast: Bool
    let iff_debug: Bool
    let iff_loopback: Bool
    let iff_pointopoint: Bool
    let iff_notrailers: Bool
    let iff_running: Bool
    let iff_noarp: Bool
    let iff_promisc: Bool
    let iff_allmulti: Bool
    let iff_oactive: Bool
    let iff_simplex: Bool
    let iff_link0: Bool
    let iff_link1: Bool
    let iff_link2: Bool
    let iff_altphys: Bool
    let iff_multicast: Bool
}
```

#### Graphics

```swift
// All informations for a GPU
public struct GPUInfos {
    let name: String
    let isOn: Bool
    let utilization: UInt
    let vramTotalMB: UInt
    let vramFreeMB: UInt
    let coreClockMHz: UInt
    let memoryClockMHz: UInt
    let sensors: GPUSensors
}
// GPU sensors informations
public struct GPUSensors {
    let totalPower: UInt
    let temperature: UInt
    let fanSpeedPercent: UInt
    let fanSpeedRPM: UInt
}
```

#### Power and Battery

```swift
// Battery informations
public struct BatteryInfos {
    let serialNumber: String
    let manufactureDate: Date
    let cycleCount: Int
    
    let designCapacity: Int
    let maxCapacity: Int
    let currentCapacity: Int
    let voltage: Int
    let amperage: Int
    let instantAmperage: Int
    
    let timeRemaining: Int
    let timeToFull: Int
    let timeToEmpty: Int
    let isCharging: Bool
    let isFullyCharged: Bool
    let chargingCurrent: Int
}
```

#### Sensors

```swift
// All sensors informations
public struct SensorsInfos {
    let fans: [FanSensor]
    let temperatures: [String:Float]
    let amperages: [String:Float]
    let voltages: [String:Float]
    let powers: [String:Float]
}
// Single fan's speed informations
public struct FanSensor {
    let min: Float
    let max: Float
    let actual: Float
    let target: Float
}
```
