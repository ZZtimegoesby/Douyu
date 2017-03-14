//
//  MyTabBarItem.swift
//  Douyu1611
//
//  Created by 王博 on 2016/10/8.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit

class MyTabBarItem: UITabBarItem {
    
    //从xib加载后，调用该方法
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orange], for: .selected)
        
    }
}
