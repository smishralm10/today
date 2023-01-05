//
//  ReminderViewController+cellConfiguration.swift
//  Today
//
//  Created by Shreyansh Mishra on 02/12/22.
//
import UIKit

extension ReminderViewController {
    func defualtConfiguration(for cell: UICollectionViewListCell, at row: Row) -> UIListContentConfiguration {
        var cellConfiguration = cell.defaultContentConfiguration()
        cellConfiguration.text = text(for: row)
        cellConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        cellConfiguration.image = row.image
        return cellConfiguration
    }
    
    func headerConfiguration(for cell: UICollectionViewListCell, with title: String) -> UIListContentConfiguration {
        var cellConfiguration = cell.defaultContentConfiguration()
        cellConfiguration.text = title
        return cellConfiguration
    }
    
    func titleConfiguartion(for cell: UICollectionViewListCell, with title: String?) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.onChange = { [weak self] title in
            self?.workingReminder.title = title
        }
        return contentConfiguration
    }
    
    func dateConfiguration(for cell: UICollectionViewListCell, with date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.datePikerConfiguration()
        contentConfiguration.date = date
        contentConfiguration.onChange = { [weak self] dueDate in
            self?.workingReminder.dueDate = dueDate
        }
        return contentConfiguration
    }
    
    func notesConfiguration(for cell: UICollectionViewListCell, with notes: String?) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = notes
        contentConfiguration.onChange = { [weak self] notes in
            self?.workingReminder.notes = notes
        }
        return contentConfiguration
    }
    
    func listConfiguration(for cell: UICollectionViewListCell) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = NSLocalizedString("List", comment: "list section cell text")
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: .current)
        return contentConfiguration
    }
    
    func text(for row: Row) -> String? {
        switch row {
        case .viewDate:
            return reminder.dueDate.dayText
        case .viewTitle:
            return reminder.title
        case .viewNotes:
            return reminder.notes
        case .viewTime:
            return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        default:
            return nil
        }
    }
}
