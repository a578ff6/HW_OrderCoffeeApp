//
//  EditOrderItemViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/23.
//


// MARK: - EditOrderItemViewController 筆記
/**
 ## EditOrderItemViewController 筆記

 ---

 `* What `
 
 - `EditOrderItemViewController` 是負責編輯飲品訂單項目的頁面控制器。它的主要功能包括：
 
 1. 顯示飲品的詳細資訊（如名稱、描述、圖片、尺寸選擇與價格）。
 2. 提供使用者調整飲品尺寸與數量的互動界面。
 3. 通過 `EditOrderItemModel` 管理當前編輯的訂單資料。
 4. 使用 `EditOrderItemHandler` 作為 `UICollectionView` 的資料來源與委派，專注處理視圖邏輯。
 5. 通過實作 `EditOrderItemHandlerDelegate` 接收並處理來自視圖的互動行為（如尺寸或數量變更）。

 ---

 `* Why`
 
 `1. 資料與邏輯分離`
 
    - `EditOrderItemViewController` 聚焦於控制器邏輯，將視圖更新與互動委派給 `EditOrderItemHandler`，降低耦合性。
    - 透過 `EditOrderItemModel` 簡化資料處理，確保頁面顯示的內容與當前資料一致。

 `2. 提升可維護性`
 
    - `EditOrderItemHandler` 負責 `UICollectionView` 的操作邏輯，實現單一職責原則（Single Responsibility Principle）。
    - 控制器只需專注於接收資料更新，提升程式碼的清晰度與擴展性。

 `3. 增強使用者體驗`
 
    - 使用者可視化選擇飲品的尺寸與數量，並即時更新顯示的價格資訊。
    - 操作完成後，資料會同步更新至全域訂單管理，並自動返回主頁面。

 ---

 `* How`
 
 `1. 初始化頁面與資料`
 
    - 使用 `orderItem` 初始化 `EditOrderItemModel`，提供頁面展示所需的資料。
    - 設置 `EditOrderItemHandler` 為 `UICollectionView` 的資料來源與委派。

    ```swift
    private func initializeOrderItemModel() {
        guard let orderItem else {
            print("無法加載訂單資料")
            return
        }
        editOrderItemModel = EditOrderItemModel(orderItem: orderItem)
    }
    ```

    ```swift
    private func setupHandler() {
        handler = EditOrderItemHandler(editOrderItemHandlerDelegate: self)
        editOrderItemView.editOrderItemCollectionView.delegate = handler
        editOrderItemView.editOrderItemCollectionView.dataSource = handler
        editOrderItemView.editOrderItemCollectionView.reloadData()
    }
    ```

 `2. 處理尺寸變更`
 
    - 使用者選擇新的尺寸後，更新 `selectedSize` 並重新整理對應的尺寸按鈕與價格資訊。

    ```swift
    func didChangeSize(_ newSize: String) {
        editOrderItemModel?.selectedSize = newSize
        print("尺寸已更新：\(newSize)")
        editOrderItemView.editOrderItemCollectionView.performBatchUpdates {
            guard let sizes = editOrderItemModel?.sortedSizes else { return }
            for (index, size) in sizes.enumerated() {
                let indexPath = IndexPath(item: index, section: EditOrderItemSection.sizeSelection.rawValue)
                guard let cell = editOrderItemView.editOrderItemCollectionView.cellForItem(at: indexPath) as? EditOrderItemSizeSelectionCollectionViewCell else { continue }
                cell.configure(with: size, isSelected: size == editOrderItemModel?.selectedSize)
            }
        }
        editOrderItemView.editOrderItemCollectionView.reloadSections(IndexSet(integer: EditOrderItemSection.priceInfo.rawValue))
    }
    ```

 `3. 處理數量變更`
 
    - 當使用者調整飲品數量，並且點擊「修改按鈕」後，更新模型並同步至全域訂單管理（`OrderItemManager`）。

    ```swift
    func didConfirmQuantityChange(to quantity: Int) {
        guard var editOrderItemModel = editOrderItemModel else { return }
        editOrderItemModel.quantity = quantity
        self.editOrderItemModel = editOrderItemModel
        print("數量已變更為：\(quantity)")
        OrderItemManager.shared.updateOrderItem(withID: editOrderItemModel.id, with: editOrderItemModel.selectedSize, and: quantity)
        dismiss(animated: true, completion: nil)
    }
    ```

` 4. 視圖架構`
 
    - 設定主要視圖為 `EditOrderItemView`，並通過 `loadView` 設置。
    - 視圖內部的 `UICollectionView` 由 `EditOrderItemHandler` 負責資料與互動管理。

    ```swift
    override func loadView() {
        view = editOrderItemView
    }
    ```
 */


// MARK: - 在 EditOrderItem 頁面避免重複使用 MenuController 和 Firebase 請求資料
/**
 
 ## 在 EditOrderItem 頁面避免重複使用 MenuController 和 Firebase 請求資料

 - 重構`DrinkDetail`職責前，當初在 `DrinkDetailViewController` 同時負責`展示飲品詳細資訊`和`編輯訂單項目`時，需要向 Firebase 請求飲品的詳細資料。
 
 ---

 `* What`

 - 在 `EditOrderItemViewController` 中展示和編輯訂單項目資料時，**避免重複使用 `MenuController` 或 Firebase 請求資料**。
 - 透過傳遞已存在的 `OrderItem` 資料，初始化 `EditOrderItemModel`，完成資料展示與編輯，減少不必要的網路請求，提升性能。

 ---

 `* Why`

 `1. 資料來源已足夠`
 
    - `OrderItem` 已包含飲品的相關資料，例如名稱、描述、圖片、尺寸資訊、數量等，這些資料是展示和編輯頁面所需的全部內容。
    - 因此，可以直接使用 `OrderItem` 而無需重新向 Firebase 請求。

 `2. 提升效能與效率`
 
    - 避免多餘的網路請求，減少 Firebase 負載，提升應用的響應速度。
    - 在本地完成資料展示，確保頁面切換更加順暢。

 `3. 簡化資料處理邏輯`
 
    - 不需要額外的資料請求邏輯，減少頁面初始化時的依賴。
    - 編輯頁面僅處理展示與本地修改，將 Firebase 同步操作延遲到需要時處理（如保存變更時）。

 `4. 本地資料一致性`
 
    - 保證所有與訂單相關的操作都基於 `OrderItem` 的本地資料，避免因多次請求導致的資料不一致問題。

 ---

 `* How `

 1. 設置 `OrderItem` 和 `EditOrderItemModel`
 
    - 確保 `OrderItem` 包含展示和編輯所需的完整資料。
    - 使用 `EditOrderItemModel` 將 `OrderItem` 的資料轉換為適合 UI 展示的結構。

    ```swift
    struct EditOrderItemModel {
        let id: UUID
        let drinkName: String
        let drinkSubName: String
        let description: String
        let imageUrl: URL
        let selectedSize: String
        let quantity: Int
        let sortedSizes: [String]
        let sizeDetails: [String: SizeInfo]

        init(orderItem: OrderItem) {
            self.id = orderItem.id
            self.drinkName = orderItem.drink.name
            self.drinkSubName = orderItem.drink.subName
            self.description = orderItem.drink.description
            self.imageUrl = orderItem.drink.imageUrl
            self.selectedSize = orderItem.size
            self.quantity = orderItem.quantity
            self.sortedSizes = orderItem.drink.sizes.keys.sorted()
            self.sizeDetails = orderItem.drink.sizes
        }
    }
    ```

` 2. 傳遞 OrderItem 至  EditOrderItemViewController`
 
    - 在 `OrderItemViewController` 中點擊訂單項目時，將 `OrderItem` 傳遞至編輯頁面：

    ```swift
 func navigateToEditOrderItemView(with orderItem: OrderItem) {
      guard let editOrderItemVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.editOrderItemViewController) as? EditOrderItemViewController else {
          print("Failed to instantiate EditOrderItemViewController.")
          return
      }

      // 傳遞 OrderItem 資料
      editOrderItemVC.orderItem = orderItem
  }
    ```

 `3. 在 EditOrderItemViewController 中展示資料`
 
    - 使用 `EditOrderItemModel` 初始化 UI，避免 Firebase 請求。

    ```swift
    class EditOrderItemViewController: UIViewController {
        var orderItem: OrderItem?
        private var editModel: EditOrderItemModel?

        override func viewDidLoad() {
            super.viewDidLoad()
            guard let orderItem else { return }
            editModel = EditOrderItemModel(orderItem: orderItem)
            setupUI()
        }

        private func setupUI() {
            guard let editModel else { return }
            navigationItem.title = "編輯訂單項目"
            print("飲品名稱： \(editModel.drinkName)")
            print("選擇的尺寸： \(editModel.selectedSize)")
            print("數量： \(editModel.quantity)")
        }
    }
    ```

 `4. 保存變更後同步更新`
 
    - 保存變更後，將資料更新至 `OrderItemManager`，同步至 Firebase。

    ```swift
    func saveChanges(newSize: String, newQuantity: Int) {
        guard let orderItem else { return }
        OrderItemManager.shared.updateOrderItem(withID: orderItem.id, with: newSize, and: newQuantity)
        navigationController?.popViewController(animated: true)
    }
    ```

 ---

 `* 補充：適用條件與例外狀況`

 `1. 適用條件`
 
    - `OrderItem` 的資料必須完整且準確，能滿足 UI 展示和編輯需求。

 `2. 例外狀況`
 
    - 如果 `OrderItem` 的資料不完整（如缺少飲品描述或尺寸詳情），則需要額外使用 `MenuController` 請求補全資料。

 ---

 `* 總結`

 - 核心概念：利用本地緩存的 `OrderItem` 資料，避免重複請求 Firebase，提升效能和邏輯簡潔性。
 - 優勢：減少網路依賴、提高效能、確保資料一致性。
 - 關鍵步驟：傳遞完整的 `OrderItem`、初始化 `EditOrderItemModel`、完成 UI 展示與編輯。
 */


// MARK: - (v)

import UIKit

/// `EditOrderItemViewController`
///
/// 此類別負責顯示及處理編輯飲品訂單項目的頁面邏輯，
/// 包括初始化資料模型、設定視圖、處理使用者交互行為（例如尺寸選擇與數量變更）。
///
/// ### 功能：
/// - 使用 `EditOrderItemModel` 初始化當前的訂單項目資料，提供視圖展示所需的數據。
/// - 將 `UICollectionView` 的資料來源與委派交由 `EditOrderItemHandler` 管理。
/// - 通過實作 `EditOrderItemHandlerDelegate`，處理來自 Handler 的互動事件（如尺寸與數量變更）。
class EditOrderItemViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 主視圖：包含顯示編輯飲品項目資訊的 UI 元件。
    private let editOrderItemView = EditOrderItemView()
    
    /// 接收傳遞進來的訂單項目資料
    var orderItem: OrderItem?
    
    /// 編輯中的訂單項目資料模型，包含尺寸、數量及其他詳細資訊
    private var editOrderItemModel: EditOrderItemModel?
    
    /// 管理 `UICollectionView` 的資料來源與互動事件
    private var handler: EditOrderItemHandler?
    
    // MARK: - Lifecycle
    
    /// 設定視圖為 `editOrderItemView`
    override func loadView() {
        view = editOrderItemView
    }
    
    /// 視圖加載完成後初始化所需資料與邏輯
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 驗證並初始化資料
        initializeOrderItemModel()
        
        // 設置 Handler 與委派
        setupHandler()
    }
    
    // MARK: - Private Methods
    
    /// 驗證並初始化 `EditOrderItemModel`。
    private func initializeOrderItemModel() {
        guard let orderItem else {
            print("無法加載訂單資料")
            return
        }
        editOrderItemModel = EditOrderItemModel(orderItem: orderItem)
    }
    
    /// 設置 `EditOrderItemHandler` 與相關的委派。
    private func setupHandler() {
        handler = EditOrderItemHandler(editOrderItemHandlerDelegate: self)
        editOrderItemView.editOrderItemCollectionView.delegate = handler
        editOrderItemView.editOrderItemCollectionView.dataSource = handler
        editOrderItemView.editOrderItemCollectionView.reloadData()
    }
    
}

// MARK: - EditOrderItemHandlerDelegate
extension EditOrderItemViewController: EditOrderItemHandlerDelegate {
    
    /// 提供當前編輯中的訂單項目資料模型。
    /// - Returns: 包含飲品詳細資料的 `EditOrderItemModel`。
    func getEditOrderItemModel() -> EditOrderItemModel {
        guard let editOrderItemModel else {
            fatalError("EditOrderItemModel 不存在")
        }
        return editOrderItemModel
    }
    
    /// 當飲品尺寸改變時觸發。
    /// - Parameter newSize: 使用者選擇的新尺寸。
    func didChangeSize(_ newSize: String) {
        
        /// 更新選中的尺寸狀態
        editOrderItemModel?.selectedSize = newSize
        print("尺寸已更新：\(newSize)")
        
        /// 刷新所有尺寸按鈕的選中狀態
        editOrderItemView.editOrderItemCollectionView.performBatchUpdates ({
            guard let sizes = editOrderItemModel?.sortedSizes else { return }
            for (index, size) in sizes.enumerated() {
                let indexPath = IndexPath(item: index, section: EditOrderItemSection.sizeSelection.rawValue)
                guard let cell = editOrderItemView.editOrderItemCollectionView.cellForItem(at: indexPath) as? EditOrderItemSizeSelectionCollectionViewCell else { continue }
                cell.configure(with: size, isSelected: size == editOrderItemModel?.selectedSize)
            }
        }, completion: nil)
        
        /// 刷新價格資訊
        editOrderItemView.editOrderItemCollectionView.reloadSections(IndexSet(integer: EditOrderItemSection.priceInfo.rawValue))
    }
    
    /// 當使確認變更數量時觸發（點擊「修改訂單」按鈕後）。
    /// - Parameter quantity: 使用者調整後的新數量。
    func didConfirmQuantityChange(to quantity: Int) {
        
        // 更新模型中的數量
        guard var editOrderItemModel = editOrderItemModel else { return }
        editOrderItemModel.quantity = quantity
        self.editOrderItemModel = editOrderItemModel
        print("數量已變更為：\(quantity)")
        
        // 更新 OrderItemManager 中的訂單
        OrderItemManager.shared.updateOrderItem(withID: editOrderItemModel.id, with: editOrderItemModel.selectedSize, and: quantity)
        
        // 當數量更新後，隨即關閉編輯頁面
        dismiss(animated: true, completion: nil)
    }
    
}
