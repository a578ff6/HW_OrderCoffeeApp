//
//  DrinkDetailHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/8.
//

/*
 ## UICollectionView 資料源管理方式：UICollectionViewDiffableDataSource vs UICollectionViewDataSource （對比 OrderViewController 的使用）

 & UICollectionViewDiffableDataSource
 
        - UICollectionViewDiffableDataSource 是在 iOS 13 引入的更現代化的資料管理方式。
        - 它通過 快照 (NSDiffableDataSourceSnapshot) 來追蹤和管理資料變更，讓資料的更新更加簡單和直觀。
        - 支援自動處理資料更新的動畫效果，讓 UI 更加流暢。

    * 使用情境：
        - 當資料經常更新或需要處理多個資料來源時，diffable data source 非常適合。
        - 可以輕鬆處理新增、刪除和重新排列資料，並自動為 UICollectionView 添加動畫效果。

    * 範例： 重構 DrinkDetailViewController 前在 configureDataSource() 中，定義了一個 UICollectionViewDiffableDataSource，並根據資料類型來返回相應的 UICollectionViewCell：
 
 dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: drinkDetailView.collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
     switch item {
     case .detail(let drink):
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkInfoCollectionViewCell else {
             fatalError("Unable to dequeue DrinkInfoCollectionViewCell")
         }
         cell.configure(with: drink)
         return cell
     case .sizeSelection(let size):
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkSizeSelectionCollectionViewCell else {
             fatalError("Unable to dequeue DrinkSizeSelectionCollectionViewCell")
         }
         cell.configure(with: size, isSelected: size == selectedSize)
         return cell
     case .priceInfo(let sizeInfo):
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkPriceInfoCollectionViewCell else {
             fatalError("Unable to dequeue DrinkPriceInfoCollectionViewCell")
         }
         cell.configure(with: sizeInfo)
         return cell
     case .orderOptions:
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkOrderOptionsCollectionViewCell else {
             fatalError("Unable to dequeue DrinkOrderOptionsCollectionViewCell")
         }
         return cell
     }
 }
 
 
 & UICollectionViewDataSource
 
        - UICollectionViewDataSource 是傳統的資料源管理方式，需要手動配置 UICollectionView 的每個 cell。
        - 相對於 diffable data source，UICollectionViewDataSource 需要開發者自行處理資料的變更，並手動更新 UICollectionView。

    * 使用情境：
        - 當資料較為靜態，或不需要頻繁更新時，可以使用 UICollectionViewDataSource。
        - 它適合需要更多控制的場景，開發者可以手動配置每個 cell 的行為和顯示邏輯。

    * 範例： 重構之後在 cellForItemAt 中，改成手動配置每個 UICollectionViewCell，並根據不同的 section 顯示對應的資料：
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     let sectionType = DrinkDetailViewController.Section.allCases[indexPath.section]
     
     switch sectionType {
     case .info:
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkInfoCollectionViewCell else {
             fatalError("Unable to dequeue DrinkInfoCollectionViewCell")
         }
         cell.configure(with: drink)
         return cell
     case .sizeSelection:
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkSizeSelectionCollectionViewCell else {
             fatalError("Unable to dequeue DrinkSizeSelectionCollectionViewCell")
         }
         cell.configure(with: size, isSelected: size == selectedSize)
         return cell
     case .priceInfo:
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkPriceInfoCollectionViewCell else {
             fatalError("Unable to dequeue DrinkPriceInfoCollectionViewCell")
         }
         cell.configure(with: sizeInfo)
         return cell
     case .orderOptions:
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkOrderOptionsCollectionViewCell else {
             fatalError("Unable to dequeue DrinkOrderOptionsCollectionViewCell")
         }
         return cell
     }
 }

 
 & 比較與應用
 
    * 設計模式不同：
        - diffable data source 讓開發者不必手動處理資料變更，適合需要平滑動畫效果和頻繁資料更新的應用。
        - UICollectionViewDataSource 則是傳統方法，需要手動處理每個 cell 的配置和資料更新，適合靜態或簡單場景。

    * 選擇：
        - 如果需要更強大的資料差異管理能力，建議使用 diffable data source。
        - 如果需要更多自定義控制或資料變更不頻繁，則可以使用 UICollectionViewDataSource。
 
 -------------------------------------------------------------------------------------------------------------------------------------------
 
 ## DrinkDetailHandler：
    
    * 功能： DrinkDetailHandler 負責管理 DrinkDetailViewController 的 UICollectionView 的資料來源 (dataSource) 和使用者互動 (delegate)。
 
    * 主要職責：
        1. 將視圖控制器中的邏輯分離，處理不同區段（section）的顯示資料。
        2. 管理使用者的尺寸選擇操作，並將結果回傳給 DrinkDetailViewController。
        3. 處理加入購物車的邏輯，將訂單的數量傳回至控制器。
    
    * 主要方法：
        - numberOfSections(in:)： 回傳 UICollectionView 中有幾個 section，根據 DrinkDetailViewController.Section 的不同類型進行動態設定。
 
        - collectionView(_:numberOfItemsInSection:)： 根據 section 的類型動態決定每個 section 中應該顯示的 item 數量。
                                                        
            1. info： 顯示飲品的詳細資訊，固定為 1。
            2. sizeSelection： 顯示可選擇的尺寸，數量根據 drink.sizes 而定。
            3. priceInfo： 若使用者已選擇尺寸，顯示價格資訊，否則為 0。
            4. orderOptions： 顯示訂單選項，如加入購物車按鈕，固定為 1。

        - collectionView(_:cellForItemAt:)： 根據 sectionType，動態設置每個區段的 cell。

            1. info： 顯示飲品的基本資訊。
            2. sizeSelection： 顯示每個可選尺寸的按鈕，並允許使用者選擇尺寸。
            3. priceInfo： 顯示所選尺寸的價格資訊。
            4. orderOptions： 顯示加入購物車或更新訂單的選項。
    
        - viewForSupplementaryElementOfKind： 用來處理 UICollectionView 的區段補充視圖（如 footer），主要用來顯示分隔視圖。
 
    * 主要重點：
        - 使用 sizeSelectionHandler 和 addToCartHandler 來與 DrinkDetailViewController 互動，保持單一職責，清楚分離資料顯示與邏輯處理。
        - 將 UICollectionView 的 dataSource 和 delegate 邏輯完全封裝在 DrinkDetailHandler 中，讓控制器更專注於邏輯處理。

 */


// MARK: - 已完善

import UIKit

/// `DrinkDetailHandler` 負責管理 `DrinkDetailViewController` 中的 UICollectionView 的資料來源 (dataSource) 及使用者互動 (delegate)。
class DrinkDetailHandler: NSObject {

    // MARK: - Properties
    
    private weak var viewController: DrinkDetailViewController?

    // 使用 closures 來與 `DrinkDetailViewController` 溝通
    var sizeSelectionHandler: ((String) -> Void)?           // 當使用者選擇尺寸時觸發
    var addToCartHandler: ((Int) -> Void)?                  // 當使用者點擊加入購物車時觸發
    
    // MARK: - Initializer
    init(viewController: DrinkDetailViewController) {
        self.viewController = viewController
    }

}

// MARK: - UICollectionViewDataSource
extension DrinkDetailHandler: UICollectionViewDataSource {
    
    // 回傳 section 數量，對應到 `DrinkDetailViewController.Section` 中的項目
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DrinkDetailViewController.Section.allCases.count
    }

    /// 根據 UICollectionView 中的不同 section 動態返回該 section 中應顯示的 item 個數。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let drink = viewController?.drink else { return 0 }

        let sectionType = DrinkDetailViewController.Section.allCases[section]

        switch sectionType {
        case .info:
            return 1
        case .sizeSelection:
            return drink.sizes.count
        case .priceInfo:
            return viewController?.selectedSize != nil ? 1 : 0
        case .orderOptions:
            return 1
        }
    }
    
    /// 根據不同的 section 類型返回對應的 cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewController = viewController else { fatalError("No ViewController found") }
        let sectionType = DrinkDetailViewController.Section.allCases[indexPath.section]

        switch sectionType {
        case .info:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkInfoCollectionViewCell else {
                fatalError("Unable to dequeue DrinkInfoCollectionViewCell or drink is nil")
            }
            cell.configure(with: viewController.drink!)
            return cell

        case .sizeSelection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkSizeSelectionCollectionViewCell else {
                fatalError("Unable to dequeue DrinkSizeSelectionCollectionViewCell")
            }
            let size = viewController.sortedSizes[indexPath.item]
            cell.configure(with: size, isSelected: size == viewController.selectedSize)
            cell.sizeSelected = { [weak self] selectedSize in
                self?.sizeSelectionHandler?(selectedSize)
            }
            return cell

        case .priceInfo:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkPriceInfoCollectionViewCell else {
                fatalError("Unable to dequeue DrinkPriceInfoCollectionViewCell")
            }
            let sizeInfo = viewController.drink?.sizes[viewController.selectedSize ?? ""]
            cell.configure(with: sizeInfo!)
            return cell
            
        case .orderOptions:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkOrderOptionsCollectionViewCell else {
                fatalError("Unable to dequeue DrinkOrderOptionsCollectionViewCell")
            }
            cell.updateOrderButtonTitle(isEditing: viewController.isEditingOrderItem)
            cell.configure(with: viewController.editingOrderQuantity)
            
            // 當使用者點擊加入購物車時，透過 handler 傳遞數量
            cell.addToCart = { [weak self] quantity in
                self?.addToCartHandler?(quantity)
            }
            return cell
        }
    }
    
    /// 處理 section 的補充視圖 (footer)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier, for: indexPath) as? DrinkDetailSeparatorView else {
                fatalError("Cannot create footer view")
            }
            return footerView
        }
        return UICollectionReusableView()
    }
    
}

// MARK: - UICollectionViewDelegate
extension DrinkDetailHandler: UICollectionViewDelegate {
    
}

