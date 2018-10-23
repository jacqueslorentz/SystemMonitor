//
//  NetworkHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 17/07/2018.
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

import Darwin

public struct InterfaceAddressFlags {
    public let iff_up: Bool
    public let iff_broadcast: Bool
    public let iff_debug: Bool
    public let iff_loopback: Bool
    public let iff_pointopoint: Bool
    public let iff_notrailers: Bool
    public let iff_running: Bool
    public let iff_noarp: Bool
    public let iff_promisc: Bool
    public let iff_allmulti: Bool
    public let iff_oactive: Bool
    public let iff_simplex: Bool
    public let iff_link0: Bool
    public let iff_link1: Bool
    public let iff_link2: Bool
    public let iff_altphys: Bool
    public let iff_multicast: Bool
}

public struct InterfaceAddress {
    public let address: String
    public let netmask: String
    public let destaddress: String
    public let type: String
    public let flags: InterfaceAddressFlags
}

public struct NetworkInterfaceInfos {
    public let name: String
    public let bytessend: UInt
    public let bytesreceived: UInt
    public let addresses: [InterfaceAddress]
}

struct NetworkHandler {
    static func getNetworkInfos() throws -> [NetworkInterfaceInfos] {
        let interfaces = try getInterfaceIO(interfaces: try getInterfaceNames())
        let ifaddresses = try getIFAddresses()
        return interfaces.map { (interface: NetworkInterfaceInfos) -> NetworkInterfaceInfos in
            return NetworkInterfaceInfos(
                name: interface.name,
                bytessend: interface.bytessend,
                bytesreceived: interface.bytesreceived,
                addresses: ifaddresses[interface.name] ?? [InterfaceAddress]()
            )
        }
    }
}

func getInterfaceNames() throws -> [String] {
    let request = [CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST, 0]
    var count = 0
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), nil, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: "net...", errno: stringErrno())
    }
    let ptr = UnsafeMutablePointer<Int8>.allocate(capacity: count)
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), ptr, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: "net...", errno: stringErrno())
    }
    var interfaces = [String]()
    var cursor = 0
    while (cursor < count) {
        cursor = ptr.advanced(by: cursor).withMemoryRebound(to: if_msghdr.self, capacity: MemoryLayout<if_msghdr>.size) { ifm_ptr -> Int in
            if (integer_t(ifm_ptr.pointee.ifm_type) == RTM_IFINFO) {
                let interface = ifm_ptr.advanced(by: 1).withMemoryRebound(to: Int8.self, capacity: 20) { name_ptr -> String in
                    let size = Int(name_ptr.advanced(by: 5).pointee)
                    let buf = name_ptr.advanced(by: 8)
                    buf.advanced(by: size).pointee = 0
                    return String(cString: buf)
                }
                if (!interface.isEmpty) {
                    interfaces.append(interface)
                }
            }
            return cursor + Int(ifm_ptr.pointee.ifm_msglen)
        }
    }
    ptr.deallocate()
    return interfaces
}


func getInterfaceIO(interfaces: [String]) throws -> [NetworkInterfaceInfos] {
    let request = [CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0]
    var count = 0
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), nil, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: "net...", errno: stringErrno())
    }
    let ptr = UnsafeMutablePointer<Int8>.allocate(capacity: count)
    if (sysctl(UnsafeMutablePointer(mutating: request), UInt32(request.count), ptr, &count, nil, 0) != 0) {
        throw SystemMonitorError.sysctlError(arg: "net...", errno: stringErrno())
    }
    var io = [NetworkInterfaceInfos]()
    var cursor = 0
    var index = 0
    while (cursor < count) {
        cursor = ptr.advanced(by: cursor).withMemoryRebound(to: if_msghdr.self, capacity: MemoryLayout<if_msghdr>.size) { ifm_ptr -> Int in
            if integer_t(ifm_ptr.pointee.ifm_type) == RTM_IFINFO2 {
                ifm_ptr.withMemoryRebound(to: if_msghdr2.self, capacity: MemoryLayout<if_msghdr2>.size) { ifm_ptr in
                    let pd = ifm_ptr.pointee
                    
                    // SEE WHAT ELSE WE CAN GET
                    // print(pd.ifm_flags)
                    
                    if index < interfaces.count {
                        io.append(NetworkInterfaceInfos(name: interfaces[index], bytessend: UInt(pd.ifm_data.ifi_obytes), bytesreceived: UInt(pd.ifm_data.ifi_ibytes), addresses: [InterfaceAddress]()))
                    }
                    index += 1
                }
            }
            return cursor + Int(ifm_ptr.pointee.ifm_msglen)
        }
    }
    ptr.deallocate()
    return io
}

func getNameFromIfAddress(ptr: UnsafeMutablePointer<sockaddr>?) -> String {
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    if (ptr != nil && getnameinfo(ptr, socklen_t(ptr!.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0) {
        return String(cString: hostname)
    }
    return ""
}

func getAddressType(ptr: UnsafeMutablePointer<sockaddr>?) -> String {
    if (ptr == nil) {
        return ""
    }
    switch ptr!.pointee.sa_family {
    case UInt8(AF_INET):
        return "ipv4"
    case UInt8(AF_INET6):
        return "ipv6"
    case UInt8(AF_LINK):
        return "ether"
    default:
        return String(ptr!.pointee.sa_family)
    }
}

func checkIfFlag(value: Int32, flag: Int32) -> Bool {
    return value & flag == flag
}

func getIFAddresses() throws -> [String:[InterfaceAddress]] {
    var addresses = [String:[InterfaceAddress]]()
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    if (getifaddrs(&ifaddr) != 0 || ifaddr == nil) {
        throw SystemMonitorError.getifaddrsError()
    }
    for ptr in sequence(first: ifaddr!, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        let name = String(cString: ptr.pointee.ifa_name)
        if (!addresses.contains(where: { (args) -> Bool in
            let (key, _) = args
            return key == name
        })) {
            addresses.updateValue([InterfaceAddress](), forKey: name)
        }
        addresses[name]?.append(InterfaceAddress(
            address: getNameFromIfAddress(ptr: ptr.pointee.ifa_addr),
            netmask: getNameFromIfAddress(ptr: ptr.pointee.ifa_netmask),
            destaddress: getNameFromIfAddress(ptr: ptr.pointee.ifa_dstaddr),
            type: getAddressType(ptr: ptr.pointee.ifa_addr),
            flags: InterfaceAddressFlags(
                iff_up: checkIfFlag(value: flags, flag: IFF_UP),
                iff_broadcast: checkIfFlag(value: flags, flag: IFF_BROADCAST),
                iff_debug: checkIfFlag(value: flags, flag: IFF_DEBUG),
                iff_loopback: checkIfFlag(value: flags, flag: IFF_LOOPBACK),
                iff_pointopoint: checkIfFlag(value: flags, flag: IFF_POINTOPOINT),
                iff_notrailers: checkIfFlag(value: flags, flag: IFF_NOTRAILERS),
                iff_running: checkIfFlag(value: flags, flag: IFF_RUNNING),
                iff_noarp: checkIfFlag(value: flags, flag: IFF_NOARP),
                iff_promisc: checkIfFlag(value: flags, flag: IFF_PROMISC),
                iff_allmulti: checkIfFlag(value: flags, flag: IFF_ALLMULTI),
                iff_oactive: checkIfFlag(value: flags, flag: IFF_OACTIVE),
                iff_simplex: checkIfFlag(value: flags, flag: IFF_SIMPLEX),
                iff_link0: checkIfFlag(value: flags, flag: IFF_LINK0),
                iff_link1: checkIfFlag(value: flags, flag: IFF_LINK1),
                iff_link2: checkIfFlag(value: flags, flag: IFF_LINK2),
                iff_altphys: checkIfFlag(value: flags, flag: IFF_ALTPHYS),
                iff_multicast: checkIfFlag(value: flags, flag: IFF_MULTICAST))
            )
        )
    }
    freeifaddrs(ifaddr)
    return addresses
}
