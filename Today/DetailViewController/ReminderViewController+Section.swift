//
//  ReminderViewController+Section.swift
//  Today
//
//  Created by Shreyansh Mishra on 01/12/22.
//

import Foundation

extension ReminderViewController {
    enum Section: Int, Hashable {
        case view
        case title
        case notes
        case date
        case list
        
        var name: String {
            switch self {
            case .view:
                return ""
            case .title:
                return NSLocalizedString("Title", comment: "Title section name")
            case .notes:
                return NSLocalizedString("Notes", comment: "Notes section name")
            case .date:
                return NSLocalizedString("Date", comment: "Date section name")
            default:
                return ""
            }
        }
    }
}
