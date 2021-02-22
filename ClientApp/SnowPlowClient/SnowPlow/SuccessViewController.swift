//
//  successViewController.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 2/14/19.
//  Copyright © 2019 Kyle Hannibal. All rights reserved.
//

import Foundation
import UIKit

class SuccessViewController: UIViewController{
    
    @IBOutlet weak var returnToMapButton: UIButton!
    
    override func viewDidLoad() {
        //unrecognized selector sent to instance
        super.viewDidLoad()
    }
    @IBAction func returnToMap(_ sender: UIButton) {
        global.flagSubmitted = true
        dismiss(animated: false, completion: nil)
    }
}
