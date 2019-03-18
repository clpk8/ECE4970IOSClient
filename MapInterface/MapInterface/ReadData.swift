//
//  ReadData.swift
//  MapInterface
//
//  Created by linChunbin on 3/17/19.
//  Copyright © 2019 clpk8. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore

class ReadData{
    var ref: DatabaseReference!
    var databaseHandle : DatabaseHandle!
    
    var lat = Double()
    var lon = Double()
    
    
    func connect(){
        
        ref = Database.database().reference()
        databaseHandle = ref.child("ece4995").observe(.childChanged) { (snapshot) in
            //Code to executer when a child is changed
            
        }
    }
    func update(){
        
    }
}
