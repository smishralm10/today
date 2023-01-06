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
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguartion)
        super.init(collectionViewLayout: listLayout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
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
        let section = section(for: indexPath)
        print(indexPath)
        if section == .list {
        }
    }
    
    @objc func didCancelEdit() {
       workingReminder = reminder
        setEditing(false, animated: true)
    }
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([.viewTitle, .viewDate, .viewTime, .viewNotes], toSection: .view)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func prepareForViewing() {
        navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        updateSnapshotForViewing()
    }
    
    private func updateSnapshotForEditing(reloading row: [Row] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .notes, .date, .list])
        snapshot.appendItems([.editText(reminder.title)], toSection: .title)
        snapshot.appendItems([.editText(reminder.notes)], toSection: .notes)
        snapshot.appendItems([.editDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.editList], toSection: .list)
        if !row.isEmpty {
            snapshot.reloadItems([.editList])
        }
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
        case(.view, _):
            cell.contentConfiguration = defualtConfiguration(for: cell, at: row)
        case(.title, .editText(let title)):
            cell.contentConfiguration = titleConfiguartion(for: cell, with: title)
        case(.notes, .editText(let notes)):
            cell.contentConfiguration = notesConfiguration(for: cell, with: notes)
        case(.date, .editDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case(.list, .editList):
            var labelAccessoryOptions = UICellAccessory.LabelOptions()
            labelAccessoryOptions.tintColor = workingReminder.list.color
            cell.contentConfiguration = listConfiguration(for: cell)
            cell.accessories = [
                .label(text: workingReminder.list.name, options: labelAccessoryOptions),
                .disclosureIndicator(displayed: .always)
            ]
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelectListCell(_:)))
            cell.addGestureRecognizer(tapGesture)
        default:
            fatalError("No matching combination for section and row")
        }
        cell.tintColor = .todayPrimaryTint
    }
    
    @objc func didTapSelectListCell(_ sender: UITapGestureRecognizer) {
        let viewController = SelectListViewController(list: self.reminder.list) { [weak self] list in
            self?.workingReminder.list = list
            self?.updateSnapshotForEditing(reloading: [.editList])
        }
        self.navigationController?.pushViewController(viewController, animated: true)
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
