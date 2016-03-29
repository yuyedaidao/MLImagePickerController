//
//  MLHud.swift
//  MLImagePickerController
//
//  Created by Wang on 16/3/29.
//  Copyright © 2016年 zhanglei. All rights reserved.
//

import UIKit

let MLHudTag = 10086
let MLHudWidthHeight: CGFloat = 100.0
class MLHud: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    private let hudView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func commonInit() {
        self.addSubview(self.hudView)
//        self.hudView.translatesAutoresizingMaskIntoConstraints = false
//        let views = ["hudView" : self.hudView]
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[hudView(width)]-|", options: .AlignAllCenterX, metrics: ["width" : MLHudWidthHeight], views: views))
//        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[hudView(height)]-|", options: .AlignAllCenterY, metrics: ["height" : MLHudWidthHeight], views: views))
        self.hudView.frame = CGRectMake(0, 0, MLHudWidthHeight, MLHudWidthHeight)
//        self.hudView.backgroundColor = UIColor.blueColor()
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.hudView.bounds
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        vibrancyEffectView.frame = blurEffectView.bounds
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        self.hudView.insertSubview(blurEffectView, atIndex: 0)
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), CGRectGetMidY(self.hudView.bounds))
        self.hudView.addSubview(indicator)
        indicator.startAnimating()
        self.hudView.layer.cornerRadius = 10
        self.hudView.clipsToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.hudView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    }
    
    class func show() {
        let window = UIApplication.sharedApplication().delegate?.window!
        var hud = window?.viewWithTag(MLHudTag)
        if hud == nil {
            hud = MLHud(frame: CGRectZero)
            window?.addSubview(hud!)
            hud!.translatesAutoresizingMaskIntoConstraints = false
            window!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(0)-[hud]-(0)-|", options: [.AlignAllLeading,.AlignAllTrailing], metrics: nil, views: ["hud" : hud!]))
            window!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[hud]-(0)-|", options: [.AlignAllTop,.AlignAllBottom], metrics: nil, views: ["hud" : hud!]))
        }
        
    }
    
    class func hide() {
        if let window = UIApplication.sharedApplication().delegate?.window {
            if let view = window?.viewWithTag(MLHudTag) {
                view.removeFromSuperview()
            }
        }
    }
    
    

}
