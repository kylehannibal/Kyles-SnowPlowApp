//
//  UserRequestsTableViewCell.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 1/16/19.
//  Copyright © 2019 Hannibal Enterprises. All rights reserved.
//

import UIKit

class UserRequestsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var objID: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Updates the cells with ObjectID and Job Status. 
    func update(with id: String) {
        objID.text = id
        let stat = Flags().checkStatus(ObjId: id)
        let accepted = Array(stat.keys)
        let completed = Array(stat.values)
        print("called update")
        
        if !accepted[0] {
            status.text = "Pending"
        } else if accepted[0] && !completed[0] {
            status.text = "Accepted"
        } else {
            status.text = "Completed"
        }
        
    }

}
