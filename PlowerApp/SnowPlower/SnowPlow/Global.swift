//
//  Globals.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 1/15/19.
//  Copyright © 2019 Hannibal Enterprises. All rights reserved.
//

import Foundation
import CoreLocation
import Parse

class Global {
    var jobLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var objIDJob: String = ""
    var userType = ""
    
    //Everything up to line 48 is dedicated to long term memory
//    struct PropertyKey {
//        static let id = "ID"
//    }
//
//    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("IDs")
//
//    func loadFromFile() -> [String]?  {
//        return NSKeyedUnarchiver.unarchiveObject(withFile: Global.ArchiveURL.path) as? [String]
//    }
//
//    func saveToFile(flags: [String]) {
//        NSKeyedArchiver.archiveRootObject(flags, toFile: Global.ArchiveURL.path)
//    }
//
//    required convenience init?(coder aDecoder: NSCoder) {
//
//        guard (aDecoder.decodeObject(forKey: PropertyKey.id) as? String) != nil
//            else {
//                return nil
//        }
//
//        self.init(coder: aDecoder)
//
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(myFlags, forKey: PropertyKey.id)
//    }

//gets flags. Maybe better name would be getFlags
    func checkFlags() -> [String]{
        var statusList: [String] = []
        let query = PFQuery(className: "Flags")
        query.whereKey("requestBy", equalTo: PFUser.current()?.objectId! as Any)
        do{
            let myFlags = try query.findObjects()
            for item in myFlags{
                statusList.append(item.objectId!)
            }
        } catch{
            print("error! Flags could not be received")
        }
        return statusList
    }
    func setUserType(type: String, logout: Bool){
        guard let me = PFUser.current() else {
            
            return
        }
        me["userType"] = type
        if logout == false{
            self.userType = type
            do{
                try me.save()
            }catch{
                print("error saving type in global")
            }
        }
    }
    func myType() -> String{
        return userType
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        self.jobLocation = location
    }
    
    func setObjIDJob(id: String) {
        self.objIDJob = id
    }
    
    func checkLogin(currentView: UIViewController){
        guard PFUser.current() != nil else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let logInViewController = storyBoard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
            currentView.present(logInViewController, animated: true, completion: nil)
            return
        }
        return
    }
    
    
}


