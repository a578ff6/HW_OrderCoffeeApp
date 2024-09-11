//
//  DrinkDetailViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/25.
//

/*
## 目前邏輯：
    - 當使用者從 OrderViewController 點擊訂單飲品進入 DrinkDetailViewController 後，飲品的資訊（尺寸和數量）會被傳遞到 DrinkDetailViewController 進行編輯。
    - 當使用者修改完成後，再次提交修改，這些資料會正確地更新到訂單中。
 
 * 進入編輯模式
    - 當使用者在 OrderViewController 點擊訂單中的飲品時，會透過 presentDrinkDetailViewController ，將飲品的資訊（尺寸和數量）傳遞給 DrinkDetailViewController。
    - 在 DrinkDetailViewController 中，使用 selectedSize 和 editingOrderQuantity 來接收這些資料，準備顯示在畫面上。

 * 顯示正確資料
    - 進入 DrinkDetailViewController 後，透過 setSelectedSize ，確保畫面上顯示出正確的尺寸。
    - 如果傳遞過來的尺寸不為空，會使用這些資料顯示在界面上，避免預設值覆蓋正確的飲品資訊。
 
 * 提交修改
    - 當使用者修改完飲品資訊後，點擊「加入訂單」或「更新訂單」按鈕時，會透過 addToCart 方法提交更新的尺寸和數量。
    - 若 isEditingOrderItem == true（即進入編輯模式），系統會透過 OrderController.shared.updateOrderItem 更新該飲品的訂單資訊。

 * 資料更新回傳
    - addToCart 方法成功執行後，會將更新的資料提交到訂單系統，訂單中的飲品資訊（尺寸與數量）會正確更新並回傳到 OrderViewController，並即時反映在訂單列表中。
 
 * 無需額外的委託模式
    - OrderViewController：負責設置 OrderModificationDelegate，當用戶點擊訂單中的飲品時，它將飲品資訊傳遞給 DrinkDetailViewController，並在必要時通過委託方法來接收飲品更新。
    - DrinkDetailViewController：負責顯示並編輯飲品的詳細資訊，直接透過方法更新訂單，不需要設置委託。
 
 --------------------------------------------------------------------------------------------------------------------------------
 
 ## DrinkDetailViewController：

    - 功能： 顯示特定飲品的詳細資訊，允許使用者選取尺寸並加入購物車。
    - 視圖設置： 透過 DrinkDetailView 設置視圖，並使用 DrinkDetailHandler 管理 UICollectionView 的資料顯示及用戶互動。
    - 尺寸選擇： 初始化時會自動選擇預設尺寸，使用者也可以手動選擇其他尺寸，並即時更新價格及 UI 狀態。
 
    * 使用的自定義視圖：
        - DrinkDetailView： 包含一個 UICollectionView 用於顯示飲品的相關資訊與選項（如尺寸、價格、加入購物車按鈕等）。

    * 數據處理：
        - DrinkDetailHandler： 負責管理 UICollectionView 的資料顯示及用戶互動，包括處理尺寸選擇的邏輯，以及處理加入購物車的功能。
        - 當飲品資訊和尺寸加載完成後，會透過 setupHandler() 將邏輯處理交由 DrinkDetailHandler，並更新 UICollectionView。

    * 主要流程：
        - selectSize： 初始化選中的預設尺寸，或者當使用者手動選擇尺寸時，更新尺寸並刷新價格與 UI 狀態。
        - addToCart： 使用者確認選擇後，將飲品加入購物車，若處於編輯訂單模式，則會更新現有訂單項目。
        - handleSizeSelection： 當使用者選擇不同尺寸時，透過 selectSize 方法處理尺寸切換邏輯，並更新價格與 UI。
        - updateSizeSelectionAndPrice： 根據選擇的尺寸，更新飲品的價格資訊，並刷新尺寸選擇按鈕的狀態。
 
    * 主要功能概述：
        - 「初始化尺寸選擇邏輯」與「按鈕狀態刷新」都集中在 selectSize 和 updateSizeSelectionAndPrice 方法內，達到共用邏輯的目的。
        - DrinkDetailHandler 用於解耦控制器與視圖，清楚劃分了業務邏輯與顯示邏輯。
 */


// MARK: - 已經完善
import UIKit

/// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - Properties

    private let drinkDetailView = DrinkDetailView()
    private var collectionHandler: DrinkDetailHandler!
    
    /// 目前顯示的飲品資訊
    var drink: Drink?
    
    /// 使用者選擇的飲品尺寸
    var selectedSize: String?
    
    /// 是否在編輯現有訂單項目
    var isEditingOrderItem = false
    
    /// 如果是編輯模式，儲存該訂單項目的 ID
    var editingOrderID: UUID?
    
    /// 存取當前訂單飲品項目的杯數
    var editingOrderQuantity: Int = 1
    
    // 預先排序的尺寸，方便顯示
    var sortedSizes: [String] = []
    
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("接收到的 size: \(String(describing: selectedSize))") // 觀察訂單修改用
//        print("接收到的 quantity: \(editingOrderQuantity)")         // 觀察訂單修改用
        prepareSizes()
        configureCollectionView()
        setupHandler()
        selectSize()  // 初始化預設尺寸
    }
    
    // MARK: - Section Enum
    
    /// 定義不同的 section，依序為：飲品資訊、尺寸選擇、價格資訊、訂單選項
    enum Section: Int, CaseIterable {
        case info, sizeSelection, priceInfo, orderOptions
    }
    
    // MARK: - Setup Methods
    
    /// 將飲品尺寸排序
    private func prepareSizes() {
        sortedSizes = drink?.sizes.keys.sorted() ?? []
    }
    
    /// 設置 UICollectionView 的佈局與 collectionHandler
    private func configureCollectionView() {
        collectionHandler = DrinkDetailHandler(viewController: self)
        let collectionView = drinkDetailView.collectionView
        collectionView.dataSource = collectionHandler
        collectionView.delegate = collectionHandler
    }
    
    /// 配置尺寸選擇與加入購物車的邏輯處理
    private func setupHandler() {
        // 處理選取尺寸的邏輯
        collectionHandler.sizeSelectionHandler = { [weak self] selectedSize in
            self?.handleSizeSelection(selectedSize)
        }
        
        // 處理加入購物車的邏輯
        collectionHandler.addToCartHandler = { [weak self] quantity in
            self?.addToCart(quantity: quantity)
        }
    }
    
    // MARK: - Add to Cart Handler、Size Selection Handler
    
    /// 根據目前的選中尺寸與數量，將飲品加入購物車
    private func addToCart(quantity: Int) {
        guard let drink = drink, let size = selectedSize else { return }
        
        if isEditingOrderItem, let id = editingOrderID {
            OrderController.shared.updateOrderItem(withID: id, with: size, and: quantity)
            dismiss(animated: true, completion: nil)                        // 只在編輯模式時關閉
        } else {
            OrderController.shared.addOrderItem(drink: drink, size: size, quantity: quantity)
        }
    }
    
    /// 處理使用者選擇不同尺寸的邏輯
    private func handleSizeSelection(_ selectedSize: String) {
        selectSize(selectedSize)  // 選擇使用者點選的尺寸
    }
    
    /// 初始化選中的預設尺寸，或者當使用者手動選擇尺寸時，更新尺寸並刷新價格與 UI 狀態。
    ///
    /// 如果傳入的 size 為 nil，則初始化為「預設尺寸」。並更新價格與UI。
    private func selectSize(_ size: String? = nil) {
        if let size = size {
            selectedSize = size
        } else if selectedSize == nil {
            selectedSize = sortedSizes.first
        }
        updateSizeSelectionAndPrice()
    }

    // MARK: - Update UI Elements
    
    /// 根據選中尺寸更新價格資訊並刷新 UI
    private func updateSizeSelectionAndPrice() {
        if let sizeInfo = drink?.sizes[selectedSize ?? ""] {
            updatePriceInfo(sizeInfo: sizeInfo)
        }
        refreshSelectedSizeButtons()
    }

    /// 根據選中尺寸，更新價格資訊
    private func updatePriceInfo(sizeInfo: SizeInfo) {
        let priceInfoIndexPath = IndexPath(item: 0, section: DrinkDetailViewController.Section.priceInfo.rawValue)
        drinkDetailView.collectionView.reloadItems(at: [priceInfoIndexPath])
    }

    /// 刷新所有尺寸按鈕的狀態
    private func refreshSelectedSizeButtons() {
        drinkDetailView.collectionView.performBatchUpdates({
            for (index, size) in sortedSizes.enumerated() {
                let indexPath = IndexPath(item: index, section: Section.sizeSelection.rawValue)
                if let cell = drinkDetailView.collectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell {
                    cell.isSelectedSize = (size == selectedSize)
                }
            }
        }, completion: nil)
    }
    
}





// MARK: - 尺寸完成，數量完成（成功）UUID、UICollectionViewDiffableDataSource（重構前）
/*
 1. 設置當編輯訂單飲品項目時 DrinkDetailViewController 為 present modally：
    - 藉此讓用戶可以更快速地完成操作，而不需要跳轉到全螢幕視圖。
    - 當用戶在 OrderViewController 中點擊訂單飲品項目進行「修改」時，可以讓 DrinkDetailViewController 以卡片視圖的方式從下而上呈現。
    - 使用 present modally ，設置相應的過渡模式。
    - 此外，當用戶完成修改後，可以點擊按鈕將修改保存並關閉 DrinkDetailViewController 回到 OrderViewController。
 
 2. 通過更新按鈕的文字，讓用戶更清楚當前操作是添加新飲品還是修改訂單中的飲品

 3. 步驟：
    - 在 OrderViewController 中導航到 DrinkDetailViewController 時使用 present modally。
    - 在 DrinkDetailViewController 中配置 orderButton 的文字。
    - 在 DrinkDetailViewController 完成修改後導航回 OrderViewController。
 
 ------------------------------------------------------------------------------------------
 
 1. 在 DrinkDetailViewController 使用閉包：
    - 由於 DrinkOrderOptionsCollectionViewCell 和 DrinkSizeSelectionCollectionViewCell 是 DrinkDetailViewController的子視圖，這邊採用通過閉包傳遞數據和事件。
 
 2. sizeSortingOrder「根據預定的順序來排序尺寸」的位置：
    - 將這部分的處理法砸 DrinkDetailViewController 中，而不是 DrinkSizeSelectionCollectionViewCell 中。因為排序邏輯是與整個 ViewController的數據管理有關，而不是某個具體的 Cell。
    - DrinkSizeSelectionCollectionViewCell 只是展示數據。
 
 3. 重用的 Cell 在滾動時會被重新配置。如果不在 Cell 內將顯示或停止顯示時更新他們的選中狀態，會導致狀態不一致。
 
 ---------------------- ---------------------- ----------------------

 4. 處理當前正在「編輯的訂單飲品」的「數量」：
    - 設置 var editingOrderQuantity: Int = 1 是為了在 `DrinkDetailViewController` 中有一個變數來保存當前正在編輯的訂單飲品的數量。

 A. 初始化數量：
    - 當使用者從 OrderViewController 點擊一個訂單飲品項目進入到 DrinkDetailViewController 時，需要將該訂單飲品的數量傳遞過來。這個變數用來保存並顯示正在編輯的數量。

 B. 默認值：
    - 設置默認值 1 避免在未傳遞數量時出現數量為 0 的情況，保證數量至少為 1。
 
 C. 保持一致性：
    - 通過設置這個變數，可以確保在 `DrinkDetailViewController` 中使用這個數量來初始化和更新數量顯示，保持與實際訂單數量的一致性。

 */


/*
 import UIKit

 /// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
 class DrinkDetailViewController: UIViewController {

     @IBOutlet weak var drinkDetailCollectionView: UICollectionView!
     
     var drink: Drink?
     var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
     var selectedSize: String?
     let layoutProvider = DrinkDetailLayoutProvider()
     
     var isEditingOrderItem = false
     var editingOrderID: UUID?
     /// 存取當前訂單飲品項目的杯數
     var editingOrderQuantity: Int = 1

     
     // MARK: - Lifecycle Methods
     override func viewDidLoad() {
         super.viewDidLoad()
         setupCollectionView()
         configureDataSource()
         applyInitialSnapshot()
     }

     
     // MARK: - Section and Item Enum
     
     /// 定義不同的 section
     enum Section: CaseIterable {
         case info, sizeSelection, priceInfo, orderOptions
     }
     
     /// 定義不同的 item 類型
     enum Item: Hashable {
           case detail(Drink), sizeSelection(String), priceInfo(SizeInfo), orderOptions
     }
     
     // MARK: - Setup Methods
     
     /// 初始化 CollectionView 的佈局和註冊 Cell
     private func setupCollectionView() {
         drinkDetailCollectionView.register(DrinkInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier)
         drinkDetailCollectionView.register(DrinkSizeSelectionCollectionViewCell.self, forCellWithReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier)
         drinkDetailCollectionView.register(DrinkPriceInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier)
         drinkDetailCollectionView.register(DrinkOrderOptionsCollectionViewCell.self, forCellWithReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier)
         drinkDetailCollectionView.register(DrinkDetailSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier)
         drinkDetailCollectionView.collectionViewLayout = layoutProvider.createLayout()
     }
     
     /// 配置分隔線
     private func configureSeparatorView() {
         dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
             if kind == UICollectionView.elementKindSectionFooter {
                 let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkDetailSeparatorView.reuseIdentifier, for: indexPath)
                 return separatorView
             }
             return nil
         }
     }

 }


 // MARK: - Helper Methods
 extension DrinkDetailViewController {
     
     /// 根據預定的順序來排序尺寸
     private func sizeSortingOrder(size1: String, size2: String) -> Bool {
         let sizeOrder = ["ExtraLarge", "Large", "Medium", "Small", "Doppio", "Solo", "Pot"]
         if let index1 = sizeOrder.firstIndex(of: size1), let index2 = sizeOrder.firstIndex(of: size2) {
             return index1 < index2
         }
         return size1 < size2
     }
     
     /// 尺寸選擇項目
     /// - Parameter sizes: 尺寸的 String Array
     /// - Returns: 將每個 尺寸 String 映射為相應的 Item 並返回包含這些 Item 的 Array
     private func createSizeSelectionItems(from sizes: [String]) -> [Item] {
         return sizes.map { .sizeSelection($0) }
     }
     
     /// 更新 priceInfo 部分
     private func updatePriceInfo(sizeInfo: SizeInfo) {
         var snapshot = dataSource.snapshot()
         snapshot.deleteItems(dataSource.snapshot().itemIdentifiers(inSection: .priceInfo))   // 清空 priceInfo 部分的舊 items
         snapshot.appendItems([.priceInfo(sizeInfo)], toSection: .priceInfo)                  // 添加新的 priceInfo items
         dataSource.apply(snapshot, animatingDifferences: true)
     }
     
 }


 // MARK: - DataSource Configuration
 extension DrinkDetailViewController: UICollectionViewDelegate {
     
     /// 配置 collectionView 的資料源
     func configureDataSource() {
         dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: drinkDetailCollectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
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
                 cell.configure(with: size, isSelected: size == self.selectedSize)
                 cell.sizeSelected = { [weak self] selectedSize in
                     self?.selectedSize = selectedSize
                     if let sizeInfo = self?.drink?.sizes[selectedSize] {
                         self?.updatePriceInfo(sizeInfo: sizeInfo)
                     }
                     self?.updateSelectedSizeInCells(selectedSize)
                 }
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
                 cell.configure(with: self.editingOrderQuantity) // 初始化時設置數量
                 cell.addToCart = { [weak self] quantity in
                     guard let self = self else { return }
                     print("Order \(quantity) cups of \(self.selectedSize ?? "")")   // 測試
                     if let drink = self.drink, let size = self.selectedSize {
                         if self.isEditingOrderItem, let id = self.editingOrderID {
                             OrderController.shared.updateOrderItem(withID: id, with: size, and: quantity)
                         } else {
                             OrderController.shared.addOrderItem(drink: drink, size: size, quantity: quantity)
                         }
                     }
                                         
                     // 如果是編輯訂單項目，則關閉當前視圖，否則保持在當前視圖。
                     if self.isEditingOrderItem {
                         self.dismiss(animated: true, completion: nil)   // 完成修改後返回
                     }
                     
                 }
                 cell.updateOrderButtonTitle(isEditing: self.isEditingOrderItem)     // 根據編輯狀態更新按鈕
                 return cell
             }
         }
         
         configureSeparatorView()
         drinkDetailCollectionView.delegate = self
     }
     
     
     /// 更新選中的尺寸
     /// - Parameter selectedSize: 選中的尺寸
     private func updateSelectedSizeInCells( _ selectedSize: String) {
         for case let cell as DrinkSizeSelectionCollectionViewCell in drinkDetailCollectionView.visibleCells {
             cell.isSelectedSize = (cell.size == selectedSize)
         }
     }
     
     /// Cell 將顯示時
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         if let cell = cell as? DrinkSizeSelectionCollectionViewCell {
             cell.isSelectedSize = (cell.size == selectedSize)
         }
     }
     
     /// Cell 停止顯示時
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         if let cell = cell as? DrinkSizeSelectionCollectionViewCell {
             cell.isSelectedSize = false
         }
     }
     
 }

 // MARK: - Snapshot Configuration
 extension DrinkDetailViewController {
     
     /// 配置不同的 Section。
     private func applyInitialSnapshot() {
         var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
         snapshot.appendSections(Section.allCases)
         
         if let drink = drink {
             configureDrinkInfoSection(drink, snapshot: &snapshot)
             configureSizeSelectionSection(drink, snapshot: &snapshot)
             configurePriceInfoSection(drink, snapshot: &snapshot)
             configureOrderOptionsSection(snapshot: &snapshot)
         }
         
         dataSource.apply(snapshot, animatingDifferences: false)
     }
     
     /// 配置 DrinkInfo Section
     private func configureDrinkInfoSection(_ drink: Drink, snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
         snapshot.appendItems([.detail(drink)], toSection: .info)
     }
     
     /// 配置 SizeSelection Section
     private func configureSizeSelectionSection(_ drink: Drink, snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
         let sizes = Array(drink.sizes.keys).sorted(by: sizeSortingOrder)
         // 如果不是在編輯訂單項目，則設置第一個尺寸為選中狀態
         if !isEditingOrderItem {
             selectedSize = sizes.first
         }
         snapshot.appendItems(createSizeSelectionItems(from: sizes), toSection: .sizeSelection)
     }
     
     /// 配置 PriceInfo Section
     private func configurePriceInfoSection(_ drink: Drink, snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
         if let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] {
             snapshot.appendItems([.priceInfo(sizeInfo)], toSection: .priceInfo)
         }
     }
     
     /// 配置 OrderOptions Section
     private func configureOrderOptionsSection(snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
         snapshot.appendItems([.orderOptions], toSection: .orderOptions)
     }
     
 }


 // MARK: - OrderModificationDelegate
 extension DrinkDetailViewController: OrderModificationDelegate {
     
     func modifyOrderItem(_ orderItem: OrderItem, withID id: UUID) {
         self.drink = orderItem.drink
         self.selectedSize = orderItem.size
         self.isEditingOrderItem = true
         self.editingOrderID = id
         self.editingOrderQuantity = orderItem.quantity
         applyInitialSnapshot()
     }
     
 }
*/
