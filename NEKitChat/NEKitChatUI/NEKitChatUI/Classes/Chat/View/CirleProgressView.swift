
// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import UIKit

class CirleProgressView: UIView {
//    0~1
    public var progress: Float = 0 {
        didSet {
            if progress == 0 {
                self.borderLayer.isHidden = true
                self.sectorLayer.isHidden = true
                self.imageView.isHidden = false
                self.imageView.image = UIImage.ne_imageNamed(name: "chat_unread")
            }else if progress == 1.0 {
                self.borderLayer.isHidden = true
                self.sectorLayer.isHidden = true
                self.imageView.isHidden = false
                self.imageView.image = UIImage.ne_imageNamed(name: "chat_read_all")
            }else {
                self.imageView.isHidden = true
                self.borderLayer.isHidden = false
                self.sectorLayer.isHidden = false
                drawCircle(progress: progress)
            }
        }
    }
    private var borderLayer = CAShapeLayer()
    private var sectorLayer = CAShapeLayer()
    private var imageView = UIImageView.init(image: UIImage.ne_imageNamed(name: "chat_unread"))
    
//    override func draw(_ rect: CGRect) {
//        drawCircle(progress: progress)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        imageView.frame = self.bounds
        imageView.contentMode = .center
        self.addSubview(imageView)
        
        let borderPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: 8, startAngle:0, endAngle: 2 * Double.pi, clockwise: false)
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = UIColor.ne_blueText.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2
        borderLayer.frame = self.bounds
        layer.addSublayer(borderLayer)
        
        sectorLayer.frame = self.bounds
        layer.addSublayer(sectorLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func drawCircle(progress: Float) {
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let start = -Float.pi / 2.0
        let end = start + (progress * 2 * Float.pi)
        
        let sectorPath = UIBezierPath(arcCenter: center, radius: 8, startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: true)
        sectorPath.addLine(to: center)
        sectorLayer.path = sectorPath.cgPath
        sectorLayer.fillColor = UIColor.ne_blueText.cgColor
    }

}
