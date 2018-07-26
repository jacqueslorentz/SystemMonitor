//
//  SystemHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 25/07/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

public struct SystemSpecificInfos {
    let boottime: Int
    let hostname: String
    let kernel: String
    let kernelVersion: String
}

struct SystemHandler {
    static func getSystemInfos() throws -> SystemSpecificInfos {
        return SystemSpecificInfos(
            boottime: try getSysctlAsTimeval(request: [CTL_KERN, KERN_BOOTTIME]).tv_sec,
            hostname: try getSysctlAsString(request: [CTL_KERN, KERN_HOSTNAME]),
            kernel: try getSysctlAsString(request: [CTL_KERN, KERN_OSTYPE]),
            kernelVersion: try getSysctlAsString(request: [CTL_KERN, KERN_OSRELEASE])
        )
    }
}

func getSysctlAsTimeval(request: [Int32]) throws -> timeval {
    var count = MemoryLayout<timeval>.size
    var time = timeval()
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), &time, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: request, errno: stringErrno())
    }
    return time
}

func getSysctlAsString(request: [Int32]) throws -> String {
    var count = 0
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), nil, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: request, errno: stringErrno())
    }
    let ptr = UnsafeMutablePointer<Int8>.allocate(capacity: count)
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), ptr, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: request, errno: stringErrno())
    }
    let res = Array(UnsafeBufferPointer(start: ptr, count: count)).reduce("", { (str: String, code: Int8) -> String in
        return (code == 0 ? str : str + String(Character(UnicodeScalar(Int(code))!)))
    })
    ptr.deallocate()
    return res
}
