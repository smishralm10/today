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
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = list.name
        contentConfig.textProperties.font = UIFont.preferredFont(forTextStyle: .title3)
        contentConfig.image = UIImage(systemName: "list.bullet.circle.fill")
        contentConfig.imageProperties.tintColor = list.color
        contentConfig.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        contentConfig.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        cell.contentConfiguration = contentConfig
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(lists.map { $0.id })
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
    
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                lists = reminderStore.fetchLists()
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
        lists = reminderStore.fetchLists()
        updateSnapshot()
    }
}
