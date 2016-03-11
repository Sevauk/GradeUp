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
    var origin: CGPoint!
    var rightAction: (() -> ())?
    var leftAction: (() -> ())?
    
    var upView: UIView!
    var downView: UIView!
    
    let addView: () -> UIView
    
    init(addView: () -> UIView) {

        self.addView = addView
        
        super.init()

        putViewBehind(callAddView())

        origin = upView.center
    }

    var pg: UIPanGestureRecognizer!
    
    func callAddView() -> UIView {
        let v = addView()
        let newLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        newLabel.text = "Hello World"
        newLabel.clipsToBounds = true
        newLabel.layer.borderWidth = 3
        v.addSubview(newLabel)
        return v
    }
    
    func putViewBehind(which: UIView) {

        self.upView = which
        which.superview!.bringSubviewToFront(which)
        which.userInteractionEnabled = true
        pg = UIPanGestureRecognizer(target: self, action: Selector("drag:"))
        which.addGestureRecognizer(pg)
        
        downView = callAddView()
        downView.superview!.sendSubviewToBack(downView)
    }
    
    func reset() {

        UIView.animateWithDuration(0.2, animations: {
            self.upView.center = self.origin
            self.upView.transform = CGAffineTransformMakeRotation(0)
        })
    }
  
    func swipe(right: Bool) {
        
        
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
