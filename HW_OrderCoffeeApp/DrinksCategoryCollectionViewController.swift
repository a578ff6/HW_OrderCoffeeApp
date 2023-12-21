//
//  DrinksCategoryCollectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/19.
//

import UIKit
import Firebase

private let columnReuseIdentifier = "ColumnItemCell"

private let gridReuseIdentifier = "GridItemCell"



class DrinksCategoryCollectionViewController: UICollectionViewController {
    
    
    @IBOutlet weak var switchLayoutsButton: UIBarButtonItem!
    
    var categoryId: String?
    
    /// 存儲飲品數據
    var drinks: [Drink] = []
    
    var subcategoryDrinks: [SubcategoryDrinks] = []
    
    
    /// 切換佈局的Enum
    enum Layout {
        case grid
        case column
    }
    
    var layout: [Layout: UICollectionViewLayout] = [:]
    
    /// 用來儲存目前的布局類型。預設為 .colum。
    var activeLayout: Layout = .column {
        didSet {
            if let layout = layout[activeLayout] {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                
                // 將集合視圖的布局切換到新的布局，並使用動畫效果。
                collectionView.setCollectionViewLayout(layout, animated: true) { (_) in
                    // 切換完成後，根據目前的布局類型，更新layoutButton圖示。
                    switch self.activeLayout {
                    case .grid:
                        self.switchLayoutsButton.image = UIImage(systemName: "rectangle.grid.1x2")
                    case .column:
                        self.switchLayoutsButton.image = UIImage(systemName: "square.grid.2x2")
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDrinkForCategory()
                        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.headerIdentifier)
    
        
        layout[.grid] = CollectionViewLayoutProvider.generateGridLayout(includeHeader: true)
        layout[.column] = CollectionViewLayoutProvider.generateColumnLayout()
        
        if let layout = layout[activeLayout] {
            collectionView.collectionViewLayout = layout
        }
        

    }
    
    
    // 切換布局的功能
    @IBAction func switchLayoutsButtonTapped(_ sender: UIBarButtonItem) {
        switch activeLayout {
        case .grid:
            activeLayout = .column
        case .column:
            activeLayout = .grid
        }
    }
    
    
    func loadDrinkForCategory() {
        guard let categoryId = categoryId else { return }
        
        FirebaseController.shared.loadDrinksForCategory(categoryId: categoryId) { [weak self] result in
            switch result {
            case .success(let subcategoryDrinks):
                self?.subcategoryDrinks = subcategoryDrinks
                self?.collectionView.reloadData()
            case .failure(let error):
                print("Error loading drinks: \(error)")
            }
        }
    }
  

    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return subcategoryDrinks.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subcategoryDrinks[section].drinks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: columnReuseIdentifier, for: indexPath) as? DrinkCollectionViewCell else {
            fatalError("Cannot create DrinkCollectionViewCell")
        }
        
        let drink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
        cell.configure(with: drink)
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.headerIdentifier, for: indexPath) as? SectionHeaderView else {
            fatalError("Cannot create new header view")
        }
        
        let subcategoryTitle = subcategoryDrinks[indexPath.section].subcategory.title
        headerView.titlelabel.text = subcategoryTitle
        return headerView
    }
    
}

