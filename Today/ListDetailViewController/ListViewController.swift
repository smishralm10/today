//
//  ListViewController.swift
//  Today
//
//  Created by Shreyansh Mishra on 23/12/22.
//

import Foundation
import UIKit

class ListViewController: UICollectionViewController {
    static let sectionBackgroundDecorationElementKind = "section-background-element-kind"
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var list: List {
        didSet {
            onChange(list)
        }
    }
    private let onChange: (List) -> Void
    private var workingList: List
    var dataSource: DataSource!
    let colors: [UIColor] = [.systemBlue, .systemRed, .systemCyan, .systemPink, .systemTeal, .systemMint, .systemBrown, .systemOrange, .systemPurple, .systemIndigo]
    
    init(list: List, onChange: @escaping (List) -> Void) {
        self.list = list
        self.onChange = onChange
        self.workingList = list
        super.init(collectionViewLayout: ListViewController.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func viewDidLoad() {
        collectionView.backgroundColor = .systemGray6
        configureDataSource()
        updateSnapshot()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDoneButton(_:)))
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let selectedColor = colors[indexPath.row]
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .small)
        let image = UIImage(systemName: "checkmark", withConfiguration: imageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell?.backgroundConfiguration?.image = image
        cell?.backgroundConfiguration?.imageContentMode = .center
        
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .colors])
        snapshot.appendItems([.editTitle(workingList.name, selectedColor)], toSection: .title)
        snapshot.appendItems(colors.map { .viewColor($0) }, toSection: .colors)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundConfiguration?.image = nil
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    static private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let fraction = sectionIndex == 0 ? 1.0 : 0.15
            let heightFraction = sectionIndex == 0 ? 0.15 : 0.15
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(heightFraction))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(20)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let sectionBackgroundDecorationItem = NSCollectionLayoutDecorationItem.background(elementKind: ListViewController.sectionBackgroundDecorationElementKind)
            sectionBackgroundDecorationItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            section.decorationItems = [sectionBackgroundDecorationItem]
            return section
        }
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        layout.register(SectionBackgroundDecorationItem.self, forDecorationViewOfKind: ListViewController.sectionBackgroundDecorationElementKind)
        return layout
    }
    
    func cellRegistrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, row: Row) {
        let section = Section(rawValue: indexPath.section)
        switch (section, row) {
        case(.title, .editTitle(let title, let color)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title, color: color)
        case(.colors, .viewColor(let color)):
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.cornerRadius = cell.bounds.width / 2
            backgroundConfig.backgroundColor = color
            backgroundConfig.backgroundInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            cell.backgroundConfiguration = backgroundConfig
        default:
           fatalError("No matching combination for section and row")
        }
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .colors])
        snapshot.appendItems([.editTitle(list.name, list.color)], toSection: .title)
        snapshot.appendItems(colors.map { .viewColor($0) }, toSection: .colors)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func didPressDoneButton(_ sender: UIBarButtonItem) {
        onChange(workingList)
    }
}

extension ListViewController {
    enum Section: Int, Hashable {
        case title
        case colors
    }
    
    enum Row: Hashable {
        case editTitle(String, UIColor)
        case viewColor(UIColor)
    }
}

extension ListViewController {
    func titleConfiguration(for cell: UICollectionViewCell, with title: String, color: UIColor?) -> ListTitleContentView.Configuration {
        var contentConfiguration = cell.titleConfiguration()
        contentConfiguration.text = title
        contentConfiguration.tintColor = color
        contentConfiguration.onChange = { [weak self] (title, color) in
            self?.workingList.name = title
            guard let color = color else { return }
            self?.workingList.color = color
        }
        return contentConfiguration
    }
}
