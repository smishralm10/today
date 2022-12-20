//
//  Reminder+EKReminder.swift
//  Today
//
//  Created by Shreyansh Mishra on 13/12/22.
//

import Foundation
import UIKit.UIColor
import EventKit

extension Reminder {
    init(with ekReminder: EKReminder, calendar: EKCalendar) throws {
        guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
            throw TodayError.reminderHasNoDueDate
        }
        id = ekReminder.calendarItemIdentifier
        title = ekReminder.title
        self.dueDate = dueDate
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
        list = List(id: calendar.calendarIdentifier, name: calendar.title, color: UIColor(cgColor: calendar.cgColor))
    }
}
