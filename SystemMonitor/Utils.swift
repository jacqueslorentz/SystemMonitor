//
//  Utils.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

func sysctlCall(request: [Int32], layoutSize: Int) -> [UInt64] {
    let size = layoutSize / MemoryLayout<UInt64>.size
    let ptr = UnsafeMutablePointer<UInt64>.allocate(capacity: size)
    var count = layoutSize

    if( sysctl(UnsafeMutablePointer(mutating: request), 2, ptr, &count, nil, 0) != 0 )
    {
        //throw MachError()
        //perror( "unable to get swap usage by calling sysctlbyname(\"vm.swapusage\",...)" );
        // Log error
    }
    return Array(UnsafeBufferPointer(start: ptr, count: size))
}
