//
//  PreviewCalendarCell.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/05/24.
//

import UIKit


class PreviewCalendarCell: UICollectionViewCell {
    
    
    @IBOutlet weak var previewCalendarView: UIView!
    @IBOutlet weak var previewDateLabel: UILabel!
    
    @IBOutlet weak var reviewState1View: UIView!
    @IBOutlet weak var reviewState2View: UIView!
    @IBOutlet weak var reviewState3View: UIView!
    @IBOutlet weak var reviewState4View: UIView!
    @IBOutlet weak var reviewState5View: UIView!
    
    @IBOutlet weak var reviewTimeTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // preview Calendar view
        previewCalendarView.layer.cornerRadius = 10
        previewCalendarView.layer.borderWidth = 1
        previewCalendarView.layer.borderColor = UIColor(named: "TaskItemBorderColor")?.cgColor
        
        reviewState1View.layer.cornerRadius = 5
        reviewState2View.layer.cornerRadius = 5
        reviewState3View.layer.cornerRadius = 5
        reviewState4View.layer.cornerRadius = 5
        reviewState5View.layer.cornerRadius = 5
        
        // review TimePicker textfield
        reviewTimeTextField.borderStyle = .none
        reviewTimeTextField.layer.borderWidth = 1
        reviewTimeTextField.layer.borderColor = UIColor(named: "TaskItemBorderColor")?.cgColor
        reviewTimeTextField.layer.cornerRadius = 7
        reviewTimeTextField.isUserInteractionEnabled = false
    }
    
    
    func setReviewState(_ reviewCount: Int){
        // the reason why set background all the reviewstates in each case is cell is reusable
        switch reviewCount {
        case 0:
            reviewState1View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState2View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState3View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState4View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
        case 1:
            reviewState1View.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState3View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState4View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
        case 2:
            reviewState1View.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2View.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState4View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
        case 3:
            reviewState1View.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2View.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3View.backgroundColor = UIColor(named: "ReviewState3Color")
            reviewState4View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
        case 4:
            reviewState1View.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2View.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3View.backgroundColor = UIColor(named: "ReviewState3Color")
            reviewState4View.backgroundColor = UIColor(named: "ReviewState4Color")
            reviewState5View.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
        default:
            reviewState1View.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2View.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3View.backgroundColor = UIColor(named: "ReviewState3Color")
            reviewState4View.backgroundColor = UIColor(named: "ReviewState4Color")
            reviewState5View.backgroundColor = UIColor(named: "ReviewState5Color")
        }
    }
}
