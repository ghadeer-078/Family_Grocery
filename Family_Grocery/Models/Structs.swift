//
//  Structs.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import Foundation


struct GroceryAppUser {
  
    let emailAddress: String
    
    // create a computed property safe email
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}


class GroceryItem{

    var name: String
    var addedByUser: String
    
    init( name: String , addedByUser: String) {
        self.name = name
        self.addedByUser = addedByUser
    }
}
