//
//  DiskHandler.swift
//  SystemMonitor
//
//  Created by Jacques Lorentz on 04/07/2018.
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

import IOKit

public struct VolumesDisksInfos {
    let volumes: [VolumeInfos]
    let disks: [DiskInfos]
}

public struct ConvertedVolumeUsage {
    let total: Float
    let free: Float
    let available: Float
    let unit: String
}

// In blocks
public struct VolumeUsage {
    let blocksize: UInt32
    let iosize: Int32
    let blocks: UInt64
    let free: UInt64
    let available: UInt64
    let files: UInt64
    let filesfree: UInt64
    
    func convertTo(unit: String) throws -> ConvertedVolumeUsage {
        let pageSize: UInt64 = UInt64(blocksize)
        let mult = try getBytesConversionMult(unit: unit)
        return ConvertedVolumeUsage(
            total: (Float)(self.blocks * pageSize) / mult,
            free: (Float)(self.free * pageSize) / mult,
            available: (Float)(self.available * pageSize) / mult,
            unit: unit
        )
    }
}

public struct VolumeInfos {
    let filesystem: String
    let mountpoint: String
    let mountname: String
    let usage: VolumeUsage
}

public struct DiskUsage {
    let bytesread: UInt64
    let byteswritten: UInt64
    let operationsread: UInt64
    let operationswritten: UInt64
}

public struct DiskInfos {
    let name: String
    let blocksize: UInt32
    let size: UInt64
    let usage: DiskUsage
}

struct DiskHandler {
    static func getVolumesInfos() throws -> [VolumeInfos] {
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: URL(string: "file:///Volumes/")!,
            includingPropertiesForKeys: nil
        )
        let allVolumes = try fileURLs.map { (file: URL) -> VolumeInfos in
            let infos = try getStatfsInfo(file: file)
            var localfstypename = infos.f_fstypename
            var localmntonname = infos.f_mntonname
            var localmntfromname = infos.f_mntfromname
            return VolumeInfos(
                filesystem: withUnsafePointer(to: &localfstypename) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: infos.f_fstypename)) {
                        String(cString: $0)
                    }
                },
                mountpoint: withUnsafePointer(to: &localmntonname) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: infos.f_mntonname)) {
                        String(cString: $0)
                    }
                },
                mountname: withUnsafePointer(to: &localmntfromname) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: infos.f_mntfromname)) {
                        String(cString: $0)
                    }
                },
                usage: VolumeUsage(
                    blocksize: infos.f_bsize,
                    iosize: infos.f_iosize,
                    blocks: infos.f_blocks,
                    free: infos.f_bfree,
                    available: infos.f_bavail,
                    files: infos.f_files,
                    filesfree: infos.f_ffree
                )
            )
        }
        var mountnames = [String]()
        return allVolumes.filter({ (volume: VolumeInfos) -> Bool in
            if (mountnames.firstIndex(of: volume.mountname) != nil) {
                return false
            }
            mountnames.append(volume.mountname)
            return true
        })
    }
    
    static func getDisksInfos() throws -> [DiskInfos] {
        var list = [DiskInfos]()
        let drives = try getAllDrives()
        for drive in drives {
            let properties = try getProperties(drive: drive.parent)
            if (properties["Statistics"] == nil) {
                continue
            }
            let stat = properties["Statistics"] as! [String: Any]
            list.append(DiskInfos(
                name: drive.name,
                blocksize: drive.blockSize,
                size: drive.size,
                usage: DiskUsage(
                    bytesread: stat["Bytes (Read)"] as? UInt64 ?? 0,
                    byteswritten: stat["Bytes (Write)"] as? UInt64 ?? 0,
                    operationsread: stat["Operations (Read)"] as? UInt64 ?? 0,
                    operationswritten: stat["Operations (Write)"] as? UInt64 ?? 0
                )
            ))
        }
        return list
    }
}

func getStatfsInfo(file: URL) throws -> statfs {
    let statsptr = UnsafeMutablePointer<statfs>.allocate(capacity: 1)
    if (statfs(file.path, statsptr) != 0) {
        throw SystemMonitorError.statfsError(errno: stringErrno())
    }
    let res = Array(UnsafeBufferPointer(start: statsptr, count: 1))
    statsptr.deallocate()
    return res[0]
}

struct DriveStats {
    let parent: io_registry_entry_t
    let name: String
    let blockSize: UInt32
    let size: UInt64
}

func getProperties(drive: io_registry_entry_t) throws -> [String:Any] {
    var properties: Unmanaged<CFMutableDictionary>? = nil
    if (IORegistryEntryCreateCFProperties(drive, &properties, kCFAllocatorDefault, 0) != KERN_SUCCESS) {
        throw SystemMonitorError.IOKitError(error: "Device has no properties")
    }
    guard let prop = properties?.takeUnretainedValue() as? [String:Any] else {
        throw SystemMonitorError.IOKitError(error: "Device has no properties")
    }
    properties?.release()
    return prop
}

func getDriveStats(drive: io_registry_entry_t) throws -> DriveStats {
    var parent = io_registry_entry_t()
    if (IORegistryEntryGetParentEntry(drive, kIOServicePlane, &parent) != KERN_SUCCESS) {
        throw SystemMonitorError.IOKitError(error: "Device has no parent")
    }
    if (IOObjectConformsTo(parent, "IOBlockStorageDriver") == 0) {
        IOObjectRelease(parent)
        throw SystemMonitorError.IOKitError(error: "Device driver not conform")
    }
    let properties = try getProperties(drive: drive)
    return DriveStats(
        parent: parent,
        name: properties[kIOBSDNameKey] != nil ? properties[kIOBSDNameKey] as! String : "",
        blockSize: properties["Preferred Block Size"] as? UInt32 ?? 0,
        size: properties["Size"] as? UInt64 ?? 0
    )
}

func getAllDrives() throws -> [DriveStats] {
    var drives = [DriveStats]()
    guard var iomatch = IOServiceMatching("IOMedia") as? [String: Any] else {
        throw SystemMonitorError.IOKitError(error: "IOMedia")
    }
    iomatch.updateValue(kCFBooleanTrue, forKey: "Whole")
    var drivelist = io_iterator_t()
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, iomatch as CFDictionary, &drivelist) != KERN_SUCCESS) {
        throw SystemMonitorError.IOKitError(error: "IOMedia")
    }
    for _ in 0 ... 10 {
        let drive = IOIteratorNext(drivelist)
        if (drive != io_object_t(0)) {
            do {
                drives.append(try getDriveStats(drive: drive))
            } catch {}
        }
        IOObjectRelease(drive)
    }
    IOObjectRelease(drivelist)
    return drives
}
