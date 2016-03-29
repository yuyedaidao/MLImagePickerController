//
//  MLHud.swift
//  MLImagePickerController
//
//  Created by Wang on 16/3/29.
//  Copyright © 2016年 zhanglei. All rights reserved.
//

import UIKit

let MLHudTag = 10086

class MLHud: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
//    init(frame: CGRect) {
//        
//    }
    
    class func show() {
        let window = UIApplication.sharedApplication().delegate?.window!
        var hud = window?.viewWithTag(MLHudTag)
        if hud == nil {
            hud = MLHud()
        }
        window?.addSubview(hud!)
    }
    
    class func hide() {
        if let window = UIApplication.sharedApplication().delegate?.window {
            if let view = window?.viewWithTag(MLHudTag) {
                view.removeFromSuperview()
            }
        }
    }
    
    

}
