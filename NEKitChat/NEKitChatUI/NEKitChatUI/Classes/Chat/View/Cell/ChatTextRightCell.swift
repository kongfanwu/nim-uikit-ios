
// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import UIKit

class ChatTextRightCell: ChatBaseRightCell {
    public let textLable = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonUI() {
        textLable.translatesAutoresizingMaskIntoConstraints = false
        textLable.isEnabled = false
        textLable.isUserInteractionEnabled = false
        textLable.numberOfLines = 0
        textLable.font = DefaultTextFont(16)
        bubbleImage.addSubview(textLable)
        NSLayoutConstraint.activate([
            self.textLable.rightAnchor.constraint(equalTo: bubbleImage.rightAnchor, constant: 0),
            self.textLable.leftAnchor.constraint(equalTo: bubbleImage.leftAnchor, constant: 8),
            self.textLable.topAnchor.constraint(equalTo: bubbleImage.topAnchor, constant: 0),
            self.textLable.bottomAnchor.constraint(equalTo: bubbleImage.bottomAnchor, constant: 0)
        ])
    }
    
    override func setModel(_ model: MessageContentModel) {
        super.setModel(model)
        if let m  = model as? MessageTextModel {
//            textView.text = m.text
            textLable.attributedText = m.attributeStr
        }
    }
}


