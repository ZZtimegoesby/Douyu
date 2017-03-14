//
//  CustomNacigationController.swift
//  Douyu1611
//
//  Created by qianfeng on 16/10/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit

class CustomNacigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if let vc = topViewController {
            
            return vc.supportedInterfaceOrientations
        }
        
        return .portrait
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
