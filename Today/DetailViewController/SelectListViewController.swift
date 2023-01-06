//
//  SelectListViewController.swift
//  Today
//
//  Created by Shreyansh Mishra on 05/01/23.
//

import Foundation
import UIKit

class SelectListViewController: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, List.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, List.ID>
    var list: List
    var lists: [List] = []
    var onChange: (List) -> Void
    var dataSource: DataSource!
    
    init(list: List, onChange: @escaping (List) -> Void) {
        self.list = list
        self.onChange = onChange
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = true
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationItem.title = NSLocalizedString("Select List", comment: "SelectListViewController title")
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        lists = ReminderStore.shared.fetchLists()
        updateSnapshot()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
        let selectedList = lists[indexPath.row]
        cell?.accessories = [.checkmark()]
        self.list = selectedList
        onChange(selectedList)
        navigationController?.popViewController(animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
        cell?.accessories = []
    }
    
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: List.ID) {
        let list = list(for: id)
        let listIcon = UIImage(systemName: "list.bullet.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(list.color)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = list.name
        configuration.image = listIcon
        cell.contentConfiguration = configuration
        if list.id == self.list.id {
            cell.accessories = [.checkmark()]
        }
    }
    
    private func list(for id: List.ID) -> List {
        let index = lists.indexOfList(with: id)
        return lists[index]
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(lists.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
