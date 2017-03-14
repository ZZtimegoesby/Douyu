//
//  DanmuView.swift
//  Douyu1611
//
//  Created by qianfeng on 16/10/12.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit

class DanmuView: UIView {

    var messageQueue: [String] = []
    var reuseSet: Set<UILabel> = []
    var labelOnViewSet: Set<UILabel> = []
    var timer: Timer?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        if newSuperview != nil {
            
            timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.refreshAction), userInfo: nil, repeats: true)
        } else {
            
            timer?.invalidate()
            timer = nil
        }
    }
    func refreshAction() -> Void {
        
        var offsetDic: [Int:CGFloat] = [:]
        
        for label in labelOnViewSet {
            
            var frame = label.frame
            frame.origin.x -= 1
            label.frame = frame
            
            let offset = frame.origin.x + frame.size.width
            
            if offset < 0 {
                
                reuseSet.insert(label)
                label.removeFromSuperview()
            } else {
                
                let line = Int(frame.origin.y / label.frame.height)
                
                print(label.frame.height
                    ,   line)
                if let oldOffset = offsetDic[line] {
                    
                    if oldOffset > offset {
                        
                        continue
                    }
                }
                
                offsetDic[line] = offset
            }
        }
        
        for label in reuseSet {
            
            labelOnViewSet.remove(label)
        }
        if messageQueue.count > 0 {
            
            for index in 0..<16 {
                
                if let offset = offsetDic[index] {
                    
                    if offset > self.bounds.size.width {
                        
                        continue
                    }
                }
                
                var label = reuseSet.popFirst()
                if label == nil {
                    
                    label = UILabel()
                    label?.textColor = UIColor.white
                }
                
                if let message = messageQueue.first {
                    
                    label?.text = message
                    label?.font = UIFont.systemFont(ofSize: 19)
                    label?.sizeToFit()
                    var frame = label?.frame
                    frame?.origin.x = self.bounds.size.width
                    frame?.origin.y = CGFloat(25 * index)
                    
                    label?.frame = frame!
                    
                    messageQueue.removeFirst()
                    self.addSubview(label!)
                    labelOnViewSet.insert(label!)
                }
                
            }
        }
        
    }
}
