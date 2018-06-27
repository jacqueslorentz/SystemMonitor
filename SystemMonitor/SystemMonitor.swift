//
//  SystemMonitor.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

class SystemMonitor {
    func getInfos() {
        
    }
    
    func getMemoryInfos() -> MemoryUsage {
        return MemoryUsage(
            swapUsage: MemoryHandler.getSwapInfos(),
            ramUsage: MemoryHandler.getRAMInfos()
        )
    }
}
