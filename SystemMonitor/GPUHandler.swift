//
//  GPUHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 23/07/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import IOKit

public struct GPUSensors {
    let totalPower: UInt
    let temperature: UInt
    let fanSpeedPercent: UInt
    let fanSpeedRPM: UInt
}

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

struct GPUHandler {
    static func getGPUUsage() throws -> [GPUInfos] {
        let pcidevices = try getIOProperties(ioClassname: "IOPCIDevice").filter { (dict: [String : Any]) -> Bool in
            return dict["model"] != nil
        }
        return try getIOProperties(ioClassname: "IOAccelerator").map({ (accelerator: [String : Any]) -> GPUInfos in
            guard let agcInfo = accelerator["AGCInfo"] as? [String:Int] else {
                throw SystemMonitorError.IOKitError(error: "IOAccelerator -> AGCInfo")
            }
            guard let performanceStatistics = accelerator["PerformanceStatistics"] as? [String:Any] else {
                throw SystemMonitorError.IOKitError(error: "IOAccelerator -> PerformanceStatistics")
            }
            guard let pci = try pcidevices.first(where: { (pcidevice: [String : Any]) -> Bool in
                guard let deviceID = pcidevice["device-id"] as? Data, let vendorID = pcidevice["vendor-id"] as? Data else {
                    throw SystemMonitorError.IOKitError(error: "IOPCIDevice -> device-id, vendor-id")
                }
                let pciMatch = "0x" + Data([deviceID[1], deviceID[0], vendorID[1], vendorID[0]]).map { String(format: "%02hhX", $0) }.joined()
                let accMatch = accelerator["IOPCIMatch"] as? String ?? accelerator["IOPCIPrimaryMatch"] as? String ?? ""
                return accMatch.range(of: pciMatch) != nil
            }) else {
                throw SystemMonitorError.IOKitError(error: "IOAccelerator IOPCIDevice not corresponding")
            }
            return GPUInfos(
                name: String(data: pci["model"]! as! Data, encoding: String.Encoding.ascii)!,
                isOn: agcInfo["poweredOffByAGC"] == 0,
                utilization: performanceStatistics["Device Utilization %"] as? UInt ?? 0,
                vramTotalMB: accelerator["VRAM,totalMB"] as? UInt ?? pci["VRAM,totalMB"] as? UInt ?? 0,
                vramFreeMB: (performanceStatistics["vramFreeBytes"] as? UInt ?? 0) / (1024 * 1024),
                coreClockMHz: performanceStatistics["Core Clock(MHz)"] as? UInt ?? 0,
                memoryClockMHz: performanceStatistics["Memory Clock(MHz)"] as? UInt ?? 0,
                sensors: GPUSensors(
                    totalPower: performanceStatistics["Total Power(W)"] as? UInt ?? 0,
                    temperature: performanceStatistics["Temperature(C)"] as? UInt ?? 0,
                    fanSpeedPercent: performanceStatistics["Fan Speed(%)"] as? UInt ?? 0,
                    fanSpeedRPM: performanceStatistics["Fan Speed(RPM)"] as? UInt ?? 0
                )
            )
        })
    }
}

func getIOProperties(ioClassname: String) throws -> [[String:Any]] {
    var results = [[String:Any]]()
    let matchDict = IOServiceMatching(ioClassname)
    var iterator = io_iterator_t()
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, matchDict, &iterator) == kIOReturnSuccess) {
        var regEntry: io_registry_entry_t = IOIteratorNext(iterator)
        while (regEntry != io_object_t(0)) {
            var properties: Unmanaged<CFMutableDictionary>? = nil
            if (IORegistryEntryCreateCFProperties(regEntry, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess) {
                guard let prop = properties?.takeUnretainedValue() as? [String:Any] else {
                    throw SystemMonitorError.IOKitError(error: ioClassname)
                }
                properties?.release()
                results.append(prop)
            }
            IOObjectRelease(regEntry)
            regEntry = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)
    }
    return results
}
