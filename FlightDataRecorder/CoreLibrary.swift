//
//  CoreLibrary.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 29/11/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit

var Core: CoreLibrary = CoreLibrary()

class CoreLibrary: NSObject {
    func alertView(message: String, context: UIViewController) {
        let alertController = UIAlertController(title: "Error", message:
            "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        context.present(alertController, animated: true, completion: nil)
    }
}
