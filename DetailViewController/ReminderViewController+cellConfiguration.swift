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
        return contentConfiguration
    }
    
    func dateConfiguration(for cell: UICollectionViewListCell, with date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.datePikerConfiguration()
        contentConfiguration.date = date
        return contentConfiguration
    }
    
    func notesConfiguration(for cell: UICollectionViewListCell, with notes: String?) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = notes
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
