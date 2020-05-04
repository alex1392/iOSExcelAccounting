//
//  AlertManager.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/1.
//  Copyright © 2020 cyc. All rights reserved.
//

import UIKit
import Foundation

public class AlertManager{
    
    /// show alert with OK and cancel button
    public static func showWithOkCancel(controller: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    /// show alert with ok button without any handler
    public static func showWithOK(controller: UIViewController, title: String, message: String){
        showWithCustom(controller: controller, title: title, message: message, actionTitle: "OK")
    }
    
    /// show alert with custom button
    public static func showWithCustom(controller: UIViewController, title: String, message: String, actionTitle: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
