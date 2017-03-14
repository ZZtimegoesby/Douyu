//
//  ZZAutoCollectionView.swift
//  aMyAutoScrolling
//
//  Created by qianfeng on 16/9/12.
//  Copyright © 2016年 张政. All rights reserved.
//

import UIKit
import AlamofireImage

//扩展UICollectionView
extension UICollectionView {
    
    class func zzLayout() -> UICollectionViewFlowLayout {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        return layout
    }
}

class ZZAutoCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

//MARK: ------------ 需要调用的属性及方法 --------------
    
    /**  网格图片数组  */
    lazy var pictureArray: [URL] = []
    
    /**  label内容数组  */
    lazy var labelArray: [String] = []
    
    /**  图片类型  */
    lazy var imageType = ""
    
    /**  书页管理器  */
    var page: UIPageControl?
    
    /**  轮播文本标签  */
    var label: UILabel?
    
    /**
     
     创建pageControl的方法函数。 第一个参数为frame，第二个参数为需要添加page的视图view，第三个参数为page圆点选中时的颜色，第四个参数为page圆点未选中时的颜色
     
     */
    func createPageViewOnCarousel(frame pageframe: CGRect, subView: UIView, 圆点选中颜色 currentPageIndecatorColor: UIColor?, 圆点未选中颜色 pageIndictorColor: UIColor?) -> Void {
        
        page = UIPageControl.init(frame: pageframe)
        page!.numberOfPages = pictureArray.count
        
        page?.currentPageIndicatorTintColor = currentPageIndecatorColor
        page?.pageIndicatorTintColor = pageIndictorColor
        
        subView.addSubview(page!)
    }
    
    /**
     
     创建label的方法函数。 第一个参数为frame，第二个参数为需要添加label的视图view，第三个参数为label上字体的大小
     
     */
    func createLabelOnCarousel(frame pageframe: CGRect, subView: UIView, fontSize: CGFloat) -> Void {
        
        label = UILabel.init(frame: pageframe)
        
        label?.text = labelArray[0]
        
        label?.textAlignment = .center
        
        label?.textColor = UIColor.white
        
        label?.font = UIFont.systemFont(ofSize: fontSize)
        
        subView.addSubview(label!)
    }
    
    /**
     
     创建轮播构造方法。  第一个参数为frame， 第二个参数为设置collectionView的滑动方向，需要传入UICollectionView.zzLayout()
     
     */
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.backgroundColor = UIColor.white
        
        self.delegate = self
        self.dataSource = self
        
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false

        registerMyCell()
        createTimer()
    }
    
    let width = UIScreen.main.bounds.width
    var timer: Timer?
    
//MARK： --------------- 创建计时器与计时器方法 -------------------
    
    private func createTimer() -> Void {
        
        timer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(self.addTimer), userInfo: nil, repeats: true)
        
        //解决线程冲突
        RunLoop.current.add(timer!, forMode: .UITrackingRunLoopMode)
    }
    
    @objc private func addTimer() -> Void {
        
        //通过设置偏移量，改变轮播的图片
        self.setContentOffset(CGPoint.init(x: self.contentOffset.x + width, y: 0), animated: true)
        
        if self.contentOffset.x == width * CGFloat(pictureArray.count) {
            
            self.contentOffset = CGPoint.init(x: 0, y: 0)
        }
    }
    
//MARK：---------------- 轮播滚动改变page的方法 --------------------
    
    private func doScrollingChangeCurrentPage(scrollView: UIScrollView) -> Void {
        
        let indexPage = Int(scrollView.contentOffset.x / width) % (pictureArray.count)
        
        page?.currentPage = indexPage
        
        label?.text = labelArray[indexPage]
    }
    
    private func registerMyCell() {
        
        let nib = UINib(nibName: "MyCell", bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: "MyCell")
    }
    
//MARK: -------------------- collectionView相关协议方法 --------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath) as! MyCell
        
        if indexPath.item == pictureArray.count {
            
            cell.imageView.af_setImage(withURL: pictureArray[0], placeholderImage: #imageLiteral(resourceName: "Img_default"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: true, completion: nil)
            
        } else {
            
            cell.imageView.af_setImage(withURL: pictureArray[indexPath.item], placeholderImage: #imageLiteral(resourceName: "Img_default"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: true, completion: nil)
        }
        
        return cell
    }
    
    //设置网格的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: self.frame.width, height: self.frame.height)
    }
    
    //设置网格间最小行距, 默认最小行距为10
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    
//MARK: ----------- scrollView 相关协议方法 ----------------
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        doScrollingChangeCurrentPage(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        doScrollingChangeCurrentPage(scrollView: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        timer?.invalidate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        createTimer()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
