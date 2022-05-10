
// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import UIKit

@objc public protocol EmojiPageViewDataSource: AnyObject {
    @objc optional func numberOfPages(pageView: EmojiPageView?) -> NSInteger
    @objc optional func pageView(pageView: EmojiPageView?,index:NSInteger) ->UIView
}

@objc public protocol EmojiPageViewDelegate: AnyObject {
   
    @objc optional func pageViewScrollEnd(
        _ pageView: EmojiPageView?,
        currentIndex: Int,
        totolPages : Int)

    @objc optional func pageViewDidScroll(_ pageView: EmojiPageView?)
    @objc optional func needScrollAnimation() -> Bool
}

public class EmojiPageView: UIView {
    
    public weak var dataSource: EmojiPageViewDataSource?
    public weak var pageViewDelegate: EmojiPageViewDelegate?
    private var currentPage:NSInteger = 0
    private var pages = [AnyObject]()
    private let className = "EmojiPageView"
     
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var frame: CGRect {
        set {
            let originalWidth = self.width
            super.frame = newValue
            if originalWidth != frame.size.width {
                self.reloadData()
            }
        }
        get {
            return super.frame
        }
    }
    
    func setupControls(){
        self.addSubview(scrollView)
    }
    
    
    public func scrollToPage(page:NSInteger){
        if currentPage != page || page == 0 {
            currentPage = page
            reloadData()
        }
    }

   public func reloadData(){
       calculatePageNumbers()
       setupInit()
//       reloadPage()
    }
    
    func viewAtIndex(index:NSInteger)->UIView?{
        
        if index >= 0 && index < pages.count{
            let obj = pages[index]
            if obj.isKind(of: UIView.self) {
                return obj as? UIView
            }
        }
        return nil
    }

    func reloadPage(){
        //reload时候记录上次位置
//        guard let cPage = currentPage else {
//            QChatLog.errorLog(className, desc: "❌currentPage is nil")
//            return
//        }
        if currentPage >= pages.count {
            currentPage = pages.count - 1
        }
        if currentPage < 0 {
            currentPage = 0
        }
        loadPages(currentPage: currentPage)
        raisePageIndexChangedDelegate()
        setNeedsLayout()
    }
    
    func calculatePageNumbers(){

        var numberOfPages = 0
        for obj in pages {
            if obj.isKind(of: UIView.self) {
                obj.removeFromSuperview()
            }
        }
        numberOfPages = dataSource?.numberOfPages?(pageView: self) ?? 0
        
        for _ in 0..<numberOfPages {
            pages.append(NSNull())
        }
        scrollView.delegate = nil
        let size = self.bounds.size
        scrollView.contentSize = CGSize.init(width: size.width*CGFloat(numberOfPages), height: size.height)
        scrollView.delegate = nil
    }
    
    
    func pageInBound(value:NSInteger,min:NSInteger, max: NSInteger) -> NSInteger {
        
        var maxUse = max
        
        if maxUse < min {
            maxUse = min
        }
        var bounded = value
        if bounded > maxUse {
            bounded = maxUse
        }
        if bounded < min {
            bounded = min
        }
        return bounded
    }
    
    func setupInit(){
        let count = pages.count
        for i in (0..<count) {
            if let targetView = dataSource?.pageView?(pageView: self, index: i) {
                pages[i] = targetView
                scrollView.addSubview(targetView)
                let size = self.bounds.size
                targetView.frame = CGRect.init(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height)
            }
        }
    }
    
    //page载入和销毁
    func loadPages(currentPage:NSInteger?){
        let count = pages.count
        if count == 0 {
            return
        }
        guard let curPage = currentPage else {
            return
        }
        
        let first = pageInBound(value: curPage - 1 , min: 0, max: count - 1)
        let last = pageInBound(value: curPage + 1, min: 0, max: count - 1)
        let range = NSRange.init(location: first, length: last - first + 1)
        for i in (0..<count) {
            if NSLocationInRange(i, range) {
                let obj = pages[i]
                if !obj.isKind(of: UIView.self) {
                    
                    if let targetView = dataSource?.pageView?(pageView: self, index: i) {
                        pages[i] = targetView
                        scrollView.addSubview(targetView)
                        let size = self.bounds.size
                        targetView.frame = CGRect.init(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height)
                    }else {
                        assert(false)
                    }
                    
                }
            }else {
                let obj = pages[i]
                if obj.isKind(of: UIView.self) {
                    obj.removeFromSuperview()
                    pages[i] = NSNull()
                }
                
            }
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        scrollView.contentSize = CGSize.init(width: size.width * CGFloat(pages.count), height: size.height)
        
        for i in 0..<pages.count {
            let obj = pages[i]
            if obj.isKind(of: UIView.self) {
                (obj as! UIView).frame = CGRect.init(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height)
            }
        }
        
//        for obj in pages {
//            if obj.isKind(of: UIView.self) {
//              (obj as! UIView).frame = CGRect.init(x: size.width, y: 0, width: size.width, height: size.height)
//            }
//        }
        let animation = pageViewDelegate?.needScrollAnimation?()
//        if let current = currentPage {
            scrollView.scrollRectToVisible(CGRect.init(x: CGFloat(currentPage)*size.width, y: 0, width: size.width, height: size.height), animated: animation ?? false)
//        }
    }
    
    
    
    //MARK: private method
    private lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView.init(frame: self.bounds)
        scrollView.autoresizingMask = .flexibleWidth
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        return scrollView
    }()
    
    //MARK: 辅助方法
    func raisePageIndexChangedDelegate(){
        pageViewDelegate?.pageViewScrollEnd?(self, currentIndex: currentPage, totolPages: pages.count)
    }
    
}


extension EmojiPageView:UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let offsetX = scrollView.contentOffset.x
        let page = Int(abs(offsetX/width))
        if page >= 0 && page < pages.count {
            if currentPage == page {
                return
            }
            currentPage = page
            loadPages(currentPage: currentPage )
        }
        
        pageViewDelegate?.pageViewDidScroll?(self)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageViewDelegate?.pageViewScrollEnd?(self, currentIndex: currentPage, totolPages: pages.count)
    }
}
