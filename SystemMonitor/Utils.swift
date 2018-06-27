//
//  Utils.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

func hostCall(request: Int32, layoutSize: Int) -> [Int32] {
    let size = layoutSize / MemoryLayout<Int32>.size
    let ptr = UnsafeMutablePointer<Int32>.allocate(capacity: size)
    var count = UInt32(size)
    
    if (host_statistics64(mach_host_self(), request, ptr, &count) != 0) {
        //throw MachError()
        //perror( "unable to get swap usage by calling sysctlbyname(\"vm.swapusage\",...)" );
        // Log error
    }
    let res = Array(UnsafeBufferPointer(start: ptr, count: size))
    ptr.deallocate()
    return res
}

func sysctlCall(request: [Int32], layoutSize: Int) -> [UInt64] {
    let size = layoutSize / MemoryLayout<UInt64>.size
    let ptr = UnsafeMutablePointer<UInt64>.allocate(capacity: size)
    var count = layoutSize

    if (sysctl(UnsafeMutablePointer(mutating: request), 2, ptr, &count, nil, 0) != 0) {
        //throw MachError()
        //perror( "unable to get swap usage by calling sysctlbyname(\"vm.swapusage\",...)" );
        // Log error
    }
    let res = Array(UnsafeBufferPointer(start: ptr, count: size))
    ptr.deallocate()
    return res
}

func getBytesConversionMult(unit: String) -> Float {
    let units = ["B", "KB", "MB", "GB"]
    if (!units.contains(unit)) {
        // throw error
    }
    let index = units.firstIndex(of: unit)
    return pow(Float(1024), Float(index!))
}
