//
//  ChildTask.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/06.
//

import UIKit
import RealmSwift

class ChildTask: Object{
    
    @objc dynamic var date: Date = Date()
    @objc dynamic var time: Date = Date()
    @objc dynamic var state: Bool = false
    @objc dynamic var reviewPosition: Int = 1  // review position 1~5 to sort tasks & toggle review indicator
    @objc dynamic var parentUUID: String = UUID().uuidString // this uuid is foreign key to ParentTask
    
    
    override init() {
        super.init()
    }
    
    
    init(_ date: Date,
         _ time: Date,
         _ state: Bool,
         _ reviewPosition: Int,
         _ parentUUID: String?) {
        
        self.date = date
        self.time = time
        self.state = state
        self.reviewPosition = reviewPosition
        self.parentUUID = parentUUID ?? ""
    }

}
