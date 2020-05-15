//
//  DataManager.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/1.
//  Copyright © 2020 cyc. All rights reserved.
//

import Foundation
import UIKit

public class DataManager {
    public enum error : Error {
        case FetchListFailed
        case FetchTableFailed
        case ParseListFailed
        case ParseTableFailed
    }
    
    public static let csvList = CsvEditor()
    public static let csvTable = CsvEditor()
    
    public static var csvTableID : String = ""
    public static var shops : [String] = []
    public static var categories : [String] = []
    public static var comsumeCategories : [String] = []
    public static var headers : [String] = []
    public static var uploadedData : [[String]] = []

    public static func getList(controller: ViewControllerWithSpinner, completion: @escaping(Error?) -> Void) {
        controller.spinner.start(container: controller) // start spinner
        // Search for the excel file
        GraphManager.instance.searchDrive(query: "Alex", selects: [.id, .name, .downloadUrl], completion: {
            (json, error) in
            guard let json = json, error == nil else {
                AlertManager.showWithOK(controller: controller, title: "搜尋OneDrive時出錯", message: "錯誤訊息: \(error.debugDescription)")
                controller.spinner.stop()
                completion(error)
                return
            }
            // get the url strings
            let UrlString_csvList = json["value"].arrayValue.first{ $0["name"].stringValue.contains("清單.csv") }?[GraphManager.selectType.downloadUrl.rawValue].stringValue ?? ""
            guard let url_csvList = URL(string: UrlString_csvList) else {
                AlertManager.showWithOK(controller: controller, title: "無法取得清單", message: "請檢查OneDrive中的清單是否存在")
                controller.spinner.stop()
                completion(self.error.FetchListFailed)
                return
            }
            // Parse the csv file
            guard let _ = try? csvList.parse(fileUrl: url_csvList) else {
                AlertManager.showWithOK(controller: controller, title: "解析清單出錯", message: "請檢查清單格式是否符合csv格式，且檔案編碼是否為UTF-8或Big-5")
                controller.spinner.stop()
                completion(self.error.ParseListFailed)
                return
            }

            // Get Comsumable List
            csvList.table.removeFirst()
            shops = csvList.getColumns(i: 0).filter{!$0.isEmpty}
            categories = csvList.getColumns(i: 1).filter{!$0.isEmpty}
            comsumeCategories = csvList.getColumns(i: 2).filter{!$0.isEmpty}

            controller.spinner.stop()
            completion(nil)
        })
    }
    
    public static func getTable(controller: ViewControllerWithSpinner, completion: @escaping(Error?) -> Void) {
            controller.spinner.start(container: controller) // start spinner
            // Search for the excel file
            GraphManager.instance.searchDrive(query: "Alex", selects: [.id, .name, .downloadUrl], completion: {
                (json, error) in
                guard let json = json, error == nil else {
                    AlertManager.showWithOK(controller: controller, title: "搜尋OneDrive時出錯", message: "錯誤訊息: \(error.debugDescription)")
                    controller.spinner.stop()
                    completion(error)
                    return
                }
                // get the url strings
                let UrlString_csvTable = json["value"].arrayValue.first{ $0["name"].stringValue.contains("記帳表.csv") }?[GraphManager.selectType.downloadUrl.rawValue].stringValue ?? ""
                // save TableID for later usage (when updating the table)
                csvTableID = json["value"].arrayValue.first{ $0["name"].stringValue.contains("記帳表.csv") }?[GraphManager.selectType.id.rawValue].stringValue ?? ""
                guard let url_csvTable = URL(string: UrlString_csvTable) else {
                    AlertManager.showWithOK(controller: controller, title: "無法取得記帳表", message: "請檢查OneDrive中的記帳表是否存在")
                    controller.spinner.stop()
                    completion(self.error.FetchTableFailed)
                    return
                }
                // Parse the csv file
                guard let _ = try? csvTable.parse(fileUrl: url_csvTable) else {
                    AlertManager.showWithOK(controller: controller, title: "解析記帳表出錯", message: "請檢查記帳表格式是否符合csv格式，且檔案編碼是否為UTF-8或Big-5")
                    controller.spinner.stop()
                    completion(self.error.ParseTableFailed)
                    return
                }
                // get headers
                headers = csvTable.table.removeFirst()

                controller.spinner.stop()
                completion(nil)
            })
        }
    
    public static func uploadTable(controller: ViewControllerWithSpinner, completion: @escaping() -> Void = {}){
        csvTable.table.insert(DataManager.headers, at: 0) //temperary add header back
        csvTable.updateContents()
        csvTable.table.removeFirst() // remove header again
        // upload csv file
        controller.spinner.start(container: controller)
        GraphManager.instance.updateFile(id: DataManager.csvTableID, content: DataManager.csvTable.content ) { (json, error) in
            guard let _ = json, error == nil else{
                AlertManager.showWithOK(controller: controller, title: "上傳失敗", message: "錯誤訊息： \(error.debugDescription)")
                return
            }
            completion()
            controller.spinner.stop()
        }
    }
    
}
