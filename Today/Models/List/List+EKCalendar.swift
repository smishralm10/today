//
//  List+EKCalendar.swift
//  Today
//
//  Created by Shreyansh Mishra on 19/12/22.
//

import Foundation
import UIKit.UIColor
import EventKit.EKCalendar

extension List {
    init(with calendar: EKCalendar) {
        id = calendar.calendarIdentifier
        name = calendar.title
        color = UIColor(cgColor: calendar.cgColor)
    }
}
