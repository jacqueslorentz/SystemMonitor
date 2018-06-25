//
//  MemoryHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

public struct SwapUsage {
    let total: UInt64
    let used: UInt64
    let free: UInt64
}

struct MemoryHandler {
    static func getSwapInfos() -> SwapUsage {
        
        let res = sysctlCall(request: [CTL_VM, VM_SWAPUSAGE], layoutSize: MemoryLayout<xsw_usage>.size);
        return SwapUsage(total: res[0], used: res[1], free: res[2]);
        
    }
}
