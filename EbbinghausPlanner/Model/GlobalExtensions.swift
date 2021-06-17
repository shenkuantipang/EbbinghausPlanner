//
//  GlobalExtensions.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/02.
//

import UIKit
import FSCalendar

public extension UIColor {
      func toHexString() -> String {
          var r:CGFloat = 0
          var g:CGFloat = 0
          var b:CGFloat = 0
          var a:CGFloat = 0

          getRed(&r, green: &g, blue: &b, alpha: &a)

          let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

          return String(format:"#%06x", rgb)
      }
    
    convenience init(hexString: String) {
            let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int = UInt64()
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
  }


public extension UIImage {

    func addBackgroundCircle(_ color: UIColor?) -> UIImage? {

        let circleSize = CGSize(width: 50, height: 50)
        let circleFrame = CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        let imageFrame = CGRect(x: circleSize.width / 2 - 10, y: circleSize.width / 2 - 10, width: 20, height: 20)

        let view = UIView(frame: circleFrame)
        view.backgroundColor = color ?? .systemRed
        view.layer.cornerRadius = circleSize.width * 0.5

        UIGraphicsBeginImageContextWithOptions(circleSize, false, UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: circleSize)
        let circleImage = renderer.image { ctx in
            view.drawHierarchy(in: circleFrame, afterScreenUpdates: true)
        }

        circleImage.draw(in: circleFrame, blendMode: .normal, alpha: 1.0)
        draw(in: imageFrame, blendMode: .normal, alpha: 1.0)

        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
    
    
    func addBackgroundRect(_ cellHeight: CGFloat,_ color: UIColor?) -> UIImage?{
        
        
        let rectSize = CGSize(width: 70, height: cellHeight)
        let rectFrame = CGRect(x: 0, y: 0, width: rectSize.width, height: rectSize.height)
        let imageFrame = CGRect(x: rectSize.width * 0.5 - 12.5, y: rectSize.height * 0.5 - 12.5, width: 25, height: 25)
        
        print("Log width: \(rectSize.width) height: \(rectSize.height)")

        let view = UIView(frame: rectFrame)
        view.backgroundColor = color ?? UIColor(named: "TaskItemBackgroundColor")
        view.layer.cornerRadius = 15
    

        // begin drawing image with rect background
        UIGraphicsBeginImageContextWithOptions(rectSize, false, UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: rectSize)
        let rectImage = renderer.image { ctx in
            view.drawHierarchy(in: rectFrame, afterScreenUpdates: true)
        }

        rectImage.draw(in: rectFrame, blendMode: .normal, alpha: 1.0)
        draw(in: imageFrame, blendMode: .normal, alpha: 1.0)

        // get result drawing
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        // finish drawing
        UIGraphicsEndImageContext()

        return image
    }
}



public extension Date{
    
    func toMinutes() -> Float{
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        
        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "mm"
        
        let hour = Float(hourFormatter.string(from: self))
        let minute = Float(minuteFormatter.string(from: self))
        
        let fullMinutes = (hour! * 60) + minute!
        
        
        return fullMinutes
    }
    
    
    func toHourMinutes(_ time: Int) -> Date{
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let hour = time / 60
        let minute = time % 60
        
        let timeString = "\(hour):\(minute)"
        let date = timeFormatter.date(from: timeString)!
        
        
        return date
    }
    
    
    func decreaseTimeWithMultiplier(_ multiplier: Float) -> Date{
        
        let minutes = self.toMinutes()
        let decreasedTime = minutes - (minutes * multiplier)
        
        let decreasedDate = toHourMinutes(Int(decreasedTime))
        
        
        return decreasedDate
    }
    
    
    func toFormattedTime() -> String{
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let formattedTime = timeFormatter.string(from: self)
        
        
        return formattedTime
    }
}



public extension UITextView{
    
    // UITextview center vertical alignment extension
    func alignTextVertically(){
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }
}



public extension Date{
    
    // returns yyyy-MM-dd formate date
    var comparableDate: String{ // this variable will return comparable date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let comparableString = dateFormatter.string(from: self)
        
        return comparableString
    }
    
    // returns HH:mm formate time
    var formattedTime: String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let formattedTime = timeFormatter.string(from: self)
        
        return formattedTime
    }
    
    
    // returns M/d formate date
    var formattedDate: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let formattedDate = dateFormatter.string(from: self)
        
        return formattedDate
    }
}


public extension String{
    
    // HH:mm format to Date() type
    var formattedTime: Date{
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        guard let formattedTime = timeFormatter.date(from: self) else { return Date() }
        
        return formattedTime
    }
    
    
    // M/d format to Date() type
    var formattedDate: Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        guard let restoredDate = dateFormatter.date(from: self) else { return Date() }
        
        return restoredDate
    }
}


public extension FSCalendar{
    func setCalendarScopeToWeek(){
        DispatchQueue.main.async {
            if self.scope == .month{
                self.scope = .week
                
                self.alpha = 0.2
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1
                }
            }
        }
    }
    
    func setCalendarScopeToMonth(){
        DispatchQueue.main.async {
            if self.scope == .week{
                self.scope = .month
                
                self.alpha = 0.2
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1
                }
            }
        }
        
        
    }
}
