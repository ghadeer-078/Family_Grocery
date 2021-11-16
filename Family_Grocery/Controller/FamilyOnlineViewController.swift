//
//  FamilyOnlineViewController.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth


class FamilyOnlineViewController: UIViewController {

    
    @IBOutlet weak var familyTableView: UITableView!
    
    let userRef = Database.database().reference(withPath: "online")
    var userRefObservers: [DatabaseHandle] = []
    var user: [User] = []
    var currentUser:[String] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Family Online"
        
        familyTableView.dataSource = self
        familyTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
                let childAdd = userRef.observe(.childAdded, with: { [weak self]
                    snap in
                    guard let emailToFind = snap.value as? String, let self = self else{
                        return
                    }
                    for (index, email) in
                    
                    self.currentUser.enumerated()
                    where email == emailToFind{
                        
                        let indexPath = IndexPath(row: index, section: 0)
                        self.user.remove(at: index)
                        
                        self.familyTableView.insertRows(at: [indexPath], with: .top)
                        
                    }
                })
        
                userRefObservers.append(childAdd)
        }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        userRefObservers.forEach(userRef.removeObserver(withHandle:))
        userRefObservers = []
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        // show alert
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: {
            [weak self] _ in
            
            guard self != nil else {
                    return
                }
                
                guard let user = Auth.auth().currentUser else{
                    return
                }
                
                let online = Database.database().reference(withPath: "online/\(user.uid)")
                
                online.removeValue(completionBlock: {
                    error, _ in
                    if let error = error{
                        print("removeing online failed:\(error)")
                        return
                    }
                })
            
                do{
                    try FirebaseAuth.Auth.auth().signOut()

                let VC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self?.navigationController?.pushViewController(VC, animated: true)
                
            }
            catch{
                print("faild to log out!")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancele",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
        
    }
}



extension FamilyOnlineViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = familyTableView.dequeueReusableCell(withIdentifier: "familyCell", for: indexPath)
        cell.textLabel?.text = currentUser[indexPath.row]
        return cell
        
    }
}
