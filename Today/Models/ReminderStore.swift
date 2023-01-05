//
//  ReminderStore.swift
//  Today
//
//  Created by Shreyansh Mishra on 13/12/22.
//

import Foundation
import EventKit

class ReminderStore {
    static let shared = ReminderStore()
    
    private let ekStore = EKEventStore()
    
    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            return
        case .restricted:
            throw TodayError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestAccess(to: .reminder)
            guard accessGranted else {
                throw TodayError.accessDenied
            }
        case .denied:
            throw TodayError.accessDenied
        @unknown default:
            throw TodayError.unknown
        }
    }
    
    private func read(with id: Reminder.ID) throws -> EKReminder {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw TodayError.failedReadingCalendarItem
        }
        return ekReminder
    }
    
    private func readCalendar(with id: List.ID) throws -> EKCalendar {
        guard let ekCalendar = ekStore.calendar(withIdentifier: id) else {
            throw TodayError.failedReadingCalendar
        }
        return ekCalendar
    }
    
    func getDefaultListForReminder() -> List? {
        guard let ekCalender = ekStore.defaultCalendarForNewReminders() else {
            return nil
        }
        return List(with: ekCalender)
    }
    
    func readAll(with identifier: List.ID? = nil) async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        
        var predicate: NSPredicate
        if let identifier = identifier {
            let calendar = ekStore.calendar(withIdentifier: identifier)!
            predicate = ekStore.predicateForReminders(in: [calendar])
        } else {
            predicate = ekStore.predicateForReminders(in: nil)
        }
        
        let ekReminders = try await ekStore.fetchReminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap({ reminder in
            do {
                return try Reminder(with: reminder)
            } catch TodayError.reminderHasNoDueDate {
                return nil
            }
        })
        
        return reminders
    }
    
    func fetchLists() -> [List] {
        let calendars = ekStore.calendars(for: .reminder)
        let lists: [List] = calendars.map { calendar in
            return List(with: calendar)
        }
        return lists
    }
    
    func remove(with id: Reminder.ID) throws {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder = try read(with: id)
        try ekStore.remove(ekReminder, commit: true)
    }
    
    @discardableResult
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            ekReminder = EKReminder(eventStore: ekStore)
        }
        ekReminder.update(using: reminder, in: ekStore)
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
    
    @discardableResult
    func saveCalendar(_ list: List) throws -> List.ID {
        guard isAvailable else { throw TodayError.accessDenied }
        var ekCalendar: EKCalendar
        
        do {
            ekCalendar = try readCalendar(with: list.id)
        } catch {
            ekCalendar = EKCalendar(for: .reminder, eventStore: ekStore)
        }
        guard let source = getSourceForCalendar() else { throw TodayError.noSourceAvailable }
        ekCalendar.source = source
        ekCalendar.update(using: list, in: ekStore)
        try ekStore.saveCalendar(ekCalendar, commit: true)
        return ekCalendar.calendarIdentifier
    }
    
    private func getSourceForCalendar() -> EKSource? {
        return ekStore.sources.first {  $0.sourceType == .local }
    }
    
    func resetStore() {
        ekStore.reset()
    }
}
