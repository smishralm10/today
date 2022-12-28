//
//  EKCalendar+List.swift
//  Today
//
//  Created by Shreyansh Mishra on 21/12/22.
//

import Foundation
import EventKit

extension EKCalendar {
    func update(using list: List, in store: EKEventStore) {
        title = list.name
        cgColor = list.color.cgColor
    }
}
