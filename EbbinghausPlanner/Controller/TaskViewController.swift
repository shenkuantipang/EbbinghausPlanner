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
    
    var currentDate = Date()
    
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var todaysTodoTableview: UITableView!
    @IBOutlet weak var reviewTaskTableview: UITableView!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Initializations
    func initView(){
        // Header date label
        let currentDate = currentDate.formattedDate
        headerDateLabel.text = currentDate
        
        // Add TaskButton
        addTaskButton.layer.cornerRadius = 15
        addTaskButton.layer.shadowColor = UIColor.gray.cgColor
        addTaskButton.layer.shadowOffset = .zero
        addTaskButton.layer.shadowRadius = 15
        addTaskButton.layer.shadowOpacity = 0.1
        
        // Today's todo tableview
        todaysTodoTableview.layer.cornerRadius = 20
        todaysTodoTableview.separatorStyle = .none
        
        // Review task tableview
        reviewTaskTableview.layer.cornerRadius = 20
        reviewTaskTableview.separatorStyle = .none
        
    }
    func initInstance(){
        // Tableview Cell
        let taskCellNibName = UINib(nibName: "TaskItemCell", bundle: nil)
        todaysTodoTableview.register(taskCellNibName, forCellReuseIdentifier: "taskItemCell")
        reviewTaskTableview.register(taskCellNibName, forCellReuseIdentifier: "taskItemCell")
        
        
        // Today's todo tableview
        todaysTodoTableview.delegate = self
        todaysTodoTableview.dataSource = self
        
        // Review task tableview
        reviewTaskTableview.delegate = self
        reviewTaskTableview.dataSource = self
    }
    func initEventListener(){
        // Add task button
        addTaskButton.rx.tap
            .bind{ [weak self] in
                self?.presentAddTaskVC()
            }.disposed(by: disposeBag)
    }
    

    // MARK: - Methods
    func presentAddTaskVC(){
        guard let addTaskVC = storyboard?.instantiateViewController(identifier: "addTaskStoryboard") as? AddTaskViewController else { return }
        
        addTaskVC.currentDate = currentDate
        
        present(addTaskVC, animated: true, completion: nil)
    }
}

// MARK: - Extensions
extension TaskViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.todaysTodoTableview:
            return 10
        case self.reviewTaskTableview:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableView {
        case self.todaysTodoTableview:
            guard let todoTaskCell = tableView.dequeueReusableCell(withIdentifier: "taskItemCell") as? TaskItemCell else{
                return UITableViewCell()
            }

            return todoTaskCell
        case self.reviewTaskTableview:
            guard let reviewTaskCell = tableView.dequeueReusableCell(withIdentifier: "taskItemCell") as? TaskItemCell else{
                return UITableViewCell()
            }

            return reviewTaskCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
