//
//  UserManagement.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class User{
    
    var id: String
    var email: String

    //MARK: - Initializers
    init(_id: String, _email: String) {
        self.id = _id
        self.email = _email
    }
    
    //MARK: - Dictionary Init
    init(_dictionary: NSDictionary) {
        
        if let _id = _dictionary["id"] as? String {
            self.id = _id
        } else {
            id = ""
        }
     
        
        if let mail = _dictionary["email"] {
            email = mail as! String
        } else {
            email = ""
        }
        
    }


    //MARK: - Returning current user funcs
    
    class func currentId() -> String {
        // return current user ID
        return Auth.auth().currentUser!.uid
    }

    
    class func currentUser () -> User? {
        // return current user
        if Auth.auth().currentUser != nil {
            
            if let dictionary = UserDefaults.standard.object(forKey: "currentUser") {
                return User.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }

    
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (myUser, error) in
            
            if error == nil {

                fetchCurrentUserFromFirestore(userId: myUser!.user.uid)
                //self.currentUser()?.isLoggedIn
                completion(nil)
                
            } else {
                
                completion(error)
                return
            }
        })
    }

    
    class func UserRegistrWith(email: String, Password: String, completion: @escaping(_ error:Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: Password) { (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                let myUser = User(_id: authDataResult!.user.uid, _email: authDataResult!.user.email!)
                
                saveUserLocally(userDictionary: userDictionaryFrom(user: myUser))
                saveUserToFireStore(user: myUser)
            }
        }
    }
   
    
    // MARK: - Logout
    class func userLogOut (completion: @escaping(_ error: Error?) -> Void) {
        
        do {
            
            try Auth.auth().signOut()
            //database.child("online").child(currentUser()!.email).setValue(nil)
            UserDefaults.standard.removeObject(forKey: "currentUser")
            UserDefaults.standard.synchronize()
            completion(nil)
            
            
        }
        catch let error as NSError {
            completion(error)
        }
    }
        
       
}//end the class

        




//MARK: - Fetch User funcs
func fetchCurrentUserFromFirestore(userId: String) {
    
    reference(.User).document(userId).getDocument { (snapshot, error) in

        guard let snapshot = snapshot else {  return }

        if snapshot.exists {
            debugPrint("updated current users param")
            
            saveUserLocally(userDictionary: snapshot.data()! as NSDictionary)
        }
    }
}



// MARK: - Save user Locally
func saveUserLocally(userDictionary: NSDictionary)  {
    
    UserDefaults.standard.set(userDictionary, forKey: "currentUser")
    UserDefaults.standard.synchronize()
}


//MARK: - From User To  Dict
func userDictionaryFrom(user: User) -> NSDictionary {
    
    return NSDictionary(
        
        objects: [user.id, user.email],
                        
                        forKeys: ["id" as NSCopying,
                                  "email" as NSCopying])
}


func saveUserToFireStore (user: User){
    
    reference(.User).document(user.id).getDocument { (snapshot, error) in
       
        guard let snapshot = snapshot else {return}
        
        if snapshot.exists {
            saveUserLocally(userDictionary: snapshot.data()! as NSDictionary)
        }
        else {
            
            saveUserLocally(userDictionary: userDictionaryFrom(user: user))
            saveUserToFireBase(myUser: user)
        }
    }
}


// MARK: - Save user to firebae & fireStore
func saveUserToFireBase(myUser: User) {
    
    reference(.User).document(myUser.id).setData( userDictionaryFrom(user: myUser) as! [String : Any]) { (error) in
     
        if error != nil {
            print("Error is " + error!.localizedDescription)
        }
    }
}
