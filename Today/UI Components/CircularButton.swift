//
//  AddButton.swift
//  Today
//
//  Created by Shreyansh Mishra on 21/12/22.
//

import Foundation
import UIKit

class CircularButton: UIButton {
    private let width: CGFloat
    
    init(ofWidth width: CGFloat) {
        self.width = width
        super.init(frame: .zero)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureButton() {
        self.layer.shadowRadius = 10
        self.layer.cornerRadius = (width) / 2
        self.layer.shadowOpacity = 0.3
    }
}
