//
//  DrinkDetailViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/25.
//

// MARK: - Favorite async 部分

/*
 ## 目前邏輯：
  
  * 資料傳遞與加載：
     - 當使用者從 OrderViewController 點擊訂單飲品進入 DrinkDetailViewController 後，僅會傳遞飲品的 drinkId、categoryId 和 subcategoryId，DrinkDetailViewController 會根據這些參數動態從 Firestore 加載飲品的詳細資訊。
     - 飲品的尺寸和數量等編輯內容，則會根據從 OrderViewController 傳遞的資料 (selectedSize 和 editingOrderQuantity) 顯示在界面上。

  
  * 進入編輯模式：
     - 當使用者在 OrderViewController 點擊訂單中的飲品時，會透過 presentDrinkDetailViewController，將飲品的 drinkId、categoryId、subcategoryId 以及尺寸和數量傳遞給 DrinkDetailViewController。
     - DrinkDetailViewController 中會根據傳遞的 selectedSize 和 editingOrderQuantity，來顯示飲品的詳細資訊與尺寸選擇。

  * 資料動態加載與顯示：
     - DrinkDetailViewController 會透過 drinkId、categoryId 和 subcategoryId 從 Firestore 加載飲品資料，並在資料加載完成後，透過 selectSize 來顯示傳遞過來的尺寸和數量。
     - 確保傳遞過來的 selectedSize 和 editingOrderQuantity 會正確顯示在界面上，避免預設值覆蓋這些資料。
  
  * 提交修改：
     - 當使用者修改完飲品資訊後，點擊「加入訂單」或「更新訂單」按鈕時，會透過 addToCart 方法提交更新的尺寸和數量。
     - 若 isEditingOrderItem == true（即進入編輯模式），系統會透過 OrderController.shared.updateOrderItem 更新該飲品的訂單資訊。

  * 資料更新回傳
     - addToCart 方法成功執行後，會將更新的資料提交到訂單系統，訂單中的飲品資訊（尺寸與數量）會正確更新並回傳到 OrderViewController，並即時反映在訂單列表中。
  
  * 無需額外的委託模式
     - OrderViewController 負責設置 OrderViewInteractionDelegate，當使用者點擊訂單中的飲品時，它將飲品的 drinkId、categoryId、subcategoryId 和編輯資料傳遞給 DrinkDetailViewController。並在必要時通過委託方法來接收飲品更新。
     - DrinkDetailViewController 負責加載和顯示飲品的詳細資訊，並直接透過方法更新訂單，而不需要額外設置委託來回傳資料。
  
  --------------------------------------------------------------------------------------------------------------------------------
  
  ## DrinkDetailViewController：

     * 功能：
         - 顯示特定飲品的詳細資訊，允許使用者選擇不同尺寸並將飲品加入購物車，且能在編輯模式下更新現有訂單項目。
         - 透過新增的 categoryId 和 subcategoryId，可更精確地從 Firestore 加載飲品資料。
     
     * 主要調整點：
         - 移除了全局 var drink: Drink?，改為使用 drinkId、categoryId 和 subcategoryId 來動態加載飲品資料。
         - 確保所有飲品資料在需要時動態從 Firestore 加載，避免 ViewController 依賴於「預先加載」的資料。
  
     * 視圖設置：
         - 透過 DrinkDetailView 設置主視圖，並使用 DrinkDetailHandler 管理 UICollectionView 的資料顯示及使用者互動。

     * 尺寸選擇：
         - 初始化時自動選擇預設尺寸，使用者可手動選擇其他尺寸，並即時更新價格和相關 UI 狀態。

     * 購物車功能：
         - 當使用者確認尺寸選擇後，將飲品加入購物車。
         - 若處於編輯模式，則更新現有的訂單項目，而不是添加新的項目。
  
  ## 調整後的資料處理：

     * 新增 categoryId、subcategoryId 的處理：
         - 當進入此頁面時，透過傳遞的 drinkId、categoryId 和 subcategoryId 來動態加載對應的飲品資料。
         - 移除了全局的 drink 屬性，將資料加載與顯示分離，透過 Firestore 加載後處理 UI 更新。

     * 尺寸選擇與價格更新：
         - 在 handleDrinkLoaded 中，飲品資料加載完成後會初始化可選尺寸，並透過 selectSize 自動選擇預設尺寸。
         - 使用者手動選擇尺寸時會更新選擇狀態和價格，並即時刷新尺寸按鈕的 UI 狀態。

  ## 主要流程：
  
     * viewDidLoad：
         - 加載主視圖後，透過 drinkId、categoryId 和 subcategoryId 加載飲品詳細資料。
         - 飲品資料加載後，透過 handleDrinkLoaded 更新可選尺寸及 UI 顯示。

     * loadDrinkDetail：
         - 從 Firestore 加載對應的飲品資料，確保使用者可以根據不同類別和子類別正確檢索飲品。
  
     * setupHandler：
         - 配置尺寸選擇及加入購物車的邏輯，透過 DrinkDetailHandler 處理 UICollectionView 的資料顯示和互動邏輯。

     * selectSize：
         - 根據使用者選擇的尺寸，更新價格資訊及尺寸按鈕狀態，並刷新相關的 UI 元素。

     * addToCart：
         - 將飲品與對應尺寸、數量加入購物車。若處於編輯模式，則會更新現有訂單項目，而非添加新項目。

  ## 功能概述：
     
     * 動態加載資料：
         - 使用 drinkId、categoryId 和 subcategoryId 從 Firestore 動態加載飲品資料，移除了對全局 drink 的依賴，使控制器更加靈活。

     * 尺寸選擇與價格更新：
         - 當使用者選擇不同尺寸時，會即時更新飲品的價格資訊並刷新按鈕的狀態，保持 UI 的一致性。

     * 加入購物車與訂單編輯：
         - 在購物車功能中，若處於編輯模式，會更新已存在的訂單項目，而不會新增新項目，確保購物車邏輯的完整性。

     * 分享功能：
         - 使用 ShareManager 分享當前飲品的詳細資訊，包含選擇的尺寸、名稱及描述等。
         - setupShareButton： 設置分享按鈕，並將其放置於導航列的右上角。
         - shareDrinkInfo： 使用 ShareManager 分享當前的飲品資訊，包括名稱、描述以及使用者選取的尺寸與相關尺寸資訊。
 
 ## Firebase 資料同步（FavoriteManager）

    * Firebase 資料操作現在使用 async/await，資料加載和更新的操作更直觀。
    * 當使用者操作「我的最愛」按鈕時，會即時更新 UI，並在背景中處理 Firebase 的資料同步，確保使用者能馬上看到按鈕狀態變化。
    * toggleFavorite(for: in:)：
        - 當使用者切換「我的最愛」狀態時，按鈕會即時更新，後續才進行 Firebase I/O 操作。
        - 使用 async/await 代替回調函數處理非同步操作，使結構更清晰。
 
 ## 資料加載與最愛功能的獨立性：

    * loadDrinkDetail：
        - 此方法主要負責從 Firestore 中加載飲品詳細資料，並將資料顯示在 UI 中。
        - 此部分與「我的最愛」功能無直接關聯，主要是處理飲品的數據加載與 UI 更新。

    * updateFavoriteButtonUIState：
        - 當飲品詳細資料加載完成後，才會檢查該飲品是否已加入「我的最愛」，並更新按鈕圖示和顏色。
        - 「我的最愛」的相關操作與資料加載是相對獨立的，保持分離是為了清晰區分資料加載與使用者互動的邏輯。
        - 當頁面載入或飲品資料加載完成時，會執行這段程式碼來顯示飲品是否已加入最愛。
 
 */



// MARK: - 調整我的最愛、drinkID & asyc & 分享、我的最愛已經完善 & 當 HUD 顯示時，不需要手動控制按鈕的禁用與否，因為 HUD 已經會禁用所有的互動。& 震動反饋 & 另外設置Image處理Cell佈局。
/*
import UIKit

/// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let drinkDetailView = DrinkDetailView()
    private var collectionHandler: DrinkDetailHandler!
    
    var categoryId: String?         // 傳遞進來的 categoryId，對應飲品所屬的類別
    var subcategoryId: String?      // 傳遞進來的 subcategoryId，對應飲品所屬的子類別
    var drinkId: String?            // 傳遞進來的 drinkId，用來從 Firestore 加載飲品詳細資料

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
    
    // MARK: - Section Enum
    
    /// 定義不同的 section，依序為：圖片、飲品資訊、尺寸選擇、價格資訊、訂單選項
    enum Section: Int, CaseIterable {
        case image, info, sizeSelection, priceInfo, orderOptions
    }
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print("接收到的 size: \(String(describing: selectedSize))") // 觀察訂單修改用
        //        print("接收到的 quantity: \(editingOrderQuantity)")         // 觀察訂單修改用
//        print("Received in DrinkDetailViewController: drinkId = \(String(describing: drinkId)), categoryId = \(String(describing: categoryId)), subcategoryId = \(String(describing: subcategoryId))")
        
        setupLargeTitleMode()
        registerNotifications()
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.setupNavigationBarItems() }
                group.addTask { await self.loadDrinkDetail() }
            }
        }
    }
    
    // MARK: - deinit
    deinit {
        removeNotifications() // 移除通知
    }
    
    // MARK: - Data Loading (using async/await)
    
    /// 從 Firestore 加載飲品資料，根據 drinkId、categoryId 和 subcategoryId 確定正確的資料來源
    private func loadDrinkDetail() async {
        guard let drinkId = drinkId, let categoryId = categoryId, let subcategoryId = subcategoryId else { return }
        HUDManager.shared.showLoading(text: "Loading Detail...")
        do {
            let loadedDrink = try await MenuController.shared.loadDrinkById(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
            await handleDrinkLoaded(loadedDrink)
        } catch {
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
        HUDManager.shared.dismiss()
    }
    
    // MARK: - UI Update
    
    /// 加載完成後的處理邏輯
    private func handleDrinkLoaded(_ drink: Drink) async {
        updateSortedSizes(with: drink)
        updateUI(with: drink)
        setupHandler(with: drink)
        await updateFavoriteButtonUIState()    // 當資料載入完成後，更新按鈕的視覺狀態即可，無需再管理按鈕的互動性。
    }
    
    /// 更新排序的尺寸
    private func updateSortedSizes(with drink: Drink) {
        sortedSizes = drink.sizes.keys.sorted()
    }
    
    /// 更新 UI 元素以顯示飲品詳細資料
    private func updateUI(with drink: Drink) {
        drinkDetailView.collectionView.reloadData()
        selectSize(with: drink)  // 初始化預設尺寸
    }
    
    // MARK: - Setup Methods
    
    /// 配置尺寸選擇與加入購物車的邏輯處理
    private func setupHandler(with drink: Drink) {
        collectionHandler = DrinkDetailHandler(viewController: self, drink: drink)  // 在這裡初始化
        let collectionView = drinkDetailView.collectionView
        collectionView.dataSource = collectionHandler
        collectionView.delegate = collectionHandler
        
        // 處理選取尺寸的邏輯
        collectionHandler.sizeSelectionHandler = { [weak self] selectedSize in
            self?.handleSizeSelection(selectedSize, with: drink)
        }
        
        // 處理加入購物車的邏輯
        collectionHandler.addToCartHandler = { [weak self] quantity in
            self?.addToCart(quantity: quantity, with: drink)
        }
    }
    
    // MARK: - Add to Cart Handler、Size Selection Handler
    
    /// 根據目前的選中尺寸與數量，將飲品加入購物車或是更新購物車中的飲品資訊，並傳遞對應的 categoryId 和 subcategoryId
    private func addToCart(quantity: Int, with drink: Drink) {
        guard let size = selectedSize else {
            print("無法添加到購物車，未選擇尺寸")
            return
        }
        
        if isEditingOrderItem, let id = editingOrderID {
            OrderItemManager.shared.updateOrderItem(withID: id, with: size, and: quantity)
            dismiss(animated: true, completion: nil)
        } else {
            print("正在添加到購物車: 飲品 - \(drink.name), 尺寸 - \(size), 數量 - \(quantity)")
            OrderItemManager.shared.addOrderItem(drink: drink, size: size, quantity: quantity, categoryId: categoryId, subcategoryId: subcategoryId)
        }
    }
    
    /// 處理使用者選擇不同尺寸的邏輯
    private func handleSizeSelection(_ selectedSize: String, with drink: Drink) {
        selectSize(selectedSize, with: drink)
    }
    
    /// 初始化選中的預設尺寸，或者當使用者手動選擇尺寸時，更新尺寸並刷新價格與 UI 狀態。
    private func selectSize(_ size: String? = nil, with drink: Drink) {
        if let size = size {
            selectedSize = size
        } else if selectedSize == nil {
            selectedSize = sortedSizes.first  // 確保有預設尺寸
        }
        updateSizeSelectionAndPrice(with: drink)
    }
    
    // MARK: - Update UI Elements
    
    /// 根據選中尺寸更新價格資訊並刷新 UI
    private func updateSizeSelectionAndPrice(with drink: Drink) {
        guard let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] else { return }
        updatePriceInfo(sizeInfo: sizeInfo)
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
    
    // MARK: - Navigation Bar Items Setup
    
    /// 設置導航欄按鈕（`分享` 和 `我的最愛`）
    private func setupNavigationBarItems() async {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareDrinkInfo))
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        self.navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
        self.navigationItem.rightBarButtonItems = [shareButton]
        
        await updateFavoriteButtonUIState()                                   // 當資料加載完成後更新我的最愛的視覺狀態
    }
    
    /// 更新 `我的最愛` 按鈕的視覺狀態
    private func updateFavoriteButtonUIState() async {
        guard let drinkId = drinkId else { return }
        let isFavorite = await FavoriteManager.shared.isFavorite(drinkId: drinkId)
        let favoriteButton = self.navigationItem.rightBarButtonItems?[1]
        favoriteButton?.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton?.tintColor = isFavorite ? UIColor.deepGreen : UIColor.deepGreen
    }
    
    // MARK: - Share Action & Favorite Action
    
    /// `分享`當前的飲品資訊，包含名稱、描述以及使用者選取的尺寸與相關尺寸資訊。
    @objc private func shareDrinkInfo() {
        guard let drink = collectionHandler.drink else { return }
        guard let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] else { return }
        ShareManager.shared.share(drink: drink, selectedSize: selectedSize, sizeInfo: sizeInfo, from: self)
    }
    
    /// 切換飲品的「加入最愛」狀態，並且添加震動反饋
    @objc private func toggleFavorite() {
        guard let categoryId = categoryId, let subcategoryId = subcategoryId, let drinkId = drinkId else { return }
        // 創建 FavoriteDrink 結構
        let favoriteDrink = FavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
        Task {
            await FavoriteManager.shared.toggleFavorite(for: favoriteDrink, in: self)
            ButtonEffectManager.shared.applyHapticFeedback()
        }
    }
    
    // MARK: - Navigation Title
    
    /// 設定 navigationItem 的大標題顯示模式
    private func setupLargeTitleMode() {
        navigationItem.largeTitleDisplayMode = .never
    }

}

// MARK: - Notifications Handling

extension DrinkDetailViewController {
    /// 註冊通知觀察者
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteStatusChanged), name: .favoriteStatusChanged, object: nil)
    }
    
    /// 移除通知觀察者
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 當「我的最愛」狀態改變時，更新 UI，檢查最新的「我的最愛」狀態並更新按鈕
    @objc private func handleFavoriteStatusChanged() {
        Task {
            await updateFavoriteButtonUIState()
        }
    }
}
*/


// MARK: - 重構我的最愛部分
/*
import UIKit

/// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let drinkDetailView = DrinkDetailView()
    private var collectionHandler: DrinkDetailHandler!
    
    var categoryId: String?         // 傳遞進來的 categoryId，對應飲品所屬的類別
    var subcategoryId: String?      // 傳遞進來的 subcategoryId，對應飲品所屬的子類別
    var drinkId: String?            // 傳遞進來的 drinkId，用來從 Firestore 加載飲品詳細資料

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
    
    // MARK: - Section Enum
    
    /// 定義不同的 section，依序為：圖片、飲品資訊、尺寸選擇、價格資訊、訂單選項
    enum Section: Int, CaseIterable {
        case image, info, sizeSelection, priceInfo, orderOptions
    }
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print("接收到的 size: \(String(describing: selectedSize))") // 觀察訂單修改用
        //        print("接收到的 quantity: \(editingOrderQuantity)")         // 觀察訂單修改用
//        print("Received in DrinkDetailViewController: drinkId = \(String(describing: drinkId)), categoryId = \(String(describing: categoryId)), subcategoryId = \(String(describing: subcategoryId))")
        
        setupLargeTitleMode()
//        registerNotifications()
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.setupNavigationBarItems() }
                group.addTask { await self.loadDrinkDetail() }
            }
        }
    }
    
    // MARK: - deinit
//    deinit {
//        removeNotifications() // 移除通知
//    }
    
    // MARK: - Data Loading (using async/await)
    
    /// 從 Firestore 加載飲品資料，根據 drinkId、categoryId 和 subcategoryId 確定正確的資料來源
    private func loadDrinkDetail() async {
        guard let drinkId = drinkId, let categoryId = categoryId, let subcategoryId = subcategoryId else { return }
        HUDManager.shared.showLoading(text: "Loading Detail...")
        do {
            let loadedDrink = try await MenuController.shared.loadDrinkById(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
            await handleDrinkLoaded(loadedDrink)
        } catch {
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
        HUDManager.shared.dismiss()
    }
    
    // MARK: - UI Update
    
    /// 加載完成後的處理邏輯
    private func handleDrinkLoaded(_ drink: Drink) async {
        updateSortedSizes(with: drink)
        updateUI(with: drink)
        setupHandler(with: drink)
//        await updateFavoriteButtonUIState()    // 當資料載入完成後，更新按鈕的視覺狀態即可，無需再管理按鈕的互動性。
    }
    
    /// 更新排序的尺寸
    private func updateSortedSizes(with drink: Drink) {
        sortedSizes = drink.sizes.keys.sorted()
    }
    
    /// 更新 UI 元素以顯示飲品詳細資料
    private func updateUI(with drink: Drink) {
        drinkDetailView.collectionView.reloadData()
        selectSize(with: drink)  // 初始化預設尺寸
    }
    
    // MARK: - Setup Methods
    
    /// 配置尺寸選擇與加入購物車的邏輯處理
    private func setupHandler(with drink: Drink) {
        collectionHandler = DrinkDetailHandler(viewController: self, drink: drink)  // 在這裡初始化
        let collectionView = drinkDetailView.collectionView
        collectionView.dataSource = collectionHandler
        collectionView.delegate = collectionHandler
        
        // 處理選取尺寸的邏輯
        collectionHandler.sizeSelectionHandler = { [weak self] selectedSize in
            self?.handleSizeSelection(selectedSize, with: drink)
        }
        
        // 處理加入購物車的邏輯
        collectionHandler.addToCartHandler = { [weak self] quantity in
            self?.addToCart(quantity: quantity, with: drink)
        }
    }
    
    // MARK: - Add to Cart Handler、Size Selection Handler
    
    /// 根據目前的選中尺寸與數量，將飲品加入購物車或是更新購物車中的飲品資訊，並傳遞對應的 categoryId 和 subcategoryId
    private func addToCart(quantity: Int, with drink: Drink) {
        guard let size = selectedSize else {
            print("無法添加到購物車，未選擇尺寸")
            return
        }
        
        if isEditingOrderItem, let id = editingOrderID {
            OrderItemManager.shared.updateOrderItem(withID: id, with: size, and: quantity)
            dismiss(animated: true, completion: nil)
        } else {
            print("正在添加到購物車: 飲品 - \(drink.name), 尺寸 - \(size), 數量 - \(quantity)")
            OrderItemManager.shared.addOrderItem(drink: drink, size: size, quantity: quantity, categoryId: categoryId, subcategoryId: subcategoryId)
        }
    }
    
    /// 處理使用者選擇不同尺寸的邏輯
    private func handleSizeSelection(_ selectedSize: String, with drink: Drink) {
        selectSize(selectedSize, with: drink)
    }
    
    /// 初始化選中的預設尺寸，或者當使用者手動選擇尺寸時，更新尺寸並刷新價格與 UI 狀態。
    private func selectSize(_ size: String? = nil, with drink: Drink) {
        if let size = size {
            selectedSize = size
        } else if selectedSize == nil {
            selectedSize = sortedSizes.first  // 確保有預設尺寸
        }
        updateSizeSelectionAndPrice(with: drink)
    }
    
    // MARK: - Update UI Elements
    
    /// 根據選中尺寸更新價格資訊並刷新 UI
    private func updateSizeSelectionAndPrice(with drink: Drink) {
        guard let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] else { return }
        updatePriceInfo(sizeInfo: sizeInfo)
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
    
    // MARK: - Navigation Bar Items Setup
    
    /// 設置導航欄按鈕（`分享` 和 `我的最愛`）
    private func setupNavigationBarItems() async {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareDrinkInfo))
//        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
//        self.navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
        self.navigationItem.rightBarButtonItems = [shareButton]
        
//        await updateFavoriteButtonUIState()                                   // 當資料加載完成後更新我的最愛的視覺狀態
    }
    
    /*
    /// 更新 `我的最愛` 按鈕的視覺狀態
    private func updateFavoriteButtonUIState() async {
        guard let drinkId = drinkId else { return }
        let isFavorite = await FavoriteManager.shared.isFavorite(drinkId: drinkId)
        let favoriteButton = self.navigationItem.rightBarButtonItems?[1]
        favoriteButton?.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton?.tintColor = isFavorite ? UIColor.deepGreen : UIColor.deepGreen
    }
    */
    
    // MARK: - Share Action & Favorite Action
    
    /// `分享`當前的飲品資訊，包含名稱、描述以及使用者選取的尺寸與相關尺寸資訊。
    @objc private func shareDrinkInfo() {
        guard let drink = collectionHandler.drink else { return }
        guard let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] else { return }
        ShareManager.shared.share(drink: drink, selectedSize: selectedSize, sizeInfo: sizeInfo, from: self)
    }
    
    /*
    /// 切換飲品的「加入最愛」狀態，並且添加震動反饋
    @objc private func toggleFavorite() {
        guard let categoryId = categoryId, let subcategoryId = subcategoryId, let drinkId = drinkId else { return }
        // 創建 FavoriteDrink 結構
        let favoriteDrink = FavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
        Task {
            await FavoriteManager.shared.toggleFavorite(for: favoriteDrink, in: self)
            ButtonEffectManager.shared.applyHapticFeedback()
        }
    }
    */
    
    // MARK: - Navigation Title
    
    /// 設定 navigationItem 的大標題顯示模式
    private func setupLargeTitleMode() {
        navigationItem.largeTitleDisplayMode = .never
    }

}

// MARK: - Notifications Handling
/*
extension DrinkDetailViewController {
    /// 註冊通知觀察者
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteStatusChanged), name: .favoriteStatusChanged, object: nil)
    }
    
    /// 移除通知觀察者
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 當「我的最愛」狀態改變時，更新 UI，檢查最新的「我的最愛」狀態並更新按鈕
    @objc private func handleFavoriteStatusChanged() {
        Task {
            await updateFavoriteButtonUIState()
        }
    }
}
*/
 
*/


// MARK: - 重構我的最愛，但先刪除掉。
/*
import UIKit

/// 該飲品的詳細資訊頁面，選取相對應的尺寸並加入訂單。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let drinkDetailView = DrinkDetailView()
    private var collectionHandler: DrinkDetailHandler!
    
    var categoryId: String?         // 傳遞進來的 categoryId，對應飲品所屬的類別
    var subcategoryId: String?      // 傳遞進來的 subcategoryId，對應飲品所屬的子類別
    var drinkId: String?            // 傳遞進來的 drinkId，用來從 Firestore 加載飲品詳細資料

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
    
    // MARK: - Section Enum
    
    /// 定義不同的 section，依序為：圖片、飲品資訊、尺寸選擇、價格資訊、訂單選項
    enum Section: Int, CaseIterable {
        case image, info, sizeSelection, priceInfo, orderOptions
    }
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLargeTitleMode()
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.setupNavigationBarItems() }
                group.addTask { await self.loadDrinkDetail() }
            }
        }
    }
    
    // MARK: - Data Loading (using async/await)
    
    /// 從 Firestore 加載飲品資料，根據 drinkId、categoryId 和 subcategoryId 確定正確的資料來源
    private func loadDrinkDetail() async {
        guard let drinkId = drinkId, let categoryId = categoryId, let subcategoryId = subcategoryId else { return }
        HUDManager.shared.showLoading(text: "Loading Detail...")
        do {
            let loadedDrink = try await MenuController.shared.loadDrinkById(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
            await handleDrinkLoaded(loadedDrink)
        } catch {
            AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self)
        }
        HUDManager.shared.dismiss()
    }
    
    // MARK: - UI Update
    
    /// 加載完成後的處理邏輯
    private func handleDrinkLoaded(_ drink: Drink) async {
        updateSortedSizes(with: drink)
        updateUI(with: drink)
        setupHandler(with: drink)
    }
    
    /// 更新排序的尺寸
    private func updateSortedSizes(with drink: Drink) {
        sortedSizes = drink.sizes.keys.sorted()
    }
    
    /// 更新 UI 元素以顯示飲品詳細資料
    private func updateUI(with drink: Drink) {
        drinkDetailView.collectionView.reloadData()
        selectSize(with: drink)  // 初始化預設尺寸
    }
    
    // MARK: - Setup Methods
    
    /// 配置尺寸選擇與加入購物車的邏輯處理
    private func setupHandler(with drink: Drink) {
        collectionHandler = DrinkDetailHandler(viewController: self, drink: drink)  // 在這裡初始化
        let collectionView = drinkDetailView.collectionView
        collectionView.dataSource = collectionHandler
        collectionView.delegate = collectionHandler
        
        // 處理選取尺寸的邏輯
        collectionHandler.sizeSelectionHandler = { [weak self] selectedSize in
            self?.handleSizeSelection(selectedSize, with: drink)
        }
        
        // 處理加入購物車的邏輯
        collectionHandler.addToCartHandler = { [weak self] quantity in
            self?.addToCart(quantity: quantity, with: drink)
        }
    }
    
    // MARK: - Add to Cart Handler、Size Selection Handler
    
    /// 根據目前的選中尺寸與數量，將飲品加入購物車或是更新購物車中的飲品資訊，並傳遞對應的 categoryId 和 subcategoryId
    private func addToCart(quantity: Int, with drink: Drink) {
        guard let size = selectedSize else {
            print("無法添加到購物車，未選擇尺寸")
            return
        }
        
        if isEditingOrderItem, let id = editingOrderID {
            OrderItemManager.shared.updateOrderItem(withID: id, with: size, and: quantity)
            dismiss(animated: true, completion: nil)
        } else {
            print("正在添加到購物車: 飲品 - \(drink.name), 尺寸 - \(size), 數量 - \(quantity)")
            OrderItemManager.shared.addOrderItem(drink: drink, size: size, quantity: quantity, categoryId: categoryId, subcategoryId: subcategoryId)
        }
    }
    
    /// 處理使用者選擇不同尺寸的邏輯
    private func handleSizeSelection(_ selectedSize: String, with drink: Drink) {
        selectSize(selectedSize, with: drink)
    }
    
    /// 初始化選中的預設尺寸，或者當使用者手動選擇尺寸時，更新尺寸並刷新價格與 UI 狀態。
    private func selectSize(_ size: String? = nil, with drink: Drink) {
        if let size = size {
            selectedSize = size
        } else if selectedSize == nil {
            selectedSize = sortedSizes.first  // 確保有預設尺寸
        }
        updateSizeSelectionAndPrice(with: drink)
    }
    
    // MARK: - Update UI Elements
    
    /// 根據選中尺寸更新價格資訊並刷新 UI
    private func updateSizeSelectionAndPrice(with drink: Drink) {
        guard let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] else { return }
        updatePriceInfo(sizeInfo: sizeInfo)
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
                    let isSelected = (size == selectedSize) // 判斷是否為選中尺寸
                    cell.configure(with: size, isSelected: isSelected)
                }
                
            }
        }, completion: nil)
    }
    
    // MARK: - Navigation Bar Items Setup
    
    /// 設置導航欄按鈕（`分享` 和 `我的最愛`）
    private func setupNavigationBarItems() async {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareDrinkInfo))
        self.navigationItem.rightBarButtonItems = [shareButton]
    }

    // MARK: - Share Action & Favorite Action
    
    /// `分享`當前的飲品資訊，包含名稱、描述以及使用者選取的尺寸與相關尺寸資訊。
    @objc private func shareDrinkInfo() {
        guard let drink = collectionHandler.drink else { return }
        guard let selectedSize = selectedSize, let sizeInfo = drink.sizes[selectedSize] else { return }
        ShareManager.shared.share(drink: drink, selectedSize: selectedSize, sizeInfo: sizeInfo, from: self)
    }
    
    
    // MARK: - Navigation Title
    
    /// 設定 navigationItem 的大標題顯示模式
    private func setupLargeTitleMode() {
        navigationItem.largeTitleDisplayMode = .never
    }

}
*/










// MARK: - 我的最愛、添加訂單(v)

/*
import UIKit

/// `DrinkDetailViewController`
///
/// ### 功能描述
/// 此控制器負責顯示飲品的詳細資訊，並提供以下功能：
/// - 顯示飲品圖片、描述、尺寸選擇與價格資訊。
/// - 支援用戶選擇飲品尺寸並動態更新價格資訊。
/// - 加入購物車功能，將所選飲品及數量傳遞至購物車管理邏輯。
/// - 支援分享與收藏功能，並確保收藏按鈕狀態即時更新。
///
/// ### 設計目標
/// 1. 清晰架構：
///    - 分離業務邏輯、資料處理與視圖層次，提升可讀性與可維護性。
/// 2. 模組化設計：
///    - 使用 `DrinkDetailHandler` 處理 `UICollectionView` 的資料來源與交互邏輯。
///    - 使用 `DrinkDetailNavigationBarManager` 管理導航欄邏輯。
///    - 使用 `DrinkDetailHandlerDelegate` 與控制器進行通信。
///
/// ### 注意事項
/// - 確保 `drinkId` 在操作過程中非空，避免崩潰。
/// - 確保 `favoritesHandler` 與 `navigationBarManager` 正確初始化以處理收藏與導航相關功能。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 主視圖：包含顯示飲品詳細資訊的 UI 元件。
    private let drinkDetailView = DrinkDetailView()
    
    // MARK: - Handlers and Managers
    
    /// 處理 `UICollectionView` 的資料與使用者互動邏輯。
    private var handler: DrinkDetailHandler?
    
    /// 管理導航欄按鈕與標題的邏輯。
    private var navigationBarManager: DrinkDetailNavigationBarManager?
    
    /// 分享管理器：處理飲品分享的邏輯。
    private var shareManager: DrinkDetailShareManager?
    
    /// 收藏管理器：負責收藏功能的業務邏輯。
    private var favoritesHandler: DrinkDetailFavoritesHandler?
    
    // MARK: - Model and State
    
    /// 飲品詳細資料：從 Firebase 加載的資料模型。
    private var drinkDetailModel: DrinkDetailModel?
    
    /// 當前選擇的飲品尺寸，用於全局狀態管理。
    private var selectedSize: String = ""
    
    // MARK: - Identifier Properties
    
    /// 飲品的分類 ID
    var categoryId: String?
    
    /// 飲品的子分類 ID
    var subcategoryId: String?
    
    /// 飲品的唯一 ID
    var drinkId: String?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    /// 初始化控制器時加載資料並設置導航欄。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        initializeFavoritesHandler()
        loadDrinkDetail()
    }
    
    /// 當頁面即將顯示時更新收藏按鈕狀態。
    ///
    /// - 確保收藏按鈕的圖示能正確反映後端的收藏狀態。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButtonState()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄樣式與功能按鈕。
    ///
    /// 此方法使用 `DrinkDetailNavigationBarManager`：
    /// 1. 設置導航欄標題的顯示模式。
    /// 2. 添加功能按鈕，包括「分享」與「收藏」按鈕。
    /// 3. 設置當按鈕被點擊時的回調代理。
    private func configureNavigationBar() {
        navigationBarManager = DrinkDetailNavigationBarManager(navigationItem: navigationItem)
        navigationBarManager?.delegate = self
        navigationBarManager?.configureNavigationBarTitle(largeTitleDisplayMode: false)
        navigationBarManager?.addNavigationButtons()
    }
    
    /// 初始化收藏管理器。
    ///
    /// 此方法負責為 `favoritesHandler` 指派實例，用於處理與收藏相關的邏輯操作。
    /// - 注意：`favoritesHandler` 必須在進行收藏檢查或狀態更新前正確初始化。
    private func initializeFavoritesHandler() {
        favoritesHandler = DrinkDetailFavoritesHandler()
    }
    
    /// 更新收藏按鈕的狀態。
    ///
    /// 此方法檢查當前飲品是否已被收藏，並根據後端返回的狀態更新按鈕圖示。
    /// - 注意：此操作依賴於 `favoritesHandler` 正確初始化，且需要異步從後端獲取狀態。
    private func updateFavoriteButtonState() {
        Task {
            guard let drinkId else { return }
            let isFavorite = await favoritesHandler?.isFavorite(drinkId: drinkId) ?? false
            navigationBarManager?.updateFavoriteButton(isFavorite: isFavorite)
        }
    }
    
    // MARK: - Data Loading
    
    /// 從 Firebase 加載飲品詳細資訊。
    /// - 確保分類與飲品 ID 已設置。
    private func loadDrinkDetail() {
        guard let categoryId, let subcategoryId, let drinkId else { return }
        print("[DrinkDetailViewController] 開始加載飲品詳細資料 - categoryId: \(categoryId), subcategoryId: \(subcategoryId), drinkId: \(drinkId)")
        HUDManager.shared.showLoading(text: "載入中...")
        
        Task {
            do {
                let drinkDetail = try await DrinkDetailManager().fetchDrinkDetail(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
                print("[DrinkDetailViewController] 加載成功 - 飲品名稱: \(drinkDetail.name)")
                handleDrinkDetailLoaded(drinkDetail)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - View Updates

    /// 加載飲品詳細資料後的處理邏輯。
    /// - Parameter drinkDetail: 已加載的飲品詳細資料模型。
    private func handleDrinkDetailLoaded(_ drinkDetail: DrinkDetailModel) {
        updateModel(with: drinkDetail)
        setupCollectionView()
        drinkDetailView.drinkDetailCollectionView.reloadData()
    }
    
    /// 更新模型資料。
    /// - Parameter drinkDetail: 飲品詳細資料模型。
    private func updateModel(with drinkDetail: DrinkDetailModel) {
        self.drinkDetailModel = drinkDetail
        guard let firstSize = drinkDetail.sortedSizes.first else {
            fatalError("DrinkDetailModel.sortedSizes 必須至少有一個值")
        }
        self.selectedSize = firstSize
    }
    
    /// 配置 `UICollectionView` 的資料來源與委派。
    private func setupCollectionView() {
        let collectionView = drinkDetailView.drinkDetailCollectionView
        handler = DrinkDetailHandler(delegate: self)
        collectionView.dataSource = handler
        collectionView.delegate = handler
    }
    
}

// MARK: - DrinkDetailHandlerDelegate

extension DrinkDetailViewController: DrinkDetailHandlerDelegate {
    
    // MARK: - Size Selection Methods

    /// 提供飲品詳細資料模型
    func getDrinkDetailModel() -> DrinkDetailModel {
        guard let drinkDetailModel else {
            fatalError("DrinkDetailModel 尚未加載")
        }
        return drinkDetailModel
    }
    
    /// 提供當前選中的飲品尺寸
    func getSelectedSize() -> String {
        return selectedSize
    }
    
    /// 使用者選擇了新尺寸時觸發
    ///
    /// ### 功能描述：
    /// - 更新 `selectedSize` 為新選中的尺寸。
    /// - 使用 `performBatchUpdates` 刷新所有尺寸按鈕的選中狀態，確保 UI 狀態一致。
    /// - 根據新尺寸刷新價格資訊。
    ///
    /// - Parameter newSize: 使用者選中的新尺寸。
    func didSelectSize(_ newSize: String) {
        updateSelectedSize(to: newSize)
        refreshSizeButtons(selectedSize: newSize)
        refreshPriceInfo()
    }

    /// 更新選中的尺寸狀態
    private func updateSelectedSize(to newSize: String) {
        selectedSize = newSize
        print("尺寸已更新：\(newSize)")
    }

    /// 刷新所有尺寸按鈕的選中狀態
    private func refreshSizeButtons(selectedSize: String) {
        drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
            guard let sizes = drinkDetailModel?.sortedSizes else { return }
            for (index, size) in sizes.enumerated() {
                let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
                guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
                cell.configure(with: size, isSelected: size == selectedSize)
            }
        }, completion: nil)
    }

    /// 刷新價格資訊
    private func refreshPriceInfo() {
        drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
    }

    // MARK: - Cart Management Methods

    /// 當點擊加入購物車按鈕時觸發
    ///
    /// ### 功能描述：
    /// - 使用當前選中的飲品詳細資料模型（`DrinkDetailModel`）與尺寸（`selectedSize`）構建基礎飲品模型（`Drink`）。
    /// - 通過 `OrderItemManager` 新增訂單項目，並傳遞飲品數據、尺寸與數量。
    ///
    /// ### 注意事項：
    /// - 確保 `drinkDetailModel` 與 `selectedSize` 已正確設置。
    /// - 使用基礎模型 `Drink`，保證數據結構一致性。
    ///
    /// - Parameter quantity: 飲品的數量
    func didTapAddToCart(quantity: Int) {
        guard let drinkDetailModel else { return } // 檢查 drinkDetailModel 是否為 nil
        print("加入購物車 - 飲品：\(drinkDetailModel.name)，尺寸：\(selectedSize)，數量：\(quantity)")
        
        /// 根據當前的 `DrinkDetailModel` 創建基礎模型 `Drink`
        let drink = Drink(
            id: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            description: drinkDetailModel.description,
            imageUrl: drinkDetailModel.imageUrl,
            sizes: drinkDetailModel.sizeDetails,
            prepTime: drinkDetailModel.prepTime
        )
        
        /// 添加訂單項目至 `OrderItemManager`
        OrderItemManager.shared.addOrderItem(
            drink: drink,
            size: selectedSize,
            quantity: quantity,
            categoryId: categoryId,
            subcategoryId: subcategoryId
        )
    }
    
}

// MARK: - DrinkDetailNavigationBarDelegate

extension DrinkDetailViewController: DrinkDetailNavigationBarDelegate {
    
    // MARK: - Share Methods

    /// 處理分享按鈕點擊事件
    ///
    /// 當使用者點擊分享按鈕時，觸發此方法。
    /// 使用 `DrinkDetailShareManager` 執行分享邏輯。
    func didTapShareButton() {
        guard let drinkDetailModel else { return }
        let shareManager = DrinkDetailShareManager()
        shareManager.share(drinkDetailModel: drinkDetailModel, selectedSize: selectedSize, from: self)
    }

    // MARK: - Favorite Methods

    /// 處理收藏按鈕點擊事件
    ///
    /// 當使用者點擊收藏按鈕時，觸發此方法。
    /// - 透過 `createFavoriteDrink` 建立 `FavoriteDrink` 資料模型。
    /// - 使用異步方法 `handleFavoriteToggle` 處理收藏狀態邏輯。
    func didTapFavoriteButton() {
        guard let categoryId, let subcategoryId, let drinkId, let drinkDetailModel else { return }
        
        let favoriteDrink = createFavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId, drinkDetailModel: drinkDetailModel)
        
        Task {
            await handleFavoriteToggle(for: favoriteDrink)
        }
    }
        
    /// 建立 `FavoriteDrink` 資料模型
    ///
    /// - Parameters:
    ///   - categoryId: 飲品的分類 ID
    ///   - subcategoryId: 飲品的次分類 ID
    ///   - drinkId: 飲品的唯一識別碼
    ///   - drinkDetailModel: 飲品的詳細資料模型
    /// - Returns: 一個新的 `FavoriteDrink` 實例
    private func createFavoriteDrink(categoryId: String, subcategoryId: String, drinkId: String, drinkDetailModel: DrinkDetailModel) -> FavoriteDrink {
        return FavoriteDrink(
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            drinkId: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            imageUrlString: drinkDetailModel.imageUrl.absoluteString,
            timestamp: Date()
        )
    }
    
    /// 處理收藏邏輯
    ///
    /// - Parameter favoriteDrink: 需要進行收藏狀態更新的飲品
    ///
    /// 功能描述：
    /// 1. 即時更新 UI，切換收藏按鈕圖示。
    /// 2. 使用 `favoritesHandler` 切換收藏狀態，確保後端同步更新。
    /// 3. 根據最終狀態再次更新按鈕圖示，確保與後端狀態一致。
    private func handleFavoriteToggle(for favoriteDrink: FavoriteDrink) async {
        let drinkId = favoriteDrink.drinkId
        
        // 即時更新 UI 狀態
        let currentState = await favoritesHandler?.isFavorite(drinkId: drinkId) ?? false
        navigationBarManager?.updateFavoriteButton(isFavorite: !currentState)
        
        // 更新收藏狀態
        let finalState = await favoritesHandler?.toggleFavorite(for: favoriteDrink) ?? currentState
        if currentState != finalState {
            navigationBarManager?.updateFavoriteButton(isFavorite: finalState)
        }
    }
     
}
*/



// MARK: - 處理 拆分handleFavoriteToggle
/*
import UIKit

/// `DrinkDetailViewController`
///
/// ### 功能描述
/// 此控制器負責顯示飲品的詳細資訊，並提供以下功能：
/// - 顯示飲品圖片、描述、尺寸選擇與價格資訊。
/// - 支援用戶選擇飲品尺寸並動態更新價格資訊。
/// - 加入購物車功能，將所選飲品及數量傳遞至購物車管理邏輯。
/// - 支援分享與收藏功能，並確保收藏按鈕狀態即時更新。
///
/// ### 設計目標
/// 1. 清晰架構：
///    - 分離業務邏輯、資料處理與視圖層次，提升可讀性與可維護性。
/// 2. 模組化設計：
///    - 使用 `DrinkDetailHandler` 處理 `UICollectionView` 的資料來源與交互邏輯。
///    - 使用 `DrinkDetailNavigationBarManager` 管理導航欄邏輯。
///    - 使用 `DrinkDetailHandlerDelegate` 與控制器進行通信。
///
/// ### 注意事項
/// - 確保 `drinkId` 在操作過程中非空，避免崩潰。
/// - 確保 `favoritesHandler` 與 `navigationBarManager` 正確初始化以處理收藏與導航相關功能。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 主視圖：包含顯示飲品詳細資訊的 UI 元件。
    private let drinkDetailView = DrinkDetailView()
    
    // MARK: - Handlers and Managers
    
    /// 處理 `UICollectionView` 的資料與使用者互動邏輯。
    private var handler: DrinkDetailHandler?
    
    /// 管理導航欄按鈕與標題的邏輯。
    private var navigationBarManager: DrinkDetailNavigationBarManager?
    
    /// 分享管理器：處理飲品分享的邏輯。
    private var shareManager: DrinkDetailShareManager?
    
    /// 收藏管理器：負責收藏功能的業務邏輯。
    private var favoritesHandler: DrinkDetailFavoritesHandler?
    
    // MARK: - Model and State
    
    /// 飲品詳細資料：從 Firebase 加載的資料模型。
    private var drinkDetailModel: DrinkDetailModel?
    
    /// 當前選擇的飲品尺寸，用於全局狀態管理。
    private var selectedSize: String = ""
    
    // MARK: - Identifier Properties
    
    /// 飲品的分類 ID
    var categoryId: String?
    
    /// 飲品的子分類 ID
    var subcategoryId: String?
    
    /// 飲品的唯一 ID
    var drinkId: String?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    /// 初始化控制器時加載資料並設置導航欄。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        initializeFavoritesHandler()
        loadDrinkDetail()
    }
    
    /// 當頁面即將顯示時更新收藏按鈕狀態。
    ///
    /// - 確保收藏按鈕的圖示能正確反映後端的收藏狀態。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButtonState()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄樣式與功能按鈕。
    ///
    /// 此方法使用 `DrinkDetailNavigationBarManager`：
    /// 1. 設置導航欄標題的顯示模式。
    /// 2. 添加功能按鈕，包括「分享」與「收藏」按鈕。
    /// 3. 設置當按鈕被點擊時的回調代理。
    private func configureNavigationBar() {
        navigationBarManager = DrinkDetailNavigationBarManager(navigationItem: navigationItem)
        navigationBarManager?.delegate = self
        navigationBarManager?.configureNavigationBarTitle(largeTitleDisplayMode: false)
        navigationBarManager?.addNavigationButtons()
    }
    
    /// 初始化收藏管理器。
    ///
    /// 此方法負責為 `favoritesHandler` 指派實例，用於處理與收藏相關的邏輯操作。
    /// - 注意：`favoritesHandler` 必須在進行收藏檢查或狀態更新前正確初始化。
    private func initializeFavoritesHandler() {
        favoritesHandler = DrinkDetailFavoritesHandler()
    }
    
    /// 更新收藏按鈕的狀態。
    ///
    /// 此方法檢查當前飲品是否已被收藏，並根據後端返回的狀態更新按鈕圖示。
    /// - 注意：此操作依賴於 `favoritesHandler` 正確初始化，且需要異步從後端獲取狀態。
    private func updateFavoriteButtonState() {
        Task {
            guard let drinkId else { return }
            let isFavorite = await favoritesHandler?.isFavorite(drinkId: drinkId) ?? false
            navigationBarManager?.updateFavoriteButton(isFavorite: isFavorite)
        }
    }
    
    // MARK: - Data Loading
    
    /// 從 Firebase 加載飲品詳細資訊。
    /// - 確保分類與飲品 ID 已設置。
    private func loadDrinkDetail() {
        guard let categoryId, let subcategoryId, let drinkId else { return }
        print("[DrinkDetailViewController] 開始加載飲品詳細資料 - categoryId: \(categoryId), subcategoryId: \(subcategoryId), drinkId: \(drinkId)")
        HUDManager.shared.showLoading(text: "載入中...")
        
        Task {
            do {
                let drinkDetail = try await DrinkDetailManager().fetchDrinkDetail(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
                print("[DrinkDetailViewController] 加載成功 - 飲品名稱: \(drinkDetail.name)")
                handleDrinkDetailLoaded(drinkDetail)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - View Updates

    /// 加載飲品詳細資料後的處理邏輯。
    /// - Parameter drinkDetail: 已加載的飲品詳細資料模型。
    private func handleDrinkDetailLoaded(_ drinkDetail: DrinkDetailModel) {
        updateModel(with: drinkDetail)
        setupCollectionView()
        drinkDetailView.drinkDetailCollectionView.reloadData()
    }
    
    /// 更新模型資料。
    /// - Parameter drinkDetail: 飲品詳細資料模型。
    private func updateModel(with drinkDetail: DrinkDetailModel) {
        self.drinkDetailModel = drinkDetail
        guard let firstSize = drinkDetail.sortedSizes.first else {
            fatalError("DrinkDetailModel.sortedSizes 必須至少有一個值")
        }
        self.selectedSize = firstSize
    }
    
    /// 配置 `UICollectionView` 的資料來源與委派。
    private func setupCollectionView() {
        let collectionView = drinkDetailView.drinkDetailCollectionView
        handler = DrinkDetailHandler(delegate: self)
        collectionView.dataSource = handler
        collectionView.delegate = handler
    }
    
}

// MARK: - DrinkDetailHandlerDelegate

extension DrinkDetailViewController: DrinkDetailHandlerDelegate {
    
    // MARK: - Size Selection Methods

    /// 提供飲品詳細資料模型
    func getDrinkDetailModel() -> DrinkDetailModel {
        guard let drinkDetailModel else {
            fatalError("DrinkDetailModel 尚未加載")
        }
        return drinkDetailModel
    }
    
    /// 提供當前選中的飲品尺寸
    func getSelectedSize() -> String {
        return selectedSize
    }
    
    /// 使用者選擇了新尺寸時觸發
    ///
    /// ### 功能描述：
    /// - 更新 `selectedSize` 為新選中的尺寸。
    /// - 使用 `performBatchUpdates` 刷新所有尺寸按鈕的選中狀態，確保 UI 狀態一致。
    /// - 根據新尺寸刷新價格資訊。
    ///
    /// - Parameter newSize: 使用者選中的新尺寸。
    func didSelectSize(_ newSize: String) {
        updateSelectedSize(to: newSize)
        refreshSizeButtons(selectedSize: newSize)
        refreshPriceInfo()
    }

    /// 更新選中的尺寸狀態
    private func updateSelectedSize(to newSize: String) {
        selectedSize = newSize
        print("尺寸已更新：\(newSize)")
    }

    /// 刷新所有尺寸按鈕的選中狀態
    private func refreshSizeButtons(selectedSize: String) {
        drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
            guard let sizes = drinkDetailModel?.sortedSizes else { return }
            for (index, size) in sizes.enumerated() {
                let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
                guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
                cell.configure(with: size, isSelected: size == selectedSize)
            }
        }, completion: nil)
    }

    /// 刷新價格資訊
    private func refreshPriceInfo() {
        drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
    }

    // MARK: - Cart Management Methods

    /// 當點擊加入購物車按鈕時觸發
    ///
    /// ### 功能描述：
    /// - 使用當前選中的飲品詳細資料模型（`DrinkDetailModel`）與尺寸（`selectedSize`）構建基礎飲品模型（`Drink`）。
    /// - 通過 `OrderItemManager` 新增訂單項目，並傳遞飲品數據、尺寸與數量。
    ///
    /// ### 注意事項：
    /// - 確保 `drinkDetailModel` 與 `selectedSize` 已正確設置。
    /// - 使用基礎模型 `Drink`，保證數據結構一致性。
    ///
    /// - Parameter quantity: 飲品的數量
    func didTapAddToCart(quantity: Int) {
        guard let drinkDetailModel else { return } // 檢查 drinkDetailModel 是否為 nil
        print("加入購物車 - 飲品：\(drinkDetailModel.name)，尺寸：\(selectedSize)，數量：\(quantity)")
        
        /// 根據當前的 `DrinkDetailModel` 創建基礎模型 `Drink`
        let drink = Drink(
            id: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            description: drinkDetailModel.description,
            imageUrl: drinkDetailModel.imageUrl,
            sizes: drinkDetailModel.sizeDetails,
            prepTime: drinkDetailModel.prepTime
        )
        
        /// 添加訂單項目至 `OrderItemManager`
        OrderItemManager.shared.addOrderItem(
            drink: drink,
            size: selectedSize,
            quantity: quantity,
            categoryId: categoryId,
            subcategoryId: subcategoryId
        )
    }
    
}

// MARK: - DrinkDetailNavigationBarDelegate

extension DrinkDetailViewController: DrinkDetailNavigationBarDelegate {
    
    // MARK: - Share Methods

    /// 處理分享按鈕點擊事件
    ///
    /// 當使用者點擊分享按鈕時，觸發此方法。
    /// 使用 `DrinkDetailShareManager` 執行分享邏輯。
    func didTapShareButton() {
        guard let drinkDetailModel else { return }
        let shareManager = DrinkDetailShareManager()
        shareManager.share(drinkDetailModel: drinkDetailModel, selectedSize: selectedSize, from: self)
    }

    // MARK: - Favorite Methods

    /// 處理收藏按鈕點擊事件
    ///
    /// ### 功能描述
    /// 當使用者點擊收藏按鈕時，觸發此方法。
    /// - 透過 `createFavoriteDrink` 建立 `FavoriteDrink` 資料模型。
    /// - 使用異步方法 `handleFavoriteToggle` 處理收藏狀態邏輯，完成即時 UI 更新與後端同步。
    func didTapFavoriteButton() {
        guard let categoryId, let subcategoryId, let drinkId, let drinkDetailModel else { return }
        
        let favoriteDrink = createFavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId, drinkDetailModel: drinkDetailModel)
        
        Task {
            await handleFavoriteToggle(for: favoriteDrink)
        }
    }
        
    /// 建立 `FavoriteDrink` 資料模型
    ///
    /// - Parameters:
    ///   - categoryId: 飲品的分類 ID
    ///   - subcategoryId: 飲品的次分類 ID
    ///   - drinkId: 飲品的唯一識別碼
    ///   - drinkDetailModel: 飲品的詳細資料模型
    /// - Returns: 一個新的 `FavoriteDrink` 實例
    private func createFavoriteDrink(categoryId: String, subcategoryId: String, drinkId: String, drinkDetailModel: DrinkDetailModel) -> FavoriteDrink {
        return FavoriteDrink(
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            drinkId: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            imageUrlString: drinkDetailModel.imageUrl.absoluteString,
            timestamp: Date()
        )
    }
    
    /// 處理收藏邏輯
    ///
    /// ### 功能描述
    /// 負責管理整個收藏按鈕的邏輯，包含以下步驟：
    /// 1. 即時更新 UI，減少用戶感知延遲。
    /// 2. 通過 `favoritesHandler` 與後端交互，更新收藏狀態。
    /// 3. 校正最終 UI 狀態，保證按鈕與後端狀態同步。
    ///
    /// - Parameter favoriteDrink: 需要進行收藏狀態更新的飲品
    private func handleFavoriteToggle(for favoriteDrink: FavoriteDrink) async {
        // Step 1: 即時更新 UI，避免用戶等待
        await toggleFavoriteButtonUIState()

        // Step 2: 處理後端交互，獲取最終狀態
        let finalState = await updateFavoriteStatus(for: favoriteDrink)
        
        // Step 3: 根據後端狀態再次校正 UI（如果需要）
        updateFavoriteButtonUIIfNeeded(finalState: finalState)
    }

    /// 即時切換收藏按鈕的 UI 狀態
    ///
    /// ### 功能描述
    /// 快速切換收藏按鈕圖示，提升用戶體驗，避免因後端交互導致按鈕切換延遲。
    private func toggleFavoriteButtonUIState() async {
        guard let drinkId else { return }
        let currentState = await favoritesHandler?.isFavorite(drinkId: drinkId) ?? false
        navigationBarManager?.updateFavoriteButton(isFavorite: !currentState)
    }

    /// 更新收藏狀態
    ///
    /// ### 功能描述
    /// 通過 `favoritesHandler` 與後端交互，切換飲品的收藏狀態。
    ///
    /// - Parameter favoriteDrink: 收藏飲品的數據模型
    /// - Returns: 更新後的收藏狀態（`true` 表示已收藏）
    private func updateFavoriteStatus(for favoriteDrink: FavoriteDrink) async -> Bool {
        return await favoritesHandler?.toggleFavorite(for: favoriteDrink) ?? false
    }

    /// 根據後端結果校正按鈕 UI 狀態
    ///
    /// ### 功能描述
    /// 最終確保收藏按鈕的圖示與後端狀態一致，防止因異常或網路延遲導致 UI 不同步。
    ///
    /// - Parameter finalState: 後端返回的最終收藏狀態
    private func updateFavoriteButtonUIIfNeeded(finalState: Bool) {
        navigationBarManager?.updateFavoriteButton(isFavorite: finalState)
    }
    
}
*/


// MARK: - (v)

import UIKit

/// `DrinkDetailViewController`
///
/// ### 功能描述
/// 此控制器負責顯示飲品的詳細資訊，並提供以下功能：
/// - 顯示飲品圖片、描述、尺寸選擇與價格資訊。
/// - 支援用戶選擇飲品尺寸並動態更新價格資訊。
/// - 加入購物車功能，將所選飲品及數量傳遞至購物車管理邏輯。
/// - 支援分享與收藏功能，並確保收藏按鈕狀態即時更新。
///
/// ### 設計目標
///  - 模組化設計：
///    - 使用 `DrinkDetailHandler` 處理 `UICollectionView` 的資料來源與交互邏輯。
///    - 使用 `DrinkDetailNavigationBarManager` 管理導航欄邏輯。
///    - 使用 `DrinkDetailShareManager` 處理分享邏輯。
///    - 使用 `DrinkDetailFavoriteStateCoordinator` 集中處理收藏邏輯與 UI 狀態更新，減少控制器負擔。
///    - 使用 `DrinkDetailHandlerDelegate` 與控制器進行通信。
///  - 確保 UI 與後端資料一致性：
///    - 透過 `DrinkDetailFavoriteStateCoordinator` 同步收藏按鈕狀態與後端資料。
///
/// ### 注意事項
/// - 確保 `drinkId` 在操作過程中非空，避免崩潰。
/// - 確保 `DrinkDetailFavoriteStateCoordinator` 與相關邏輯處理器正確初始化，避免狀態不同步的問題。
class DrinkDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 主視圖：包含顯示飲品詳細資訊的 UI 元件。
    private let drinkDetailView = DrinkDetailView()
    
    // MARK: - Handlers and Managers
    
    /// 處理 `UICollectionView` 的資料與使用者互動邏輯。
    private var handler: DrinkDetailHandler?
    
    /// 管理導航欄按鈕與標題的邏輯。
    private var navigationBarManager: DrinkDetailNavigationBarManager?
    
    /// 分享管理器：處理飲品分享的邏輯。
    private var shareManager: DrinkDetailShareManager?
    
    /// 收藏狀態協調器：集中管理收藏邏輯與 UI 更新。
    private var favoriteCoordinator: DrinkDetailFavoriteStateCoordinator?
    
    // MARK: - Model and State
    
    /// 飲品詳細資料：從 Firebase 加載的資料模型。
    private var drinkDetailModel: DrinkDetailModel?
    
    /// 當前選擇的飲品尺寸，用於全局狀態管理。
    private var selectedSize: String = ""
    
    // MARK: - Identifier Properties
    
    /// 飲品的分類 ID
    var categoryId: String?
    
    /// 飲品的子分類 ID
    var subcategoryId: String?
    
    /// 飲品的唯一 ID
    var drinkId: String?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = drinkDetailView
    }
    
    /// 初始化控制器時加載資料並設置導航欄。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        initializeFavoriteCoordinator()
        loadDrinkDetail()
    }
    
    /// 當頁面即將顯示時更新收藏按鈕狀態。
    ///
    /// - 確保收藏按鈕的圖示能正確反映後端的收藏狀態。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButtonState()
    }
    
    // MARK: - Setup Methods
    
    /// 配置導航欄樣式與功能按鈕。
    ///
    /// 此方法使用 `DrinkDetailNavigationBarManager`：
    /// 1. 設置導航欄標題的顯示模式。
    /// 2. 添加功能按鈕，包括「分享」與「收藏」按鈕。
    /// 3. 設置當按鈕被點擊時的回調代理。
    private func configureNavigationBar() {
        navigationBarManager = DrinkDetailNavigationBarManager(navigationItem: navigationItem)
        navigationBarManager?.delegate = self
        navigationBarManager?.configureNavigationBarTitle(largeTitleDisplayMode: false)
        navigationBarManager?.addNavigationButtons()
    }
    
    /// 初始化 `DrinkDetailFavoriteStateCoordinator` 並設置相關邏輯處理器。
    ///
    /// 透過協調器管理收藏邏輯，確保狀態更新與後端同步。
    private func initializeFavoriteCoordinator() {
        guard let navigationBarManager else { return }
        let favoritesHandler = DrinkDetailFavoritesHandler()
        favoriteCoordinator = DrinkDetailFavoriteStateCoordinator(navigationBarManager: navigationBarManager, favoritesHandler: favoritesHandler)
    }
    
    /// 更新收藏按鈕的狀態。
    ///
    /// 使用 `DrinkDetailFavoriteStateCoordinator` 刷新按鈕圖示，確保 UI 與後端資料一致。
    private func updateFavoriteButtonState() {
        favoriteCoordinator?.refreshFavoriteState(drinkId: drinkId)
    }
    
    // MARK: - Data Loading
    
    /// 從 Firebase 加載飲品詳細資訊。
    /// - 確保分類與飲品 ID 已設置。
    private func loadDrinkDetail() {
        guard let categoryId, let subcategoryId, let drinkId else { return }
        print("[DrinkDetailViewController] 開始加載飲品詳細資料 - categoryId: \(categoryId), subcategoryId: \(subcategoryId), drinkId: \(drinkId)")
        HUDManager.shared.showLoading(text: "載入中...")
        
        Task {
            do {
                let drinkDetail = try await DrinkDetailManager().fetchDrinkDetail(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId)
                print("[DrinkDetailViewController] 加載成功 - 飲品名稱: \(drinkDetail.name)")
                handleDrinkDetailLoaded(drinkDetail)
            } catch {
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - View Updates

    /// 加載飲品詳細資料後的處理邏輯。
    /// - Parameter drinkDetail: 已加載的飲品詳細資料模型。
    private func handleDrinkDetailLoaded(_ drinkDetail: DrinkDetailModel) {
        updateModel(with: drinkDetail)
        setupCollectionView()
        drinkDetailView.drinkDetailCollectionView.reloadData()
    }
    
    /// 更新模型資料。
    /// - Parameter drinkDetail: 飲品詳細資料模型。
    private func updateModel(with drinkDetail: DrinkDetailModel) {
        self.drinkDetailModel = drinkDetail
        guard let firstSize = drinkDetail.sortedSizes.first else {
            fatalError("DrinkDetailModel.sortedSizes 必須至少有一個值")
        }
        self.selectedSize = firstSize
    }
    
    /// 配置 `UICollectionView` 的資料來源與委派。
    private func setupCollectionView() {
        let collectionView = drinkDetailView.drinkDetailCollectionView
        handler = DrinkDetailHandler(delegate: self)
        collectionView.dataSource = handler
        collectionView.delegate = handler
    }
    
}

// MARK: - DrinkDetailHandlerDelegate

extension DrinkDetailViewController: DrinkDetailHandlerDelegate {
    
    // MARK: - Size Selection Methods

    /// 提供飲品詳細資料模型
    func getDrinkDetailModel() -> DrinkDetailModel {
        guard let drinkDetailModel else {
            fatalError("DrinkDetailModel 尚未加載")
        }
        return drinkDetailModel
    }
    
    /// 提供當前選中的飲品尺寸
    func getSelectedSize() -> String {
        return selectedSize
    }
    
    /// 使用者選擇了新尺寸時觸發
    ///
    /// ### 功能描述：
    /// - 更新 `selectedSize` 為新選中的尺寸。
    /// - 使用 `performBatchUpdates` 刷新所有尺寸按鈕的選中狀態，確保 UI 狀態一致。
    /// - 根據新尺寸刷新價格資訊。
    ///
    /// - Parameter newSize: 使用者選中的新尺寸。
    func didSelectSize(_ newSize: String) {
        updateSelectedSize(to: newSize)
        refreshSizeButtons(selectedSize: newSize)
        refreshPriceInfo()
    }

    /// 更新選中的尺寸狀態
    private func updateSelectedSize(to newSize: String) {
        selectedSize = newSize
        print("尺寸已更新：\(newSize)")
    }

    /// 刷新所有尺寸按鈕的選中狀態
    private func refreshSizeButtons(selectedSize: String) {
        drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
            guard let sizes = drinkDetailModel?.sortedSizes else { return }
            for (index, size) in sizes.enumerated() {
                let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
                guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
                cell.configure(with: size, isSelected: size == selectedSize)
            }
        }, completion: nil)
    }

    /// 刷新價格資訊
    private func refreshPriceInfo() {
        drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
    }

    // MARK: - Cart Management Methods

    /// 當點擊加入購物車按鈕時觸發
    ///
    /// ### 功能描述：
    /// - 使用當前選中的飲品詳細資料模型（`DrinkDetailModel`）與尺寸（`selectedSize`）構建基礎飲品模型（`Drink`）。
    /// - 通過 `OrderItemManager` 新增訂單項目，並傳遞飲品數據、尺寸與數量。
    ///
    /// ### 注意事項：
    /// - 確保 `drinkDetailModel` 與 `selectedSize` 已正確設置。
    /// - 使用基礎模型 `Drink`，保證數據結構一致性。
    ///
    /// - Parameter quantity: 飲品的數量
    func didTapAddToCart(quantity: Int) {
        guard let drinkDetailModel else { return } // 檢查 drinkDetailModel 是否為 nil
        print("加入購物車 - 飲品：\(drinkDetailModel.name)，尺寸：\(selectedSize)，數量：\(quantity)")
        
        /// 根據當前的 `DrinkDetailModel` 創建基礎模型 `Drink`
        let drink = Drink(
            id: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            description: drinkDetailModel.description,
            imageUrl: drinkDetailModel.imageUrl,
            sizes: drinkDetailModel.sizeDetails,
            prepTime: drinkDetailModel.prepTime
        )
        
        /// 添加訂單項目至 `OrderItemManager`
        OrderItemManager.shared.addOrderItem(
            drink: drink,
            size: selectedSize,
            quantity: quantity,
            categoryId: categoryId,
            subcategoryId: subcategoryId
        )
    }
    
}

// MARK: - DrinkDetailNavigationBarDelegate

extension DrinkDetailViewController: DrinkDetailNavigationBarDelegate {
    
    // MARK: - Share Methods

    /// 處理分享按鈕點擊事件
    ///
    /// 當使用者點擊分享按鈕時，觸發此方法。
    /// 使用 `DrinkDetailShareManager` 執行分享邏輯。
    func didTapShareButton() {
        guard let drinkDetailModel else { return }
        let shareManager = DrinkDetailShareManager()
        shareManager.share(drinkDetailModel: drinkDetailModel, selectedSize: selectedSize, from: self)
    }

    // MARK: - Favorite Methods

    /// 處理收藏按鈕點擊事件
    ///
    /// ### 功能描述
    /// 當使用者點擊收藏按鈕時，觸發此方法。
    /// - 透過 `createFavoriteDrink` 建立 `FavoriteDrink` 資料模型，將飲品資訊轉換為收藏所需的格式。
    /// - 使用 `DrinkDetailFavoriteStateCoordinator` 的 `handleFavoriteToggle` 方法集中處理收藏狀態邏輯，
    ///   包括即時 UI 切換與後端同步，減少控制器的邏輯負擔。
    ///
    /// ### 注意事項
    /// - 確保 `categoryId`、`subcategoryId`、`drinkId` 和 `drinkDetailModel` 均非空，否則不執行任何操作。
    /// - 此方法僅負責觸發收藏狀態的處理邏輯，具體的 UI 和後端同步由 `DrinkDetailFavoriteStateCoordinator` 完成。
    func didTapFavoriteButton() {
        guard let categoryId, let subcategoryId, let drinkId, let drinkDetailModel else { return }
        let favoriteDrink = createFavoriteDrink(categoryId: categoryId, subcategoryId: subcategoryId, drinkId: drinkId, drinkDetailModel: drinkDetailModel)
        favoriteCoordinator?.handleFavoriteToggle(for: favoriteDrink) 
    }
        
    /// 建立 `FavoriteDrink` 資料模型
    ///
    /// - Parameters:
    ///   - categoryId: 飲品的分類 ID
    ///   - subcategoryId: 飲品的次分類 ID
    ///   - drinkId: 飲品的唯一識別碼
    ///   - drinkDetailModel: 飲品的詳細資料模型
    /// - Returns: 一個新的 `FavoriteDrink` 實例
    private func createFavoriteDrink(categoryId: String, subcategoryId: String, drinkId: String, drinkDetailModel: DrinkDetailModel) -> FavoriteDrink {
        return FavoriteDrink(
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            drinkId: drinkId,
            name: drinkDetailModel.name,
            subName: drinkDetailModel.subName,
            imageUrlString: drinkDetailModel.imageUrl.absoluteString,
            timestamp: Date()
        )
    }
    
}


// MARK: - DrinkDetailViewController 筆記
/**
 
 ## DrinkDetailViewController 筆記
 
 `* What`
 
 - `DrinkDetailViewController` 是應用程式中負責展示飲品詳細資訊的核心控制器，包含以下功能：

 `1.資訊展示：`

 - 顯示飲品的圖片、描述、可選尺寸與價格資訊。
 
 `2.互動功能：`
 
 - 支援加入購物車、分享與收藏功能，並提供即時按鈕狀態更新。
 
 `3. 尺寸選擇刷新：`

 - 用戶選擇尺寸時，透過模組化方法處理尺寸狀態更新、按鈕選中狀態刷新與價格資訊更新。
 
 `3.架構模組化：`
 
 - `DrinkDetailHandler` 處理 UICollectionView 的資料來源與交互邏輯。
 - `DrinkDetailNavigationBarManager` 負責導航欄的按鈕配置與狀態更新。
 - `DrinkDetailFavoriteStateCoordinator` 集中管理收藏邏輯及其與 UI 的同步。
 
 ------------
 
 `* Why`
 
 `1.分離關注點：`

 - 清晰劃分業務邏輯、資料處理與視圖層次，避免控制器過於臃腫。
 - 確保收藏、分享、資料顯示等功能單一責任分明。
 
 `2.提升可讀性與可維護性：`

 - 各功能模組化，降低程式碼耦合，增強可測試性與擴展性。
 - 使用明確的協作方式（Delegate、Handler），使功能執行更直觀。
 
 `3.增強用戶體驗：`

 - 確保按鈕狀態即時更新，避免與用戶操作行為不一致。
 - 支援動態更新價格與資料載入進度提示，提升互動感與操作效率。
 
 ------------

 `* How`
 
 `1.依賴組件與初始化：`

 - 將主要邏輯劃分給以下組件：
    - `DrinkDetailHandler`：負責 UICollectionView 的數據與互動處理。
    - `DrinkDetailNavigationBarManager`：管理導航欄按鈕配置與狀態更新。
    - `DrinkDetailFavoriteStateCoordinator`：整合收藏邏輯與 UI 狀態更新，減少控制器內的耦合。

 - 於 viewDidLoad 初始化相關管理器並配置導航欄按鈕。
 
 `2.功能模組與核心方法：`

 - 資料載入：
    - 使用 `loadDrinkDetail()` 從 `Firebase` 獲取詳細資料。
    - 成功後調用 `handleDrinkDetailLoaded()` 更新模型與視圖。
 
 - 收藏邏輯：
    - 利用 `FavoriteStateCoordinator` 集中管理收藏狀態的檢查與切換， 使用非同步方法處理收藏邏輯，並即時同步按鈕狀態。
    - handleFavoriteToggle(for:)：處理收藏邏輯，包括 UI 即時更新與後端狀態同步。
    - refreshFavoriteState(drinkId:)：檢查後端收藏狀態並刷新按鈕。
 
 - 分享功能：
    - 使用 `didTapShareButton() `調用分享管理器 `DrinkDetailShareManager`，實現資料分享邏輯。
 
 - 加入購物車：
    - 使用 `didTapAddToCart(quantity:) `傳遞用戶選擇的飲品至購物車邏輯。
 
 `3. 尺寸選擇與刷新邏輯：`

 - `選擇尺寸邏輯：`

    - 使用 `didSelectSize(newSize:) `方法，處理用戶選擇尺寸後的狀態更新與視圖刷新。
    - `updateSelectedSize(to:)：`更新當前選中的尺寸。
    - `refreshSizeButtons(selectedSize:)：`刷新尺寸按鈕選中狀態，確保 UI 一致性。
    - `refreshPriceInfo()：`刷新價格資訊以反映最新選擇。
 
 - `刷新按鈕與價格：`

    - 使用 `performBatchUpdates` 提升效率，僅刷新受影響的按鈕，避免多餘的計算。
    - 重新載入 `priceInfo` 區段，確保價格資訊正確同步。
 
 
 `4.視圖邏輯與更新：`

 - UICollectionView 處理：
    - 使用 DrinkDetailHandler 負責數據源與用戶交互邏輯。
 
 - 擴展性設計：
    - 支援未來擴展其他功能（如更多按鈕或資料展示邏輯），不需大幅修改現有程式碼。
    - 利用模組化的組件設計，能輕鬆移植收藏與分享邏輯至其他頁面。
 
 ------------

 `* 實踐架構`
 
 ```
 [DrinkDetailViewController]
        |
        +-----------------------------+
        |                             |
 [DrinkDetailHandler]       [DrinkDetailNavigationBarManager]
                                     |
                          [FavoriteStateCoordinator]
                                     |
                    [DrinkDetailFavoritesHandler]
                                     |
                         [FavoriteManager] -> Firebase
 
 ```
 
 ------------

 `* 注意事項`
 
 `1.drinkId 必須非空：`

 - 確保執行邏輯的安全性，避免因識別碼缺失導致崩潰。
 
 `2.FavoriteStateCoordinator 的正確初始化：`

 - 確保收藏邏輯的正常運作。
 - 確保 FavoriteStateCoordinator 與 navigationBarManager 正確建立聯繫。
 
 `3.避免邏輯重複：`

 - FavoriteStateCoordinator 集中處理收藏邏輯，應避免直接操作 DrinkDetailFavoritesHandler。
 
 `4.按鈕狀態一致性：`

 - 收藏按鈕與後端資料必須保持同步，避免造成用戶誤解。
 
 `5.資料載入過程的提示：`

 - 處理網路延遲或加載錯誤，顯示進度提示與錯誤訊息。
 */



// MARK: - 頁面初始化與即時狀態更新的分工：loadDrinkDetail 與 updateFavoriteButtonState 的設計）
/**
 
 ## 頁面初始化與即時狀態更新的分工：loadDrinkDetail 與 updateFavoriteButtonState 的設計
 
 `* What`
 
 - `loadDrinkDetail` 負責從後端載入飲品詳細資料，並在首次進入 DrinkDetailViewController 時執行。
 - `updateFavoriteButtonState` 用於檢查當前飲品的收藏狀態，並在頁面每次顯示時更新收藏按鈕。
 
 ------------------

 `* Why`
 
 - 為什麼不將 loadDrinkDetail 放在 viewWillAppear？
 
 `1.避免重複資料請求：`

 - `viewWillAppear` 每次頁面顯示時都會被調用，而 `loadDrinkDetail` 通常只需要在進入頁面時執行一次即可。
 - 重複從後端請求飲品詳細資料會浪費資源並降低效能。
 
` 2.資料更新頻率不同：`

 - 飲品詳細資料在頁面首次載入時應完成，不需要在每次顯示時重新載入。
 - 收藏狀態可能會因為其他頁面的操作（例如 `FavoritesViewController` 的刪除或添加收藏）發生變化，因此需要在每次顯示時進行檢查。
 
 `3.用戶體驗考量：`

 - 在 `viewWillAppear` 中多次調用 loadDrinkDetail 可能導致用戶頻繁看到加載指示（HUD），影響體驗。
 - 收藏狀態更新是一個輕量操作，適合在每次顯示時執行。
 
 ------------------
 
 `* How`
 
 `1.loadDrinkDetail 放在 viewDidLoad：`

 - 飲品詳細資料通常不會頻繁更新，應在頁面初始化時載入。
 - 避免重複請求資料，提升效能。
 
 `2.updateFavoriteButtonState 放在 viewWillAppear：`

 - 收藏狀態與其他頁面（例如 `FavoritesViewController`）互動緊密，適合在每次顯示時更新。
 - 更新收藏按鈕是輕量操作，執行效率高，適合在 viewWillAppear 中執行。
 
 ------------------

 `* 總結`
 
 - `loadDrinkDetail`： 放在 viewDidLoad，僅在頁面初始化時執行，避免重複資料請求。
 - `updateFavoriteButtonState`： 放在 viewWillAppear，在頁面每次顯示時更新收藏狀態。
 
 */



// MARK: - 為什麼在 `didTapAddToCart` 中需要重新構建 `Drink` 基礎模型
/**
 
 ## 為什麼在 `didTapAddToCart` 中需要重新構建 `Drink` 基礎模型

 ---

 `* What`

 - `didTapAddToCart` 是 `DrinkDetailViewController` 中的一個方法，當用戶點擊「加入購物車」按鈕時被觸發，其主要功能包括：

 `1. 飲品數據轉換：`
 
 - 使用當前的 `DrinkDetailModel` 和 `selectedSize`，生成適合訂單使用的基礎模型 `Drink`。

 `2. 新增訂單項目：`
 
 - 通過 `OrderItemManager`，將飲品、尺寸與數量封裝成 `OrderItem`，並添加到當前訂單中。

 `3. 記錄行為：`
 
 - 輸出調試訊息，顯示添加的飲品名稱、尺寸和數量，便於追蹤操作。

 ---

 `* Why`

 `1. 飲品數據處理的必要性：`
 
 - `DrinkDetailModel` 是展示模型，專注於視圖層使用。轉換為基礎模型 `Drink` 後，能夠保證與 `OrderItem` 中飲品數據結構的一致性，減少模型層次的耦合。
 - 使用 `Drink` 作為基礎數據來源，讓訂單管理邏輯更清晰。

 `2. 分離責任：`
 
 - 新增訂單的邏輯完全委託給 `OrderItemManager`，符合單一責任原則，避免控制器直接處理訂單邏輯。

 `3. 提升使用者體驗：`

 - 便於在後續顯示訂單數據或同步訂單至後端數據庫，並為用戶提供清晰的操作反饋。

 ---

 `* How`

 `1. 數據檢查：`
 
    - 確保當前的 `drinkDetailModel` 與 `selectedSize` 已正確設置，避免出現空數據或崩潰。

 `2. 飲品模型轉換：`
 
 - 根據 `DrinkDetailModel` 的內容創建一個新的 `Drink` 對象，確保數據結構符合訂單的要求。

    ```swift
    let drink = Drink(
        id: drinkId,
        name: drinkDetailModel.name,
        subName: drinkDetailModel.subName,
        description: drinkDetailModel.description,
        imageUrl: drinkDetailModel.imageUrl,
        sizes: drinkDetailModel.sizeDetails,
        prepTime: drinkDetailModel.prepTime
    )
    ```

 `3. 添加訂單項目：`
        
 - 使用 `OrderItemManager` 將轉換後的飲品數據與尺寸、數量等封裝為 `OrderItem`，添加至當前訂單。

    ```swift
    OrderItemManager.shared.addOrderItem(
        drink: drink,
        size: selectedSize,
        quantity: quantity,
        categoryId: categoryId,
        subcategoryId: subcategoryId
    )
    ```

 ---

 `* 設計考量`

 `1. 模型轉換與結構一致性：`
 
    - 雖然 `DrinkDetailModel` 是專用於詳細頁的展示模型，但它與 `Drink` 的轉換過程簡單直觀，避免了重複代碼。
    - 如果未來需要更大的靈活性，可以考慮設置單獨的訂單飲品模型（如 `OrderDrink`）。

 `2. 邏輯抽象與模組化：`
 
    - 新增訂單邏輯由 `OrderItemManager` 處理，控制器不直接操作訂單項目，符合高內聚低耦合原則。

 `3. 後續優化空間：`
 
    - 如果邏輯複雜度增加，可以進一步抽出 `func createDrink()` 或 `func addOrderItem()` 以提升可讀性。
 */




// MARK: - 筆記：`selectedSize` 的型別設計與使用方式
/**
 ## 筆記：`selectedSize` 的型別設計與使用方式


 `* What：`
 
 - `selectedSize` 是 `DrinkDetailViewController` 中用來記錄使用者目前選擇的飲品尺寸，並影響 UI 顯示和業務邏輯的屬性。

 - 相關背景：
 
   - `DrinkDetailModel` 提供了一個 `sortedSizes` 屬性（已排序的飲品尺寸）。
   - `selectedSize` 是從 `sortedSizes` 初始化後的狀態，並用於操作相關功能，例如計算價格或加入購物車。

 -------------------------------

` * Why：selectedSize 應該是非可選型別還是可選型別？`
 
 - `非可選型別的適用情境：`
 
   - 如果可以 **100% 確保畫面初始化後，`selectedSize` 一定會有值**（例如，`sortedSizes` 一定有內容）。
   - 使用非可選型別可以減少程式碼中 `nil` 檢查的需求，讓程式邏輯更清晰。

 - `可選型別的適用情境：`
 
   - 如果在某些情況下，`selectedSize` 可能沒有值（例如資料尚未準備完成，或使用者尚未選擇尺寸），使用可選型別更能反映真實的資料狀態。

 - `目前情境：`
 
   - 模型層的 `sortedSizes` 保證一定至少有一個值，因此畫面載入後 `selectedSize` 理論上也應有值，適合設計為 **非可選型別**。
   - 然而，`selectedSize` 和 `sizeDetails[selectedSize]` 的關聯需要額外檢查，避免出現資料異常導致錯誤。

 -------------------------------

 `* How：`

 - 設計 `selectedSize` 為非可選型別
 
 1. 宣告為非可選型別，並在初始化時立即設置：
 
    ```swift
    private var selectedSize: String = ""
    ```

 2. 在 `updateModel` 時，從模型中安全初始化：
 
    ```swift
    private func updateModel(with drinkDetail: DrinkDetailModel) {
        self.drinkDetailModel = drinkDetail
        guard let firstSize = drinkDetail.sortedSizes.first else {
            fatalError("DrinkDetailModel.sortedSizes 必須至少有一個值")
        }
        self.selectedSize = firstSize
    }
    ```

 3. 使用時不需要檢查 `selectedSize` 是否為 `nil`，但仍需檢查 `sizeDetails` 是否有對應的值：
 
    ```swift
    case .priceInfo:
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DrinkPriceInfoCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DrinkPriceInfoCollectionViewCell else {
            fatalError("Cannot dequeue DrinkPriceInfoCollectionViewCell")
        }

        // 檢查 `sizeDetails` 是否包含對應尺寸的資料
        guard let sizeInfo = drinkDetailModel.sizeDetails[selectedSize] else {
            fatalError("DrinkDetailModel.sizeDetails 中缺少選中的尺寸資訊")
        }
        cell.configure(with: sizeInfo)
        return cell
    ```

 ------------------
 
 `- 使用可選型別的情境（不建議）`
 
 若決定使用可選型別，需在每次使用 `selectedSize` 時進行檢查：
 
 1. 宣告為可選型別：
 
    ```swift
    private var selectedSize: String?
    ```

 2. 在使用時檢查：
 
    ```swift
    guard let selectedSize = selectedSize else {
        fatalError("selectedSize 尚未設置")
    }
    guard let sizeInfo = drinkDetailModel.sizeDetails[selectedSize] else {
        fatalError("DrinkDetailModel.sizeDetails 中缺少選中的尺寸資訊")
    }
    cell.configure(with: sizeInfo)
    ```

 ---

 `* 結論`
 
 - 設計 `selectedSize` 為 **非可選型別**，並在初始化時確保有值（例如取 `sortedSizes.first!`）。
 - 仍需對 `sizeDetails[selectedSize]` 進行檢查，確保資料完整性，這是與 `selectedSize` 型別無關的安全措施。
 - 若使用可選型別，程式會需要額外的 `nil` 檢查，反而增加複雜性，通常不建議。

 ---

 `* 小結`
 
 - `非可選型別的好處：`
 
   - 減少程式邏輯中 `nil` 檢查，讓程式碼更簡潔。
   - 符合畫面初始化後 `selectedSize` 必有值的預期。

 - `關鍵提示：`
 
   - `selectedSize` 是 UI 狀態的一部分，應根據畫面需求選擇型別。
   - 模型層的資料保證（例如 `sortedSizes`）不一定能完全覆蓋 UI 層的狀態需求，仍需在程式中進行適當的檢查與保護。
 */




// MARK: - 關於「尺寸按鈕」在 `DrinkDetailHandler` 與 `DrinkDetailViewController` 的職責與處理邏輯
/**
 
 ## 關於「`尺寸按鈕`」在 `DrinkDetailHandler` 與 `DrinkDetailViewController` 的職責與處理邏輯


 * What：
 
 1. `DrinkDetailHandler`
 
    - 處理 `UICollectionView` 的資料來源與使用者互動邏輯。
    - 初始化每個尺寸按鈕的狀態（例如是否選中）。
    - 當使用者選擇尺寸時，透過 Delegate 通知 `DrinkDetailViewController`。

 2. `DrinkDetailViewController`
 
    - 處理使用者交互後的業務邏輯，例如更新 `selectedSize`。
    - 負責刷新所有尺寸按鈕的選中狀態，並更新相關的價格資訊。
    - 保證業務邏輯與 UI 同步。

 -------------------

 * Why：
 
 `1.職責清晰`
 
    - `DrinkDetailHandler` 專注於單個 Cell 的生成與基本配置，降低耦合度。
    - `DrinkDetailViewController` 負責業務邏輯的處理與全局 UI 的刷新，確保使用者操作後的整體狀態一致。

 `2. 易於維護`
 
    - 分開處理單個 Cell 的渲染邏輯與整體界面的更新，減少程式碼重複與責任模糊的風險。

 `3. 靈活性`
 
    - `DrinkDetailHandler` 提供一個基礎的 Cell 配置方式，能在不同情境下進行擴展。
    - `DrinkDetailViewController` 負責處理特定場景（如按鈕點擊後）的業務需求，增強控制能力。

 -------------------

` * How：`

 1. `DrinkDetailHandler` 的邏輯
 
    - 位置：`cellForItemAt` 方法中。
 
    - 實現：
 
      ```swift
      let size = drinkDetailModel.sortedSizes[indexPath.item]
      cell.configure(with: size, isSelected: size == selectedSize)
      cell.sizeSelected = { selectedSize in
          delegate.didSelectSize(selectedSize)
      }
      ```
 
    - 作用：
 
      - 初始化每個尺寸按鈕的外觀。
      - 設置點擊後的回調，將選中的尺寸傳遞給 Controller。

 -----
 
 2. `DrinkDetailViewController` 的邏輯
 
    - 位置：`didSelectSize(_ newSize: String)` 方法中。
 
    - 實現：
 
      ```swift
      drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
          guard let sizes = drinkDetailModel?.sortedSizes else { return }
          for (index, size) in sizes.enumerated() {
              let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
              guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
              cell.configure(with: size, isSelected: size == newSize)
          }
      }, completion: nil)

      // 更新價格資訊
      drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
      ```
 
    - 作用：
 
      - 遍歷並更新所有尺寸按鈕的選中狀態，確保視圖與使用者選擇保持同步。
      - 刷新價格資訊，提供最新的業務結果。

 -------------------

 * 總結：
 
 - `DrinkDetailHandler`：專注於處理單個 Cell 的生成與渲染。
 - `DrinkDetailViewController`：專注於業務邏輯處理，並控制整體 UI 的一致性。

 */


// MARK: - 調整尺寸按鈕刷新邏輯與職責架構的探討
/**
 
 ## 調整尺寸按鈕刷新邏輯與職責架構的探討

 ---

 `1. 調整是否更好？（將 `updateSelectedSize` 移至 `DrinkDetailViewController` 的 `performBatchUpdates`）`

 `* What`
 
 - 原先在 `DrinkDetailHandler` 使用手動方法 `updateSelectedSize`，逐一更新 Cell 的選中狀態。
 - 現在改為在 `DrinkDetailViewController` 的 `didSelectSize` 中，透過 `performBatchUpdates` 刷新所有尺寸按鈕。

 ------------------

 `* Why`
 
 - 職責更明確：將業務邏輯（更新選中尺寸狀態）集中在 `DrinkDetailViewController`，符合業務邏輯應由 Controller 處理的原則。
 
 - 效能與一致性：
 
   - `performBatchUpdates` 可一次性更新多個 Cell，避免多次執行單個 Cell 的刷新，對效能有幫助。
   - 集中處理 UI 更新，確保整體狀態一致，避免手動刷新可能帶來的漏刷或邏輯錯誤。
 
 - 易於擴展與維護：
 
   - Controller 作為唯一管理業務邏輯的層級，易於進行後續擴展與除錯。
   - 減少 `DrinkDetailHandler` 的責任，讓它專注於 Cell 的初始化和用戶操作的即時回傳。

 ------------------

 `* How`
 
 - 調整後的程式碼實現：
 
 ```swift
 func didSelectSize(_ newSize: String) {
     selectedSize = newSize
     print("尺寸已更新：\(newSize)")
     
     // 刷新所有尺寸按鈕
     drinkDetailView.drinkDetailCollectionView.performBatchUpdates({
         guard let sizes = drinkDetailModel?.sortedSizes else { return }
         for (index, size) in sizes.enumerated() {
             let indexPath = IndexPath(item: index, section: DrinkDetailSection.sizeSelection.rawValue)
             guard let cell = drinkDetailView.drinkDetailCollectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell else { continue }
             cell.configure(with: size, isSelected: size == newSize)
         }
     }, completion: nil)
     
     // 更新價格資訊
     drinkDetailView.drinkDetailCollectionView.reloadSections(IndexSet(integer: DrinkDetailSection.priceInfo.rawValue))
 }
 ```

 ------------------

 `2. 職責架構是否明確？是否符合 iOS 面向物件設計？`

 `* What`
 
 - `DrinkDetailHandler`
 
   - 專注於處理 `UICollectionView` 的資料來源與用戶交互。
   - 初始化 Cell 的狀態並回傳用戶操作。
 
 - `DrinkDetailViewController`
   - 管理業務邏輯與整體 UI 更新，包括選中尺寸狀態與價格資訊的刷新。

 ------------------

 
 `* Why`
 
 - `符合 MVC 架構原則：`
 
   - Model 管理資料結構（`DrinkDetailModel` 提供飲品與尺寸資訊）。
   - ViewController 處理業務邏輯（例如尺寸切換與價格更新）。
   - Handler 作為 `View` 的輔助，專注於單一 Cell 的生成與操作邏輯。
 
 - `低耦合性：`
   - Handler 和 Controller 之間透過 Delegate 進行通訊，維持清晰的責任分離，避免相互依賴。
 
 - `可測試性：`
   - 將業務邏輯集中在 Controller，有助於單元測試覆蓋關鍵功能。
   - Handler 專注於 UI 邏輯，可單獨測試 Cell 初始化的正確性。

 ------------------
 
`* How`
 
 - 目前的職責劃分：
 
 - `DrinkDetailHandler`
 
   ```swift
   let size = drinkDetailModel.sortedSizes[indexPath.item]
   cell.configure(with: size, isSelected: size == selectedSize)
   cell.sizeSelected = { selectedSize in
       delegate.didSelectSize(selectedSize)
   }
   ```
   - 單一責任：初始化尺寸 Cell 並設置選中狀態。
   - 使用 Delegate 將用戶操作回傳給 Controller。

 -----
 
 - `DrinkDetailViewController`
 
   ```swift
   func didSelectSize(_ newSize: String) {
       selectedSize = newSize
       // 刷新尺寸按鈕與價格資訊
   }
   ```
   - 集中管理業務邏輯，刷新 UI 狀態並處理業務需求（如價格更新）。

 ----------------------

 `* 結論`

 - `調整後的設計更符合 iOS 面向物件設計原則：`
 
   - 職責劃分清晰：`DrinkDetailHandler` 負責 Cell 初始化，`DrinkDetailViewController` 負責業務邏輯與全局 UI 更新。
   - 減少耦合度，增強可測試性與維護性。
 
 - `調整效果更優：`
 
   - 提升效能，集中處理尺寸按鈕的刷新。
   - 確保整體 UI 與邏輯的同步性，避免狀態不一致問題。
 */
