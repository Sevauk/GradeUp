//
//  TinderSwipe.swift
//  GradeUp
//
//  Created by Adrien morel on 2/20/16.
//  Copyright © 2016 Adrien morel. All rights reserved.
//

import UIKit


class Swiper: NSObject {

    
    var att: UIAttachmentBehavior!
    var leftLabel: UILabel?
    let leftLabelColor = UIColor(red: 76.0 / 255, green: 156.0 / 255, blue: 138.0 / 255, alpha: 1)
    var rightLabel: UILabel?
    let rightLabelColor = UIColor(red: 176.0 / 255, green: 70.0 / 255, blue: 77.0 / 255, alpha: 1)
    var origin: CGPoint!
    var rightAction: (() -> ())?
    var leftAction: (() -> ())?
    var leftMessage: String? {
        didSet {
            addLeftLabel()
        }
    }
    
    var rightMessage: String? {
        didSet {
            addRightLabel()
        }
    }
    
    func addLeftLabel() {
        leftLabel = tinderLikeStamp()
        upView.addSubview(leftLabel!)
        leftLabel!.layer.cornerRadius = 8
        leftLabel!.layer.borderWidth = 5.0
        leftLabel!.layer.borderColor = leftLabelColor.CGColor
        leftLabel!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4 / 2))
        leftLabel!.text = leftMessage
        leftLabel!.textColor = leftLabelColor
        leftLabel!.font = leftLabel!.font.fontWithSize(30)
        leftLabel!.alpha = 0
        
        leftLabel!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            leftLabel!.leadingAnchor.constraintEqualToAnchor(upView.leadingAnchor, constant: 30),
            leftLabel!.topAnchor.constraintEqualToAnchor(upView.topAnchor, constant: 100)])
    }
    
    func addRightLabel() {
        rightLabel = tinderLikeStamp()
        upView.addSubview(rightLabel!)
        rightLabel!.layer.cornerRadius = 8
        rightLabel!.layer.borderWidth = 5.0
        rightLabel!.layer.borderColor = rightLabelColor.CGColor
        rightLabel!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4 / 2))
        rightLabel!.text = rightMessage
        rightLabel!.textColor = rightLabelColor
        rightLabel!.font = rightLabel!.font.fontWithSize(30)
        rightLabel!.alpha = 0
        
        rightLabel!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            rightLabel!.trailingAnchor.constraintEqualToAnchor(upView.trailingAnchor, constant: -30),
            rightLabel!.topAnchor.constraintEqualToAnchor(upView.topAnchor, constant: 100)])
    }
    
    var upView: UIView!
    var downView: UIView!
    
    let addView: () -> UIView
    
    init(addView: () -> UIView) {
        
        self.addView = addView
        
        super.init()
        putViewBehind(addView())

        origin = upView.center
    }
    
    var pg: UIPanGestureRecognizer!
    
    func putViewBehind(which: UIView) {
        

        
        self.upView = which
        which.superview!.bringSubviewToFront(which)
        which.userInteractionEnabled = true
        pg = UIPanGestureRecognizer(target: self, action: Selector("drag:"))
        which.addGestureRecognizer(pg)
        
        downView = addView()
        downView.superview!.sendSubviewToBack(downView)
        if rightLabel != nil {
            addRightLabel()
        }
        
        if leftLabel != nil {
            addLeftLabel()
        }
    }
    
    func reset() {
        if leftLabel != nil {
            leftLabel?.alpha = 0
        }
        if rightLabel != nil {
            rightLabel?.alpha = 0
        }

        UIView.animateWithDuration(0.2, animations: {
            self.upView.center = self.origin
            self.upView.transform = CGAffineTransformMakeRotation(0)
        })
    }
    
    func swipe(right: Bool) {
        
        UIView.animateWithDuration(0.2 , animations: {
            if let labelToReveal = right ? self.leftLabel : self.rightLabel {
                labelToReveal.alpha = 1
            }
            }, completion: {
                (Bool) in
                
                UIView.animateWithDuration(0.3 , animations: {
                self.upView.center.x =
                    self.origin.x + self.upView.superview!.bounds.width * 2 * (right ? 1 : -1)
                self.rotate(self.upView)
                }, completion: {
                    (Bool) in
                    
                    right ? self.rightAction?() : self.leftAction?()
                    
                    self.upView.removeFromSuperview()
                    self.putViewBehind(self.downView)
                    
            })
        })
            
    }
    
    func rotate(view: UIView) {
        
        let c = view.center
        let degrees: Double = 10 * (Double(c.x) - Double(origin.x)) / (Double(upView.superview!.bounds.width) - Double(origin.x))
        view.transform = CGAffineTransformMakeRotation(CGFloat(degrees * M_PI / 180.0))
    }
    
    func drag(p: UIPanGestureRecognizer!) {
        
        switch p.state {
            
        case .Began:
            origin = upView.center
            
        case .Changed:
            if let rightLabel = self.rightLabel {
                rightLabel.alpha = (origin.x - upView.center.x) / 100 - 0.6
            }
            if let leftLabel = self.leftLabel {
                leftLabel.alpha = -(origin.x - upView.center.x) / 100 - 0.6
            }
            
            let delta = p.translationInView(upView.superview)
            var c = upView.center
            c.x += delta.x
            c.y += delta.y
            upView.center = c
            p.setTranslation(CGPointZero, inView: upView.superview)
            
            rotate(upView)
            
        case .Ended:
            
            let offset = origin.x - upView.center.x
            if abs(offset) > (upView.superview!.bounds.width - origin.x) / 2 {
                swipe(offset < 0)
            } else {
                reset()
            }
            
        default:
            reset()
        }
        
    }
    
}
