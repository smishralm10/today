//
//  ReminederViewController.swift
//  Today
//
//  Created by Shreyansh Mishra on 30/11/22.
//

import Foundation
import UIKit

class ReminderViewController: UICollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    var reminder: Reminder
    private var dataSource: DataSource!
    
    init(reminder: Reminder) {
        self.reminder = reminder
        var listConfiguartion = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguartion.showsSeparators = false
        listConfiguartion.headerMode = .firstItemInSection
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguartion)
        super.init(collectionViewLayout: listLayout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        navigationItem.title = "Reminder"
        navigationItem.rightBarButtonItem = editButtonItem
        updateSnapshotForViewing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialized ReminderViewController using init(reminder:)")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            updateSnapshotForEditing()
        } else {
            updateSnapshotForViewing()
        }
    }
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewTime, .viewNotes], toSection: .view)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems([.header(Section.title.name)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name)], toSection: .notes)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath)
        switch (section, row) {
        case(_, .header(let title)):
            var cellConfiguration = cell.defaultContentConfiguration()
            cellConfiguration.text = title
            cell.contentConfiguration = cellConfiguration
        case(.view, _):
            var cellConfiguration = cell.defaultContentConfiguration()
            cellConfiguration.text = text(for: row)
            cellConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
            cellConfiguration.image = row.image
            cell.contentConfiguration = cellConfiguration
        default:
            fatalError("No matching combination for section and row")
        }
        cell.tintColor = UIColor(named: "TodayPrimaryTint")
    }
    
    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
           fatalError("Failed to find matching section")
        }
        return section
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
