//
//  Collection.swift
//  Family_Grocery
//
//  Created by administrator on 10/11/2021.
//

import Foundation
import FirebaseFirestore


enum FBCollectionReference: String {
    
    case User
}


func reference(_ collectionReference: FBCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
