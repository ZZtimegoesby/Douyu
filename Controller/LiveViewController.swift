//
//  LiveViewController.swift
//  Douyu1611
//
//  Created by qianfeng on 16/10/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class LiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var roomid = "0"
    var roomInfo: [String : AnyObject]?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var timer: Timer?
    //弹幕管理器
    var liveChatManager = LiveChatManager()
    //弹幕数据源
    var chatDataArray: [ChatViewModel] = []
    
    var StatusBarHidden = false
    
    var tableViewfollow = true
    
    @IBOutlet weak var danmuView: DanmuView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newMessBtn: UIButton!
    
//MARK: ----------- 按钮方法 -----------
    // 视频刷新方法
    @IBAction func updateClick(_ sender: UIButton) {
        
        playLive()
    }
    
    //点击newBtn显示新弹幕方法
    @IBAction func newMessageClick(_ sender: UIButton) {
        
        tableViewfollow = true
        
        let indexpath = IndexPath.init(row: chatDataArray.count - 1, section: 0)
        
        tableView.scrollToRow(at: indexpath, at: .bottom, animated: true)
        
        newMessBtn.isHidden = true
    }
    
    // 切换全屏
    @IBAction func fullScreenAction(_ sender: UIButton) {
        
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
    }
    
    // 返回
    @IBAction func backAction(_ sender: UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    // 切换竖屏
    @IBAction func potratScreenAction(_ sender: UIButton) {
        
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    @IBOutlet weak var playUILView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var playerUIPView: UIView!

//MARK: -------- deinit方法 -----------
    deinit {
        
        playView.removeObserver(self, forKeyPath: "bounds")
        liveChatManager.stop()
        timer?.invalidate()
        timer = nil
        print("销毁")
    }
    
//MARK: ------ 监听方法 ---------
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "bounds" {
            
            playerLayer?.frame = playView.bounds
            
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                
                timer?.invalidate()
                
                danmuView.isHidden = false
                playerUIPView.isHidden = true
                
                StatusBarHidden = true
                self.setNeedsStatusBarAppearanceUpdate()
                
            } else {
                
                timer?.invalidate()
                
                danmuView.isHidden = true
                playUILView.isHidden = true
                playerUIPView.isHidden = false
                createTimer()
            }
        }
    }

//MARK:  ------ 播放 -------
    func playLive() -> Void {
        
        timer?.invalidate()
        
        player = AVPlayer()
        
        let playItem = AVPlayerItem(url: URL.init(string: roomInfo!["hls_url"] as! String)!)
        
        player?.replaceCurrentItem(with: playItem)
        
        //清除player层，防止刷新多次创建造成内存泄露
        playerLayer?.removeFromSuperlayer()
        
        playerLayer = AVPlayerLayer.init(player: player!)
        
        playerLayer?.frame = playView.bounds
        
        playView.layer.addSublayer(playerLayer!)
        
        player?.play()
        
        createTimer()
    }

//MARK: ----------- 展示弹幕方法 --------------
    func showMessageOnTabel(m: STTModel) ->Void {
        
        let chatViewModel = ChatViewModel()

        if m.txt != nil {
            
            chatViewModel.message = m.txt
        }
        if m.type != nil {
            
            chatViewModel.type = m.type
        }
        if m.nn != nil {
            
            chatViewModel.nn = m.nn
        }
        if m.gfid != nil {
            
            chatViewModel.gfid = m.gfid
        }
        
        chatDataArray.append(chatViewModel)
        
        if chatDataArray.count > 1000 {
            
            chatDataArray.removeSubrange(Range<Int>.init(uncheckedBounds: (lower: 0, upper: 300)))
            
            tableView.reloadData()
            
            let indexpath = IndexPath.init(row: chatDataArray.count - 1, section: 0)
            tableView.scrollToRow(at: indexpath, at: .bottom, animated: true)
            
            return
        }
        
        let indexpath = IndexPath.init(row: chatDataArray.count - 1, section: 0)
//        tableView.insertRows(at: [indexpath], with: .none)
        tableView.reloadData()
        
        if tableViewfollow == true {
            
            tableView.scrollToRow(at: indexpath, at: .bottom, animated: true)
        }
    }

    func showScrollMessageOnView(m: STTModel) ->Void {
        
        if m.txt == nil {
            return
        }
        let label = UILabel.init()
        
        label.textColor = UIColor.white
        label.text = m.txt
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        let labelWitdh = getLabWidth(labelStr: m.txt, font: label.font, height: 30)
        
        label.frame = CGRect.init(x: UIScreen.main.bounds.width + 80, y: CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.height/20))*20), width: labelWitdh, height: 19)
        
        danmuView.addSubview(label)
        
        UIView.animate(withDuration: 10, animations: {
            
            label.frame.origin.x = -labelWitdh * 2 - 20
            }) { (true) in
                
                label.removeFromSuperview()
        }
    }
    
    func getLabWidth(labelStr:String,font:UIFont,height:CGFloat) -> CGFloat {
        
        let LabelText = labelStr
        
        let size = CGSize.init(width: 900, height: height)
        
        let dic = [NSFontAttributeName : font]
        
        let stringSize = LabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        
        return stringSize.width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 10
        
        Alamofire.request(String.init(format: "http://m.douyu.com/html5/live?roomId=%@", roomid)).responseJSON { (response) in
            
            if let data = (response.result.value as? [String:AnyObject])?["data"] as? [String:AnyObject] {
                
                self.roomInfo = data
                self.playLive()
            }
        }
        
        playView.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        
        liveChatManager.setMessageReceive { [unowned self] (model) in
            
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                
                self.showMessageOnTabel(m: model!)
            } else {

//                self.showScrollMessageOnView(m: model!)
                if let message = model?.txt {
                    
                    self.danmuView.messageQueue.append(message)
                }
            }
        }
        
        liveChatManager.setInfoCallbackBlock { [unowned self] (model) in
            
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                
                self.showMessageOnTabel(m: model!)
            }
        }
        
        liveChatManager.connect(withRoomID: roomid, groupId: "-9999")
        tableView.estimatedRowHeight = 40
    }

//MARK: ------------ touchesBegan方法 ---------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            
            playUILView.isHidden = !playUILView.isHidden
            statusBarAction()
            
            if !playUILView.isHidden {
                createTimer()
            } else {
                timer?.invalidate()
            }
            
        } else {
            
            for spot in touches {
                
                if (spot.view == playerUIPView || spot.view == playView) && spot.view != playUILView {

                    playerUIPView.isHidden = !playerUIPView.isHidden
                    
                    if !playerUIPView.isHidden {
                        
                        createTimer()
                    } else {
                        
                        timer?.invalidate()
                    }
                }
            }
        }
    }
    
//MARK: ----------- timer方法 ----------------
    func createTimer() -> Void {
        
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
    }
    func timerAction() -> Void {
        
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            
            playerUIPView.isHidden = true
        } else {
            
            playUILView.isHidden = true
            statusBarAction()
        }
    }

//MARK: ----------- view出现与消失 ----------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.replaceCurrentItem(with: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
//MARK: ------------ tableView与scrollView代理方法-------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "talkCell", for: indexPath) as! ChatCell
        
        let model = chatDataArray[indexPath.row]
        
        cell.chatLabel.textColor = UIColor.orange
        
        if model.type == "chatmsg" {
            
            cell.chatLabel.textColor = UIColor.black
            
            let nameStr = NSMutableAttributedString(string: model.nn! + "：" + model.message!)
            
            nameStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange.init(location: 0, length: model.nn!.characters.count))
            
            cell.chatLabel.attributedText = nameStr
            
        } else if model.type == "uenter" {
            
            let comeStr = NSMutableAttributedString(string: "欢迎" + model.nn! + "来到本直播间！")
            
            comeStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange.init(location: 2, length: model.nn!.characters.count))
            
            cell.chatLabel.attributedText = comeStr
            
        } else if model.type == "dgb" {
            
            let thankStr = NSMutableAttributedString(string: "感谢" + model.nn! + "赠送的" + model.gfid!)
            
            thankStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange.init(location: 2, length: model.nn!.characters.count))
            
            cell.chatLabel.attributedText = thankStr
            
        }else {
            
            cell.chatLabel.text =  model.message!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }

    var lastContOffset: CGFloat = 0
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        tableViewfollow = false
        lastContOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //判断tableView的滚动方法为向上
        if lastContOffset > scrollView.contentOffset.y {
            
            newMessBtn.isHidden = false
            tableViewfollow = false
        }
        //判断tableView滑动到底部
        if scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y < 10 {
            
            newMessBtn.isHidden = true
            tableViewfollow = true
        }
    }
    
//MARK:    -----------修改状态栏------------------
    func statusBarAction() -> Void {
        
        StatusBarHidden = playUILView.isHidden
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return StatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        
        //添加淡入淡出动画
        return .fade
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
