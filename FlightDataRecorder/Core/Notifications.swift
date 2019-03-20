//
//  CoreLibrary.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 29/11/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit

class Notifications: NSObject {
    
    static func Alert(message: String, context: UIViewController) {
        let alertController = UIAlertController(title: "Error", message:
            "\(message)", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        context.present(alertController, animated: true, completion: nil)
    }
}
