//
//  ReminderViewController+Row.swift
//  Today
//
//  Created by Shreyansh Mishra on 30/11/22.
//

import Foundation
import UIKit

extension ReminderViewController {
    
    enum Row: Hashable {
        case header(String)
        case viewDate
        case viewTitle
        case viewNotes
        case viewTime
        
        var imageName: String? {
            switch self {
            case .viewDate: return "calendar.circle"
            case .viewTime: return "clock"
            case .viewNotes: return "square.and.pencil"
            default: return nil
            }
        }
        
        var image: UIImage? {
            guard let imageName = imageName else {
                return nil
            }
            let imageConfig = UIImage.SymbolConfiguration(textStyle: .headline)
            return UIImage(systemName: imageName, withConfiguration: imageConfig)
        }
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .viewTitle: return .headline
            default: return .subheadline
            }
        }
    }
}
