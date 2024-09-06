//
//  DrinksCategoryHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/4.
//

/*
 ## DrinksCategoryHandler：

    - 負責管理 DrinksCategoryViewController 中的 UICollectionView 的 dataSource 和 delegate。
    - 根據當前的佈局選擇不同的 UICollectionViewCell 顯示方式（如網格或列佈局），並處理 section header 和 section footer 的顯示。
    - 用戶點擊飲品項目時，會觸發 segue 進入詳細頁面。

    * 數據處理：
        - drinks 是存儲飲品子類別與對應的飲品數據的陣列。
        - 當數據從 Firestore 加載完成後，會透過 updateData(drinks:) 方法來更新資料並刷新顯示。

    * 主要方法：
        - updateData(drinks:)：
            用來更新飲品子類別及對應的飲品數據。
        - UICollectionViewDataSource:
            numberOfSections(in:)：設定子類別的數量（section 的數量）。
            collectionView(_:numberOfItemsInSection:)：設定每個子類別下的飲品數量（每個 section 的 item 數量）。
            collectionView(_:cellForItemAt:)：根據當前的佈局樣式，為每個 item 配置並返回對應的 cell。
            viewForSupplementaryElementOfKind(_:at:)：為每個 section 配置並返回 header 和 footer。
        - UICollectionViewDelegate：
            collectionView(_:didSelectItemAt:)：當使用者點擊某個 item 時，觸發 segue，將選中的飲品資料傳遞給下一個頁面。
 
 */

// MARK: - 已完善

import UIKit

/// DrinksCategoryHandler 負責管理 DrinksCategoryViewController 中的 UICollectionView 的 dataSource 及 delegate。
class DrinksCategoryHandler: NSObject {
    
    // MARK: - Properties
    
    /// 儲存每個子類別及其對應的飲品數據
    var drinks: [SubcategoryDrinks] = []
        
    /// 用於通知 DrinksCategoryViewController 執行某些操作
    weak var delegate: DrinksCategoryViewController?

    /// 更新資料
    /// - Parameter drinks: 傳入的飲品子類別及其飲品列表
    func updateData(drinks: [SubcategoryDrinks]) {
        self.drinks = drinks
    }
    
}

// MARK: - UICollectionViewDataSource
extension DrinksCategoryHandler: UICollectionViewDataSource {
    
    /// 設定 section 的數量，對應子類別的數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return drinks.count
    }
    
    
    /// 設定每個 section 中的 item 數量，對應每個子類別下的飲品數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinks[section].drinks.count
    }

    /// 為每個 item 配置並返回對應的 cell，根據當前的佈局樣式選擇不同的 cell 類型
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 根據當前佈局類型選擇對應的 Cell 類型
        let identifier = delegate?.activeLayout == .grid ? GridItemCell.reuseIdentifier : ColumnItemCell.reuseIdentifier
        let drink = drinks[indexPath.section].drinks[indexPath.item]

        // 取得對應的 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let columnCell = cell as? ColumnItemCell {
            columnCell.configure(with: drink)
        } else if let gridCell = cell as? GridItemCell {
            gridCell.configure(with: drink)
        }
        return cell
    }
    
    /// 為每個 section 配置並返回一個 header 或 footer view。每個 header 顯示子類別的標題，footer 顯示分隔線。
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier, for: indexPath) as? DrinksCategorySectionHeaderView else {
                fatalError("Cannot create header view")
            }
            
            let subcategoryTitle = drinks[indexPath.section].subcategory.title
            headerView.titleLabel.text = subcategoryTitle
            return headerView
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinksCategorySectionFooterView.footerIdentifier, for: indexPath) as? DrinksCategorySectionFooterView else {
                fatalError("Cannot create footer view")
            }
            
            return footerView
        }
        
        return UICollectionReusableView()
    }

}

// MARK: - UICollectionViewDelegate
extension DrinksCategoryHandler: UICollectionViewDelegate {

    /// 當使用者點擊某個 item 時，觸發 segue
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Selected item in section \(indexPath.section) at item \(indexPath.item)")    // 測試用
        // 取得選中的 cell
        if let cell = collectionView.cellForItem(at: indexPath) {
            // 添加縮放動畫，並在動畫完成後觸發 segue
            cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
                let selectedDrink = self.drinks[indexPath.section].drinks[indexPath.item]
                self.delegate?.performSegue(withIdentifier: Constants.Segue.drinksToDetailSegue, sender: selectedDrink)
            }
        }
    }
    
}
