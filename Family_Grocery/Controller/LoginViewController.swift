//
//  LoginViewController.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var emailtext: UITextField!
    @IBOutlet weak var passwordtext: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var singup: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        if emailtext.text != nil, emailtext.hasText, passwordtext.text != nil, passwordtext.hasText {
    
            User.loginUserWith(email: emailtext.text!, password: passwordtext.text!, completion: { error in

                if error == nil {
                debugPrint("Login Successfull")

                    UserDefaults.standard.set(self.emailtext.text!, forKey: "email")
                   
//                    DatabaseManger.shared.makeOnline(email: User.currentUser()!.email)
                    
                    self.performSegue(withIdentifier: "seageFromA", sender: self)
                }
                else{
                    debugPrint("Erorr\(error!.localizedDescription)")
                    self.showAlert(message: "Email or Password incorrect OR you didn't register!")
                }
            })

        }else{
            debugPrint("All fields are required")
            self.showAlert(message: "Please enter all information.")
            return
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//        let goToGroceru = GroceriesToBuyViewController()
//        goToGroceru.navigationItem.largeTitleDisplayMode = .never
//      self.present(goToGroceru, animated: true)

    }
    

    @IBAction func sinup(_ sender: UIButton) {

        if emailtext.text != nil, emailtext.hasText, passwordtext.text != nil, passwordtext.hasText {
            
            DatabaseManger.shared.userExists(with: emailtext.text!, completion: { exists in
                
                guard !exists else{
                    return
                }
                
                User.UserRegistrWith(email: self.emailtext.text!, Password: self.passwordtext.text!, completion: {
                    error in
                    
                    if error == nil{
                        
                        let chatAppUser = GroceryAppUser(emailAddress: self.emailtext.text!)
                        DatabaseManger.shared.insertUser(with: chatAppUser, Completion: { seccess in
                            
                            if seccess{
                                //go to...
                                
//                                DatabaseManger.shared.makeOnline(email: User.currentUser()!.email)
                                self.showAlertSuccess(message: "Now you can login :)")

                                //self.performSegue(withIdentifier: "seageFromA", sender: self)
                            }
                        })
                    } else{
                        debugPrint("Errrrrrror \(error!.localizedDescription)")
                        self.showAlert(message: "User already exists")
                    }
                })
            })
        }
        else{
            debugPrint("All fields are required")
            self.showAlert(message: "Please enter all information to create a new account.")
            return
        }
    }
    
    
    func showAlert(message: String) {
            let alertVC = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    
    func showAlertSuccess(message: String) {
            let alertVC = UIAlertController(title: "SUCCESS", message: message, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    
}
