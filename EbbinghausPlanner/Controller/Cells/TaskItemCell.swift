//
//  TaskItemCell.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/05/23.
//

import UIKit

class TaskItemCell: UITableViewCell{

    
    @IBOutlet weak var doneStateMaskView: UIView!
    
    @IBOutlet weak var taskItemContentView: UIView!
    
    @IBOutlet weak var taskEventColorView: UIView!
    
    @IBOutlet weak var reviewState1IndicatorView: UIView!
    @IBOutlet weak var reviewState2IndicatorView: UIView!
    @IBOutlet weak var reviewState3IndicatorView: UIView!
    @IBOutlet weak var reviewState4IndicatorView: UIView!
    @IBOutlet weak var reviewState5IndicatorView: UIView!
    
    @IBOutlet weak var reviewState1ImageView: UIImageView!
    @IBOutlet weak var reviewState2ImageView: UIImageView!
    @IBOutlet weak var reviewState3ImageView: UIImageView!
    @IBOutlet weak var reviewState4ImageView: UIImageView!
    @IBOutlet weak var reviewState5ImageView: UIImageView!
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskTimeView: UIView!
    @IBOutlet weak var taskTimeLabel: UILabel!
    
    
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        taskEventColorView.backgroundColor = UIColor(named: "DefaultEventColor")
        taskEventColorView.layer.masksToBounds = true
        taskEventColorView.layer.cornerRadius = 17
        
        taskTimeView.layer.cornerRadius = 8
        
        reviewState1IndicatorView.layer.cornerRadius = 5
        reviewState2IndicatorView.layer.cornerRadius = 5
        reviewState3IndicatorView.layer.cornerRadius = 5
        reviewState4IndicatorView.layer.cornerRadius = 5
        reviewState5IndicatorView.layer.cornerRadius = 5
        
        
        doneStateMaskView.isHidden = true
        doneStateMaskView.backgroundColor = .clear
    }

    
    
    // MARK: - Methods
    func setReviewStateIndicator(_ reviewCount: Int){
        switch reviewCount {
        case 0:
            reviewState1IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState2IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState3IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState4IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            
            reviewState1ImageView.image = UIImage()
            reviewState2ImageView.image = UIImage()
            reviewState3ImageView.image = UIImage()
            reviewState4ImageView.image = UIImage()
            reviewState5ImageView.image = UIImage()
        case 1:
            reviewState1IndicatorView.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState3IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState4IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            
            reviewState2ImageView.image = UIImage()
            reviewState3ImageView.image = UIImage()
            reviewState4ImageView.image = UIImage()
            reviewState5ImageView.image = UIImage()
        case 2:
            reviewState1IndicatorView.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2IndicatorView.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState4IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            
            reviewState3ImageView.image = UIImage()
            reviewState4ImageView.image = UIImage()
            reviewState5ImageView.image = UIImage()
        case 3:
            reviewState1IndicatorView.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2IndicatorView.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3IndicatorView.backgroundColor = UIColor(named: "ReviewState3Color")
            reviewState4IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            reviewState5IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            
            reviewState4ImageView.image = UIImage()
            reviewState5ImageView.image = UIImage()
        case 4:
            reviewState1IndicatorView.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2IndicatorView.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3IndicatorView.backgroundColor = UIColor(named: "ReviewState3Color")
            reviewState4IndicatorView.backgroundColor = UIColor(named: "ReviewState4Color")
            reviewState5IndicatorView.backgroundColor = UIColor(named: "ReviewStateDefaultColor")
            
            reviewState5ImageView.image = UIImage()
        default:
            reviewState1IndicatorView.backgroundColor = UIColor(named: "ReviewState1Color")
            reviewState2IndicatorView.backgroundColor = UIColor(named: "ReviewState2Color")
            reviewState3IndicatorView.backgroundColor = UIColor(named: "ReviewState3Color")
            reviewState4IndicatorView.backgroundColor = UIColor(named: "ReviewState4Color")
            reviewState5IndicatorView.backgroundColor = UIColor(named: "ReviewState5Color")
        }
    }
    
    
    
    func setReviewState(_ bool: Bool, _ position: Int){
        switch position {
        case 0:
            if bool {
                reviewState1ImageView.image = UIImage(named: "state-done")
            }else{
                reviewState1ImageView.image = UIImage(named: "state-fail")
            }
            break
        case 1:
            if bool {
                reviewState2ImageView.image = UIImage(named: "state-done")
            }else{
                reviewState2ImageView.image = UIImage(named: "state-fail")
            }
            break
        case 2:
            if bool {
                reviewState3ImageView.image = UIImage(named: "state-done")
            }else{
                reviewState3ImageView.image = UIImage(named: "state-fail")
            }
            break
        case 3:
            if bool {
                reviewState4ImageView.image = UIImage(named: "state-done")
            }else{
                reviewState4ImageView.image = UIImage(named: "state-fail")
            }
            break
        case 4:
            if bool {
                reviewState5ImageView.image = UIImage(named: "state-done")
            }else{
                reviewState5ImageView.image = UIImage(named: "state-fail")
            }
            break
        default:
            break
        }
        
        
    }
    
    
    
    func setItemStateDone(_ bool: Bool){
        if bool{
            doneStateMaskView.isHidden = false
            doneStateMaskView.backgroundColor = UIColor(named: "OverlayMaskViewColor")
        }else{
            doneStateMaskView.isHidden = true
            doneStateMaskView.backgroundColor = .clear
        }
    }
    
}
