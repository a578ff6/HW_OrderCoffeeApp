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
    
    * 功能：
        - DrinkDetailHandler 主要負責管理 DrinkDetailViewController 中的 UICollectionView 的資料來源 (dataSource) 和使用者互動 (delegate)。
        - 以及處理飲品詳細資料的展示和加入購物車的邏輯。

    * 主要職責：
        1. 將視圖控制器中的邏輯分離，處理不同區段（section）的顯示資料。
        2. 管理使用者的尺寸選擇操作，並透過 sizeSelectionHandler 將選擇結果回傳給 DrinkDetailViewController。
        3. 管理加入購物車的操作，透過 addToCartHandler 將飲品數量回傳給控制器進行後續處理。
    
    * 主要方法：
        - numberOfSections(in:)： 回傳 UICollectionView 中有幾個 section，根據 DrinkDetailViewController.Section 的不同類型進行動態設定。
 
        - collectionView(_:numberOfItemsInSection:)： 根據 section 的類型動態決定每個 section 中應該顯示的 item 數量。
            
            1. image: 顯示飲品的圖片。
            2. info： 顯示飲品的詳細資訊，固定為 1。
            3. sizeSelection： 顯示可選擇的尺寸，數量根據 drink.sizes 而定。
            4. priceInfo： 若使用者已選擇尺寸，顯示價格資訊，否則為 0。
            5. orderOptions： 顯示訂單選項，如加入購物車按鈕，固定為 1。

        - collectionView(_:cellForItemAt:)： 根據 sectionType，動態設置每個區段的 cell。

            1. image: 顯示飲品的圖片。
            2. info： 顯示飲品的基本資訊。
            3. sizeSelection： 顯示每個可選尺寸的按鈕，並允許使用者選擇尺寸。
            4. priceInfo： 顯示所選尺寸的價格資訊。
            5. orderOptions： 顯示加入購物車或更新訂單的選項。
    
        - viewForSupplementaryElementOfKind： 用來處理 UICollectionView 的區段補充視圖（如 footer），主要用來顯示分隔視圖。
 
    * 主要重點：
        - 使用 sizeSelectionHandler 和 addToCartHandler 來與 DrinkDetailViewController 互動，保持單一職責，清楚分離資料顯示與邏輯處理。
        - 將 UICollectionView 的 dataSource 和 delegate 邏輯完全封裝在 DrinkDetailHandler 中，讓控制器更專注於邏輯處理。
 
 -------------------------------------------------------------------------------------------------------------------------------------------

 ## 關於設置分隔線時遇到的問題：
 
 * 問題的產生：
    - 使用 .estimated 高度的 section (如 info section)，因為不同飲品的描述內容長度不同，會導致 footer 的位置隨著資料多寡變動，這會造成在實體裝置上滑動時出現 "移動感" 的問題。

 * 如何解決：
    - 將 footer 分隔線從 .estimated 高度的 section 中移除，並在更穩定的 section（ sizeSelection section）的 header 中設置分隔線，以避免受內容長度變化的影響。這樣可以確保分隔線的位置固定，並且不會隨資料變動造成視覺上的移動感。
    - 另外，將圖片從 info section 拆分出來成為獨立的 section，有助於進一步穩定 UI 排列，減少視覺跳動的可能性。(主要為圖片比例問題)

 */


// MARK: - 已完善（處理掉全局 drink ）
/*
import UIKit

/// `DrinkDetailHandler` 負責管理 `DrinkDetailViewController` 中的 UICollectionView 的資料來源 (dataSource) 及使用者互動 (delegate)。
class DrinkDetailHandler: NSObject {

    // MARK: - Properties
    
    private weak var viewController: DrinkDetailViewController?
    
    /// 存取載入的飲品詳細資料，由 handler 負責管理和顯示，避免在控制器中使用全局 drink
    var drink: Drink?

    // 使用 closures 與 `DrinkDetailViewController` 溝通
    var sizeSelectionHandler: ((String) -> Void)?           // 當使用者選擇尺寸時觸發
    var addToCartHandler: ((Int) -> Void)?                  // 當使用者點擊加入購物車時觸發
    
    // MARK: - Initializer
    
    /// 初始化，接收 DrinkDetailViewController 和 drink 資料
    init(viewController: DrinkDetailViewController, drink: Drink?) {
        self.viewController = viewController
        self.drink = drink
    }

}

// MARK: - UICollectionViewDataSource
extension DrinkDetailHandler: UICollectionViewDataSource {
    
    // 回傳 section 數量，對應到 `DrinkDetailViewController.Section` 中的項目
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DrinkDetailViewController.Section.allCases.count
    }

    /// 根據 section 動態返回應顯示的 item 數量，資料來源於內部的 `drink`
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let drink = drink else { return 0 }
        let sectionType = DrinkDetailViewController.Section.allCases[section]
        switch sectionType {
        case .image:
            return 1
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
    
    /// 根據 section 動態返回對應的 cell，資料來自於 `drink` 和 `viewController`
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewController = viewController, let drink = drink else { fatalError("No ViewController or Drink found") }
        let sectionType = DrinkDetailViewController.Section.allCases[indexPath.section]
        
        switch sectionType {
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkImageCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkImageCollectionViewCell else {
                fatalError("Unable to dequeue DrinkImageCollectionViewCell")
            }
            cell.configure(with: drink.imageUrl)
            return cell
            
        case .info:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkInfoCollectionViewCell else {
                fatalError("Unable to dequeue DrinkInfoCollectionViewCell or drink is nil")
            }
            cell.configure(with: drink)
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
            let sizeInfo = drink.sizes[viewController.selectedSize ?? ""]
            cell.configure(with: sizeInfo!)
            return cell
            
        case .orderOptions:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkOrderOptionsCollectionViewCell else {
                fatalError("Unable to dequeue DrinkOrderOptionsCollectionViewCell")
            }
            
            cell.updateOrderButton(isEditing: viewController.isEditingOrderItem)
            cell.configure(with: viewController.editingOrderQuantity)


            // 當使用者點擊加入購物車時，透過 handler 傳遞數量
            cell.addToCart = { [weak self] quantity in
                self?.addToCartHandler?(quantity)
            }
            return cell
        }
    }
    
    /// 處理 section 的補充視圖 (`header 和 footer`)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter || kind == UICollectionView.elementKindSectionHeader {            
            guard let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier, for: indexPath) as? DrinkDetailSeparatorView else {
                fatalError("Cannot create separator view")
            }
            return separatorView
        }
        return UICollectionReusableView()
    }
    
}

// MARK: - UICollectionViewDelegate
extension DrinkDetailHandler: UICollectionViewDelegate {
}
*/



// MARK: - 處理職責


import UIKit

/// `DrinkDetailHandler`
///
/// 此類負責管理飲品詳細頁面中 `UICollectionView` 的資料來源 (`dataSource`) 和使用者互動 (`delegate`)。
///
/// ### 設計目標：
/// 1. 資料與邏輯分層：
///    - 通過 `DrinkDetailHandlerDelegate` 動態訪問資料，將資料邏輯集中於控制器，降低耦合。
/// 2. 專注處理視圖邏輯：
///    - 單一職責，僅負責呈現資料及回應使用者的交互行為。
///
/// ### 功能說明：
/// - 動態生成飲品資訊，包括圖片、描述、尺寸選擇及價格資訊。
/// - 處理使用者互動，回傳選擇的尺寸或加入購物車的數量至控制器。
/// - 透過委派模式與控制器通信，將更新事件與資料讀取交由控制器管理。
class DrinkDetailHandler: NSObject {
    
    // MARK: - Properties
    
    /// 用於通知控制器處理互動事件的委派
    /// - 透過 `DrinkDetailHandlerDelegate` 訪問資料與傳遞互動事件。
    private weak var drinkDetailHandlerDelegate: DrinkDetailHandlerDelegate?
    
    
    // MARK: - Initializer
    
    /// 初始化 `DrinkDetailHandler`，並設置委派
    /// - Parameter delegate: 控制器，需實作 `DrinkDetailHandlerDelegate`
    init(delegate: DrinkDetailHandlerDelegate) {
        self.drinkDetailHandlerDelegate = delegate
    }
    
}

// MARK: - UICollectionViewDataSource
extension DrinkDetailHandler: UICollectionViewDataSource {
    
    /// 返回 `UICollectionView` 的 section 數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DrinkDetailSection.allCases.count
    }
    
    /// 返回指定 section 的 item 數量
    ///
    /// ### 功能：
    /// - 根據資料模型與選中的尺寸，動態返回不同 section 的數量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = drinkDetailHandlerDelegate else { fatalError("Delegate is not set") }
        let drinkDetailModel = delegate.getDrinkDetailModel()
        let selectedSize = delegate.getSelectedSize()
        
        let section = DrinkDetailSection.allCases[section]
        switch section {
        case .image, .info, .orderOptions:
            return 1
        case .sizeSelection:
            return drinkDetailModel.sortedSizes.count
        case .priceInfo:
            return selectedSize.isEmpty ? 0 : 1
        }
    }
    
    /// 返回指定位置的 Cell
    ///
    /// - 根據 section 動態返回對應的 Cell，並配置相關資料。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = drinkDetailHandlerDelegate else { fatalError("Delegate is not set") }
        let drinkDetailModel = delegate.getDrinkDetailModel()
        let selectedSize = delegate.getSelectedSize()
        
        let section = DrinkDetailSection.allCases[indexPath.section]
        switch section {
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkImageCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkImageCollectionViewCell else {
                fatalError("Cannot dequeue DrinkImageCollectionViewCell")
            }
            cell.configure(with: drinkDetailModel.imageUrl)
            return cell
            
        case .info:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkInfoCollectionViewCell else {
                fatalError("Cannot dequeue DrinkInfoCollectionViewCell")
            }
            cell.configure(with: drinkDetailModel)
            return cell
            
        case .sizeSelection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkSizeSelectionCollectionViewCell else {
                fatalError("Unable to dequeue DrinkSizeSelectionCollectionViewCell")
            }
            let size = drinkDetailModel.sortedSizes[indexPath.item]
            cell.configure(with: size, isSelected: size == selectedSize)
            cell.sizeSelected = { selectedSize in
                delegate.didSelectSize(selectedSize)
            }
            return cell
            
        case .priceInfo:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier, for: indexPath
            ) as? DrinkPriceInfoCollectionViewCell else {
                fatalError("Cannot dequeue DrinkPriceInfoCollectionViewCell")
            }
            let sizeInfo = drinkDetailModel.sizeInfo(for: selectedSize)
            cell.configure(with: sizeInfo)
            return cell
            
        case .orderOptions:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier, for: indexPath) as? DrinkOrderOptionsCollectionViewCell else {
                fatalError("Cannot dequeue DrinkOrderOptionsCollectionViewCell")
            }
            cell.addToCart = { quantity in
                delegate.didTapAddToCart(quantity: quantity)
            }
            return cell
            
        }
    }
    
    /// 處理 section 的補充視圖 (`header 和 footer`)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter || kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier, for: indexPath) as? DrinkDetailSeparatorView else {
            fatalError("Cannot create separator view")
        }
        return separatorView
    }
    
}

// MARK: - UICollectionViewDelegate
extension DrinkDetailHandler: UICollectionViewDelegate {

}






// MARK: - 筆記：處理尺寸按鈕選取狀態更新與動畫效果
/**
 
 ## 筆記：處理尺寸按鈕選取狀態更新與動畫效果

 `* What`
 
 - 在 `DrinkSizeSelectionCollectionViewCell` 中處理尺寸按鈕的選取狀態更新和動畫效果時，需要決定使用 `reloadItems` 還是手動更新 Cell。

 - 選擇方式
 
 1. `reloadItems`
    - 用於刷新特定的 Cell，但可能會中斷動畫效果。
 
 2. `手動處理 Cell`
    - 精準更新目標 Cell 的狀態和顯示，不會影響動畫。

 --------------------

 `* Why`

 `1.使用 reloadItems 的原因`
 
 - 簡化邏輯：
   - 一次性更新特定的 Cell，適合批量刷新或大範圍改變。
 - 性能表現：
   - 在少量更新中性能表現足夠，但頻繁使用可能導致性能下降。

 `2.手動處理的原因`
 
 - 動畫需求：
   - 確保選中狀態和動畫效果的連續性，不會因刷新而中斷。
 - 精準更新：
   - 僅影響目標 Cell，減少不必要的刷新，提升性能和用戶體驗。

 --------------------

 `* How`

 `1. 使用 reloadItems 的情境`
 
 - 當需要批量更新 Cell，且對動畫效果沒有特殊要求時：
 ```swift
 let indexPaths = [currentIndexPath, previousIndexPath]
 collectionView.reloadItems(at: indexPaths)
 ```

 `2. 手動處理 Cell 的實作`
 
 - 當需要保持動畫效果並更新選中狀態時：
 ```swift
 func updateSelectedSize(to newSize: String, collectionView: UICollectionView, currentIndexPath: IndexPath) {
     guard let delegate = drinkDetailHandlerDelegate else { return }
     
     // 獲取舊尺寸
     let oldSize = delegate.getSelectedSize()
     if oldSize == newSize { return } // 如果尺寸未更改則直接返回
     
     // 更新舊尺寸的 Cell 狀態
     if let previousIndex = delegate.getDrinkDetailModel().sortedSizes.firstIndex(of: oldSize) {
         let previousIndexPath = IndexPath(item: previousIndex, section: DrinkDetailSection.sizeSelection.rawValue)
         updateCellState(at: previousIndexPath, in: collectionView, size: oldSize, isSelected: false)
     }
     
     // 更新新尺寸的 Cell 狀態
     updateCellState(at: currentIndexPath, in: collectionView, size: newSize, isSelected: true)
}
 ```

 --------------------

 `* 想法`
 
 - `手動處理 Cell`：適合當前需求（選取狀態和動畫結合緊密）。
 - `reloadItems`： 適合不需要動畫，且需要批量更新多個 Cell 的場景。

 */



// MARK: - DrinkDetailHandler 筆記
/**
 
 ## DrinkDetailHandler 筆記

 `* What`
 
 - `DrinkDetailHandler` 是一個負責管理飲品詳細頁面中 `UICollectionView` 的資料顯示和使用者互動邏輯的類別。
 - 它依賴於 `DrinkDetailHandlerDelegate` 來訪問資料與通知控制器進行業務邏輯處理。
 
 --------------------
 
 `* Why`
 
` 1.減少控制器的負擔：`
 
 -  將 `UICollectionView` 的資料與交互邏輯抽離至 `DrinkDetailHandler`，讓控制器專注於高層邏輯與功能。
 
 `2.增強模組化：`
 
 - 將 UICollectionView 的資料處理邏輯與顯示邏輯集中於 Handler，方便維護與重用。
 
 `3,提升可讀性與測試性：`
 
 - 控制器只需實作 `DrinkDetailHandlerDelegate`，單元測試時可獨立測試視圖邏輯。
 
 
 --------------------

 `* How`
 
 `1.初始化 Handler 並設置委派：`

 - 在控制器中初始化 `DrinkDetailHandler`，並將控制器設為委派對象。

 ```swift
 private func setupCollectionView() {
     guard let drinkDetailModel else { return }
     handler = DrinkDetailHandler(delegate: self)
     let collectionView = drinkDetailView.drinkDetailCollectionView
     collectionView.dataSource = handler
     collectionView.delegate = handler
 }
 ```
 
 ----
 
 `2.處理尺寸選擇邏輯：`

 - 使用 `updateSelectedSize` 更新當前選中尺寸，並透過委派通知控制器刷新價格資訊。
 
 ```swift
 func updateSelectedSize(to newSize: String, collectionView: UICollectionView, currentIndexPath: IndexPath) {
     guard let delegate = drinkDetailHandlerDelegate else { return }
     // 更新選中尺寸並通知控制器
     delegate.didSelectSize(newSize)
 }
 ```
 
 ----

 `3.資料來源邏輯：`

 - 在 `UICollectionViewDataSource` 中配置每個 `Section` 的 Cell。
 
 ```swift
 extension DrinkDetailHandler: UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         guard let delegate = drinkDetailHandlerDelegate else { return 0 }
         return delegate.getDrinkDetailModel().sortedSizes.count
     }
 }
 ```
 
 ----
 
 `4.通知控制器進行業務處理：`

 - 當使用者操作（如選擇尺寸或加入購物車）時，透過委派模式將事件傳遞給控制器。
 
 ```swift
 delegate.didSelectSize(newSize)
 delegate.didTapAddToCart(quantity: quantity)
 ```
 
 --------------------

 `* 注意事項`
 
 `1.選中狀態的同步：`

 - 確保 selectedSize 與 UI 狀態一致，避免出現狀態不同步的問題。
 
 `2.代碼擴展性：`

 - 若需要新增更多的互動邏輯（例如飲品配料選擇），可以直接在 `DrinkDetailHandlerDelegate` 中擴展方法，並更新 `DrinkDetailHandler` 的邏輯。
 
 `3.性能優化：`

 - 在大型列表中，需注意避免過度頻繁的 UI 刷新，使用適當的 IndexPath 更新。
 */
