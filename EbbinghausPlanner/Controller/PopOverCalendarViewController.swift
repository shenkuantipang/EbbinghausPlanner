//
//  PopOverCalendarViewController.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/01.
//

import UIKit
import FSCalendar

protocol PopOverCalendarViewDelegate {
    func PopOverCalendarView(selectedDate: Date, indexPath: IndexPath)
}

class PopOverCalendarViewController: UIViewController {

    // MARK: - Declarations
    var delegate: PopOverCalendarViewDelegate?
    
    var indexPath: IndexPath?
    
    var today = Date()
    var startRangeDate: Date?
    var endRangeDate: Date?
    
    
    @IBOutlet weak var calendarBaseView: UIView!
    @IBOutlet weak var calendarView: FSCalendar!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
        
        setToday()
        modifyDate()
        
    }


    // MARK: - Initializations
    func initView(){
        // CalendarBaseView
        calendarBaseView.layer.cornerRadius = 8
        
        // CalendarView
        calendarView.today = today
        calendarView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        calendarView.weekdayHeight = 50
        calendarView.appearance.eventDefaultColor = UIColor(named: "DefaultEventColor")
        calendarView.appearance.todaySelectionColor = UIColor(named: "AccentColor")
        calendarView.appearance.todayColor = .clear
        calendarView.appearance.selectionColor = UIColor(named: "AccentColor")
        calendarView.appearance.titleTodayColor = UIColor(named: "BackgroundColor")
        calendarView.appearance.titleSelectionColor = UIColor(named: "BackgroundColor")
        calendarView.appearance.weekdayTextColor = UIColor(named: "TextColor")
        calendarView.appearance.weekdayTextColor = UIColor(named: "WeekdayTextColor")
        calendarView.appearance.headerTitleColor = UIColor(named: "TextColor")
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    func initInstance(){
    }
    func initEventListener(){}
    
    func setToday(){
        calendarView.select(today)
    }
    
    
    // MARK: - Methods
    func modifyDate(){ // modify endRangeDate to endRangeDate - 1
        if let endRangeDate = endRangeDate{
            if let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: endRangeDate){
                self.endRangeDate = modifiedDate
            }
        }
    }

}

//MARK: - Extensions
extension PopOverCalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        // 3 states for disable dates
        // if startRangeDate is nil and endRangeDate is not nil  (infinite...endRange)
        // if endRangeDate is nil and startRangeDate is not nil  (startRange...infinite)
        // if both is not nil (startRange...endRange)
        if (startRangeDate == nil && endRangeDate != nil){
            if(date < endRangeDate!) {
                return true
            }else{
                return false
            }
        }else if (startRangeDate != nil && endRangeDate == nil){
            if(date > startRangeDate!) {
                return true
            }else{
                return false
            }
        }else{
            if(date > startRangeDate! && date < endRangeDate!) {
                return true
            }else{
                return false
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if (startRangeDate == nil && endRangeDate != nil){
            if(date < endRangeDate!) {
                return UIColor(named: "TextColor")
            }else{
                return UIColor(named: "PlaceholderColor")
            }
        }else if (startRangeDate != nil && endRangeDate == nil){
            if(date > startRangeDate!) {
                return UIColor(named: "TextColor")
            }else{
                return UIColor(named: "PlaceholderColor")
            }
        }else{
            if(date > startRangeDate! && date < endRangeDate!) {
                return UIColor(named: "TextColor")
            }else{
                return UIColor(named: "PlaceholderColor")
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.delegate?.PopOverCalendarView(selectedDate: date, indexPath: indexPath!)
        dismiss(animated: true, completion: nil)
    }
}

