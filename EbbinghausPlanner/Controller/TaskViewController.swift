//
//  TaskViewController.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/05/23.
//

import UIKit
import RxSwift
import RxCocoa

class TaskViewController: UIViewController {

    // MARK: - Declaration
    var disposeBag = DisposeBag()
    
    var currentDate: Date? // pass data
    let taskHandler = TaskHandler()
    var todoTaskArr = Array<ChildTask>()
    
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var todoTaskTableView: UITableView!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        initView()
        initInstance()
        initEventListener()
        initTaskView()
    }
    
    // MARK: - Initializations
    func initData(){
        if currentDate == nil{
            dismiss(animated: true, completion: nil)
        } // you can use 'currentDate' as 'currentDate!' after this
    }
    func initView(){
        // Header date label
        let currentDate = currentDate!.formattedDate
        headerDateLabel.text = currentDate
        
        // Add TaskButton
        addTaskButton.layer.cornerRadius = 15
        addTaskButton.layer.shadowColor = UIColor.gray.cgColor
        addTaskButton.layer.shadowOffset = .zero
        addTaskButton.layer.shadowRadius = 15
        addTaskButton.layer.shadowOpacity = 0.1
        
        // todoTask tableview
        todoTaskTableView.layer.cornerRadius = 20
        todoTaskTableView.separatorStyle = .none
        todoTaskTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)

        // add task button
        addTaskButton.layer.cornerRadius = 15
        addTaskButton.layer.shadowColor = UIColor(named: "AccentColor")?.cgColor
        addTaskButton.layer.borderWidth = 1
        addTaskButton.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        addTaskButton.layer.shadowOffset = .zero
        addTaskButton.layer.shadowRadius = 15
        addTaskButton.layer.shadowOpacity = 0.1
        addTaskButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
    }
    func initInstance(){
        // Tableview Cell
        let taskCellNibName = UINib(nibName: "TaskItemCell", bundle: nil)
        todoTaskTableView.register(taskCellNibName, forCellReuseIdentifier: "taskItemCell")
        
        
        // todoTask tableview
        todoTaskTableView.delegate = self
        todoTaskTableView.dataSource = self
        
    }
    func initEventListener(){
        // Add task button
        addTaskButton.rx.tap
            .bind{ [weak self] in
                self?.presentAddTaskVC()
            }.disposed(by: disposeBag)
    }
    func initTaskView(){
        reloadTasks()
    }
    

    // MARK: - Methods
    func presentAddTaskVC(){
        
        guard let addTaskVC = storyboard?.instantiateViewController(identifier: "addTaskStoryboard") as? AddTaskViewController else {return}
        
        addTaskVC.currentDate = currentDate!
        addTaskVC.delegate = self
        
        present(addTaskVC, animated: true, completion: nil)
    }
    
    
    func presentEditTaskVC(currentChildTask: ChildTask){
        // Edit Task VC will get uuid by childtask
        guard let editTaskVC = storyboard?.instantiateViewController(identifier: "editTaskStoryboard") as? EditTaskViewController else {return}
        
        editTaskVC.currentChildTask = currentChildTask
        editTaskVC.delegate = self
        
        present(editTaskVC, animated: true, completion: nil)
    }
    
    
    func reloadTasks(){
        todoTaskArr.removeAll()
        
        todoTaskArr = taskHandler.fetchChildTaskWithDate(currentDate!)
        
        todoTaskTableView.reloadData()
    }
    
    func reloadTodoTaskTableView(){
        // sort by task priority
        todoTaskArr = todoTaskArr.sorted{ $0.reviewPosition < $1.reviewPosition}
        todoTaskArr = todoTaskArr.sorted{ !$0.state && $1.state }
        todoTaskTableView.reloadData()
    }
    
    public func toggleAddButton(toggle: Bool, withAnimation: Bool){
        
        if withAnimation{
            if toggle{
                UIView.animate(withDuration: 0.3) {
                    self.addTaskButton.alpha = 1.0
                }
            }else{
                UIView.animate(withDuration: 0.3) {
                    self.addTaskButton.alpha = 0
                }
            }
        }else{
            if toggle{
                self.addTaskButton.alpha = 1.0
            }else{
                self.addTaskButton.alpha = 0
            }
        }
        
    }
    
}




// MARK: - Extensions
extension TaskViewController: UITableViewDataSource, UITableViewDelegate{
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoTaskArr.count
    }
    
    // cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "taskItemCell") as? TaskItemCell else{
            return UITableViewCell()
        }
        
        let currentTask = todoTaskArr[indexPath.row]
        
        // set task Title label
        let taskTitle = taskHandler.getTaskTitle(currentTask)
        taskCell.taskTitleLabel.text = taskTitle
        
        // set task event Color
        let eventColor =  taskHandler.getTaskEventColor(currentTask)
        taskCell.taskEventColorView.backgroundColor = UIColor(hexString: eventColor)
        
        // set task time
        let taskTime = currentTask.time
        let taskTimeText = taskTime.formattedTime
        taskCell.taskTimeLabel.text = taskTimeText

        // set state indicator image
        let reviewStateArr = taskHandler.getReviewStates(currentTask.parentUUID)
        for (index, bool) in reviewStateArr.enumerated(){
            taskCell.setReviewState(bool, index)
        }
        
        // set state indicator
        taskCell.setReviewStateIndicator(todoTaskArr[indexPath.row].reviewPosition)
        
        // set done state
        if currentTask.state{
            taskCell.setItemStateDone(true)
        }else{
            taskCell.setItemStateDone(false)
        }
        
        
        
        return taskCell
    }
    
    
    // TableView Cell select event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentTask = todoTaskArr[indexPath.row]
        
        presentEditTaskVC(currentChildTask: currentTask)
    }
    
    
    // TableView swipe action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // done Action Button
        let doneAction = UIContextualAction.init(
            style: .destructive,
            title: nil)
        { [weak self] (action, view, completionHandler) in
            guard let strongSelf = self else { return }
            
            let currentTask = strongSelf.todoTaskArr[indexPath.row]
            
            
            if currentTask.state{ // if state true -> false
                strongSelf.taskHandler.updateReviewState(currentTask, false)
                strongSelf.todoTaskTableView.reloadRows(at: [indexPath], with: .right)
            }else{ // if state false -> true
                strongSelf.taskHandler.updateReviewState(currentTask, true)
                strongSelf.todoTaskTableView.reloadRows(at: [indexPath], with: .left)
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                strongSelf.reloadTodoTaskTableView()
            }
        }
        
        
        
        // default image
        var doneImage = UIImage(named: "state-done")!
        doneImage = doneImage.withTintColor(.systemGreen)
        
        
        if todoTaskArr[indexPath.row].state{ // if task state is done -> underdone
            doneImage = UIImage(named: "state-fail")!
            doneImage = doneImage.withTintColor(UIColor(named: "RemoveButtonForegroundColor")!)
        }else{ // if task state is underdone -> done
            doneImage = UIImage(named: "state-done")!
            doneImage = doneImage.withTintColor(.systemGreen)
        }
        
        
        doneImage = doneImage.addBackgroundCircle(UIColor(named: "TaskItemBackgroundColor"))!
        doneAction.image = doneImage
        doneAction.backgroundColor = UIColor(named: "BackgroundColor")
        
                                     
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
}


// notify when new task did added
extension TaskViewController: AddTaskViewDelegate{
    
    func AddTaskView(taskDidAdded: Bool) {
        if taskDidAdded {
            
            reloadTasks()
//            mainCalendarView.reloadData() // TODO: make as delegate
        }
    }
}


// Task Editted (remove || editted)
extension TaskViewController: EditTaskDelegate{
    
    func EditTaskView(taskDidEdited: Bool) {
        if taskDidEdited {
            
            reloadTasks()
//            mainCalendarView.reloadData() // TODO: make as delegate
        }
    }
}
