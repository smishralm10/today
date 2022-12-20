//
//  List.swift
//  Today
//
//  Created by Shreyansh Mishra on 18/12/22.
//

import Foundation
import UIKit.UIColor

struct List: Equatable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var color: UIColor = .systemBlue
}

extension Array where Element == List {
    func indexOfList(with id: List.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError()
        }
        return index
    }
}


#if DEBUG
extension List {
    static var sampleData = [
        List(name: "My Reminders"),
        List(name: "Groceries", color: .systemPurple),
        List(name: "Task", color: .systemRed),
    ]
}
#endif
