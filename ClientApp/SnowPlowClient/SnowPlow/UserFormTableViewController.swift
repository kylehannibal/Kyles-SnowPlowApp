//
//  UserFormTableViewController.swift
//  
//
//  Created by Kyle Hannibal on 1/14/19.
//

import UIKit
import CoreLocation
import Stripe

class UserFormTableViewController: UITableViewController {

   
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        submitButton.layer.cornerRadius = 8
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        if global.flagSubmitted {
            global.flagSubmitted = false
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func BackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    //submits a flag with the given details to the parse server
    
    
    @IBAction func submitTapped(_ sender: UIButton) {
        let size = sizeTextField.text
        let amount = amountTextField.text
        
        let addCardViewController = STPAddCardViewController(configuration: STPPaymentConfiguration(), theme: STPTheme())
        addCardViewController.delegate = self
        navigationController?.pushViewController(addCardViewController, animated: true)
        
        //Flags().createFlag(payment: NSString(string: amount!).doubleValue, size: NSString(string: size!).doubleValue, location: global.jobLocation)
        print("sent to server")
        //performSegue(withIdentifier: "FormToSuccess", sender: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserFormTableViewController: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        StripeClient.shared.completeCharge(with: token, amount: Int(amountTextField.text!)!) { result in
            switch result {
            case .success:
                completion(nil)
                
                let alertController = UIAlertController(title: "Congrats", message: "Your payment was successful!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
