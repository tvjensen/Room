//
//  MyRoomsViewController.swift
//  Room
//
//  Created by Rick Duenas on 5/8/18.
//  Copyright © 2018 csmith. All rights reserved.
//

import Foundation
import UIKit

class MyRoomsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        Firebase.getMyRooms("test") { rooms in
            print(rooms)
            print(rooms[0].roomID)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CreateRoomButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create New Room", message: "Name your new room whatever you would like!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Room name"
        })
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            let name = (alert?.textFields![0].text)!
            Firebase.createRoom(name)
        }))
       
        self.present(alert, animated: true, completion: nil)
    }
    
    func createRoom(newRoomName: String) {
        let timestamp = NSDate().timeIntervalSince1970
        let user = "test"
        let latitude = 1.0
        let longitude = 1.0
        
        
        Firebase.createRoom(newRoomName, user, timestamp, latitude, longitude) { success in
            if success == false {
                print("Didn't create room successfully.")
            }
        }
    }
    
}
