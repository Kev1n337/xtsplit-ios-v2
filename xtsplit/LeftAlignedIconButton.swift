//
//  LeftAlignedIconButton.swift
//  xtsplit
//
//  Created by Kevin Linne on 06.04.17.
//  Copyright © 2017 XTsolutions. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LeftAlignedIconButton: UIButton {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentHorizontalAlignment = .left
        let availableSpace = UIEdgeInsetsInsetRect(bounds, contentEdgeInsets)
        let availableWidth = availableSpace.width - imageEdgeInsets.right - (imageView?.frame.width ?? 0) - (titleLabel?.frame.width ?? 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: availableWidth / 2, bottom: 0, right: 0)
        
    }
}
