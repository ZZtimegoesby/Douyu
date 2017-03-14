//
//  RemmViewController.swift
//  Douyu1611
//
//  Created by qianfeng on 16/10/9.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit
import Alamofire

class RemmViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var dataArray:  [[String:AnyObject]] = []
//    var picDataArray: [URL] = []
    lazy var ZZView = { () -> ZZAutoCollectionView in 
        
        let view = ZZAutoCollectionView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 420 / 1080), collectionViewLayout: UICollectionView.zzLayout())
        
        return view
    }()
    
    @IBOutlet weak var collctionView: UICollectionView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collctionView.register(UINib.init(nibName: "RemmCell", bundle: nil), forCellWithReuseIdentifier: "RemmCell")
        collctionView.register(UINib.init(nibName: "HeaderScrollCell", bundle: nil), forCellWithReuseIdentifier: "HeaderScrollCell")
        
        collctionView.showsVerticalScrollIndicator = false
        Alamofire.request("http://capi.douyucdn.cn/api/v1/slide/6?aid=ios&client_sys=ios&time=" + String(format: "%d", Date().timeIntervalSince1970) + "&version=2.10").responseJSON(completionHandler: { (response) in
            
            if let json = response.result.value {
                
                let dic = json as! NSDictionary
                
                for temp in dic["data"] as! NSArray {
                    
                    let model = temp as! NSDictionary
                    
                    let url = URL(string: model["tv_pic_url"] as! String)
                    
                    self.ZZView.pictureArray.append(url!)
                }
            }
            Alamofire.request("http://capi.douyucdn.cn/api/v1/getCustomRoom?aid=ios&client_sys=ios&time=" + String(format: "%d", Date().timeIntervalSince1970)).responseJSON(completionHandler: { (response) in
                
                if let json = response.result.value {
                    
                    let dic = json as! NSDictionary
                    
                    self.dataArray = dic["data"] as! [[String:AnyObject]]
                    
                    self.dataArray.insert(["":"" as AnyObject], at: 0)
                    
                    self.collctionView.reloadData()
                }
            })
            self.ZZView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
        } else {
            
            let data = dataArray[section]
            
            if let room_list = data["room_list"] as? [[String:AnyObject]] {
                
                return room_list.count
            }
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderScrollCell", for: indexPath) as! HeaderScrollCell
            
            cell.ZZCollectionView.addSubview(ZZView)
            
            ZZView.createPageViewOnCarousel(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.width * 420 / 1080 - 15, width: UIScreen.main.bounds.width, height: 15), subView: cell.ZZCollectionView, 圆点选中颜色: nil, 圆点未选中颜色: nil)
            
            return cell
            
        } else {

            let data = dataArray[indexPath.section]

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemmCell", for: indexPath) as! RemmCell
            
            if let roomdic = (data["room_list"] as? [[String:AnyObject]])?[indexPath.item] {
                
                cell.roomTitleLabel.text = roomdic["room_name"] as? String
                cell.nickNameLabel.text = roomdic["nickname"] as? String
                
                let onlineNumber = roomdic["online"] as! Int
                
                if onlineNumber >= 10000 {
                    
                    cell.onlineLabel.text = String.init(format: "%.1f万", Double(onlineNumber)/10000.0)
                } else {
                    
                    cell.onlineLabel.text = String.init(format: "%.1d", onlineNumber)
                }
                
                //加载网络图片库方法
                cell.img.af_setImage(withURL: URL.init(string: (roomdic["room_src"] as! String))!, placeholderImage: #imageLiteral(resourceName: "Img_default"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let header = collctionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionHeaderView
            
            let data = dataArray[indexPath.section]
            
            header.SectionName.text = data["tag_name"] as? String
            
            header.callback = { () in
                
                print("点击的是" + String(indexPath.section))
            }
            
            return header
        } else {
            
            let footer = collctionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = dataArray[indexPath.section]
        
        if let roomdic = (data["room_list"] as? [[String:AnyObject]])?[indexPath.item] {
            
            //通过storyborad获得视图控制器
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "LiveViewController") as! LiveViewController
            
            VC.roomid = roomdic["room_id"] as! String
            
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            return CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 420 / 1080)
        } else {
            
            let cellWidth = (UIScreen.main.bounds.width - 30) / 2
            
            return CGSize(width: cellWidth, height: cellWidth * 193 / 345 + 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            
            return CGSize.init(width: 414, height: 0)
        }
        return CGSize.init(width: 414, height: 40)
    }
    
    override var shouldAutorotate: Bool {
        
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        //只支持竖屏
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
