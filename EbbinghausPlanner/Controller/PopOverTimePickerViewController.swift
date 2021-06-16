//
//  PopOverTimePickerViewController.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/02.
//

import UIKit
import RxSwift
import RxCocoa



protocol PopOverTimePickerDelegate {
    func popOverTimePickerView(selectedTime: String) -> Void
}

class PopOverTimePickerViewController: UIViewController {
    
    // MARK: - Declarations
    var disposeBag = DisposeBag()
    
    var defaultTime: String?
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var timePickerView: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    
    
    // MARK: - Declarations
    var delegate: PopOverTimePickerDelegate?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        initDefaults()
    }
  

    // MARK: - Initializations
    func initView(){
        // time picker view
        timePickerView.setValue(UIColor(named: "TextColor"), forKey: "TextColor")
        
        // top var view
        topBarView.layer.borderWidth = 1
        topBarView.layer.borderColor = UIColor(named: "TaskItemBorderColor")?.cgColor
    }
    func initInstance(){
        
    }
    func initEventListener(){
        // timePicker value change event
        timePickerView.addTarget(self, action: #selector(pickerViewValueChanged), for: .valueChanged)
        
        // done button action
        doneButton.rx.tap
            .bind{self.dismiss(animated: true, completion: nil)}
            .disposed(by: disposeBag)
    }
    func initDefaults(){
        if let defaultTime = defaultTime{
            if defaultTime == "00:00"{
                let time = "01:00".formattedTime
                timePickerView.date = time
                delegate?.popOverTimePickerView(selectedTime: time.formattedTime)
            }else{
                let defaultDate = defaultTime.formattedTime
                let time = defaultDate
                timePickerView.date = time
                delegate?.popOverTimePickerView(selectedTime: time.formattedTime)
            }
        }
    }

    
    
    //MARK: - Methods
    @objc
    func pickerViewValueChanged(){
        
        let time = timePickerView.date.formattedTime
        
        delegate?.popOverTimePickerView(selectedTime: time)
    }

}
