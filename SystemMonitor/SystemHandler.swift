//
//  SystemHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 25/07/2018.
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
