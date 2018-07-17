//
//  MemoryHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

public struct MemoryUsage {
    let swapUsage: SwapUsage
    let ramUsage: RAMUsage
    
    func print() throws {
        Swift.print(try swapUsage.convertTo(unit: "GB"))
        Swift.print(try ramUsage.convertTo(unit: "GB"))
    }
}

public struct ConvertedSwapUsage {
    let total: Float
    let used: Float
    let free: Float
    let unit: String
}

// In bytes
public struct SwapUsage {
    let total: UInt64
    let used: UInt64
    let free: UInt64
    
    func convertTo(unit: String) throws -> ConvertedSwapUsage {
        let mult = try getBytesConversionMult(unit: unit)
        return ConvertedSwapUsage(
            total: (Float)(self.total) / mult,
            used: (Float)(self.used) / mult,
            free: (Float)(self.free) / mult,
            unit: unit
        )
    }
}

public struct ConvertedRAMUsage {
    let wired: Float
    let active: Float
    let appMemory: Float
    let compressed: Float
    let available: Float
    let unit: String
}

// In Memory pages (4096 bytes)
public struct RAMUsage {
    let wired: UInt
    let active: UInt
    let appMemory: UInt
    let compressed: UInt
    let available: UInt
    
    func convertTo(unit: String) throws -> ConvertedRAMUsage {
        let pageSize: UInt = 4096
        let mult = try getBytesConversionMult(unit: unit)
        return ConvertedRAMUsage(
            wired: (Float)(self.wired * pageSize) / mult,
            active: (Float)(self.active * pageSize) / mult,
            appMemory: (Float)(self.appMemory * pageSize) / mult,
            compressed: (Float)(self.compressed * pageSize) / mult,
            available: (Float)(self.available * pageSize) / mult,
            unit: unit
        )
    }
}

struct MemoryHandler {
    static func getRAMInfos() throws -> RAMUsage {
        let array = try hostMemoryCall(request: HOST_VM_INFO64, layoutSize: MemoryLayout<vm_statistics64_data_t>.size);
        
        var stat: [String: UInt] = [:]
        let attr: [(String, Int)] = [
            ("free", 1), ("active", 1), ("inactive", 1), ("wired", 1),
            ("zeroFilled", 2), ("reactivations", 2), ("pageins", 2), ("pageouts", 2),
            ("faults", 2), ("cowfaults", 2), ("lookups", 2), ("hits", 2),
            ("purges", 2), ("purgeable", 1), ("speculative", 1),
            ("decompressions", 2), ("compressions", 2), ("swapins", 2), ("swapouts", 2),
            ("compressorPage", 1), ("throttled", 1),
            ("externalPage", 1), ("internalPage", 1), ("totalUncompressedInCompressor", 2)
        ]
        
        var inc = 0;
        for tag in attr {
            if (tag.1 == 1) {
                stat[tag.0] = UInt(array[inc])
            } else {
                stat[tag.0] = UInt(UInt32(array[inc])) + UInt(UInt32(array[inc + 1])) * UInt(UINT32_MAX)
            }
            inc += tag.1
        }
        return RAMUsage(
            wired: stat["wired"]!,
            active: stat["active"]!,
            appMemory: stat["active"]! + stat["purgeable"]!,
            compressed: stat["compressorPage"]!,
            available: stat["inactive"]! + stat["free"]!
        );
    }
    
    static func getSwapInfos() throws -> SwapUsage {
        let request = [CTL_VM, VM_SWAPUSAGE]
        let size = MemoryLayout<xsw_usage>.size / MemoryLayout<UInt64>.size
        let ptr = UnsafeMutablePointer<UInt64>.allocate(capacity: size)
        var count = 0
        if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), ptr, &count, nil, 0) != 0) {
            throw SystemMonitorError.sysctlError(arg: request, errno: stringErrno())
        }
        let res = Array(UnsafeBufferPointer(start: ptr, count: size))
        ptr.deallocate()
        return SwapUsage(total: res[0], used: res[1], free: res[2]);
    }
}

func hostMemoryCall(request: Int32, layoutSize: Int) throws -> [Int32] {
    let size = layoutSize / MemoryLayout<Int32>.size
    let ptr = UnsafeMutablePointer<Int32>.allocate(capacity: size)
    var count = UInt32(size)
    if (host_statistics64(mach_host_self(), request, ptr, &count) != 0) {
        throw SystemMonitorError.hostCallError(arg: request, errno: stringErrno())
    }
    let res = Array(UnsafeBufferPointer(start: ptr, count: size))
    ptr.deallocate()
    return res
}
