//
//  EditTaskViewController.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/05.
//

import UIKit
import FlexColorPicker
import RxSwift
import RxCocoa


protocol EditTaskDelegate {
    func EditTaskView(taskDidEdited: Bool)
}


class EditTaskViewController: UIViewController {

    // MARK: - Declarations
    var delegate: EditTaskDelegate?
    
    var disposeBag = DisposeBag()
    
    var uuid: String = ""
    let taskTitlePlaceholder = "enter some task title"

    let taskHandler = TaskHandler()
    var parentTask = ParentTask()
    var currentChildTask = ChildTask()
    
    
    @IBOutlet weak var headerDateLabel: UILabel!
    
    @IBOutlet weak var taskTitleBaseView: UIView!
    @IBOutlet weak var taskTitleTextview: UITextView!
    @IBOutlet weak var eventColorPickerButton: UIButton!
    @IBOutlet weak var taskTimePickerTextfield: UITextField!
    
    @IBOutlet weak var editTaskButton: UIButton!
    @IBOutlet weak var removeTaskButton: UIButton!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
        initDefaults()
    }
    
    // MARK: - Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    // MARK: - Initializaionts
    func initView(){
        // done accessory on keyboard
        let keyboardAccessoryView = UIToolbar()
        keyboardAccessoryView.sizeToFit()
        let spacingItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        keyboardAccessoryView.items = [spacingItem, doneButtonItem]
        
        
        // Task title baseview
        taskTitleBaseView.layer.cornerRadius = 20
        taskTitleBaseView.clipsToBounds = true
        
        
        // Task title textview
        taskTitleTextview.text = taskTitlePlaceholder
        taskTitleTextview.textColor = .lightGray
        taskTitleTextview.alignTextVertically()
        taskTitleTextview.sizeToFit()
        taskTitleTextview.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        taskTitleTextview.inputAccessoryView = keyboardAccessoryView
        
        
        // Pin color picker button
        eventColorPickerButton.layer.cornerRadius = eventColorPickerButton.frame.width / 2
        eventColorPickerButton.layer.borderWidth = 1
        eventColorPickerButton.layer.borderColor = UIColor(named: "TaskItemBorderColor")?.cgColor
        
        
        // Task time picker button
        taskTimePickerTextfield.layer.cornerRadius = 8
        taskTimePickerTextfield.borderStyle = .none
        
        
        // edit task button
        editTaskButton.layer.borderWidth = 1
        editTaskButton.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        editTaskButton.layer.cornerRadius = 15
        editTaskButton.layer.shadowColor = UIColor(named: "AccentColor")?.cgColor
        editTaskButton.layer.shadowOffset = .zero
        editTaskButton.layer.shadowRadius = 15
        editTaskButton.layer.shadowOpacity = 0.1
        
        
        // remove task button
        removeTaskButton.layer.borderWidth = 1
        removeTaskButton.layer.borderColor = UIColor(named: "RemoveButtonForegroundColor")?.cgColor
        removeTaskButton.layer.cornerRadius = 15
        removeTaskButton.layer.shadowColor = UIColor(named: "RemoveButtonForegroundColor")?.cgColor
        removeTaskButton.layer.shadowOffset = .zero
        removeTaskButton.layer.shadowRadius = 15
        removeTaskButton.layer.shadowOpacity = 0.1
        
    }
    func initInstance(){
        
    }
    func initEventListener(){
        // Task title textview begin editing
        taskTitleTextview.rx.didBeginEditing
            .bind(with: self){ vc,_ in
                if vc.taskTitleTextview.text.lowercased() == vc.taskTitlePlaceholder.lowercased(){
                    vc.taskTitleTextview.text = ""
                    vc.taskTitleTextview.textColor = UIColor(named: "TextColor")
                }
                
                vc.taskTitleBaseView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
                vc.taskTitleBaseView.layer.borderWidth = 1
            }.disposed(by: disposeBag)
        
        
        // Task title textview editing end
        taskTitleTextview.rx.didEndEditing
            .bind(with: self){ vc,_ in
                if vc.taskTitleTextview.text.trimmingCharacters(in: .whitespaces).isEmpty{
                    vc.taskTitleTextview.text = vc.taskTitlePlaceholder
                    vc.taskTitleTextview.textColor = UIColor(named: "PlaceholderColor")
                }else{
                    vc.taskTitleTextview.text = vc.taskTitleTextview.text.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                vc.taskTitleBaseView.layer.borderWidth = 0
            }.disposed(by: disposeBag)
        
        
        // EventColor Picker Button
        eventColorPickerButton.rx.tap
            .bind(with: self){ vc,_ in
                vc.presentColorPickerView()
            }.disposed(by: disposeBag)
        
        
        // taskTimePickerTextfield tap event
        let taskTimePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(taskTimePickerTextfieldTap(_:)))
        taskTimePickerTextfield.addGestureRecognizer(taskTimePickerTapGesture)
        
        
        // Prevent Paste something into taskTimePickerTextfield
        taskTimePickerTextfield.addGestureRecognizer(taskTimePickerTapGesture)
        
        
        // remove task button action
        removeTaskButton.rx.tap
            .bind(with: self){ vc,_ in
                vc.presentRemoveTaskAlert()
            }.disposed(by: disposeBag)
        
        
        // Edit task button action
        editTaskButton.rx.tap
            .bind(with: self){ vc,_ in
                vc.updateTask()
            }.disposed(by: disposeBag)
        
    }
    func initDefaults(){
        parentTask = taskHandler.fetchParentTaskWithUUID(currentChildTask.parentUUID)
        
        // set header date label
        let headerDateText = currentChildTask.date.formattedDate
        headerDateLabel.text = headerDateText
        
        // set task title
        taskTitleTextview.text = parentTask.title
        taskTitleTextview.textColor = UIColor(named: "TextColor")
        
        // set task event color
        taskTitleBaseView.backgroundColor = UIColor.init(hexString: parentTask.eventColor)
        eventColorPickerButton.backgroundColor = UIColor.init(hexString: parentTask.eventColor)
        
        // set task time
        taskTimePickerTextfield.text = currentChildTask.time.formattedTime
        taskTimePickerTextfield.sendActions(for: .valueChanged)
        
    }

    
    
    // MARK: - Methods
  
    
    
    func presentColorPickerView(){
        let colorPickerVC = DefaultColorPickerViewController()
        colorPickerVC.view.backgroundColor = UIColor(named: "BackgroundColor")
        colorPickerVC.selectedColor = eventColorPickerButton.backgroundColor!
        colorPickerVC.delegate = self
        
        view.endEditing(true)
        present(colorPickerVC, animated: true, completion: nil)
    }
    
    
    func presentPopOverTimePickerView(){
        
        guard let popOverTimePickerVC = storyboard?.instantiateViewController(identifier: "popOverTimePickerStoryboard") as? PopOverTimePickerViewController else {return}
        
        popOverTimePickerVC.modalPresentationStyle = .popover
        popOverTimePickerVC.preferredContentSize = CGSize(width: 300, height: 300)
        popOverTimePickerVC.popoverPresentationController?.permittedArrowDirections = .right
        popOverTimePickerVC.popoverPresentationController?.sourceRect = taskTimePickerTextfield.bounds
        popOverTimePickerVC.popoverPresentationController?.sourceView = taskTimePickerTextfield
        popOverTimePickerVC.presentationController?.delegate = self
        popOverTimePickerVC.defaultTime = taskTimePickerTextfield.text?.trimmingCharacters(in: .whitespaces)
        popOverTimePickerVC.delegate = self
        
        
        view.endEditing(true)
        present(popOverTimePickerVC, animated: true, completion: nil)
    }
    
    
    func presentRemoveTaskAlert(){
        let alertTitle = "are you sure you want to remove this task?"
        let alertMessage = "Not only the current task will be removed, but all tasks for this task will be removed"
        
        let removeTaskAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { action in
            self.removeParentTask()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeTaskAlert.addAction(cancelAction)
        removeTaskAlert.addAction(removeAction)
        
        
        present(removeTaskAlert, animated: true, completion: nil)
    }
    
    
    func presentRemoveFailAlert(title: String, message: String){
        let failAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAcion = UIAlertAction(title: "Confirm", style: .default){ action in
            failAlert.dismiss(animated: true, completion: nil)
        }
        
        
        failAlert.addAction(confirmAcion)
        
        present(failAlert, animated: true, completion: nil)
    }
    
    
    func removeParentTask(){
        let isSuccess = taskHandler.removeParentTask(parentTask)
        if isSuccess{
            // success to remove task
            self.delegate?.EditTaskView(taskDidEdited: true)
            self.dismiss(animated: true, completion: nil)
        }else{
            // fail to remove task
            let title = "Fail to remove task"
            let message = "please try again"
            self.presentRemoveFailAlert(title: title, message: message)
        }
    }
    
    
    func updateTask(){
        
        // update childtask
        let taskTime = taskTimePickerTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines).formattedTime
        let updateChildTaskOb = taskHandler.updateChildTask(currentChildTask, currentChildTask.date, taskTime, currentChildTask.state)
        
        // update parent task
        let taskTitle = taskTitleTextview.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let eventColor = eventColorPickerButton.backgroundColor?.toHexString()
        let updateParentTaskOb = taskHandler.updateParentTask(parentTask, taskTitle, eventColor, nil)
        
        
        if updateChildTaskOb && updateParentTaskOb{
            self.delegate?.EditTaskView(taskDidEdited: true)
            print("activated")
            dismiss(animated: true, completion: nil)
        }else{
            print("fail to update")
            let title = "Fail to update Task"
            let message = "please try again"
            presentRemoveFailAlert(title: title, message: message)
        }
    }
    
    
    
    @objc
    func taskTimePickerTextfieldTap(_ sender: UITapGestureRecognizer){
        presentPopOverTimePickerView()
    }
    
    @objc
    func doneAction(sender: Any){
        self.view.endEditing(true)
    }
}

// MARK: - Extensions

// Always Popover Delegate
extension EditTaskViewController: UIAdaptivePresentationControllerDelegate{
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// ColorPickerView Delegate
extension EditTaskViewController: ColorPickerDelegate{
    
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        
        eventColorPickerButton.backgroundColor = selectedColor
        taskTitleBaseView.backgroundColor = selectedColor
    }
}

// PopOver Timepicker Delegate
extension EditTaskViewController: PopOverTimePickerDelegate{
    
    func popOverTimePickerView(selectedTime: String) {
        taskTimePickerTextfield.text = selectedTime
        taskTimePickerTextfield.sendActions(for: .valueChanged)
//        setReviewTime()
    }
}
