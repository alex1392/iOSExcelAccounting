//
//  iOSExcelAccountingTests.swift
//  iOSExcelAccountingTests
//
//  Created by cyc on 2020/4/30.
//  Copyright © 2020 cyc. All rights reserved.
//

import XCTest
import iOSExcelAccounting
import SwiftyJSON

enum MyError: Error {
    case runtimeError(String)
}

class iOSExcelAccountingTests: XCTestCase {

    let editor : CsvEditor = CsvEditor()
    let graphManager : GraphManager = GraphManager.instance
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let filePath = "/Users/cyc/OneDrive/未命名檔案夾/Alex^L0Coco家庭記賬_清單.csv"
        try! editor.parse(fileUrl: URL(fileURLWithPath: filePath))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPrintTable() throws {
        editor.printTable()
    }
    
    func testUpdate() throws {
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
