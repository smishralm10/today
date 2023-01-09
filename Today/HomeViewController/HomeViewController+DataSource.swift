//
//  HomeViewController+DataSource.swift
//  Today
//
//  Created by Shreyansh Mishra on 18/12/22.
//

import Foundation
import UIKit

extension HomeViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, List.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, List.ID>
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: List.ID) {
        let list = list(for: id)
        let count = reminderCounts(for: id)
        let listIcon = UIImage(systemName: "list.bullet.circle.fill")
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = list.name
        contentConfig.textProperties.font = UIFont.preferredFont(forTextStyle: .title3)
        contentConfig.image = listIcon
        contentConfig.imageProperties.tintColor = list.color
        contentConfig.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        contentConfig.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        cell.contentConfiguration = contentConfig
        if #available(iOS 15.4, *) {
            let detailActionHandler = createListDetailActionHandler(with: id)
            cell.accessories = [.delete(), .label(text: String(count)), .disclosureIndicator(displayed: .whenNotEditing), .detail(displayed: .whenEditing, actionHandler: detailActionHandler)]
        } else {
            cell.accessories = [.delete(), .label(text: String(count)), .disclosureIndicator(displayed: .whenNotEditing)]
        }
    }
    
    func createListDetailActionHandler(with id: List.ID) -> UICellAccessory.ActionHandler {
        let list = list(for: id)
        let actionHandler = { [weak self] in
            let viewController = ListViewController(list: list) { [weak self] list in
                self?.update(list, with: id)
                self?.updateSnapshot(reloading: [id])
                self?.dismiss(animated: true)
            }
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self?.didPressCancel(_:)) )
            let navigationController = UINavigationController(rootViewController: viewController)
            self?.present(navigationController, animated: true)
        }
        return actionHandler
    }
        
    func reminderCounts(for identifier: List.ID) -> Int {
        return reminders.filter { $0.list.id == identifier }.count
    }
    
    func updateSnapshot(reloading idsThatChanged: [List.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(lists.map { $0.id })
        if !idsThatChanged.isEmpty {
            snapshot.reloadItems(idsThatChanged)
        }
        dataSource.apply(snapshot)
    }
    
    func list(for id: List.ID) -> List {
        let index = lists.indexOfList(with: id)
        return lists[index]
    }
    
    func add(list: List) {
        var list = list
        do {
            let idFromStore = try reminderStore.saveCalendar(list)
            list.id = idFromStore
            lists.append(list)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func add(reminder: Reminder) {
        var reminder = reminder
        do {
            let idFromStore = try reminderStore.save(reminder)
            reminder.id = idFromStore
            reminders.append(reminder)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func update(_ list: List, with id: List.ID) {
        do {
            try reminderStore.saveCalendar(list)
            let index = lists.indexOfList(with: id)
            lists[index] = list
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                lists = reminderStore.fetchLists()
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                lists = List.sampleData
                #endif
            } catch {
                showError(error)
            }
            updateSnapshot()
        }
    }
    
    func reminderStoreChanged() {
        Task {
            lists = reminderStore.fetchLists()
            reminders = try await reminderStore.readAll()
            updateSnapshot(reloading: lists.map { $0.id })
        }
    }
}
