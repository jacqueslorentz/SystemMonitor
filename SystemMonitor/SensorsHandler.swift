//
//  SensorsHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 30/07/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import Foundation

public typealias SMCBytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8)

extension UInt32 {
    init(fromBytes bytes: (UInt8, UInt8, UInt8, UInt8)) {
        let byte0 = UInt32(bytes.0) << 24
        let byte1 = UInt32(bytes.1) << 16
        let byte2 = UInt32(bytes.2) << 8
        let byte3 = UInt32(bytes.3)
        self = byte0 | byte1 | byte2 | byte3
    }
}

public struct SMCParamStruct {

    /// I/O Kit function selector
    public enum Selector: UInt8 {
        case kSMCHandleYPCEvent  = 2
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    }
    
    /// Return codes for SMCParamStruct.result property
    public enum Result: UInt8 {
        case kSMCSuccess     = 0
        case kSMCError       = 1
        case kSMCKeyNotFound = 132
    }
    
    public struct SMCVersion {
        var major: CUnsignedChar = 0
        var minor: CUnsignedChar = 0
        var build: CUnsignedChar = 0
        var reserved: CUnsignedChar = 0
        var release: CUnsignedShort = 0
    }
    
    public struct SMCPLimitData {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }
    
    public struct SMCKeyInfoData {
        /// How many bytes written to SMCParamStruct.bytes
        var dataSize: IOByteCount = 0
        
        /// Type of data written to SMCParamStruct.bytes. This lets us know how
        /// to interpret it (translate it to human readable)
        var dataType: UInt32 = 0
        
        var dataAttributes: UInt8 = 0
    }
    
    /// FourCharCode telling the SMC what we want
    var key: UInt32 = 0
    var vers = SMCVersion()
    var pLimitData = SMCPLimitData()
    var keyInfo = SMCKeyInfoData()
    /// Padding for struct alignment when passed over to C side
    var padding: UInt16 = 0
    /// Result of an operation
    var result: UInt8 = 0
    var status: UInt8 = 0
    /// Method selector
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    /// Data returned from the SMC
    var bytes: SMCBytes = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                           UInt8(0), UInt8(0))
}

public struct SMCSensor {
    let name: String
    let dataType: String
    let keyCode: UInt32
    let dataTypeCode: UInt32
    let bytes: SMCBytes
}

public struct SensorsInfos {
    let smcSensors: [SMCSensor]
}

struct SensorsHandler {
    var sensors: [SMCSensor]
    
    init() {
        self.sensors = [SMCSensor]()
        var ioc = io_connect_t()
        let service: io_object_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleSMC"))
        if (service != IO_OBJECT_NULL) {
            IOServiceOpen(service, mach_task_self_, 0, &ioc)
            var inputStruct = SMCParamStruct()
            var outputStruct = SMCParamStruct()
            let inputStructSize = MemoryLayout<SMCParamStruct>.stride
            var outputStructSize = MemoryLayout<SMCParamStruct>.stride
            
            let key = stringToKeyCode(key: "#KEY")
            inputStruct.key = key
            inputStruct.keyInfo.dataSize = 4
            inputStruct.data8 = 5
            if (IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize) != kIOReturnSuccess) {
                //
            }
            let total = UInt32(outputStruct.bytes.0) << 24 + UInt32(outputStruct.bytes.1) << 16
                + UInt32(outputStruct.bytes.2) << 8 + UInt32(outputStruct.bytes.3)
            var i = UInt32(0)

            while (i < total) {
                inputStruct.data8 = 8
                inputStruct.data32 = i
                if (IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize) != kIOReturnSuccess) {
                    //
                }
                let key = outputStruct.key
                inputStruct.key = outputStruct.key
                inputStruct.keyInfo.dataSize = 4
                inputStruct.data8 = 9
                if (IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize) != kIOReturnSuccess) {
                    //
                }
                let dataType = outputStruct.keyInfo.dataType
                self.sensors.append(SMCSensor(
                    name: uint32ToString(value: key),
                    dataType: uint32ToString(value: dataType),
                    keyCode: key,
                    dataTypeCode: dataType,
                    bytes: outputStruct.bytes
                ))
                i += 1
            }
            IOServiceClose(ioc)
        }
    }
    
    func getSensorsInfos() throws -> SensorsInfos {
        var ioc = io_connect_t()
        let service: io_object_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleSMC"))
        var sensors = [SMCSensor]()
        if (service != IO_OBJECT_NULL) {
            IOServiceOpen(service, mach_task_self_, 0, &ioc)
            var inputStruct = SMCParamStruct()
            var outputStruct = SMCParamStruct()
            let inputStructSize = MemoryLayout<SMCParamStruct>.stride
            var outputStructSize = MemoryLayout<SMCParamStruct>.stride
            sensors = self.sensors.map { (s: SMCSensor) -> SMCSensor in
                inputStruct.key = s.keyCode
                inputStruct.keyInfo.dataSize = 4
                inputStruct.data8 = 5
                if (IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize) != kIOReturnSuccess) {
                    //
                }
                let data = outputStruct.bytes
                return SMCSensor(name: s.name, dataType: s.dataType, keyCode: s.keyCode, dataTypeCode: s.dataTypeCode, bytes: data)
            }
            IOServiceClose(ioc)
        }
        return SensorsInfos(smcSensors: sensors)
    }
}

func stringToKeyCode(key: String) -> UInt32 {
    return (key.count != 4 ? 0 : key.utf8.reduce(0) { sum, character in
        return sum << 8 | UInt32(character)
    })
}

func uint32ToString(value: UInt32) -> String {
    return String(describing: UnicodeScalar(value >> 24 & 0xff)!) +
        String(describing: UnicodeScalar(value >> 16 & 0xff)!) +
        String(describing: UnicodeScalar(value >> 8  & 0xff)!) +
        String(describing: UnicodeScalar(value & 0xff)!)
}

func sp78ToDouble(_ byte0: UInt8, _ byte1: UInt8) -> Double {
    return Double(Int16(byte0) << 8 + Int16(byte1)) / 256.0 // (2 ^ 8)
}

func fpe2ToDouble(_ byte0: UInt8, _ byte1: UInt8) -> Double {
    return Double(UInt16(byte0) << 8 + UInt16(byte1)) / 4.0 // (2 ^ 2)
}
