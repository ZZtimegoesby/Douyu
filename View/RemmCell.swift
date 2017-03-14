//
//  RemmCell.swift
//  Douyu1611
//
//  Created by qianfeng on 16/10/9.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit

class RemmCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var blackImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var onlineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
