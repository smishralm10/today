//
//  SectionBackgroundDecorationItem.swift
//  Today
//
//  Created by Shreyansh Mishra on 26/12/22.
//

import Foundation
import UIKit

class SectionBackgroundDecorationItem: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func configure() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
    }
}
