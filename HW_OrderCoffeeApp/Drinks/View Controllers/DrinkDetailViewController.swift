//
//  DrinkDetailViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/25.
//

/*
 （UICollectionViewDiffableDataSource）配置 collectionView 的資料源 -> 註冊XXCollectionViewCell到集合視圖，然後配置資料來源以返回該區段的單元格。-> createLayout
 
 
 1. 在 Firebase 中， Dictionary 的數據是順序的，無法按照我事先定義好的順序顯示這些尺寸，EX: 從大到小。
        - 因此，需要按特定順序顯示按鈕，需要對尺寸進行排序。
        - 在 applyInitialSnapshot 中對 sizes 進行排序，然後再添加到 snapshot 中。
 
 2. 比較元素： 在閉包內，比較兩個尺寸名稱 size1 和 size2
        - sizeOrder.firstIndex(of: size1) 取得 size1 在 sizeOrder 中的位置。
        - 如果 size1 存在於 sizeOrder 中，則返回它的索引位置（EX，"ExtraLarge" 的索引是 0）。同樣，sizeOrder.firstIndex(of: size2) 取得 size2 的索引位置。
 
 3. 判斷順序 if let index1 = sizeOrder.firstIndex(of: size1)...部分：
        - 如果 size1 和 size2 都存在於 sizeOrder 中，則比較它們的索引。如果 index1 小於 index2，說明 size1 的順序在 size2 前面，應該排在前面。
        - return size1 < size2：
            - 如果 size1 或 size2 不存在於 sizeOrder 中（這種情況不應該發生，除非有未定義的尺寸），則使用字母順序比較它們。這是個備用比較方法。
 
 5-1. orderOptions 布局問題：
        - 當選擇不同尺寸時，orderOptions的佈局位置，會移動到 sizeSelection 與 priceInfo 之間。
        - 是因為選取不同的尺寸時會刪除前一個尺寸的資訊包含布局。
 
 **5-2. 新的解法：
        - 後續改採用更新 priceInfo 的數據而不是刪除並重新添加 sections。藉此减少布局重新計算問題，及避免 orderOptions 位置錯誤。
        - 更新 priceInfo 時不再刪除 section ，而是僅刪除 section 內的 items 並重新添加 items。
        - 因此不再刪除 orderOptions 佈局，只是在更新 priceInfo 時保留其佈局。
 
 6-1. NotificationCenter 註冊和未解除註冊：
        - 導致當進入 DrinkDetailViewController 時，離開後，再次進入 DrinkDetailViewController 並且下訂單後，會導致重複發送和處理。
        - 每次進入 DrinkDetailViewController 時，會再次註冊通知觀察者，但是退出時並未成功解除註冊。
        - 確保在每次離開 DrinkDetailViewController 時解除通知觀察者的註冊，以避免重複調用。
        
 6-2. 先前使用 deinit 處理移除通知觀察者：
        -  deinit 方法是在對象被釋放（deallocated）時調用的，因此如果在 deinit 中移除通知觀察者，這僅在對象實際被釋放時才會生效。
        - 在某些情況下，例如對象沒有被釋放或者多次創建新的對象導致多次添加觀察者，僅使用 deinit 可能無法解決問題。
        - 而在 viewWillDisappear 方法中移除通知觀察者，則是在視圖控制器即將消失時移除觀察者，確保在視圖控制器每次消失時都能夠移除觀察者，避免重複接收通知。
            - 好處是確保每次視圖控制器消失時都能及時移除通知觀察者，避免重複添加觀察者或接收到過多不必要的通知。
 
--------------------------------------------------------------------------------------------------------------
    1. deinit 方法：適用於對象即將被釋放時進行清理操作，但如果對象沒有及時被釋放，可能無法及時移除觀察者。
    2. viewWillDisappear 方法：適用於每次視圖控制器即將消失時進行清理操作，確保不會多次添加觀察者或接收到重複的通知。
 -------------------------------------------------------------------------------------------------------------
 

 7. 關於訂單的處理，會在專門的訂單控制器（EX: 訂單列表 / 購物車）中進行，而不是在 DrinkDetailViewController 中進行。
        - 藉此保持單一責任原則，讓每個視圖控制器專注於自己的任務。
        - 在 DrinkDetailViewController 中，只需處理飲品的選擇和數量選擇，並將這些資訊傳遞給訂單控制器。訂單控制器會處理訂單項目的添加、更新和管理等操作。
        - 訂單控制器負責接收訂單資訊，並根據需要添加或更新訂單項目。
        - 在訂單控制器中集中處理訂單邏輯，如計算總金額、顯示訂單列表等。
 */


// MARK: - NotificationCenter

/*
import UIKit

/// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
class DrinkDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var drink: Drink?
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var selectedSize: String?
    let layoutProvider = DrinkDetailLayoutProvider()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        configureDataSource()
        applyInitialSnapshot()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()
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
        collectionView.register(DrinkInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkInfoCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkSizeSelectionCollectionViewCell.self, forCellWithReuseIdentifier: DrinkSizeSelectionCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkPriceInfoCollectionViewCell.self, forCellWithReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier)
        collectionView.register(DrinkOrderOptionsCollectionViewCell.self, forCellWithReuseIdentifier: DrinkOrderOptionsCollectionViewCell.reuseIdentifier)
        collectionView.register(SeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SeparatorView.reuseIdentifier)
        collectionView.collectionViewLayout = layoutProvider.createLayout()
    }
    
}


// MARK: - Helper Methods
extension DrinkDetailViewController {
    
    /// 根據預定的順序來排序尺寸：return Bool，表示 size1 是否應在 size2 之前
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
        return sizes.map { .sizeSelection($0)}
    }
    
}


// MARK: - Notification Handlers
extension DrinkDetailViewController {
    
    /// 設置通知觀察者
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(sizeChanged(_:)), name: Notification.Name("SizeChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orderButtonTapped(_:)), name: Notification.Name("OrderButtonTapped"), object: nil)
    }
    
    /// 移除通知觀察者
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SizeChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OrderButtonTapped"), object: nil)
    }
    
    /// 處理尺寸更改通知
    @objc func sizeChanged(_ notification: Notification) {
        guard let size = notification.userInfo?["size"] as? String, let drink = drink else { return }
        
        selectedSize = size
        
        if let sizeInfo = drink.sizes[size] {
            updatePriceInfo(sizeInfo: sizeInfo)
        }
    }
    
    /// 處理加入訂單按鈕的點擊事件
    @objc func orderButtonTapped(_ notification: Notification) {
        guard let quantity = notification.userInfo?["quantity"] as? Int else { return }
        print("Order \(quantity) cups of \(selectedSize ?? "")")    // 在這處理訂單邏輯，將訂單添加到訂單列表中
    }
    
    /// 更新 priceInfo 部分
    private func updatePriceInfo(sizeInfo: SizeInfo) {
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteItems(dataSource.snapshot().itemIdentifiers(inSection: .priceInfo))   // 清空 priceInfo 部分的舊 items
        snapshot.appendItems([.priceInfo(sizeInfo)], toSection: .priceInfo)                  // 添加新的 priceInfo items
        dataSource.apply(snapshot, animatingDifferences: true)
        
        NotificationCenter.default.post(name: NSNotification.Name("UpdateSelectedSize"), object: nil, userInfo: ["size": selectedSize ?? ""])           // 發送通知已更新選中狀態
    }
    
}


// MARK: - DataSource Configuration
extension DrinkDetailViewController {
    
    /// 配置 collectionView 的資料源
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
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
        
        // 配置分隔線視圖
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            if kind == UICollectionView.elementKindSectionFooter {
                let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SeparatorView.reuseIdentifier, for: indexPath)
                return separatorView
            }
            return nil
        }
    }
    
    /// 應用初始 Snapshot
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.info, .sizeSelection, .priceInfo, .orderOptions])
        
        if let drink = drink {
            snapshot.appendItems([.detail(drink)], toSection: .info)
            
            let sizes = Array(drink.sizes.keys).sorted(by: sizeSortingOrder)
            selectedSize = sizes.first  // 默認選擇第一個尺寸
            
            snapshot.appendItems(createSizeSelectionItems(from: sizes), toSection: .sizeSelection)
            
            if let firstSizeInfo = drink.sizes[sizes.first!] {
                snapshot.appendItems([.priceInfo(firstSizeInfo)], toSection: .priceInfo)
            }
            
            snapshot.appendItems([.orderOptions], toSection: .orderOptions)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}
*/


/*
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


// MARK: - 完全使用閉包（備用）
/*
 import UIKit

 /// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
 class DrinkDetailViewController: UIViewController {

     @IBOutlet weak var drinkDetailCollectionView: UICollectionView!
     
     var drink: Drink?
     var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
     var selectedSize: String?
     let layoutProvider = DrinkDetailLayoutProvider()
     
     
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
         drinkDetailCollectionView.register(SeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SeparatorView.reuseIdentifier)
         drinkDetailCollectionView.collectionViewLayout = layoutProvider.createLayout()
     }
     
 }


 // MARK: - Helper Methods
 extension DrinkDetailViewController {
     
     /// 根據預定的順序來排序尺寸： size1 是否應在 size2 之前
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
         return sizes.map { .sizeSelection($0)}
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
                 cell.addToCart = { [weak self] quantity in
                     print("Order \(quantity) cups of \(self?.selectedSize ?? "")")
                     // 在這處理訂單邏輯，將訂單添加到訂單列表中
                     if let drink = self?.drink, let size = self?.selectedSize {
                         OrderController.shared.addOrderItem(drink: drink, size: size, quantity: quantity)
                     }
                     
                 }
                 
                 return cell
             }

         }
         
         // 配置分隔線視圖
         dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
             if kind == UICollectionView.elementKindSectionFooter {
                 let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SeparatorView.reuseIdentifier, for: indexPath)
                 return separatorView
             }
             return nil
         }
         
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
     
     /// 應用初始 Snapshot，配置不同的 Section。
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
         selectedSize = sizes.first  // 默認選擇第一個尺寸
         snapshot.appendItems(createSizeSelectionItems(from: sizes), toSection: .sizeSelection)
     }
     
     /// 配置 PriceInfo Section
     private func configurePriceInfoSection(_ drink: Drink, snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
         if let firstSizeInfo = drink.sizes[selectedSize ?? ""] {
             snapshot.appendItems([.priceInfo(firstSizeInfo)], toSection: .priceInfo)
         }
     }
     
     /// 配置 OrderOptions Section
     private func configureOrderOptionsSection(snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
         snapshot.appendItems([.orderOptions], toSection: .orderOptions)
     }
     
 }
*/



// MARK: - 尺寸完成，數量完成（成功）UUID
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



// MARK: - uuid部分

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
