//
//  SystemMonitor.swift
//  SystemMonitor
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

import Foundation

enum SystemMonitorError : Error {
    case sysctlError(arg: [Int32], errno: String)
    case hostCallError(arg: Int32, errno: String)
    case conversionFailed(invalidUnit: String)
    case statfsError(errno: String)
    case IOKitError(error: String)
    case getifaddrsError()
    case SMCError(error: String)
}

public struct SystemInfos {
    let memory: MemoryUsage
    let processor: CPUInfos
    let disk: VolumesDisksInfos
    let network: [NetworkInterfaceInfos]
    let graphics: [GPUInfos]
    let system: SystemSpecificInfos
    let battery: BatteryInfos
    let sensors: SensorsInfos
}

public class SystemMonitor {
    let sensorsHandler: SensorsHandler
        
    public init() throws {
        self.sensorsHandler = try SensorsHandler()
    }
    
    public func getInfos() throws -> SystemInfos {
        return SystemInfos(
            memory: try self.getMemoryInfos(),
            processor: try self.getProcessorInfos(),
            disk: try self.getDiskInfos(),
            network: try self.getNetworkInfos(),
            graphics: try self.getGPUInfos(),
            system: try self.getSystemInfos(),
            battery: try self.getBatteryInfos(),
            sensors: try self.getSensorsInfos()
        )
    }
    
    public func getMemoryInfos() throws -> MemoryUsage {
        return MemoryUsage(
            swapUsage: try MemoryHandler.getSwapInfos(),
            ramUsage: try MemoryHandler.getRAMInfos()
        )
    }
    
    public func getProcessorInfos() throws -> CPUInfos {
        return CPUInfos(
            usage: try ProcessorHandler.getCPUUsage()
        )
    }
    
    public func getDiskInfos() throws -> VolumesDisksInfos {
        return VolumesDisksInfos(
            volumes: try DiskHandler.getVolumesInfos(),
            disks: try DiskHandler.getDisksInfos()
        )
    }
    
    public func getNetworkInfos() throws -> [NetworkInterfaceInfos] {
        return try NetworkHandler.getNetworkInfos()
    }
    
    public func getGPUInfos() throws -> [GPUInfos] {
        return try GPUHandler.getGPUUsage()
    }
    
    public func getSystemInfos() throws -> SystemSpecificInfos {
        return try SystemHandler.getSystemInfos()
    }
    
    public func getBatteryInfos() throws -> BatteryInfos {
        return try BatteryHandler.getBatteryInfos()
    }
    
    public func getSensorsInfos() throws -> SensorsInfos {
        return try sensorsHandler.getSensorsInfos()
    }
}
