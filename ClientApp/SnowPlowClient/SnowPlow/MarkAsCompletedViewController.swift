//
//  MarkAsCompletedViewController.swift
//  SnowPlow
//
//  Created by Michael Baraty on 1/14/19.
//  Copyright © 2019 Baraty Hannibal Enterprises. All rights reserved.
//

import UIKit

class MarkAsCompletedViewController: UIViewController {

    @IBOutlet weak var completedButton: UIButton!
    
    //Marks the flag as complete
    @IBAction func completedButtonTapped(_ sender: UIButton) {
        Flags().markAsComplete(objid: global.objIDJob)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //marks the job as accepted as soon as the view loads
        Flags().markAsAccepted(objid: global.objIDJob)
        
        completedButton.layer.cornerRadius = 16
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
