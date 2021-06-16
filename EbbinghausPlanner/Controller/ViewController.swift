//
//  ViewController.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/05/22.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
import RealmSwift


class ViewController: UIViewController {

    // MARK: -Declaration
    var disposeBag = DisposeBag()
    
    let taskHandler = TaskHandler()
    var todoTaskArr = Array<ChildTask>()
    
    var currentDate = Date()
    var swipeIndex: Int = 0
    
    var originCenterY: CGFloat = 0
    var latestCenterY: CGFloat = 0
    
    @IBOutlet weak var mainCalendarBaseView: UIView!
    @IBOutlet weak var mainCalendarView: FSCalendar!
    @IBOutlet weak var mainCalendarViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainTaskView: UIView!
    @IBOutlet weak var panHandleView: UIView!
    @IBOutlet weak var panHandlerView: UIView!
    
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var todoTaskTableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initInstance()
        initEventListener()
        
        setMainTaskView(currentDate)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        mainCalendarViewHeightConstraint.constant = mainCalendarBaseView.frame.height
        
        initOriginalValues()
    }
    


    // MARK: - Initializations
    func initView(){
        // Main CalendarView
        mainCalendarView.scope = .week
        mainCalendarView.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 23)
        mainCalendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
        mainCalendarView.appearance.titleFont = UIFont.systemFont(ofSize: 16)
        mainCalendarView.weekdayHeight = 37 //sun mon tue height
        mainCalendarView.appearance.eventDefaultColor = UIColor(named: "DefaultEventColor")
        mainCalendarView.appearance.todaySelectionColor = UIColor(named: "AccentColor")
        mainCalendarView.appearance.todayColor = UIColor(named: "AccentColor")
        mainCalendarView.appearance.selectionColor = UIColor(named: "AccentColor")
        mainCalendarView.appearance.titleTodayColor = UIColor(named: "BackgroundColor")
        mainCalendarView.appearance.titleSelectionColor = UIColor(named: "BackgroundColor")
        mainCalendarView.appearance.weekdayTextColor = UIColor(named: "TextColor")
        mainCalendarView.appearance.weekdayTextColor = UIColor(named: "WeekdayTextColor")
        mainCalendarView.appearance.headerTitleColor = UIColor(named: "TextColor")
        mainCalendarView.appearance.todayColor = UIColor(named: "TodayColor")
        mainCalendarView.appearance.borderRadius = 0.6
        mainCalendarView.dataSource = self
        mainCalendarView.delegate = self
        mainCalendarView.select(Date())
        
        
        // Main TaskView
        mainTaskView.layer.cornerRadius = 30
        mainTaskView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainTaskView.layer.shadowColor = UIColor.lightGray.cgColor
        mainTaskView.layer.shadowOffset = .zero
        mainTaskView.layer.shadowRadius = 20
        mainTaskView.layer.shadowOpacity = 0.1
        
        
        // TODO Task TableView
        todoTaskTableView.tableFooterView = UIView()
        todoTaskTableView.layer.cornerRadius = 17
        todoTaskTableView.separatorStyle = .none
        todoTaskTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        todoTaskTableView.showsVerticalScrollIndicator = false
        
        
        // Add Task button
        addTaskButton.layer.cornerRadius = 15
        addTaskButton.layer.shadowColor = UIColor(named: "AccentColor")?.cgColor
        addTaskButton.layer.borderWidth = 1
        addTaskButton.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        addTaskButton.layer.shadowOffset = .zero
        addTaskButton.layer.shadowRadius = 15
        addTaskButton.layer.shadowOpacity = 0.1
        addTaskButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        // pan handleView
        panHandleView.layer.cornerRadius = panHandleView.frame.height / 2
    }
    func initInstance(){
        let taskCellNibName = UINib(nibName: "TaskItemCell", bundle: nil)
        todoTaskTableView.register(taskCellNibName, forCellReuseIdentifier: "taskItemCell")
        
        
        todoTaskTableView.delegate = self
        todoTaskTableView.dataSource = self
        
    }
    func initEventListener(){
        // AddTask button tap event
        addTaskButton.rx.tap
            .bind(with: self){ vc,_ in
                vc.presentAddTaskVC()
            }.disposed(by: disposeBag)
        
        
        // Main calendarView gesture event
        let scopeGesture = UIPanGestureRecognizer(target: self, action: #selector(scopeGestureAction(_:)))
        scopeGesture.minimumNumberOfTouches = 1
        scopeGesture.maximumNumberOfTouches = 2
        panHandlerView.addGestureRecognizer(scopeGesture)
    }
    func initOriginalValues(){
        originCenterY = mainTaskView.center.y
        latestCenterY = originCenterY
    }
    
    
    
    // MARK: - Methods
    func presentAddTaskVC(){
        
        guard let addTaskVC = storyboard?.instantiateViewController(identifier: "addTaskStoryboard") as? AddTaskViewController else {return}
        
        addTaskVC.currentDate = currentDate
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
    
    
    func setMainTaskView(_ date: Date){ // set or change MainTasklistView when calendar clicked
        
        // set header date "M/d"
        let headerDateFormatter = DateFormatter()
        headerDateFormatter.dateFormat = "M/d"
        let headerDate = headerDateFormatter.string(from: date)
        headerDateLabel.text = headerDate
        
        
        let compareDateFormatter = DateFormatter()
        compareDateFormatter.dateFormat = "yyyy-MM-dd"
        
        reloadTasks()
        
    }
    
    
    func reloadTasks(){
        todoTaskArr.removeAll()
        
        todoTaskArr = taskHandler.fetchChildTaskWithDate(currentDate)
        
        todoTaskTableView.reloadData()
        
    }
    
    
    func reloadTodoTaskTableView(){
        todoTaskArr = todoTaskArr.sorted{ $0.reviewPosition < $1.reviewPosition}
        todoTaskArr = todoTaskArr.sorted{ !$0.state && $1.state }
        todoTaskTableView.reloadData()
    }


    
    @objc
    func scopeGestureAction(_ sender: UIPanGestureRecognizer){ //method name is tmp
        let translation = sender.translation(in: mainTaskView)
        let velocity = sender.velocity(in: mainTaskView)
        let changedCenterY = mainTaskView.center.y + translation.y
        var destCenterY = originCenterY
        let minCenterY = self.view.frame.height + 20
        
        // pan up & down
        mainTaskView.center.y = changedCenterY
        
        
        let triggerCenterY = originCenterY + 50

        if changedCenterY < triggerCenterY{ //panning down
            destCenterY = originCenterY
            
            if mainCalendarView.scope == .month{
                mainCalendarView.setCalendarScopeToWeek()
            }
        }else if changedCenterY > triggerCenterY{ // panning up
            
            destCenterY = minCenterY
            if mainCalendarView.scope == .week{
                mainCalendarView.setCalendarScopeToMonth()
            }
        }

        
        // block panning over +30
        if changedCenterY < originCenterY - 30{
            mainTaskView.center.y = originCenterY - 30
        }
        
        
        // reset translation
        sender.setTranslation(.zero, in: self.view)
        
        // finish panning
        if sender.state == .ended{
            if velocity.y > 1000{
                destCenterY = minCenterY
                mainCalendarView.setCalendarScopeToMonth()
            }else if velocity.y < -1000{
                destCenterY = originCenterY
                mainCalendarView.setCalendarScopeToWeek()
            }
            
            
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.2,
                           options: .curveEaseInOut) {
                self.mainTaskView.center.y = destCenterY
            } completion: { complete in
                if complete{
                    self.latestCenterY = destCenterY
                }
            }
        }
    }
}




// MARK: - Extensions


// about Tableview
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    
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



// about FSCalendar
extension ViewController: FSCalendarDelegate, FSCalendarDataSource{

    // did select
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        
        currentDate = date
        setMainTaskView(date)
        
        DispatchQueue.global(qos: .background).async {
            usleep(80)
            DispatchQueue.main.async {
                self.mainTaskView.center.y = self.latestCenterY
            }
        }
    }

    // set date event
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        if taskHandler.taskExists(date){
            return 1
        }else{
            return 0
        }
    }
}



// notify when new task did added
extension ViewController: AddTaskViewDelegate{
    
    func AddTaskView(taskDidAdded: Bool) {
        if taskDidAdded {
            
            setMainTaskView(currentDate)
            mainCalendarView.reloadData()
        }
    }
}



// Task Editted (remove || editted)
extension ViewController: EditTaskDelegate{
    
    func EditTaskView(taskDidEdited: Bool) {
        if taskDidEdited {
            
            setMainTaskView(currentDate)
            mainCalendarView.reloadData()
        }
    }
}
