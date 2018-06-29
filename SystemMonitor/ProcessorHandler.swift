//
//  ProcessorHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 29/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

public struct CPUCoreUsagePercent {
    let user: Float
    let system: Float
    let idle: Float
    let nice: Float
}

public struct CPUCoreUsage {
    let user: UInt32
    let system: UInt32
    let idle: UInt32
    let nice: UInt32
    
    func toPercent() -> CPUCoreUsagePercent {
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
    let cores: [CPUCoreUsagePercent]
    let total: CPUCoreUsagePercent
}

public struct CPUUsage {
    let cores: [CPUCoreUsage]
    let total: CPUCoreUsage
    
    func toPercent(unixLike: Bool) -> CPUUsagePercent {
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
    let usage: CPUUsage
}

struct ProcessorHandler {
    static func getCPUUsage() throws -> CPUUsage {
        let cpuLoad = try hostProcessorCall(request: PROCESSOR_CPU_LOAD_INFO);
        let cores = cpuLoad.map { (load: [UInt32]) -> CPUCoreUsage in
            CPUCoreUsage(user: load[0], system: load[1], idle: load[2], nice: load[3])
        }
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
