//
//  Utils.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

func stringErrno() -> String {
    return String(cString: strerror(errno));
}

func sysctlCall(request: [Int32], layoutSize: Int) throws -> [UInt64] {
    let size = layoutSize / MemoryLayout<UInt64>.size
    let ptr = UnsafeMutablePointer<UInt64>.allocate(capacity: size)
    var count = layoutSize
    if (sysctl(UnsafeMutablePointer(mutating: request), 2, ptr, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: request, errno: stringErrno())
    }
    let res = Array(UnsafeBufferPointer(start: ptr, count: size))
    ptr.deallocate()
    return res
}

func getBytesConversionMult(unit: String) throws -> Float {
    let units = ["B", "KB", "MB", "GB"]
    if (!units.contains(unit)) {
        throw SystemMonitorError.conversionFailed(invalidUnit: unit)
    }
    let index = units.firstIndex(of: unit)
    return pow(Float(1024), Float(index!))
}
