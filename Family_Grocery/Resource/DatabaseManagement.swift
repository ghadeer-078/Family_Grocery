//
//  DatabaseManagement.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth


final class DatabaseManger {
    
    public static let shared = DatabaseManger()
    
    // reference the database
    public let database = Database.database().reference()
    
    public static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    /// Insert new user to database
    public func insertUser(with user: GroceryAppUser, Completion: @escaping (Bool) -> Void){
        
        
        database.child(user.safeEmail).setValue(["email":user.emailAddress],
                                                withCompletionBlock:{
            error , _ in
            
            guard error == nil else {
                print("failed to write to database!")
                Completion(false)
                return
            }
            
            /*///
             users = [
             [
             "safe_email":
             ],
             [
             "safe_email":
             ],....
             ]
             */
            
            self.database.child("online").observeSingleEvent(of: .value, with: {
                
                snapshot in
                
//                if var userssCollection = snapshot.value as? [String: String]{
//
//                    //append to user dictionary
//                    let newElement =  user.safeEmail
//
//                    //userssCollection.append(newElement)
//
//                    //(userssCollection, withCompletionBlock: {
////                        error, _ in
////
////                        guard error == nil else {
////                            Completion(false)
////                            return
////                        }
////
////                        Completion(true)
////                    })
//                }
                //else{
                    //create that array
                    let newCollection: [String: String] = [
                        
                            "email": user.safeEmail
                    ]
                    
                    self.database.child("online").setValue(newCollection, withCompletionBlock: {
                        error, _ in
                        
                        guard error == nil else {
                            Completion(false)
                            return
                        }
                        
                        Completion(true)
                    })
                //}
            })
        })
    }
    
    
    func makeOnline(email: String){

        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        self.database.child("online").childByAutoId().child(safeEmail)
    }
//
//
//    func makeOffline(email: String){
//
//        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentEmail)
//        self.database.child("online").childByAutoId().child(safeEmail).setValue(nil)
//    }
    
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    

//    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
//        database.child("online").observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [[String: String]] else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//
//            completion(.success(value))
//        }
//    }
//
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}//end the class...



extension DatabaseManger{
    
    ///creates new grocery...                               //GroceryItem
    public func creatNewGrocery(with email: String,name: String, completion: @escaping (Bool) -> Void){
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        
        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentEmail)
        
        self.database.child("grocery-list-items").observeSingleEvent(of: .value, with: { snapshot in
            
            if var groceriesCollection = snapshot.value as? [[String: Any]] {
                
                print("Array!!!!!!!!!!")
                let newGrocery = [
                    
                    "name": name,
                    "email": safeEmail
                ]
                
                groceriesCollection.append(newGrocery)
                
                self.database.child("grocery-list-items").setValue(groceriesCollection, withCompletionBlock: { error, _ in
                    
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
                
            }
            else{
                print("newArray!!!!!!!")
                //create that array
                //                let newGrocery: [String: String] = [
                //
                //                    "name": name,
                //                    "addedByUser": safeEmail
                //
                //                ]
                //
                //                //"grocery-items"
                //                let newgroceryList = [
                //                    name:
                //                        newGrocery
                //                ]
                
                self.database.child("grocery-list-items").child(name).setValue(["name": name,"addedByUser": safeEmail], withCompletionBlock: {
                    error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                })
            }
        })
    }
}
