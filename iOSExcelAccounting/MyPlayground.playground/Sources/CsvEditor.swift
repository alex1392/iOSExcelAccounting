//
//  csvReader.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/4/30.
//  Copyright © 2020 cyc. All rights reserved.
//

import Foundation

public class CsvEditor{
    
    public enum error : Error {
        case InvalidUrl
        case InvalidEncoding
    }
    
    public var content : String = ""
    public var table : [[String]] = [[]]

    public init(){
        
    }
    
    public init(fileUrl: URL) throws {
        do {
            try parse(fileUrl: fileUrl)
        } catch {
            throw error
        }
    }
        
    public func parse(fileUrl: URL?) throws {
        guard let url = fileUrl else {
            throw error.InvalidUrl
        }
        let big5 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue)))
        guard let content = (try? String(contentsOf: url)) ?? (try? String(contentsOf: url, encoding: big5)) else {
            throw error.InvalidEncoding
        }
        self.content = content
        /// TODO: what if csv file is broken?
        self.table = content.components(separatedBy: "\r\n").map{$0.components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}}
    }
    
    public func getColumns(i:Int) -> [String]{
        var col_i : [String] = []
        for row in self.table {
            guard row.count > i else{
                continue
            }
            col_i.append(row[i])
        }
        return col_i
    }
    
    public func getRowsCols(rows:[Int], cols:[Int]) -> [[String]]{
        var array : [[String]] = []
        for row in rows{
            var new_row : [String] = []
            for col in cols{
                new_row.append(self.table[row][col])
            }
            array.append(new_row)
        }
        return array
    }
    
    public func printTable(){
        for row in table{
            for cell in row {
                print(cell + ",", terminator:"")
            }
            print("")
        }
    }
    
    public func updateContents(){
        // find the number of columns
        guard let colN = table.max(by: { $0.count < $1.count })?.count else {
            print("Error updating content.")
            return
        }
        // fill all rows
        table = table.map { (line) -> [String] in
            var output = line
            var n = colN - line.count
            while n > 0{
                output.append("")
                n -= 1
            }
            return output
        }
        
        content = "\u{feff}" + table.map{$0.joined(separator: ",")}.joined(separator: "\r\n")
        
    }
}
