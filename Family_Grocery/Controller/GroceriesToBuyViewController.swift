//
//  SingupViewController.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftUI

class GroceriesToBuyViewController: UIViewController {
    
    @IBOutlet weak var groceryTableView: UITableView!
    private var groceryItem = [GroceryItem]()
    
    let userRef = Database.database().reference(withPath: "online")
    var userRefObservers: [DatabaseHandle] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Grocery to Buy"

        reload()
        
        groceryTableView.delegate = self
        groceryTableView.dataSource = self
        
        let online = UIBarButtonItem(title: "Online", style: .plain , target: self, action: #selector(online))
        navigationItem.leftBarButtonItem = online
        
    }
    
    func reload() {
        let data = Database.database().reference().child("grocery-list-items")
        data.observe(DataEventType.value, with:{(snapshote) in
            if snapshote.childrenCount>0{
                self.groceryItem.removeAll()
                for item in snapshote.children.allObjects as![DataSnapshot] {
                    let object = item.value as? [String:AnyObject]
                    let name = object?["name"]
                    let addedby = object?["addedByUser"]
                    
                    let itemobjct = GroceryItem(name: name as! String, addedByUser: addedby as! String)
                    
                    self.groceryItem.append(itemobjct)
                }
                self.groceryTableView.reloadData()
            }
        } )
    }
    
    @IBAction func ADD(_ sender: Any) {
        
        showInputDialog(title: "New Grocery",
                        subtitle: "Add a new grocery",
                        actionHandler:
                            { [weak self] name in
            
            DatabaseManger.shared.creatNewGrocery(with: User.currentId(), name: name ?? "", completion: {_ in })
            
            self?.groceryTableView.reloadData()
        })
    }
    
    
    
    @objc func online(){

        self.performSegue(withIdentifier: "seageFromB", sender: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = true
        
//        let currentUserRef = self.userRef.child(User.currentId())
//                currentUserRef.setValue(User.currentUser()!.email)
//                currentUserRef.onDisconnectRemoveValue()
//
//        let users = userRef.observe(.value, with: {
//            snapshot in
//
//            //let onlineUserCount =
//            if snapshot.exists(){
//                self.onlineUserCount.title = snapshot.childrenCount.description
//            }
//            else{
//                self.onlineUserCount.title = "0"
//            }
//        })
//
//        userRefObservers.append(users)
    }
    
    
    private func showInputDialog(title: String? = nil,
                                 subtitle: String? = nil,
                                 actionTitle: String? = "Save",
                                 cancelTitle: String? = "Cancel",
                                 name: String? = nil,
                                 inputPlaceholder: String? = nil,
                                 cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                                 actionHandler: ((_ text: String?) -> Void)? = nil ) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.text = name
            textField.placeholder = "Enter Grocery Name"
        }
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let nameTextField = alert.textFields?[0]
                    
            else {
                actionHandler?(nil)
                return
            }
            actionHandler?(nameTextField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}







extension GroceriesToBuyViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItem.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groceryTableView.dequeueReusableCell(withIdentifier: "groceruCell", for: indexPath)
        cell.textLabel?.text = groceryItem[indexPath.row].name
        cell.detailTextLabel?.text = groceryItem[indexPath.row].addedByUser
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let wanted = groceryItem[indexPath.row].name
        // Edit action
        let edit = UIContextualAction(style: .normal,
                                      title: "Edit") { [weak self] (action, view, completionHandler) in
            completionHandler(true)
            self?.showInputDialog(title: "Edit Grocery",
                                  subtitle: "Edit already existing Grocery",
                                  actionHandler:
                                    { [weak self] newname in
                 let editItem = [
                    //"addedByUser":
                    "addedByUser": User.currentUser()?.email,
                        "name": newname
                ]
                var  data = Database.database().reference().child("grocery-list-items").child(wanted)
                data.setValue(nil)

                data = Database.database().reference().child("grocery-list-items").child(newname!)
                data.setValue(editItem)
                
                self?.reload()
            })
            
            self?.groceryTableView.reloadData()
        }
        
        edit.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [edit])
        return configuration
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let wanted = groceryItem[indexPath.row].name
        
        if editingStyle == .delete{
            //deletItem(path: indexPath.row)
            let  data = Database.database().reference().child("grocery-list-items").child(wanted)
            data.setValue(nil)
            self.reload()
            self.groceryTableView.reloadData()
        }
    }
    
}
