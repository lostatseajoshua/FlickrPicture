//
//  UIViewController+Ext.swift
//  FlickerPicture
//
//  Created by Joshua Alvarado on 11/4/15.
//  Copyright © 2015 Joshua Alvarado. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}