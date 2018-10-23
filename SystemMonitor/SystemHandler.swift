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
    public let boottime: Int
    public let hostname: String
    public let kernel: String
    public let kernelVersion: String
}

struct SystemHandler {
    static func getSystemInfos() throws -> SystemSpecificInfos {
        return SystemSpecificInfos(
            boottime: try getSysctlAsTimeval(request: "kern.boottime").tv_sec,
            hostname: try getSysctlString(request: "kern.hostname"),
            kernel: try getSysctlString(request: "kern.ostype"),
            kernelVersion: try getSysctlString(request: "kern.osrelease")
        )
    }
}

func getSysctlAsTimeval(request: String) throws -> timeval {
    var count = MemoryLayout<timeval>.size
    var time = timeval()
    if (sysctlbyname(request, &time, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: request, errno: stringErrno())
    }
    return time
}
