//
//  MyRoomsViewController.swift
//  Room
//
//  Created by Rick Duenas on 5/8/18.
//  Copyright © 2018 csmith. All rights reserved.
//

import Foundation
import UIKit

class MyRoomsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    private var rooms: [Models.Room] = []
    private var filteredRooms: [Models.Room] = []
    
    private var selectedRoom: Models.Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Rooms"

        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        Firebase.getMyRooms() { rooms in
            self.rooms = rooms
            self.filteredRooms = rooms
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Firebase.getMyRooms() { rooms in
            self.rooms = rooms
            self.filteredRooms = rooms
            self.tableView.reloadData()
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            let name = (alert?.textFields![0].text)!
            Firebase.createRoom(name) { newRoom in
                self.rooms.insert(newRoom, at:0)
                self.filteredRooms.insert(newRoom, at:0)
                self.tableView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "insideOfRoomSegue") {
            let vc = segue.destination as! InsideOfRoomViewController
            vc.room = selectedRoom!
        }
    }
    
}

extension MyRoomsViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue to the inside rooms view
        self.selectedRoom = self.filteredRooms[indexPath.row]
        self.performSegue(withIdentifier: "insideOfRoomSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "roomPreviewCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredRooms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    private func parseTime(_ time: Double) -> String {
        // Get the current time in Date()
        let curTime = Date()
        // Get the time of the post in terms of Date(), i.e. convert from seconds to Date()
        let postedTime = Date(timeIntervalSince1970: time)
        // Find the difference between the two dates
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear, .year], from: postedTime, to: curTime)
        // if number of years is 0:
        if components.year == 0{
            if components.weekOfYear == 0{
                if components.day == 0{
                    if components.hour == 0{
                        if components.minute == 0{
                            return "Just now"
                        } else{
                            return "\(components.minute!)m ago"
                        }
                    } else{
                        return "\(components.hour!)h ago"
                    }
                } else{
                    return "\(components.day!)d ago"
                }
            } else{
                return "\(components.weekOfYear!)w ago"
            }
        } else{
            return "\(components.year!)y ago"
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MyRoomPreviewTableViewCell
        let room = self.filteredRooms[indexPath.row]
        cell.nameLabel.text = room.name
        cell.nMemLabel.text = "\(room.numMembers) member" + (room.numMembers > 1 ? "s" : "")
        cell.lastActivityLabel.text = "Last active " + parseTime(room.lastActivity)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredRooms = searchText.isEmpty ? self.rooms : self.rooms.filter { (item : Models.Room) -> Bool in
            // include in filteredRooms array items from rooms array whose name matches searchText
            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale : nil) != nil
            
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
