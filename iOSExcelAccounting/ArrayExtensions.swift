//
//  ArrayExtensions.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/3.
//  Copyright © 2020 cyc. All rights reserved.
//

import Foundation

extension Array where Element == Array<String> {
    mutating func removeColumn(colID:Int) {
        for row in 1 ... self.count - 1{
            self[row].remove(at: colID)
        }
    }
    
    func getColumn(colID:Int) -> [String]{
        var col_i : [String] = []
        for row in self {
            guard row.count > colID else{
                continue
            }
            col_i.append(row[colID])
        }
        return col_i
    }
    
    mutating func setColumn(col:[String], colID:Int) {
        for rowID in 0...self.count - 1 {
            self[rowID][colID] = col[rowID]
        }
    }
    
    func printTable(){
        for row in self{
            for cell in row {
                print(cell + ",", terminator:"")
            }
            print("")
        }
    }
    
    func getRowsCols(rows:[Int], cols:[Int]) -> [[String]]{
        var array : [[String]] = []
        for row in rows{
            var new_row : [String] = []
            for col in cols{
                new_row.append(self[row][col])
            }
            array.append(new_row)
        }
        return array
    }
}
