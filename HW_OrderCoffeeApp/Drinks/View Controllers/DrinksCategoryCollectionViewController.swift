//
//  DrinksCategoryCollectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/19.
//

// MARK: - 整理版本（將切換按鈕也改成程式碼處理）
/*
 import UIKit
 import Firebase

 private let columnReuseIdentifier = "ColumnItemCell"
 private let gridReuseIdentifier = "GridItemCell"

 /// 顯示特定類別下的飲品，並允許用戶在網格和列視圖之間切換。
 class DrinksCategoryCollectionViewController: UICollectionViewController {
         
     // 從上一個視圖控制器傳遞的類別ID、類別標題。
     var categoryId: String?
     var categoryTitle: String?

     /// 存儲飲品數據
     var subcategoryDrinks: [SubcategoryDrinks] = []
     
     /// 切換佈局的 Enum
     enum Layout {
         case grid
         case column
     }
     
     var layoutProvider: DrinksCategoryLayoutProvider!
      
     /// 用來儲存目前的布局類型。預設為 .column。
     var activeLayout: Layout = .column {
         didSet {
             switchLayout()
         }
     }
     
     struct PropertyKeys {
         static let showDrinkDetail = "ShowDrinkDetail"
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // 設置導航標題
         guard let categoryTitle = categoryTitle else { return }
         self.navigationItem.title = categoryTitle
         
         layoutProvider = DrinksCategoryLayoutProvider()
         configureCollectionView()
         
         loadDrinkForCategory()
         applyActiveLayout()
         
         // 添加切換佈局的按鈕
         let switchLayoutsButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.1x2"), style: .plain, target: self, action: #selector(switchLayoutsButtonTapped(_ :)))
         self.navigationItem.rightBarButtonItem = switchLayoutsButton
         updateSwitchLayoutsButtonIcon() // 更新切換佈局按鈕的圖標
     }
     
     // MARK: - Actions
     
     /// 切換布局的功能
     @objc func switchLayoutsButtonTapped(_ sender: UIBarButtonItem) {
         activeLayout = activeLayout == .grid ? .column : .grid
     }

     // MARK: - Data Loading

     /// 從 Firestore 加載特定類別下的飲品數據。
     func loadDrinkForCategory() {
         guard let categoryId = categoryId else { return }
         
         HUDManager.shared.showLoading(in: view, text: "LoadingTest...")
         MenuController.shared.loadDrinksForCategory(categoryId: categoryId) { [weak self] result in
             DispatchQueue.main.async {
                 HUDManager.shared.dismiss()
                 switch result {
                 case .success(let subcategoryDrinks):
                     self?.subcategoryDrinks = subcategoryDrinks
                     self?.applyActiveLayout()
                 case .failure(let error):
                     print("Error loading drinks: \(error)")
                     AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                 }
             }
         }
     }
     
     
     // MARK: - Layout Configuration

     /// 切換佈局。
     func switchLayout() {
         applyActiveLayout()
         updateSwitchLayoutsButtonIcon()
     }
     
     /// 更新切換佈局按鈕的圖標。
     func updateSwitchLayoutsButtonIcon() {
         let iconName = activeLayout == .grid ? "rectangle.grid.1x2" : "square.grid.2x2"
         self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: iconName)
     }
     
     /// 應用當前啟動的佈局。
     func applyActiveLayout() {
         let layout = layoutProvider.getLayout(for: activeLayout, subcategoryDrinksCount: subcategoryDrinks.count)
         collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] _ in
             self?.collectionView.reloadData()   // 布局切换完成後，重新加載數據
         }
     }
      
     /// 註冊自定義的 Section Header、隔線視圖、Cell 佈局
     func configureCollectionView() {
         collectionView.register(DrinksCategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier)
         collectionView.register(ThickSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ThickSeparatorView.reuseIdentifier)
         collectionView.register(ColumnItemCell.self, forCellWithReuseIdentifier: columnReuseIdentifier)
         collectionView.register(GridItemCell.self, forCellWithReuseIdentifier: gridReuseIdentifier)
     }
     
 }


 // MARK: - UICollectionViewDataSource
 extension DrinksCategoryCollectionViewController {
     
     /// 確定集合視圖中有多少個 section。每個 section 代表一個子類別。
     override func numberOfSections(in collectionView: UICollectionView) -> Int {
         return subcategoryDrinks.count
     }
     
     /// 確定特定 section 中有多少個項目（cell）。這等於詀子類別下的飲品數量。
     override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return subcategoryDrinks[section].drinks.count
     }

     /// 為每個項目配置並返回一個 cell。根據當前的布局（網格或列），使用對應的 cell id。
     override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let identifier = activeLayout == .grid ? gridReuseIdentifier : columnReuseIdentifier
         
         if activeLayout == .grid {
             guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridReuseIdentifier, for: indexPath) as? GridItemCell else {
                 fatalError("Cannot create GridItemCell")
             }
             let drink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
             cell.configure(with: drink)
             return cell
         } else {
             guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: columnReuseIdentifier, for: indexPath) as? ColumnItemCell else {
                 fatalError("Cannot create ColumnItemCell")
             }
             let drink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
             cell.configure(with: drink)
             return cell
         }
     }
     

     /// 為每個 section 配置並返回一個 header view。每個 header view 顯示對應子類別的標題。
     override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         
         if kind == UICollectionView.elementKindSectionHeader {
             guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier, for: indexPath) as? DrinksCategorySectionHeaderView else {
                 fatalError("Cannot create new header view")
             }
             
             let subcategoryTitle = subcategoryDrinks[indexPath.section].subcategory.title
             headerView.titleLabel.text = subcategoryTitle   // 設置 header 標題為子類別名稱
             return headerView
             
         } else {
             guard let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ThickSeparatorView.reuseIdentifier, for: indexPath) as? ThickSeparatorView else {
                 fatalError("Cannot create new separator view")
             }
             return separatorView
         }
     }
    
 }


 // MARK: - Navigation
 extension DrinksCategoryCollectionViewController {
     
     /// 點擊 cell 時觸發 segue
     override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         print("Selected item in section \(indexPath.section) at item \(indexPath.item)")    // 測試用
         performSegue(withIdentifier: PropertyKeys.showDrinkDetail, sender: indexPath)
     }
     
     /// 為 segue 傳遞數據
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "ShowDrinkDetail",
            let destinationVC = segue.destination as? DrinkDetailViewController,
            let indexPath = collectionView.indexPathsForSelectedItems?.first {
             // 根據 indexPath 獲取選中的飲品
             let selectedDrink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
             destinationVC.drink = selectedDrink
         }
     }
     
 }
*/


// MARK: - 整理版本（將切換按鈕也改成程式碼處理）修改用。

import UIKit
import Firebase

private let columnReuseIdentifier = "ColumnItemCell"
private let gridReuseIdentifier = "GridItemCell"

/// 顯示特定類別下的飲品，並允許用戶在網格和列視圖之間切換。
class DrinksCategoryCollectionViewController: UICollectionViewController {
        
    // 從上一個視圖控制器傳遞的類別ID、類別標題。
    var categoryId: String?
    var categoryTitle: String?

    /// 存儲飲品數據
    var subcategoryDrinks: [SubcategoryDrinks] = []
    
    /// 切換佈局的 Enum
    enum Layout {
        case grid
        case column
    }
    
    var layoutProvider: DrinksCategoryLayoutProvider!
     
    /// 用來儲存目前的布局類型。預設為 .column。
    var activeLayout: Layout = .column {
        didSet {
            switchLayout()
        }
    }
    
    struct PropertyKeys {
        static let showDrinkDetail = "ShowDrinkDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置導航標題
        guard let categoryTitle = categoryTitle else { return }
        self.navigationItem.title = categoryTitle
        
        layoutProvider = DrinksCategoryLayoutProvider()
        configureCollectionView()
        
        loadDrinkForCategory()
        applyActiveLayout()
        
        // 添加切換佈局的按鈕
        let switchLayoutsButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.1x2"), style: .plain, target: self, action: #selector(switchLayoutsButtonTapped(_ :)))
        self.navigationItem.rightBarButtonItem = switchLayoutsButton
        updateSwitchLayoutsButtonIcon() // 更新切換佈局按鈕的圖標
    }
    
    // MARK: - Actions
    
    /// 切換布局的功能
    @objc func switchLayoutsButtonTapped(_ sender: UIBarButtonItem) {
        activeLayout = activeLayout == .grid ? .column : .grid
    }

    // MARK: - Data Loading

    /// 從 Firestore 加載特定類別下的飲品數據。
    func loadDrinkForCategory() {
        guard let categoryId = categoryId else { return }
        
        HUDManager.shared.showLoading(in: view, text: "LoadingTest...")
        MenuController.shared.loadDrinksForCategory(categoryId: categoryId) { [weak self] result in
            DispatchQueue.main.async {
                HUDManager.shared.dismiss()
                switch result {
                case .success(let subcategoryDrinks):
                    self?.subcategoryDrinks = subcategoryDrinks
                    self?.applyActiveLayout()
                case .failure(let error):
                    print("Error loading drinks: \(error)")
                    AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
    }
    
    
    // MARK: - Layout Configuration

    /// 切換佈局。
    func switchLayout() {
        applyActiveLayout()
        updateSwitchLayoutsButtonIcon()
    }
    
    /// 更新切換佈局按鈕的圖標。
    func updateSwitchLayoutsButtonIcon() {
        let iconName = activeLayout == .grid ? "rectangle.grid.1x2" : "square.grid.2x2"
        self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: iconName)
    }
    
    /// 應用當前啟動的佈局。
    func applyActiveLayout() {
        let layout = layoutProvider.getLayout(for: activeLayout, subcategoryDrinksCount: subcategoryDrinks.count)
        collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] _ in
            self?.collectionView.reloadData()   // 布局切换完成後，重新加載數據
        }
    }
     
    /// 註冊自定義的 Section Header、隔線視圖、Cell 佈局
    func configureCollectionView() {
        collectionView.register(DrinksCategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier)
        collectionView.register(ThickSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ThickSeparatorView.reuseIdentifier)
        collectionView.register(ColumnItemCell.self, forCellWithReuseIdentifier: columnReuseIdentifier)
        collectionView.register(GridItemCell.self, forCellWithReuseIdentifier: gridReuseIdentifier)
    }
    
}


// MARK: - UICollectionViewDataSource
extension DrinksCategoryCollectionViewController {
    
    /// 確定集合視圖中有多少個 section。每個 section 代表一個子類別。
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return subcategoryDrinks.count
    }
    
    /// 確定特定 section 中有多少個項目（cell）。這等於詀子類別下的飲品數量。
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subcategoryDrinks[section].drinks.count
    }

    /// 為每個項目配置並返回一個 cell。根據當前的布局（網格或列），使用對應的 cell id。
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = activeLayout == .grid ? gridReuseIdentifier : columnReuseIdentifier
        
        if activeLayout == .grid {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridReuseIdentifier, for: indexPath) as? GridItemCell else {
                fatalError("Cannot create GridItemCell")
            }
            let drink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
            cell.configure(with: drink)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: columnReuseIdentifier, for: indexPath) as? ColumnItemCell else {
                fatalError("Cannot create ColumnItemCell")
            }
            let drink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
            cell.configure(with: drink)
            return cell
        }
    }
    

    /// 為每個 section 配置並返回一個 header view。每個 header view 顯示對應子類別的標題。
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier, for: indexPath) as? DrinksCategorySectionHeaderView else {
                fatalError("Cannot create new header view")
            }
            
            let subcategoryTitle = subcategoryDrinks[indexPath.section].subcategory.title
            headerView.titleLabel.text = subcategoryTitle   // 設置 header 標題為子類別名稱
            return headerView
            
        } else {
            guard let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ThickSeparatorView.reuseIdentifier, for: indexPath) as? ThickSeparatorView else {
                fatalError("Cannot create new separator view")
            }
            return separatorView
        }
    }
   
}


// MARK: - Navigation
extension DrinksCategoryCollectionViewController {
    
    /// 點擊 cell 時觸發 segue
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item in section \(indexPath.section) at item \(indexPath.item)")    // 測試用
        performSegue(withIdentifier: PropertyKeys.showDrinkDetail, sender: indexPath)
    }
    
    /// 為 segue 傳遞數據
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDrinkDetail",
           let destinationVC = segue.destination as? DrinkDetailViewController,
           let indexPath = collectionView.indexPathsForSelectedItems?.first {
            // 根據 indexPath 獲取選中的飲品
            let selectedDrink = subcategoryDrinks[indexPath.section].drinks[indexPath.item]
            destinationVC.drink = selectedDrink
        }
    }
    
}
