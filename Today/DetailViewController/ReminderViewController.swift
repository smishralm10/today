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
    
    var reminder: Reminder {
        didSet {
            onChange(reminder)
        }
    }
    var workingReminder: Reminder
    var isAddingNewReminder = false
    var onChange: (Reminder) -> Void
    private var dataSource: DataSource!
    
    init(reminder: Reminder, onChange: @escaping (Reminder) -> Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
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
        updateSnapshotForViewing()
        configureBarButtonMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialized ReminderViewController using init(reminder:)")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            prepareForEditing()
        } else {
            if !isAddingNewReminder {
                prepareForViewing()
            } else {
                onChange(workingReminder)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    @objc func didCancelEdit() {
       workingReminder = reminder
        setEditing(false, animated: true)
    }
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewTime, .viewNotes], toSection: .view)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func prepareForViewing() {
        navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        updateSnapshotForViewing()
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems([.header(Section.title.name), .editText(reminder.title)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name), .editDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name), .editText(reminder.notes)], toSection: .notes)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func prepareForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit))
        navigationItem.rightBarButtonItem = editButtonItem
        updateSnapshotForEditing()
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath)
        switch (section, row) {
        case(_, .header(let title)):
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        case(.view, _):
            cell.contentConfiguration = defualtConfiguration(for: cell, at: row)
        case(.title, .editText(let title)):
            cell.contentConfiguration = titleConfiguartion(for: cell, with: title)
        case(.date, .editDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case(.notes, .editText(let notes)):
            cell.contentConfiguration = notesConfiguration(for: cell, with: notes)
        default:
            fatalError("No matching combination for section and row")
        }
        cell.tintColor = .todayPrimaryTint
    }
    
    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
           fatalError("Failed to find matching section")
        }
        return section
    }
    
    private func configureBarButtonMenu() {
        let menuImage = UIImage(systemName: "ellipsis")
        let barButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        barButtonItem.image = menuImage
        barButtonItem.menu = createBarButtonMenu()
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func createBarButtonMenu() -> UIMenu {
        return UIMenu(title: "", children: [
            UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), handler: handleDidPressEditButton),
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), handler: handleDidPressDeleteButton)
        ])
    }
    
    private func handleDidPressEditButton(_ action: UIAction) {
        setEditing(true, animated: true)
    }
    
    private func handleDidPressDeleteButton(_ action: UIAction) {
        let viewController = navigationController?.viewControllers[0] as? ReminderListViewController
        viewController?.deleteReminder(with: reminder.id)
        viewController?.updateSnapshot()
        navigationController?.popViewController(animated: true)
    }
}
