//
//  TableViewController.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/2.
//  Copyright © 2020 cyc. All rights reserved.
//

import UIKit
import SwiftDataTables

class TableViewController: UIViewController, ViewControllerWithSpinner, SwiftDataTableDataSource, SwiftDataTableDelegate {
    
    public let spinner = SpinnerViewController()
    private var formattedData : [[String]] = []
    lazy var dataTable : SwiftDataTable = makeDataTable()
    @IBOutlet weak var DeleteButton: UIBarButtonItem!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(dataTable)
        
        DataManager.getTable(controller: self) { (error) in
            // if cannot fetch data, return to main page
            guard error == nil else{
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.getFormattedData()
            self.dataTable.reload()
            self.addConstraint()
            self.DeleteButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)], for: .normal)
        }
    }

    @IBAction func deleteData(_ sender: Any) {
        let alert = UIAlertController(title: "請選擇要刪除的資料", message: "", preferredStyle: .actionSheet)
        for (index,data) in DataManager.uploadedData.enumerated(){
//            let row = [id,date,amount, balance,category,shop,comment,cost,comsumeCategory]
            /// CHECK with the file
//            let message = "[📅\(data[1]),🏷\(data[4]),🏠\(data[5]),￡\(data[2]),💬\(data[6])]"
            let message = "ID: \(data[0])"
            alert.addAction(UIAlertAction(title: message, style: .default) { (action) in
                let id = data[0]
                AlertManager.showWithOkCancelDestructive(controller: self, title: "確定要刪除嗎？", message: "") {
                    (action) in
                    // get the latest table
                    DataManager.getTable(controller: self) { (error) in
                        guard error == nil else { return }
                        DataManager.csvTable.table.removeAll { $0[0] == id }
                        self.updateBalance(fromID: id)
                        DataManager.uploadTable(controller: self) {
                            DataManager.uploadedData.remove(at: index)
                            self.getFormattedData()
                            self.dataTable.reload()
                            AlertManager.showWithOK(controller: self, title: "已刪除資料", message: message)
                        }
                    }
                }
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateBalance(fromID fromIDStr: String){
        var baseId = 0
        guard let fromID = Int(fromIDStr.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            AlertManager.showWithOK(controller: self, title: "記帳表CSV文件ID無法解析", message: "請檢查記帳表ID欄位數字格式正確")
            return
        }
        while true{
            guard let id = Int(DataManager.csvTable.table[baseId][DataManager.id_index].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                AlertManager.showWithOK(controller: self, title: "記帳表CSV文件ID無法解析", message: "請檢查記帳表ID欄位數字格式正確")
                return
            }
            if id < fromID {
                break
            }
            baseId += 1
        }
        guard let baseBalance = Double(DataManager.csvTable.table[baseId][DataManager.balance_index].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "£"))) else{
                AlertManager.showWithOK(controller: self, title: "記帳表CSV文件餘額無法解析", message: "請檢查記帳表餘額欄位數字格式正確")
                return
        }
        var id = baseId - 1
        var balance = baseBalance
        while id >= 0{
            guard let amount = Double(DataManager.csvTable.table[id][DataManager.amount_index].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "£"))) else {
                AlertManager.showWithOK(controller: self, title: "記帳表CSV文件金額無法解析", message: "請檢查記帳表金額欄位數字格式正確")
                return
            }
            balance += amount
            DataManager.csvTable.table[id][DataManager.balance_index] = String(balance)
            id -= 1
        }
    }
    
    fileprivate func addConstraint() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    fileprivate func makeOptions() -> DataTableConfiguration{
        var options = DataTableConfiguration()
        options.defaultOrdering = DataTableColumnOrder(index: 0, order: .descending)
        options.shouldShowSearchSection = false
        options.shouldShowFooter = false
        options.shouldSectionHeadersFloat = true
        return options
    }
    
    fileprivate func makeDataTable() -> SwiftDataTable {
        let options = makeOptions()
        let dataTable = SwiftDataTable(dataSource: self, options: options)
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.delegate = self
        return dataTable
    }
    
    func numberOfColumns(in: SwiftDataTable) -> Int {
        return 9
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return formattedData.count
    }
    
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return formattedData[index].map(DataTableValueType.init)
    }
    
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return DataManager.headers[columnIndex]
    }
    
    /// Needs to be called just before everytime when dataTable.reload()
    func getFormattedData(){
        formattedData = DataManager.csvTable.table
        for i in 0...DataManager.headers.count - 1{
            var col = formattedData.getColumn(colID: i)
            var length = (col.map{ $0.count }.max(by: <) ?? 0) + 2
            length = length > 11 ? 11 : length
            col = col.map({ (cell) -> String in
                var str = cell.padding(toLength: length, withPad: " ", startingAt: 0)
                if str.count >= 11, !str.last!.isWhitespace {
                    str.append(contentsOf: "...")
                }
                return str
            })
            formattedData.setColumn(col: col, colID: i)
        }
    }
}
