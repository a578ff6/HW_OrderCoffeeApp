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
     - OrderViewController 負責設置 OrderModificationDelegate，當使用者點擊訂單中的飲品時，它將飲品的 drinkId、categoryId、subcategoryId 和編輯資料傳遞給 DrinkDetailViewController。並在必要時通過委託方法來接收飲品更新。
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

    * updateFavoriteButtonState：
        - 當飲品詳細資料加載完成後，才會檢查該飲品是否已加入「我的最愛」，並更新按鈕圖示和顏色。
        - 「我的最愛」的相關操作與資料加載是相對獨立的，保持分離是為了清晰區分資料加載與使用者互動的邏輯。
        - 當頁面載入或飲品資料加載完成時，會執行這段程式碼來顯示飲品是否已加入最愛。
 */

// MARK: - drinkID & asyc & 分享、我的最愛已經完善 & 當 HUD 顯示時，不需要手動控制按鈕的禁用與否，因為 HUD 已經會禁用所有的互動。& 震動反饋 & 另外設置Image處理Cell佈局。
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
        print("Received in DrinkDetailViewController: drinkId = \(String(describing: drinkId)), categoryId = \(String(describing: categoryId)), subcategoryId = \(String(describing: subcategoryId))")
        
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
        await updateFavoriteButtonState()    // 當資料載入完成後，更新按鈕的視覺狀態即可，無需再管理按鈕的互動性。
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
            OrderController.shared.updateOrderItem(withID: id, with: size, and: quantity)
            dismiss(animated: true, completion: nil)
        } else {
            print("正在添加到購物車: 飲品 - \(drink.name), 尺寸 - \(size), 數量 - \(quantity)")
            OrderController.shared.addOrderItem(drink: drink, size: size, quantity: quantity, categoryId: categoryId, subcategoryId: subcategoryId)
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
        await updateFavoriteButtonState()                                   // 當資料加載完成後更新我的最愛的視覺狀態
    }
    
    /// 更新 `我的最愛` 按鈕的視覺狀態
    private func updateFavoriteButtonState() async {
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
    
    /// 切換飲品的`「加入最愛」`狀態，並且添加震動反饋
    @objc private func toggleFavorite() {
        guard let drinkId = drinkId else { return }
        Task {
            await FavoriteManager.shared.toggleFavorite(for: drinkId, in: self)
            ButtonEffectManager.shared.applyHapticFeedback()
        }
    }
    
}






// MARK: - 調整 DispatchQueue.main.async & 震動反饋（暫時沒必要）
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
        print("Received in DrinkDetailViewController: drinkId = \(String(describing: drinkId)), categoryId = \(String(describing: categoryId)), subcategoryId = \(String(describing: subcategoryId))")
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
        setupHandler(with: drink)           // 先設置處理邏輯
        updateUI(with: drink)               // 然後更新 UI，避免重複刷新
        await updateFavoriteButtonState()  // 最後更新我的最愛按鈕（ 當資料載入完成後，更新按鈕的視覺狀態即可，無需再管理按鈕的互動性。）
    }
    
    /// 更新排序的尺寸
    private func updateSortedSizes(with drink: Drink) {
        sortedSizes = drink.sizes.keys.sorted()
    }
    
    /// 更新 UI 元素以顯示飲品詳細資料
    private func updateUI(with drink: Drink) {
        DispatchQueue.main.async {
            self.drinkDetailView.collectionView.reloadData()
            self.drinkDetailView.collectionView.layoutIfNeeded() // 強制佈局更新
        }
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
            OrderController.shared.updateOrderItem(withID: id, with: size, and: quantity)
            dismiss(animated: true, completion: nil)
        } else {
            print("正在添加到購物車: 飲品 - \(drink.name), 尺寸 - \(size), 數量 - \(quantity)")
            OrderController.shared.addOrderItem(drink: drink, size: size, quantity: quantity, categoryId: categoryId, subcategoryId: subcategoryId)
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
        DispatchQueue.main.async {
            self.drinkDetailView.collectionView.reloadItems(at: [priceInfoIndexPath])
        }
    }

    /// 刷新所有尺寸按鈕的狀態
    private func refreshSelectedSizeButtons() {
        DispatchQueue.main.async {
            self.drinkDetailView.collectionView.performBatchUpdates({
                for (index, size) in self.sortedSizes.enumerated() {
                    let indexPath = IndexPath(item: index, section: Section.sizeSelection.rawValue)
                    if let cell = self.drinkDetailView.collectionView.cellForItem(at: indexPath) as? DrinkSizeSelectionCollectionViewCell {
                        cell.isSelectedSize = (size == self.selectedSize)
                    }
                }
            }, completion: nil)
        }
    }
    
    // MARK: - Navigation Bar Items Setup
    
    /// 設置導航欄按鈕（`分享` 和 `我的最愛`）
    private func setupNavigationBarItems() async {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareDrinkInfo))
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        self.navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
        await updateFavoriteButtonState()                                   // 當資料加載完成後更新我的最愛的視覺狀態
    }
    
    /// 更新 `我的最愛` 按鈕的視覺狀態
    private func updateFavoriteButtonState() async {
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
    
    /// 切換飲品的`「加入最愛」`狀態，並且添加震動反饋
    @objc private func toggleFavorite() {
        guard let drinkId = drinkId else { return }
        Task {
            await FavoriteManager.shared.toggleFavorite(for: drinkId, in: self)
            ButtonEffectManager.shared.applyHapticFeedback()
        }
    }
    
}
*/




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
