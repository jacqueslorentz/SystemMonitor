//
//  BatteryHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 29/07/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

public struct BatteryInfos {
    let serialNumber: String
    let manufactureDate: Date
    let cycleCount: Int
    
    let designCapacity: Int
    let maxCapacity: Int
    let currentCapacity: Int
    let voltage: Int
    let amperage: Int
    let instantAmperage: Int
    
    let timeRemaining: Int
    let timeToFull: Int
    let timeToEmpty: Int
    let isCharging: Bool
    let isFullyCharged: Bool
    let chargingCurrent: Int
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
