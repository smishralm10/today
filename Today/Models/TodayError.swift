//
//  TodayError.swift
//  Today
//
//  Created by Shreyansh Mishra on 13/12/22.
//

import Foundation

enum TodayError: LocalizedError {
    case accessDenied
    case accessRestricted
    case failedReadingReminders
    case failedReadingCalendar
    case failedReadingCalendarItem
    case noSourceAvailable
    case reminderHasNoDueDate
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("The app doesn't have access to read reminders", comment: "access denied error description")
        case .accessRestricted:
            return NSLocalizedString("This device doesn't allow access to reminder", comment: "access restricted error description")
        case .failedReadingCalendarItem:
            return NSLocalizedString("Failed to read a calendar item", comment: "failed to read calendar item error description")
        case .failedReadingReminders:
            return NSLocalizedString("Failed to read reminders", comment: "failed reading reminders error description")
        case .reminderHasNoDueDate:
            return NSLocalizedString("Reminder has no due date", comment: "reminder has no due date error description")
        case .failedReadingCalendar:
            return NSLocalizedString("Failed to read calendar", comment: "failed reading calendar error description")
        case .noSourceAvailable:
            return NSLocalizedString("No source for calendar is available", comment: "no source available error description")
        case .unknown:
            return NSLocalizedString("An unknown error occured", comment: "unknown error description")
        }
    }
}
