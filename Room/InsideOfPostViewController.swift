//
//  InsideOfPostViewController.swift
//  Room
//
//  Created by Frank Zheng on 5/29/18.
//  Copyright © 2018 csmith. All rights reserved.
//

import UIKit

class InsideOfPostViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var post: Models.Post?
    var room: Models.Room?
    @IBOutlet weak var titleView: UILabelPadding!
    

    
    private var comments: [Models.Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        titleView.text = post?.body
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.addSubview(self.refreshControl)
        loadComments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadComments() {
        Firebase.fetchComments(self.post!) { comments in
            
            var newComments = [Models.Comment]()
            for comment in comments {
                if Current.user?.hidden[comment.commentID] == nil {
                    newComments.append(comment)
                }
            }
            self.comments = newComments.sorted(by: commentSort)
            self.tableView.reloadData()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(InsideOfRoomViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.flatSkyBlue
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.viewDidLoad()
        refreshControl.endRefreshing()
    }

    @IBAction func writeComment(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupID") as! PopupViewController
        
        popOverVC.roomID = room?.roomID
        popOverVC.postID = post?.postID
        popOverVC.isComment = true
        popOverVC.onDoneBlock = {
            self.loadComments()
        }
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    @IBAction func reportPost(_ sender: Any) {
        let confirmation = UIAlertController(title: "Are you sure you want to hide this post?", message: "Once hidden, the post will be hidden from you forever.", preferredStyle: UIAlertControllerStyle.alert)
        confirmation.view.tintColor = UIColor.flatMint
        confirmation.addAction(UIAlertAction(title: "Hide Post", style: UIAlertActionStyle.default, handler: { [weak confirmation] (_) in
            // Hide post
            Firebase.hideFromUser(contentID: (self.post?.postID)!, userID: (Current.user?.email)!)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        confirmation.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        let alert = UIAlertController(title: "Report Post", message: "Please tell us why you are reporting this post.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Description of problem"
        })
        alert.view.tintColor = UIColor.flatMint
        alert.addAction(UIAlertAction(title: "Report Post", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            // Store report
            Firebase.report(reportType: "post", reporterID: (Current.user?.email)!, reportedContentID: (self.post?.postID)!, posterID: (self.post?.posterID)!, report: (alert?.textFields![0].text)!)
        }))
         alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        
        let alertOptions = UIAlertController(title: self.post?.body, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertOptions.view.tintColor = UIColor.flatMint
        alertOptions.addAction(UIAlertAction(title: "Report Post", style: UIAlertActionStyle.default, handler: { [weak alertOptions] (_) in
            self.present(alert, animated: true, completion: nil)
        }))
        alertOptions.addAction(UIAlertAction(title: "Hide Post", style: UIAlertActionStyle.default, handler: { [weak alertOptions] (_) in
            self.present(confirmation, animated: true, completion: nil)
        }))
        alertOptions.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        
        self.present(alertOptions, animated: true, completion: nil)
    }
    
    func reportComment(index: IndexPath) {
        let alert = UIAlertController(title: "Report Comment", message: "Please tell us why you are reporting this comment.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Description of problem"
        })
        alert.view.tintColor = UIColor.flatMint
        alert.addAction(UIAlertAction(title: "Report Comment", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            // Store report
            Firebase.report(reportType: "comment", reporterID: (Current.user?.email)!, reportedContentID: (self.comments[index.row].commentID), posterID: (self.comments[index.row].posterID), report: (alert?.textFields![0].text)!)
        }))
         alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        let confirmation = UIAlertController(title: "Are you sure you want to hide this comment?", message: "Once hidden, the comment will be hidden from you forever.", preferredStyle: UIAlertControllerStyle.alert)
        confirmation.view.tintColor = UIColor.flatMint
        confirmation.addAction(UIAlertAction(title: "Hide Comment", style: UIAlertActionStyle.default, handler: { [weak confirmation] (_) in
            // Hide comment
            Firebase.hideFromUser(contentID: self.comments[index.row].commentID, userID: (Current.user?.email)!)
            self.comments.remove(at: index.row)
            self.tableView.reloadData()
        }))
        confirmation.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))

        let alertOptions = UIAlertController(title: self.comments[index.row].body, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertOptions.view.tintColor = UIColor.flatMint
        alertOptions.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        alertOptions.addAction(UIAlertAction(title: "Report Comment", style: UIAlertActionStyle.default, handler: { [weak alertOptions] (_) in
            self.present(alert, animated: true, completion: nil)
        }))
        alertOptions.addAction(UIAlertAction(title: "Hide Comment", style: UIAlertActionStyle.default, handler: { [weak alertOptions] (_) in
            self.present(confirmation, animated: true, completion: nil)
        }))


        self.present(alertOptions, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "backToRoom") {
            let vc = segue.destination as! InsideOfRoomViewController
            vc.room = self.room!
        }
    }
    
}

extension InsideOfPostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reportComment(index: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        cell.setComment(self.comments[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
}
