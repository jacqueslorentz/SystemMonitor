//
//  SystemMonitor.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

enum SystemMonitorError : Error {
    case sysctlError(arg: [Int32], errno: String)
    case hostStatError(arg: Int32, errno: String)
    case conversionFailed(invalidUnit: String)
}

class SystemMonitor {
    func getInfos() {
        
    }
    
    func getMemoryInfos() throws -> MemoryUsage {
        return MemoryUsage(
            swapUsage: try MemoryHandler.getSwapInfos(),
            ramUsage: try MemoryHandler.getRAMInfos()
        )
    }
}
