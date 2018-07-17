//
//  Utils.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

func stringErrno() -> String {
    return String(cString: strerror(errno));
}

func getBytesConversionMult(unit: String) throws -> Float {
    let units = ["B", "KB", "MB", "GB"]
    if (!units.contains(unit)) {
        throw SystemMonitorError.conversionFailed(invalidUnit: unit)
    }
    let index = units.firstIndex(of: unit)
    return pow(Float(1024), Float(index!))
}
