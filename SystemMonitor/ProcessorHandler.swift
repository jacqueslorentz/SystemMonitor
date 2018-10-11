//
//  ProcessorHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 29/06/2018.
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

public struct CPUCoreUsagePercent {
    public let user: Float
    public let system: Float
    public let idle: Float
    public let nice: Float
}

public struct CPUCoreUsage {
    public let user: UInt32
    public let system: UInt32
    public let idle: UInt32
    public let nice: UInt32
    
    public func toPercent() -> CPUCoreUsagePercent {
        let total = Float(self.user + self.system + self.idle + self.nice) / 100
        return CPUCoreUsagePercent(
            user: Float(self.user) / total,
            system: Float(self.system) / total,
            idle: Float(self.idle) / total,
            nice: Float(self.nice) / total
        )
    }
}

public struct CPUUsagePercent {
    public let cores: [CPUCoreUsagePercent]
    public let total: CPUCoreUsagePercent
}

public struct CPUUsage {
    public let cores: [CPUCoreUsage]
    public let total: CPUCoreUsage
    
    public func toPercent(unixLike: Bool) -> CPUUsagePercent {
        let totalNotUnix = self.total.toPercent()
        let coresNb = Float(self.cores.count)
        let total = (unixLike ? CPUCoreUsagePercent(
            user: totalNotUnix.user * coresNb,
            system: totalNotUnix.system * coresNb,
            idle: totalNotUnix.idle * coresNb,
            nice: totalNotUnix.nice * coresNb
        ) : totalNotUnix)
        return CPUUsagePercent(
            cores: self.cores.map { core in core.toPercent() },
            total: total
        )
    }
}

public struct CPUInfos {
    public let usage: CPUUsage
}

struct ProcessorHandler {
    var cpuLastLoad: [[UInt32]]
    
    init() throws {
        self.cpuLastLoad = try hostProcessorCall(request: PROCESSOR_CPU_LOAD_INFO)
        usleep(100000) // For calculating CPU ticks difference
    }
    
    mutating func getCPUUsage() throws -> CPUUsage {
        let cpuLoad = try hostProcessorCall(request: PROCESSOR_CPU_LOAD_INFO)
        let cores = cpuLoad.enumerated().map { (arg: (offset: Int, element: [UInt32])) -> CPUCoreUsage in
            let (offset, element) = arg
            return CPUCoreUsage(
                user: element[0] - cpuLastLoad[offset][0],
                system: element[1] - cpuLastLoad[offset][1],
                idle: element[2] - cpuLastLoad[offset][2],
                nice: element[3] - cpuLastLoad[offset][3]
            )
        }
        self.cpuLastLoad = cpuLoad
        let total = cores.reduce(CPUCoreUsage(user: 0, system: 0, idle: 0, nice: 0)) {
            (res: CPUCoreUsage, elem: CPUCoreUsage) -> CPUCoreUsage in CPUCoreUsage(
                user: res.user + elem.user,
                system: res.system + elem.system,
                idle: res.idle + elem.idle,
                nice: res.nice + elem.nice
            )
        }
        return CPUUsage(cores: cores, total: total)
    }
}

func hostProcessorCall(request: Int32) throws -> [[UInt32]] {
    var array = processor_info_array_t(bitPattern: 0)
    var msgCount = mach_msg_type_name_t()
    var count = UInt32()
    if (host_processor_info(mach_host_self(), request, &count, &array, &msgCount) != 0) {
        throw SystemMonitorError.hostCallError(arg: request, errno: stringErrno())
    }
    let cpuLoad = array!.withMemoryRebound(
        to: processor_cpu_load_info.self,
        capacity: Int(count) * MemoryLayout<processor_cpu_load_info>.size
    ) { ptr -> processor_cpu_load_info_t in ptr }
    var res = [[UInt32]]()
    for i in 0 ... Int(count) - 1 {
        res.append([
            cpuLoad[i].cpu_ticks.0,
            cpuLoad[i].cpu_ticks.1,
            cpuLoad[i].cpu_ticks.2,
            cpuLoad[i].cpu_ticks.3,
        ])
    }
    munmap(array, Int(vm_page_size))
    return res
}
