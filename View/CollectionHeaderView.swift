//
//  CollectionHeaderView.swift
//  Douyu1611
//
//  Created by qianfeng on 16/10/11.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit

class CollectionHeaderView: UICollectionReusableView {
    
    var callback: ((Void)->Void)?
    
    @IBOutlet weak var SectionName: UILabel!
    
    @IBAction func moreAction(_ sender: UIButton) {
        
        if let ck = callback {
            
            ck()
        }
    }
}
