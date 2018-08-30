//
//  SystemMonitorTests.swift
//  SystemMonitorTests
//
//  Created by Jacques Lorentz on 24/06/2018.
//
//  MIT License
//  Copyright (c) 2018 Jacques Lorentz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import SystemMonitor

class SystemMonitorTests: XCTestCase {
    let printDebug = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSystemMonitor() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testMemoryHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getMemoryInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testProcessorHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getProcessorInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testDiskHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getDiskInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testNetworkHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getNetworkInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testGPUHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getGPUInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testSystemHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getSystemInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testBatteryHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getBatteryInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testSensorsHandler() throws {
        let sm = try SystemMonitorInstance()
        let infos = try sm.getSensorsInfos()
        if (printDebug) {
            print(infos)
        }
    }
    
    func testNiceDisplay() throws {
        let sm = try SystemMonitorInstance()
        
        print("System Infos:")
        let systemInfos = try sm.getSystemInfos()
        print("\tHostname:", systemInfos.hostname)
        print("\tKernel:", systemInfos.kernel)
        print("\tKernel Version:", systemInfos.kernelVersion)
        let gmt = Date(timeIntervalSince1970: TimeInterval(systemInfos.boottime))
        let gmtDiff = TimeInterval(TimeZone.current.secondsFromGMT())
        print("\tBoottime:", gmt.addingTimeInterval(gmtDiff))
        
        print("Processor/CPU Infos:")
        let cpuInfos = try sm.getProcessorInfos()
        print("\tCPU Usage:\t User\t System\t Idle\t Nice")
        let cpuUsage = cpuInfos.usage
        for (index, core) in cpuUsage.cores.enumerated() {
            let corePercent = core.toPercent()
            print(
                "\t\tCPU" + String(index) + ":\t",
                String(floatTrunc(flt: corePercent.user, decimalNb: 1)) + "%\t",
                String(floatTrunc(flt: corePercent.system, decimalNb: 1)) + "%\t",
                String(floatTrunc(flt: corePercent.idle, decimalNb: 1)) + "%\t",
                String(floatTrunc(flt: corePercent.nice, decimalNb: 1)) + "%\t",
                "(" + String(core.user) + ",",
                String(core.system) + ",",
                String(core.idle) + ",",
                String(core.nice) + ")"
            )
        }
        let total = cpuUsage.total
        let totalPercent = cpuUsage.total.toPercent()
        print(
            "\t\tTotal:\t",
            String(floatTrunc(flt: totalPercent.user, decimalNb: 1)) + "%\t",
            String(floatTrunc(flt: totalPercent.system, decimalNb: 1)) + "%\t",
            String(floatTrunc(flt: totalPercent.idle, decimalNb: 1)) + "%\t",
            String(floatTrunc(flt: totalPercent.nice, decimalNb: 1)) + "%\t",
            "(" + String(total.user) + ",",
            String(total.system) + ",",
            String(total.idle) + ",",
            String(total.nice) + ")"
        )
        
        print("Memory Infos:")
        let memoryInfos = try sm.getMemoryInfos()
        let unitToConvert = "GB"
        let ramUsage = memoryInfos.ramUsage
        let ramUsageUnit = try memoryInfos.ramUsage.convertTo(unit: unitToConvert)
        print("\tRAM Usage:")
        print("\t\tActive:     ", floatTrunc(flt: ramUsageUnit.active, decimalNb: 2), ramUsageUnit.unit, "(", ramUsage.active, "pages )")
        print("\t\tWired:      ", floatTrunc(flt: ramUsageUnit.wired, decimalNb: 2), ramUsageUnit.unit, "(", ramUsage.wired, "pages )")
        print("\t\tApplication:", floatTrunc(flt: ramUsageUnit.appMemory, decimalNb: 2), ramUsageUnit.unit, "(", ramUsage.appMemory, "pages )")
        print("\t\tCompressed: ", floatTrunc(flt: ramUsageUnit.compressed, decimalNb: 2), ramUsageUnit.unit, "(", ramUsage.compressed, "pages )")
        print("\t\tAvailablbe: ", floatTrunc(flt: ramUsageUnit.available, decimalNb: 2), ramUsageUnit.unit, "(", ramUsage.available, "pages )")
        print("\tSwap Usage:")
        let swapUsage = memoryInfos.swapUsage
        let swapUsageUnit = try memoryInfos.swapUsage.convertTo(unit: unitToConvert)
        print("\t\tTotal:", floatTrunc(flt: swapUsageUnit.total, decimalNb: 2), swapUsageUnit.unit, "(", swapUsage.total, "bytes )")
        print("\t\tUsed: ", floatTrunc(flt: swapUsageUnit.used, decimalNb: 2), swapUsageUnit.unit, "(", swapUsage.used, "bytes )")
        print("\t\tFree: ", floatTrunc(flt: swapUsageUnit.free, decimalNb: 2), swapUsageUnit.unit, "(", swapUsage.free, "bytes )")
        
        print("Disks/Volumes Infos:")
        let disksVolumesInfos = try sm.getDiskInfos()
        print("\tVolumes Infos:")
        for volume in disksVolumesInfos.volumes {
            let usage = try volume.usage.convertTo(unit: "GB")
            print(
                "\t\t" + volume.mountname,
                "[" + volume.filesystem + "]",
                volume.mountpoint,
                "\t",
                String(floatTrunc(flt: usage.available, decimalNb: 2)) + usage.unit,
                "available on",
                String(floatTrunc(flt: usage.total, decimalNb: 2)) + usage.unit,
                "(" + String(floatTrunc(flt: usage.free, decimalNb: 2)) + usage.unit + " free)"
            )
        }
        print("\tDisks Infos:")
        for disk in disksVolumesInfos.disks {
            let usage = disk.usage
            print(
                "\t\t" + disk.name,
                "\t",
                String(floatTrunc(flt: bytesToGB(bytes: disk.size), decimalNb: 2)) + "GB",
                "(read:",
                String(floatTrunc(flt: bytesToGB(bytes: usage.bytesread), decimalNb: 2)) + "GB,",
                "writen:",
                String(floatTrunc(flt: bytesToGB(bytes: usage.byteswritten), decimalNb: 2)) + "GB)"
            )
        }
        
        print("Network Infos:")
        let networkInfos = try sm.getNetworkInfos()
        for interface in networkInfos {
            print("\tInterface " + interface.name + " (send: " + String(interface.bytessend) + ", received: " + String(interface.bytesreceived) + ")")
            for address in interface.addresses.filter({ $0.flags.iff_up && $0.address.count > 0 }) {
                print("\t\t[" + address.type + "]\t" + address.address + "\t" + address.netmask + "\t" + address.destaddress)
            }
        }
        
        print("Graphics/GPU Infos:")
        let gpuInfos = try sm.getGPUInfos()
        for gpu in gpuInfos {
            print("\t" + gpu.name + " [" + (gpu.isOn ? "ON" : "OFF") + "]")
            if (gpu.isOn) {
                print(
                    "\t\t" + String(gpu.utilization) + "% core",
                    "(@" + String(gpu.coreClockMHz) + "MHz),",
                    String(gpu.vramFreeMB) + "MB free VRAM of",
                    String(gpu.vramTotalMB) + "MB",
                    "(@" + String(gpu.memoryClockMHz) + "MHz),",
                    String(gpu.sensors.temperature) + "°C"
                )
            }
        }
        
        print("Battery Infos:")
        let batteryInfos = try sm.getBatteryInfos()
        print("\tSerial number:", batteryInfos.serialNumber)
        print("\tManufacture date:", batteryInfos.manufactureDate)
        print("\tCycle count:", batteryInfos.cycleCount)
        print("\tDesign capacity:", batteryInfos.designCapacity)
        print(
            "\tMaximum capacity:",
            batteryInfos.maxCapacity,
            "(" + String(floatTrunc(flt: Float(batteryInfos.maxCapacity) / Float(batteryInfos.designCapacity) * 100, decimalNb: 2)) + "%",
            "of design capacity)"
        )
        print(
            "\tCurrent capacity:",
            batteryInfos.currentCapacity,
            "(" + String(floatTrunc(flt: Float(batteryInfos.currentCapacity) / Float(batteryInfos.maxCapacity) * 100, decimalNb: 2)) + "%",
            "of maximum capacity)"
        )
        let watt = (Float(batteryInfos.voltage) / 1000) * (Float(batteryInfos.instantAmperage) / 1000)
        print(
            "\tUsage:",
            String(batteryInfos.voltage) + "mV",
            String(batteryInfos.instantAmperage) + "mA",
            String(floatTrunc(flt: (watt < 0 ? -watt : watt), decimalNb: 2)) + "W"
            
        )
        print(
            "\tCharging:",
            batteryInfos.isCharging,
            (batteryInfos.isCharging ? "@ " + String(floatTrunc(flt: Float(batteryInfos.chargingCurrent) / 1000, decimalNb: 2)) + "W" : ""),
            "(fully charged:",
            String(batteryInfos.isFullyCharged) + ")"
        )
        print("\tTime remaining:", batteryInfos.timeRemaining / 60, "hours", batteryInfos.timeRemaining % 60, "minutes")
        
        print("Sensors Infos:")
        let sensorsInfos = try sm.getSensorsInfos()
        print("\tFans:")
        for fan in sensorsInfos.fans {
            print("\t\t" + String(fan.actual), "RPM", "(min:", String(fan.min) + ", max:", String(fan.max) + ")")
        }
        print("\tTemperatures:")
        for temp in sensorsInfos.temperatures.filter({ (_: String, value: Float) -> Bool in value > 0 }) {
            print("\t\t" + temp.key + ": " + String(floatTrunc(flt: temp.value, decimalNb: 1)) + "°C")
        }
        print("\tVoltage:")
        for temp in sensorsInfos.voltages.filter({ (_: String, value: Float) -> Bool in value > 0 }) {
            print("\t\t" + temp.key + ": " + String(floatTrunc(flt: temp.value, decimalNb: 2)) + "V")
        }
        print("\tAmperages:")
        for temp in sensorsInfos.amperages.filter({ (_: String, value: Float) -> Bool in value > 0 }) {
            print("\t\t" + temp.key + ": " + String(floatTrunc(flt: temp.value, decimalNb: 2)) + "A")
        }
        print("\tWattages:")
        for temp in sensorsInfos.powers.filter({ (_: String, value: Float) -> Bool in value > 0 }) {
            print("\t\t" + temp.key + ": " + String(floatTrunc(flt: temp.value, decimalNb: 2)) + "W")
        }
    }
}

func floatTrunc(flt: Float, decimalNb: Int) -> Float {
    let power = pow(Float(10), Float(decimalNb))
    return round(flt * power) / power
}

func bytesToGB(bytes: UInt64) -> Float {
    return Float(bytes) / pow(Float(1024), Float(3))
}
