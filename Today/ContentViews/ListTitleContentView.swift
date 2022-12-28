//
//  ListTitleContentView.swift
//  Today
//
//  Created by Shreyansh Mishra on 26/12/22.
//

import Foundation
import UIKit

class ListTitleContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        var text: String? = ""
        var tintColor: UIColor? = nil
        var onChange: (String, UIColor?) -> Void = { _, _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return ListTitleContentView(self)
        }
    }
    
    let textField = UITextField()
    var configuration: UIContentConfiguration {
        didSet {
            configuration(configuration: configuration)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubview(textField, height: 44, insets: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24))
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        textField.backgroundColor = .systemGray3
        textField.textAlignment = .center
        textField.placeholder = "List Name"
        textField.layer.cornerRadius = 24
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
        textField.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didChange(_ sender: UITextField) {
        guard let configuration = configuration as? ListTitleContentView.Configuration else { return }
        configuration.onChange(textField.text ?? "", textField.textColor)
    }
    
    func configuration(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
        textField.textColor = configuration.tintColor
    }
}

extension UICollectionViewCell {
    func titleConfiguration() -> ListTitleContentView.Configuration {
        ListTitleContentView.Configuration()
    }
}
