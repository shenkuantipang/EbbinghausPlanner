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
import FloatingPanel


class ViewController: UIViewController {

    // MARK: -Declaration
    var disposeBag = DisposeBag()
    
    let mainTaskFpc = FloatingPanelController()
    var currentFloatingPanelState = FloatingPanelState.half
    var currentDate = Date()
    let taskHandler = TaskHandler()
    
    @IBOutlet weak var mainCalendarBaseView: UIView!
    @IBOutlet weak var mainCalendarView: FSCalendar!
    @IBOutlet weak var mainCalendarViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initInstance()
        initEventListener()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        mainCalendarViewHeightConstraint.constant = mainCalendarBaseView.frame.height
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
        
        // main task panel
        setMainTaskPanel(currentDate)
        
    }
    func initInstance(){

    }
    func initEventListener(){

    }
    
    
    
    
    // MARK: - Methods
    func setMainTaskPanel(_ date: Date){
        // set floating panel
        mainTaskFpc.removeFromParent()
        
        guard let contentVC = storyboard?.instantiateViewController(identifier: "taskStoryboard") as? TaskViewController else{return}
        contentVC.currentDate = date
        mainTaskFpc.set(contentViewController: contentVC)
        let panelLayout = CustomFloatingPanelLayout()
        panelLayout.initialState = currentFloatingPanelState
        
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = .gray
        shadow.radius = 20
        shadow.opacity = 0.1
        shadow.offset = .zero
        
        mainTaskFpc.layout = panelLayout
        mainTaskFpc.surfaceView.appearance.shadows = [shadow]
        mainTaskFpc.surfaceView.appearance.cornerRadius = 30
        mainTaskFpc.contentMode = .fitToBounds
        mainTaskFpc.delegate = self
        
        
        mainTaskFpc.addPanel(toParent: self)
    }
    
}




// MARK: - Extensions

// about FSCalendar
extension ViewController: FSCalendarDelegate, FSCalendarDataSource{

    // did select
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        currentDate = date
        setMainTaskPanel(date)
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


extension ViewController: FloatingPanelControllerDelegate{
    
//    func floatingPanelWillEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
//
//        if velocity.y > 1000{
//            mainCalendarView.setCalendarScopeToMonth()
//        }
//        if velocity.y < -1000{
//            mainCalendarView.setCalendarScopeToWeek()
//        }
//    }
    
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if fpc.isAttracting == false {
            if view.frame.height / 2 < fpc.surfaceLocation.y{
                mainCalendarView.setCalendarScopeToMonth()
            }else{
                mainCalendarView.setCalendarScopeToWeek()
            }
        }
    }
    
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        
        let contentVC = fpc.contentViewController as! TaskViewController
        
        switch fpc.state {
        case .full:
            contentVC.toggleAddButton(toggle: true, withAnimation: true)
            mainCalendarView.setCalendarScopeToWeek()
            currentFloatingPanelState = .full
            break
        case .half:
            contentVC.toggleAddButton(toggle: true, withAnimation: true)
            mainCalendarView.setCalendarScopeToWeek()
            currentFloatingPanelState = .half
            break
        case .tip:
            // if state for prevents 'add button' flickering when calendar date selected on .tip mode
            if currentFloatingPanelState == .tip{
                contentVC.toggleAddButton(toggle: false, withAnimation: false)
            }else{
                contentVC.toggleAddButton(toggle: false, withAnimation: true)
            }
            mainCalendarView.setCalendarScopeToMonth()
            currentFloatingPanelState = .tip
            break
        default:
            contentVC.toggleAddButton(toggle: true, withAnimation: true)
            mainCalendarView.setCalendarScopeToWeek()
            currentFloatingPanelState = .half
            break
        }
    }
}
