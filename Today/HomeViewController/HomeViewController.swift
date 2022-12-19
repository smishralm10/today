//
//  HomeViewController.swift
//  Today
//
//  Created by Shreyansh Mishra on 17/12/22.
//

import UIKit

class HomeViewController: UICollectionViewController {
    var dataSource: DataSource!
    var lists: [List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("My Lists", comment: "home viewcontroller title")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.collectionViewLayout = createListLayout()
        collectionView.dataSource = dataSource
        registerCellWithDataSource()
        prepareReminderStore()
        updateSnapshot()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let reminderListViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReminderListViewController") as? ReminderListViewController else {
            return
        }
        
        navigationController?.pushViewController(reminderListViewController, animated: true)
    }
    
    private func createListLayout() -> UICollectionViewCompositionalLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func registerCellWithDataSource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alertController = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("Ok", comment: "Alert ok button title")
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(alertController, animated: true)
    }
}
