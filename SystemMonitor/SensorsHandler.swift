//
//  SensorsHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 30/07/2018.
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

public struct FanSensor {
    let min: Float
    let max: Float
    let actual: Float
    let target: Float
}

public struct SensorsInfos {
    let fans: [FanSensor]
    let temperatures: [String:Float]
    let amperages: [String:Float]
    let voltages: [String:Float]
    let powers: [String:Float]
}

struct SensorsHandler {
    var sensors: [(UInt32, UInt32)]
    
    init() throws {
        self.sensors = [(UInt32, UInt32)]()
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
            let returnValue = IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize)
            if (returnValue != kIOReturnSuccess) {
                throw SystemMonitorError.SMCError(errorCode: returnValue)
            }
            let total = UInt32(outputStruct.bytes.0) << 24 + UInt32(outputStruct.bytes.1) << 16
                + UInt32(outputStruct.bytes.2) << 8 + UInt32(outputStruct.bytes.3)
            var i = UInt32(0)

            while (i < total) {
                inputStruct.data8 = 8
                inputStruct.data32 = i
                
                let returnVal0 = IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize)
                if (returnVal0 != kIOReturnSuccess) {
                    throw SystemMonitorError.SMCError(errorCode: returnVal0)
                }
                let key = outputStruct.key
                inputStruct.key = outputStruct.key
                inputStruct.keyInfo.dataSize = 4
                inputStruct.data8 = 9
                
                let returnVal1 = IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize)
                if (returnVal1 != kIOReturnSuccess) {
                    throw SystemMonitorError.SMCError(errorCode: returnVal1)
                }
                let dataType = outputStruct.keyInfo.dataType
                if (acceptKey(key: key, type: dataType)) {
                    self.sensors.append((key, dataType))
                }
                i += 1
            }
            IOServiceClose(ioc)
        }
    }
    
    func getSensorsInfos() throws -> SensorsInfos {
        var ioc = io_connect_t()
        let service: io_object_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleSMC"))
        var sensors = [String:Float]()
        var fans = [UInt32:[UInt32:Float]]()
        
        if (service != IO_OBJECT_NULL) {
            IOServiceOpen(service, mach_task_self_, 0, &ioc)
            var inputStruct = SMCParamStruct()
            var outputStruct = SMCParamStruct()
            let inputStructSize = MemoryLayout<SMCParamStruct>.stride
            var outputStructSize = MemoryLayout<SMCParamStruct>.stride
            for s in self.sensors {
                let letter = s.0 >> 24
                inputStruct.key = s.0
                inputStruct.keyInfo.dataSize = 4
                inputStruct.data8 = 5
                
                let returnVal0 = IOConnectCallStructMethod(ioc, 2, &inputStruct, inputStructSize, &outputStruct, &outputStructSize)
                if (returnVal0 != kIOReturnSuccess) {
                    throw SystemMonitorError.SMCError(errorCode: returnVal0)
                }
                let data = outputStruct.bytes
                if (letter != 0x46) {
                    sensors[uint32ToString(value: s.0)] = (s.1 == 1718383648 ? fltToFloat(data.0, data.1, data.2, data.3) : sp78ToFloat(data.0, data.1))
                } else {
                    let nb = (s.0 >> 16 & 0xFF) - 0x30 // 0
                    if (fans[nb] == nil) {
                        fans[nb] = [UInt32:Float]()
                    }
                    fans[nb]![s.0 & 0xFFFF] = fpe2ToFloat(data.0, data.1)
                }
            }
            IOServiceClose(ioc)
        }
        
        let fanSensors = fans.map({ (arg0) -> FanSensor in
            let (_, value) = arg0
            return FanSensor(
                min: value[0x4D6e]!,
                max: value[0x4D78]!,
                actual: value[0x4163]!,
                target: value[0x5467]!
            )
        })

        return SensorsInfos(
            fans: fanSensors,
            temperatures: sensors.filter({ $0.key.first == "T" }),
            amperages: sensors.filter({ $0.key.first == "I" }),
            voltages: sensors.filter({ $0.key.first == "V" }),
            powers: sensors.filter({ $0.key.first == "P" })
        )
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

func sp78ToFloat(_ byte0: UInt8, _ byte1: UInt8) -> Float {
    return Float(Int16(byte0) << 8 + Int16(byte1)) / 256.0 // (2 ^ 8)
}

func fpe2ToFloat(_ byte0: UInt8, _ byte1: UInt8) -> Float {
    return Float(UInt16(byte0) << 8 + UInt16(byte1)) / 4.0 // (2 ^ 2)
}

func fltToFloat(_ byte0: UInt8, _ byte1: UInt8, _ byte2: UInt8, _ byte3: UInt8) -> Float {
    return Float(bitPattern: UInt32(fromBytes: (byte3, byte2, byte1, byte0)))
}

func acceptKey(key: UInt32, type: UInt32) -> Bool {
    let flt = 1718383648
    let sp78 = 1936734008
    let fpe2 = 1718641970
    let letter = key >> 24
    return (
        letter == 0x56 && type == flt // V - flt
            || letter == 0x54 && type == sp78 // T - sp78
            || letter == 0x49 && type == flt // I - flt
            || letter == 0x50 && (type == flt || type == sp78) // P - flt & sp78
            || letter == 0x46 && type == fpe2 // F - fpe2
    )
}
