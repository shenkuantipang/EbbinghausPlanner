//
//  TaskHandler.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/02.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class TaskHandler{
    
    // MARK: Declarations
    let realmInstance = try! Realm()
    
    
    // MARK: - ParentTask Methods
    // add
    // update
    // remove
    // fetch
    // etc
    @discardableResult
    func addParentTask(_ title: String,
                       _ eventColor: String,
                       _ childTasks: Array<ChildTask>) -> Bool{
        
        let uuid = UUID().uuidString // uuid for foreign key
        
        let parentTask = ParentTask()
        parentTask.title = title
        parentTask.eventColor = eventColor
        parentTask.uuid = uuid
        
        
        childTasks.forEach { childTask in
            childTask.parentUUID = uuid
        }
        
        
        do{
            try realmInstance.write{
                realmInstance.add(parentTask)
                childTasks.forEach { childTask in
                    realmInstance.add(childTask)
                }
            }
            return true
        }catch{
            print(error.localizedDescription)
            return false
        }
    }
    
    
    
    @discardableResult
    func updateParentTask(_ parentTask: ParentTask,
                          _ title: String?,
                          _ eventColor: String?,
                          _ childTasks: Array<ChildTask>?) -> Bool{
        
        do{
            try self.realmInstance.write{
                parentTask.title = title ?? parentTask.title
                parentTask.eventColor = eventColor ?? parentTask.eventColor
                
            }
            // success to update
            return true
        }catch{
            // fail to update
            print(error.localizedDescription)
            
            return false
        }
    }
    
    
    
    @discardableResult
    func removeParentTask(_ parentTask: ParentTask) -> Bool{
        
        // get all childTasks
        let childTaskArr = fetchChildTaskWithUUID(parentTask.uuid)
        
        do{
            try realmInstance.write{
                realmInstance.delete(parentTask)
                
                // remove all childTasks
                childTaskArr.forEach { childTask in
                    realmInstance.delete(childTask)
                }
            }
            
            return true
        }catch{
            print(error.localizedDescription)
            return false
        }
    }
    
    
    
    func fetchParentTaskWithUUID(_ uuid: String) -> ParentTask{
        
        var resultTask = ParentTask()
        let parentTaskArr = fetchAllParentTask()
        
        parentTaskArr.forEach { parentTask in
            if parentTask.uuid == uuid{
                resultTask = parentTask
            }
        }
        
        return resultTask
    }
    
    
    
    func fetchAllParentTask() -> Array<ParentTask>{
        
        let parentTaskArr = Array(realmInstance.objects(ParentTask.self))
        
        return parentTaskArr
    }
    
    
    
    
    
    // MARK: - ChildTask Methods
    // add
    // update
    // remove
    // fetch
    // etc
    func addChildTask(_ date: Date,
                      _ time: Date,
                      _ state: Bool,
                      _ uuid: String){
        
        
        let childTask = ChildTask()
        
        childTask.date = date
        childTask.time = time
        childTask.state = state
        childTask.parentUUID = UUID().uuidString

        
        do{
            try realmInstance.write{
                realmInstance.add(childTask)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    @discardableResult
    func updateChildTask(_ childTask: ChildTask,
                         _ date: Date?,
                         _ time: Date?,
                         _ state: Bool?) -> Bool{
        
        
            do{
                try self.realmInstance.write{
                    childTask.date = date ?? childTask.date
                    childTask.time = time ?? childTask.time
                    childTask.state = state ?? childTask.state
                }
                return true
            }catch{
                print(error.localizedDescription)
                
                return false
            }
    }
    
    
    
    func updateReviewState(_ childTask: ChildTask,
                           _ state: Bool){
        
        do{
            try realmInstance.write{
                childTask.state = state
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    func removeChildTask(_ childTask: ChildTask){
        
        do{
            try realmInstance.write{
                realmInstance.delete(childTask)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    func removeAll(){
        
        do{
            try realmInstance.write{
                realmInstance.deleteAll()
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    func fetchChildTaskWithDate(_ currentDate: Date) -> Array<ChildTask>{
        
        var resultArr = Array<ChildTask>()
        let childTaskArr = Array(realmInstance.objects(ChildTask.self))
        
        childTaskArr.forEach { childTask in
            if currentDate.comparableDate == childTask.date.comparableDate{
                
                resultArr.append(childTask)
            }
        }
        
        // sort by review position
        resultArr = resultArr.sorted{ $0.reviewPosition < $1.reviewPosition }
        // sort by state
        resultArr = resultArr.sorted { !$0.state && $1.state}
        
        
        return resultArr
    }
    
    
    
    func fetchChildTaskWithUUID(_ uuid: String) -> Array<ChildTask> {
        
        var resultArr = Array<ChildTask>()
        var childTaskArr = Array(realmInstance.objects(ChildTask.self))
        
        childTaskArr.forEach { childTask in
            if childTask.parentUUID == uuid{
                resultArr.append(childTask)
            }
        }
        
        childTaskArr = childTaskArr.sorted(by: { $0.date < $1.date })
        
        return resultArr
    }
    
    
    
    func fetchAllChildTask() -> Array<ChildTask>{
        
        let childTaskArr = Array(realmInstance.objects(ChildTask.self))
        return childTaskArr
    }
    
    
    func taskExists(_ onDate: Date) -> Bool{
        
        let childTaskArr = Array(realmInstance.objects(ChildTask.self))
        var isExists = false
        
        childTaskArr.forEach { childTask in
            if childTask.date.comparableDate == onDate.comparableDate{
                isExists = true
            }
        }

        return isExists
    }
    
    
    func getTaskTitle(_ childTask: ChildTask) -> String{
        
        let parentTask = fetchParentTaskWithUUID(childTask.parentUUID)
        return parentTask.title
    }
    
    
    
    func getTaskEventColor(_ childTask: ChildTask) -> String{
        
        let parentTask = fetchParentTaskWithUUID(childTask.parentUUID)
        return parentTask.eventColor
    }
    
    
    
    func getReviewStates(_ uuid: String) -> Array<Bool>{
        
        let childTaskArr = fetchChildTaskWithUUID(uuid) // sorted by date in fetchChildTaskWithUUID()
        
        var stateArr = Array<Bool>()
        childTaskArr.forEach { childTask in
            stateArr.append(childTask.state)
        }
        
        return stateArr
    }
    
    
    func getReviewDates(_ uuid: String) -> Array<Date>{
        
        let childTaskArr = fetchChildTaskWithUUID(uuid) // sorted by date in fetchChildTaskWithUUID()
        
        var dateArr = Array<Date>()
        childTaskArr.forEach { childTask in
            dateArr.append(childTask.date)
        }
        
        return dateArr
    }
}
