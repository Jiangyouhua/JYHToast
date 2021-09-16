//
//  JYHToast.swift
//  JYHComponents
//
//  Created by 姜友华 on 2021/9/16.
//

import UIKit

public struct JYHToast {
    public enum Position {
        case top(CGFloat = 0)
        case middle(CGFloat = 0)
        case bottom(CGFloat = 0)
    }
    
    public enum Setting {
        case position(Position)
        case foreColor(UIColor)
        case backColor(UIColor)
        case fontSize(CGFloat)
        case radiusSize(CGFloat)
        case duration(TimeInterval)
    }
    
    var position: Position = .middle()
    var foreColor: UIColor = .white
    var backColor: UIColor = UIColor(displayP3Red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    var fontSize: CGFloat = 16
    var radiusSize: CGFloat = 5
    var duration: TimeInterval = 3
    
    // Global default settings.
    static var setting = JYHToast()
    // Change global default settings.
    static func config(_ settings: Setting ...){
        JYHToast.change(obj:&JYHToast.setting, settings: settings)
    }
    
    // Change obj Settings.
    static func change(obj: inout JYHToast, settings: [Setting]) {
        for setting in settings {
            switch setting {
            case let .position(position):
                obj.position = position
            case let .foreColor(color):
                obj.foreColor = color
            case let .backColor(color):
                obj.backColor = color
            case let .fontSize(size):
                obj.fontSize = size
            case let .radiusSize(size):
                obj.radiusSize = size
            case let .duration(interval):
                obj.duration = interval
            }
        }
    }
    
    func toast(message: String){
        if message.isEmpty {
            return
        }
        
        guard let view = self.topView() else {
            return
        }
        
        let padding: CGFloat = 18
        
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width - self.fontSize * 4, height: CGFloat.greatestFiniteMagnitude))
        label.text = message
        label.font = .systemFont(ofSize: self.fontSize)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.textColor = self.foreColor
        label.sizeToFit()
        
        let back = UIView()
        back.frame = CGRect(origin: label.frame.origin, size: CGSize(width: label.frame.width + padding * 2, height: label.frame.height + padding))
        back.layer.cornerRadius = self.radiusSize
        back.backgroundColor = self.backColor
        back.addSubview(label)
        back.alpha = 0.0
        label.center = back.center
        
        DispatchQueue.main.async {
            view.addSubview(back)
            view.bringSubview(toFront: back)
            switch self.position {
            case let .top(offset):
                back.center = CGPoint(x: view.center.x, y: back.frame.height + padding - offset)
            case let .middle(offset):
                back.center = CGPoint(x: view.center.x, y: view.center.y - offset)
            case let .bottom(offset):
                back.center = CGPoint(x: view.center.x, y: view.frame.height - back.frame.height - padding - offset)
            }
            
            UIView.animate(withDuration: 0.5){
                back.alpha = 1.0
            }
            
            Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false) { timer in
                UIView.animate(withDuration: 0.5) {
                    back.alpha = 0.0
                } completion: { _ in
                    back.removeFromSuperview()
                }
                timer.invalidate()
            }
        }
    }
    
    private func topView() -> UIView? {
        if var topVC = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topVC.presentedViewController {
                topVC = presentedViewController
            }
            return topVC.view
        }
        return nil
    }
}

// Show Toast.
// Settings can be specified for each call.
public func toast(_ message: String?, _ settings: JYHToast.Setting ...) {
    guard let text = message else {
        return
    }
    var t = JYHToast(position: JYHToast.setting.position, foreColor: JYHToast.setting.foreColor, backColor: JYHToast.setting.backColor, fontSize: JYHToast.setting.fontSize, duration: JYHToast.setting.duration)
    JYHToast.change(obj: &t, settings: settings)
    t.toast(message: text)
}
