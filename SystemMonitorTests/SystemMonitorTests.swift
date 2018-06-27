//
//  SystemMonitorTests.swift
//  SystemMonitorTests
//
//  Created by Jacques Lorentz on 24/06/2018.
//  Copyright © 2018 Jacques Lorentz. All rights reserved.
//

import XCTest
@testable import SystemMonitor

class SystemMonitorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPourt() {
        let infos = SystemMonitor().getMemoryInfos()
        infos.print()
        
        let ram = infos.ramUsage
        let swap = infos.swapUsage
        
        print(ram)
        print(ram.convertTo(unit: "B"))
        print(ram.convertTo(unit: "KB"))
        print(ram.convertTo(unit: "MB"))
        print(ram.convertTo(unit: "GB"))
        
        print(swap)
        print(swap.convertTo(unit: "B"))
        print(swap.convertTo(unit: "KB"))
        print(swap.convertTo(unit: "MB"))
        print(swap.convertTo(unit: "GB"))
        

    }
    
}
