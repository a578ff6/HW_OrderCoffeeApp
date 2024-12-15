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
 
 --------------------------------------------------------------------------------------------------------------------------------

 ## 大標題屬性筆記（ https://reurl.cc/myXAeW ）
 
    * 如果是從 FavoritesViewController 進入到 DrinkDetailViewController：
 
        - 那麼 DrinkDetailViewController 就會呈現空白部分，原因是因為 FavoritesViewController 使用了 prefersLargeTitles，而 DrinkDetailViewController 預設繼承了這個屬性，
          導致顯示了與 FavoritesViewController 相同的導航欄樣式（包括大標題的空間）。
 
        - 當從 FavoritesViewController 導航到 DrinkDetailViewController 時，UINavigationController 會保持相同的導航欄配置，而不會自動移除或調整 prefersLargeTitles。因此，DrinkDetailViewController 會保留大標題的空白部分。
    
        - UINavigationController 中的 prefersLargeTitles 是屬於整個導航堆疊的屬性，因此當從一個設置了大標題的視圖控制器（ FavoritesViewController）導航到另一個視圖控制器（DrinkDetailViewController）時，除非在新視圖控制器中顯式地關閉這個屬性，否則它會繼續保留大標題的樣式。
 

 &. prefersLargeTitles & largeTitleDisplayMode 使用差異：
    
    1. prefersLargeTitles
 
            定義： prefersLargeTitles 是設置在 UINavigationBar 上的屬性，控制整個 UINavigationController 是否應該顯示大標題。
 
            作用範圍： 影響整個 UINavigationController 的所有視圖控制器，若其他視圖控制器沒有特別指定，它們會遵循此屬性。
    
            用法： 通常在 UINavigationController 中全局設置，以控制大標題的顯示。

    2. largeTitleDisplayMode

        定義： largeTitleDisplayMode 是設置在每個 UIViewController 的 navigationItem 上的屬性，控制當前視圖控制器是否應該顯示大標題。

        作用範圍： 只影響當前 UIViewController，不會影響其他視圖控制器。

        用法： 用於精細控制某個視圖控制器的標題顯示模式。
 
    3. 差異比較
 
        * 作用範圍：
            - prefersLargeTitles：全局設置，影響整個 UINavigationController。
            - largeTitleDisplayMode：細粒度設置，影響單一 UIViewController。
 
        * 優先順序：
            - 當 largeTitleDisplayMode 設置為 .always 或 .never 時，會覆蓋 prefersLargeTitles 的設置。
            - 如果設置為 .automatic，則依賴 prefersLargeTitles 決定顯示大標題與否。
 
    4. 使用場景
            - prefersLargeTitles： 當 App 中大部分視圖控制器需要統一使用大標題時，適合全局設定。
            - largeTitleDisplayMode： 當需要單獨調整某些視圖控制器的標題顯示，或需要在大標題與小標題之間做平滑過渡時，可使用這個屬性。

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
