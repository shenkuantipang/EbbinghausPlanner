//
//  ParentTask.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/06.
//

import UIKit
import RealmSwift

class ParentTask: Object{
    
    @objc dynamic var title: String = ""
    @objc dynamic var eventColor: String = UIColor(named: "DefaultEventColor")?.toHexString() ?? UIColor.blue.toHexString()
    @objc dynamic var uuid: String = UUID().uuidString // this uuid is foreign key to ChildTask
    
    
    override class func primaryKey() -> String? {
        "uuid"
    }
}
