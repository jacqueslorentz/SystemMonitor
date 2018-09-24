//
//  BatteryHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 29/07/2018.
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

public struct BatteryInfos {
    public let serialNumber: String
    public let manufactureDate: Date
    public let cycleCount: Int
    
    public let designCapacity: Int
    public let maxCapacity: Int
    public let currentCapacity: Int
    public let voltage: Int
    public let amperage: Int
    public let instantAmperage: Int
    
    public let timeRemaining: Int
    public let timeToFull: Int
    public let timeToEmpty: Int
    public let isCharging: Bool
    public let isFullyCharged: Bool
    public let chargingCurrent: Int
}

struct BatteryHandler {
    static func getBatteryInfos() throws -> BatteryInfos {
        let data = try getIOProperties(ioClassname: "IOPMPowerSource")
        if (data.count == 0) {
            throw SystemMonitorError.IOKitError(error: "No battery found")
        }
        let battery = data.first!
        guard let chargerData = battery["ChargerData"] as? [String:Int] else {
            throw SystemMonitorError.IOKitError(error: "No battery charger infos")
        }
        let datecode = battery["ManufactureDate"] as! Int
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: String((datecode >> 9) + 1980) + "-" + String((datecode >> 5) & 0xF) + "-" + String(datecode & 0x1F) + "T00:00:00.000Z")!
        return BatteryInfos(
            serialNumber: battery["BatterySerialNumber"] as? String ?? "",
            manufactureDate: date,
            cycleCount: battery["CycleCount"] as? Int ?? 0,
            designCapacity: battery["DesignCapacity"] as? Int ?? 0,
            maxCapacity: battery["MaxCapacity"] as? Int ?? 0,
            currentCapacity: battery["CurrentCapacity"] as? Int ?? 0,
            voltage: battery["Voltage"] as? Int ?? 0,
            amperage: battery["Amperage"] as? Int ?? 0,
            instantAmperage: battery["InstantAmperage"] as? Int ?? 0,
            timeRemaining: battery["TimeRemaining"] as? Int ?? 0,
            timeToFull: battery["AvgTimeToFull"] as? Int ?? 65535,
            timeToEmpty: battery["AvgTimeToEmpty"] as? Int ?? 65535,
            isCharging: battery["IsCharging"] as? Bool ?? false,
            isFullyCharged: battery["IsCharging"] as? Bool ?? false,
            chargingCurrent: chargerData["ChargingCurrent"] ?? 0
        )
    }
}
