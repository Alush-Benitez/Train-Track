//
//  PopUpAnimation.swift
//  Chi Transit
//
//  Created by Alush Benitez on 6/11/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import Foundation

import UIKit
protocol PopUpAnimation {
    func show(animated:Bool)
    func dismiss(animated:Bool)
    var backgroundView:UIView {get}
    var dialogView:UIView {get set}
}
extension PopUpAnimation where Self:UIView{
    func show(animated:Bool){
        self.backgroundView.alpha = 0
        self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        if animated {
            
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0.8
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 9, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.dialogView.center  = self.center
            }, completion: { (completed) in
            })
        }else{
            self.backgroundView.alpha = 0.66
            self.dialogView.center  = self.center
        }

        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    func dismiss(animated:Bool){
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (completed) in
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }else{
            self.removeFromSuperview()
        }
    }
}
