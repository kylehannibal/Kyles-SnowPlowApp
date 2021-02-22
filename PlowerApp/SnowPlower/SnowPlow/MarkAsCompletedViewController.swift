//
//  MarkAsCompletedViewController.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 1/14/19.
//  Copyright © 2019 Hannibal Enterprises. All rights reserved.
//

import UIKit

class MarkAsCompletedViewController: UIViewController {

    @IBOutlet weak var completedButton: UIButton!
    
    //Marks the flag as complete
    @IBAction func completedButtonTapped(_ sender: UIButton) {
        Flags().markAsComplete(objid: global.objIDJob)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //marks the job as accepted as soon as the view loads
        Flags().markAsAccepted(objid: global.objIDJob)
        completedButton.layer.cornerRadius = 16
        
        let alert = UIAlertController(title: nil, message: "Please press the complete button ONLY upon completion", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel) { (alert) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true)
        
        //NotificationCenter.default.addObserver(self, selector:#selector(MarkAsCompletedViewController.onOpenApp), name:UIApplication.willEnterForegroundNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
