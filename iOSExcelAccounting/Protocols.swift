//
//  Protocols.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/3.
//  Copyright © 2020 cyc. All rights reserved.
//

import Foundation
import UIKit

public protocol ViewControllerWithSpinner : UIViewController {
    var spinner : SpinnerViewController { get }
}
