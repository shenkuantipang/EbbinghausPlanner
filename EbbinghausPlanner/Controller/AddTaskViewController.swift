//
//  AddTaskViewController.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/05/23.
//

import UIKit
import RxSwift
import RxCocoa
import FlexColorPicker
import FSCalendar


protocol AddTaskViewDelegate {
    func AddTaskView(taskDidAdded: Bool)
}


class AddTaskViewController: UIViewController {

    
    // MARK: - Declaration
    var delegate: AddTaskViewDelegate?
    
    var disposeBag = DisposeBag()
    let taskHandler = TaskHandler()
    
    var currentDate = Date()
    var reviewDateArr = Array<Date>()
    var reviewTimeArr = Array<Date>()
    
    let taskTitlePlaceholder = "enter some task title"
    
    let timePickerView = UIPickerView()
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var taskTitleTextview: UITextView!
    @IBOutlet weak var taskTitleBaseView: UIView!
    @IBOutlet weak var eventColorPickerButton: UIButton!
    @IBOutlet weak var taskTimePickerTextfield: UITextField!
    @IBOutlet weak var previewCalendarCollectionView: UICollectionView!
    @IBOutlet weak var restoreReviewDateButton: UIButton!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initInstance()
        initEventListener()
        
        setReviewDate(currentDate)
        setReviewTime()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.view.endEditing(true)
    }
    
    
    // MARK: - Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    // MARK: - Initializations
    func initView(){
        
        // done accessory on keyboard
        let keyboardAccessoryView = UIToolbar()
        keyboardAccessoryView.sizeToFit()
        let spacingItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        keyboardAccessoryView.items = [spacingItem, doneButtonItem]
        
        
        // Add task button
        addTaskButton.layer.cornerRadius = 15
        addTaskButton.layer.shadowColor = UIColor(named: "AccentColor")?.cgColor
        addTaskButton.layer.borderWidth = 1
        addTaskButton.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        addTaskButton.layer.shadowOffset = .zero
        addTaskButton.layer.shadowRadius = 15
        addTaskButton.layer.shadowOpacity = 0.1
        
        
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
        
    }
    
    func initInstance(){
        // set current date
        let headerDate = currentDate.formattedDate
        headerDateLabel.text = headerDate
        
        
        // preview calendar collection view
        previewCalendarCollectionView.layer.masksToBounds = false
        previewCalendarCollectionView.delegate = self
        previewCalendarCollectionView.dataSource = self
        previewCalendarCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
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

        
        
        // Add Task button combine observable
        let taskTitleOb = taskTitleTextview.rx.text.orEmpty.map{ $0 != self.taskTitlePlaceholder && !$0.trimmingCharacters(in: .whitespaces).isEmpty}
        let taskTimeOb = taskTimePickerTextfield.rx.text.orEmpty.map{ $0 != "00:00"}
        
        Observable.combineLatest(taskTitleOb, taskTimeOb, resultSelector: {$0 && $1}) // check task title is not empty & check task time is not 00:00
            .subscribe(with: self, onNext: { vc,bool in
                
                if bool{
                    vc.addTaskButton.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
                    vc.addTaskButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
                }else{
                    vc.addTaskButton.layer.borderColor = UIColor(named: "PlaceholderColor")?.cgColor
                    vc.addTaskButton.setTitleColor(UIColor(named: "PlaceholderColor"), for: .normal)
                }
                vc.addTaskButton.isEnabled = bool
            })
            .disposed(by: disposeBag)
        
        
        
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
        
        
        // restore button tap event
        restoreReviewDateButton.rx.tap
            .bind(with: self){ vc,_ in
                vc.setReviewDate(vc.currentDate)
            }.disposed(by: disposeBag)
        
        
        // Add Task button event
        addTaskButton.rx.tap
            .bind(with: self){ vc,_ in
                self.addTask()
            }.disposed(by: disposeBag)
    }

    
    // MARK: - Methods
    func setReviewDate(_ currentDate: Date){
        reviewDateArr.removeAll()
        
        let reviewDate1 = Calendar.current.date(byAdding: .day, value: 0, to: currentDate)
        let reviewDate2 = Calendar.current.date(byAdding: .day, value: 3, to: currentDate)
        let reviewDate3 = Calendar.current.date(byAdding: .day, value: 6, to: currentDate)
        let reviewDate4 = Calendar.current.date(byAdding: .day, value: 13, to: currentDate)
        let reviewDate5 = Calendar.current.date(byAdding: .day, value: 29, to: currentDate)
        
        reviewDateArr.append(reviewDate1!)
        reviewDateArr.append(reviewDate2!)
        reviewDateArr.append(reviewDate3!)
        reviewDateArr.append(reviewDate4!)
        reviewDateArr.append(reviewDate5!)
        
        previewCalendarCollectionView.reloadData()
    }
    
    
    func setReviewTime(){
        reviewTimeArr.removeAll()
        
        
        let reviewTime = taskTimePickerTextfield.text!.trimmingCharacters(in: .whitespaces).formattedTime
        
        let reviewTime1 = reviewTime
        let reviewTime2 = reviewTime.decreaseTimeWithMultiplier(0.2)
        let reviewTime3 = reviewTime.decreaseTimeWithMultiplier(0.5)
        let reviewTime4 = reviewTime.decreaseTimeWithMultiplier(0.7)
        let reviewTime5 = reviewTime.decreaseTimeWithMultiplier(0.9)
        
        reviewTimeArr.append(reviewTime1)
        reviewTimeArr.append(reviewTime2)
        reviewTimeArr.append(reviewTime3)
        reviewTimeArr.append(reviewTime4)
        reviewTimeArr.append(reviewTime5)
            
        
        previewCalendarCollectionView.reloadData()
    }
    
    
    func addTask(){
        
        // prepare elements
        // title
        let taskTitle = taskTitleTextview.text.trimmingCharacters(in: .whitespaces)
        
        // eventColor
        let eventColor = eventColorPickerButton.backgroundColor!.toHexString()
        
        // childTasks
        var childTaskArr = Array<ChildTask>()
        childTaskArr.append(ChildTask(reviewDateArr[0], reviewTimeArr[0], false, 1, nil))
        childTaskArr.append(ChildTask(reviewDateArr[1], reviewTimeArr[1], false, 2, nil))
        childTaskArr.append(ChildTask(reviewDateArr[2], reviewTimeArr[2], false, 3, nil))
        childTaskArr.append(ChildTask(reviewDateArr[3], reviewTimeArr[3], false, 4, nil))
        childTaskArr.append(ChildTask(reviewDateArr[4], reviewTimeArr[4], false, 5, nil))
        
        
        // Add task
        let isSuccess = taskHandler.addParentTask(taskTitle,
                                                  eventColor,
                                                  childTaskArr)
        if isSuccess{
            // success to add
            delegate?.AddTaskView(taskDidAdded: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func presentColorPickerView(){
        let colorPickerVC = DefaultColorPickerViewController()
        colorPickerVC.view.backgroundColor = UIColor(named: "BackgroundColor")
        colorPickerVC.selectedColor = eventColorPickerButton.backgroundColor! // send current event color
        colorPickerVC.delegate = self
        
        view.endEditing(true)
        present(colorPickerVC, animated: true, completion: nil)
    }
    
    
    func presentPopOverCalendarView(_ today: Date,
                                    _ startRangeDate: Date?,
                                    _ endRangeDate: Date?,
                                    _ sourceView: UICollectionViewCell,
                                    _ indexPath: IndexPath){ // get sourceView to popOver arrow source position
        
        guard let popOverCalendarVC = storyboard?.instantiateViewController(identifier: "popOverCalendarStoryboard") as? PopOverCalendarViewController else { return }
        
        popOverCalendarVC.modalPresentationStyle = .popover
        popOverCalendarVC.preferredContentSize = CGSize(width: 300, height: 300)
        popOverCalendarVC.popoverPresentationController?.permittedArrowDirections = .down
        popOverCalendarVC.popoverPresentationController?.sourceRect = sourceView.frame
        popOverCalendarVC.popoverPresentationController?.sourceView = previewCalendarCollectionView
        popOverCalendarVC.presentationController?.delegate = self
        
        // pass data
        popOverCalendarVC.indexPath = indexPath
        popOverCalendarVC.delegate = self
        
        popOverCalendarVC.today = today
        popOverCalendarVC.startRangeDate = startRangeDate
        popOverCalendarVC.endRangeDate = endRangeDate
        
        view.endEditing(true)
        present(popOverCalendarVC, animated: true, completion: nil)
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
    
    
    @objc
    func taskTimePickerTextfieldTap(_ sender: UITapGestureRecognizer){
        presentPopOverTimePickerView()
    }
    
    @objc
    func reviewTaskTimeTextfieldTap(_ sender: UITapGestureRecognizer){
        presentPopOverTimePickerView()
    }
    
    
    @objc
    func doneAction(sender: Any){
        self.view.endEditing(true)
    }

}



// MARK: - Extensions
extension AddTaskViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let previewCalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewCalenarCell", for: indexPath) as? PreviewCalendarCell else { return UICollectionViewCell() }
        
        // set review date
        let reviewDate = reviewDateArr[indexPath.row]
        
        // set review time
        previewCalendarCell.reviewTimeTextField.text = reviewTimeArr[indexPath.row].toFormattedTime()
        
        // disable edit current date
        if reviewDate <= currentDate{
            previewCalendarCell.previewDateLabel.textColor = .gray
        }else{
            previewCalendarCell.previewDateLabel.textColor = UIColor(named: "TextColor")
        }
        
        // Set review date with "M/d" formatted date
        let previewDate = reviewDate.formattedDate
        previewCalendarCell.previewDateLabel.text = previewDate
        
        // Set review state color 1 ~ 5
        previewCalendarCell.setReviewState(indexPath.row + 1)
        
        
        return previewCalendarCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // disable to change startDate
        if indexPath.row == 0{
            return
        }

        guard let previewCalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewCalenarCell", for: indexPath) as? PreviewCalendarCell else { return }
        
        
        if indexPath.row >= reviewDateArr.count - 1{ // [4], [4+1] <- index out of range
            presentPopOverCalendarView(reviewDateArr[indexPath.row],
                                       reviewDateArr[indexPath.row - 1],
                                       nil,
                                       previewCalendarCell,
                                       indexPath)
        }else{
            presentPopOverCalendarView(reviewDateArr[indexPath.row],
                                       reviewDateArr[indexPath.row - 1],
                                       reviewDateArr[indexPath.row + 1],
                                       previewCalendarCell,
                                       indexPath)
        }

    }
}


extension AddTaskViewController: ColorPickerDelegate{
    
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        
        eventColorPickerButton.backgroundColor = selectedColor
        taskTitleBaseView.backgroundColor = selectedColor
    }
}


extension AddTaskViewController: UIAdaptivePresentationControllerDelegate{
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


extension AddTaskViewController: PopOverTimePickerDelegate{
    
    func popOverTimePickerView(selectedTime: String) {
        taskTimePickerTextfield.text = selectedTime
        taskTimePickerTextfield.sendActions(for: .valueChanged)
        setReviewTime()
    }
}

extension AddTaskViewController: PopOverCalendarViewDelegate{
    
    func PopOverCalendarView(selectedDate: Date, indexPath: IndexPath) {
        reviewDateArr[indexPath.row] = selectedDate
        previewCalendarCollectionView.reloadData()
    }
}
