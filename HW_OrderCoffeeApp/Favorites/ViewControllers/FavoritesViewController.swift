//
//  FavoritesViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

/*
 透過 FavoritesViewController 練習 UICollectionViewDiffableDataSource，即使資料變動較少，藉此可以熟悉 DiffableDataSource 的運作方式。

 使用 UICollectionViewDiffableDataSource 可以有效地處理資料的新增和刪除。
 因為 DiffableDataSource 會自動處理資料變動的動畫效果。這種方法對於將來處理更複雜的資料結構或需要進行批量更新的情況也很有幫助。
 所以利用這個機會來熟悉 DiffableDataSource，即便需求相對簡單。這將提升對於 UICollectionView 和資料更新的掌握度。
 */

/*
 ## FavoritesViewController：

    & 功能：
        - 顯示使用者收藏的飲品列表，允許使用者查看收藏的飲品詳細資料。

    & 視圖設置：
        - 透過 FavoritesView 設置主要視圖，並使用 FavoritesHandler 處理 UICollectionView 的資料顯示和用戶互動。

    & 資料加載與更新流程：
 
        1.在 viewWillAppear 中重新加載資料：
            - 呼叫 validateAndLoadUserDetails() 方法，從 Firebase 獲取最新的使用者資料。
            - 確保每次視圖出現時，都能顯示最新的收藏清單。
            - 其中包含 favorites，這些資料包括了飲品的 categoryId、subcategoryId 和 drinkId，用來加載飲品的詳細資料。
 
        2. 更新本地 userDetails 並加載收藏飲品：
            - 在成功獲取最新的 userDetails 後，更新本地的 userDetails。
            - 使用新的收藏清單，透過 fetchDrinks(for:) 方法加載對應的飲品詳細資料。
 
        3. 更新 UI 顯示：
            - 透過 handler.updateSnapshot(with:) 方法，更新 UICollectionView 的資料快照，刷新收藏飲品的顯示。

    & 數據處理：
        - FavoritesHandler： 負責 UICollectionView 的 dataSource 和 delegate 方法，包括顯示收藏的飲品列表，並處理點擊事件。
 
    & 主要流程：
        - 資料接收： 從 getCurrentUserDetails 去取得最新資料。
        - 資料加載與顯示： 透過 fetchDrinks 方法，使用 categoryId、subcategoryId 和 drinkId 加載收藏飲品的詳細資料，並將結果顯示在 UICollectionView 中。
        - 數據快照更新： 當資料加載完成後，透過 handler.updateSnapshot 更新 UI。
 
    & 主要功能概述：
        - 資料來源： 從 getCurrentUserDetails 去取得最新資料。
        - 飲品資料查詢： 透過收藏清單中的 categoryId、subcategoryId 和 drinkId，直接從 MenuController 請求對應的飲品詳細資料，避免冗餘的資料遍歷。
        - 視圖與資料分離：FavoritesView 負責視圖的顯示，FavoritesHandler 負責資料處理，清楚劃分業務邏輯與 UI。
 
 ----------------------------------------------------------------------------------------------------
 
 ## FavoritesViewController 的資料更新問題與解決方案
 
    * 問題描述
        - FavoritesViewController 在視圖出現時沒有更新資料，導致當使用者在其他地方添加或移除收藏時，返回到 FavoritesViewController，顯示的收藏清單沒有即時更新。
 
    * 解決方案
        - 在 viewWillAppear 中重新加載資料： 利用 viewWillAppear，確保每次視圖將要出現時，都從 Firebase 獲取最新的使用者資料（userDetails），並更新收藏清單。
        - 使用通知機制確保資料同步（選擇性）： 在收藏狀態變化時，透過 NotificationCenter 發送通知，讓 FavoritesViewController 接收通知後更新資料。此方式可確保在視圖未出現時也能即時更新資料。
 
        (PS: 通知雖然也可以處理這部分，但是要處理跟設置的程式碼比較多一些。)


 ## FavoritesViewController 更新「我的最愛」的資料流程

    &. 為何使用 viewWillAppear 獲取最新資料
        
        * 資料即時性：
            - 每次視圖將要出現時，都從 Firebase 獲取最新的 userDetails，確保顯示的收藏清單是最新的。

        * 簡化資料傳遞：
            - 不需要依賴其他控制器傳遞資料，減少耦合度。

    &. 資料同步性的重要性
 
        * 避免資料不同步：
            - 如果依賴其他控制器傳遞的 userDetails，可能會因為資料未更新而顯示舊的收藏清單。

        * 多設備支援：
            - 從 Firebase 獲取資料，可以確保在多設備登入的情況下，資料始終保持同步。

    &. Firebase 作為權威資料來源
 
        * 資料可靠性：
            - Firebase 是主要的資料儲存來源，直接從 Firebase 獲取資料能確保資料的正確性。

        * 避免複雜的資料傳遞：
            - 透過讓每個需要資料的視圖控制器自行從 Firebase 獲取，簡化了資料流的設計。

    &. 總結
    
        - 調整了 navigateToFavorites 方法：不再在導航前獲取 userDetails，簡化了流程。
        - FavoritesViewController 自行獲取資料：在 viewWillAppear 中從 Firebase 獲取最新的 userDetails，確保資料一致性。
        - 責任劃分清晰：各個視圖控制器各司其職，UserProfileViewController 負責顯示使用者資訊和導航，FavoritesViewController 負責顯示收藏的飲品。
        - 資料流簡化：減少視圖控制器之間的資料傳遞，降低耦合度，提升維護性。
 
 ----------------------------------------------------------------------------------------------------

 ##. 為什麼之前的實作無法更新資料，導致 FavoritesViewController 無法即時更新（調整成push時發現的問題，）？
 
    - 將 present 調整成push時發現的問題，並發現從 UserProfileViewController 傳遞到 FavoritesViewController 的方式並不適合。
    - 因為當我在 FavoritesViewController 時，接著前往 DrinkDetailViewController 點擊我的最愛調整，並不會即時反映到 FavoritesViewController，需要返回到 UserProfileViewController 再重新進入到 FavoritesViewController 才會刷新。
 
    * userDetails 未更新：
        - 原先的 validateAndLoadUserDetails() 只是在使用已有的 userDetails。
        - 而這個 userDetails 是在初始化 FavoritesViewController 時從 UserProfileViewController 傳遞過來的，之後就沒有再更新。
 
    * 資料不同步：
        - 當在 DrinkDetailViewController 更新收藏後，FavoritesViewController 中的 userDetails 並不知道這個變化，導致資料未同步。
 
    * 總結：
        - 重新獲取最新的 userDetails： 在需要更新資料的地方，從 Firebase 獲取最新的使用者資料，確保資料一致性。
        - 使用 viewWillAppear 進行更新： viewWillAppear 方法在視圖即將出現時被呼叫，是更新資料的好時機。
        - 保持資料同步： 透過在適當的時機更新 userDetails，確保 App 能夠正確顯示最新的收藏資料。
 
 ----------------------------------------------------------------------------------------------------

 ## 採用 viewWillAppear 或是 通知機制 的選擇：
 
    1. 使用 viewWillAppear 方法的優點
        - viewWillAppear 專門用於在視圖即將顯示時進行更新。將資料加載放在這裡，能確保每次視圖出現時資料都是最新的。
        - 不需要額外的通知機制，程式碼更為簡潔，維護起來也更容易。
        - 使用通知需要註冊和移除觀察者，若管理不當可能導致記憶體洩漏或崩潰。
 
    2. 使用通知機制的考量
        - 如果 App 中有多個視圖控制器需要監聽「我的最愛」狀態的變化，使用通知可以在變化發生時即時更新各個視圖。
        - 通知可以在變化發生的當下觸發更新，而不需要等待視圖出現。
        - 需要管理通知的註冊和移除，增加了程式碼的複雜性。
 
 ----------------------------------------------------------------------------------------------------

 ## 將 資料加載(validateAndLoadUserDetails) 從 viewDidLoad 調整到 viewWillAppear：

    - 將資料加載的邏輯放在 viewWillAppear 中，因為這樣可以確保每次視圖即將顯示時，都會獲取最新的資料。
 
    * 為什麼移除 viewDidLoad 中的呼叫？
        - viewDidLoad 在視圖控制器的生命週期中只會被呼叫一次，當視圖第一次被載入到記憶體時。
        - 此時，如果在 viewDidLoad 中呼叫 validateAndLoadUserDetails()，那麼在視圖第一次出現時，會執行一次資料加載。
        - 但是，viewWillAppear 在每次視圖即將顯示時都會被呼叫，包括第一次。因此，當視圖第一次出現時，validateAndLoadUserDetails() 會在 viewWillAppear 中被呼叫一次。

    * 只在 viewWillAppear 中呼叫的優點
        - 確保每次視圖即將顯示時，都會更新資料。
        - 避免不必要的重複呼叫，減少資源消耗。
 
 ----------------------------------------------------------------------------------------------------

 ## FavoritesViewController 導航至 DrinkDetailViewController ：
 
    * 功能描述
        - 在 FavoritesViewController 中，使用者可以查看自己收藏的飲品清單。當使用者點擊某個飲品時，導航至該飲品的詳細頁面 DrinkDetailViewController，以查看飲品的詳細資訊。
 
 &. 架構想法：
 
    1. 責任劃分
 
        * FavoritesViewController
            - 職責： 管理整個收藏清單的視圖控制器，處理資料的加載和導航。
            - 導航邏輯： 負責處理點擊事件後的導航，將使用者導向 DrinkDetailViewController。

        * FavoritesHandler
            - 職責： 作為 UICollectionView 的資料源和委派，負責處理收藏清單的顯示和與使用者的互動（如點擊、長按等）。
            - 事件傳遞： 透過「閉包」將使用者的點擊事件傳遞給 FavoritesViewController。

 &. 設計考量

    1. 責任分離
        - 將導航邏輯保留在 FavoritesViewController 中，讓視圖控制器負責視圖的導航和資料傳遞。
 
    2. 鬆耦合
        - 透過閉包的方式，FavoritesHandler 不需要知道視圖控制器的存在，只需在適當的時候通知事件發生。
 
    3. 維護性與可讀性
        - 將導航邏輯集中在視圖控制器中，讓程式碼更易於維護和理解。

 &. 完整流程
 
    1.使用者點擊收藏的飲品
        - FavoritesHandler 的 collectionView(_:didSelectItemAt:) 方法被觸發。
 
    2. 透過閉包通知 FavoritesViewController
        - FavoritesHandler 調用 didSelectDrinkHandler 閉包，將選中的 Drink 傳遞出去。
 
    3. FavoritesViewController 處理導航
        - 接收到 Drink 後，FavoritesViewController 調用 navigateToDrinkDetail(with:) 方法。
 
    4. 取得必要的資料並導航
        - 從 userDetails.favorites 中找到對應的 FavoriteDrink，取得 categoryId、subcategoryId 和 drinkId。
        - 初始化 DrinkDetailViewController，設置必要的參數。
        - 使用 navigationController 進行推送導航。
 
 ----------------------------------------------------------------------------------------------------

 ## FavoritesViewController 的資料加載與通知機制的共同運用（重要）：
 
 &. 為何需要設置「資料加載」在 viewWillAppear 來處理「我的最愛」狀態變化？

    * 場景描述：
 
        - 當從 FavoritesViewController 點擊收藏的飲品，進入到 DrinkDetailViewController，並取消該飲品的收藏狀態時，返回到 FavoritesViewController 時，收藏清單中的變化需要即時反映出來。
 
    * 問題：
 
        1. 原本的實作依賴 viewWillAppear 中的 validateAndLoadUserDetails() 來重新加載使用者的收藏清單，來處理收藏狀態在 「Tab（Menu）中的 DrinkDetailViewController」 被變更（取消收藏），
           並不會即時反映在 FavoritesViewController 中，除非返回到 UserProfileViewController 再重新進入 FavoritesViewController。
 
        2. 後來我測試發現當場景為：
            「Tab (UserProfile)」從 FavoritesViewController 點擊最愛飲品進入到其 DrinkDetailViewController。
            而這時候 「Tab（Menu）也是處於 DrinkDetailViewController 層級」 時。
            當我在其中一個 DrinkDetailViewController 的我的最愛按鈕進行取消時，並不會影響到另一個 Tab 中的 DrinkDetailViewController 的最愛按鈕的UI更新。
            必須要先離開 DrinkDetailViewController 頁面再重新載入才能刷新按鈕UI。
 
    * 通知解決方案：
 
        - 添加通知機制，在「我的最愛」變化時，DrinkDetailViewController 透過 NotificationCenter 發送通知，FavoritesViewController 接收到通知後，即時更新收藏資料的我的最愛狀態。
 
 
 &. 為何還需要保留 validateAndLoadUserDetails() 在 viewWillAppear 中？

    * 資料初次加載：
        
        1.validateAndLoadUserDetails() 在 viewWillAppear 中的作用是確保每次進入 FavoritesViewController 時，都能從 Firebase 獲取最新的 userDetails，並加載最新的收藏清單。
          如果僅依賴通知，初次進入 FavoritesViewController 時將無法顯示任何收藏飲品。
 
        2. 資料即時性：
            - 通知機制只能處理收藏狀態的變化，但無法處理視圖初次顯示時的資料加載。viewWillAppear 確保了每次視圖即將顯示時，收藏清單都能與 Firebase 的資料保持同步。（重要）
 
 
&. 通知機制與 validateAndLoadUserDetails() 的搭配使用

    * 通知處理：
        - 在 FavoritesViewController 中，註冊通知來監聽「我的最愛」狀態變化，當通知觸發時，重新加載資料。
 
    * viewWillAppear 仍保留的原因：
        - viewWillAppear 中的 validateAndLoadUserDetails() 是用來處理視圖首次顯示以及每次返回 FavoritesViewController 時的資料加載，確保資料一致性。即便有通知機制，也無法取代視圖首次加載時所需的資料同步。
 

&. 通知機制與 viewWillAppear 的分工

    - viewWillAppear: 確保每次視圖即將顯示時，都能從 Firebase 獲取最新的 userDetails，更新收藏清單。
    - 通知機制: 確保「我的最愛」狀態變化時，無論是否返回 FavoritesViewController，都能即時更新資料。
 
 ----------------------------------------------------------------------------------------------------

 ## 添加飲品資料到「我的最愛」時，可以根據 subcategory 來設置 section 並做區分 & 依照添加的順序展示（ feature/favorites-page-V7 ）：
 
    1. 在設置完 FavoritesViewController 展示飲品後，就想說可以再加入飲品到我的最愛後，還可以顯示其 subcategory 加強分類。
    2. 後來發現設計的過程中，我將資料是以無序的方式儲存到 Dictionary 後，它會被動排序，後來採用有序的 tuple ，確保顯示順序與使用者收藏順序一致。
  
    * 處理 section header 顯示子類別的名稱
 
        - 在 fetchDrinks 中，為了顯示使用者收藏的飲品，使用 MenuController 的 loadSubcategoryById 來加載每個飲品所屬的子類別名稱，將其作為 section header 顯示在 UICollectionView 中。
        - 這個讓收藏的飲品根據其所屬子類別進行分類展示，使用者可以清楚地看到每個子類別下的飲品清單。
 
    * 按照收藏的順序顯示飲品
 
        - FavoritesViewController 會根據使用者的「收藏順序」顯示飲品。在 fetchDrinks 中，儲存並更新「有序的子類別」及其「對應的飲品」資料，使得畫面呈現時按照收藏順序來顯示。
        - 使用 appendDrinkToSubcategory 來檢查子類別是否已存在於資料中，若存在則將飲品添加到對應的子類別，否則新建一個新的子類別項目。
 
 ----------------------------------------------------------------------------------------------------

 ## HUD 設置筆記（ feature/favorites-page-V8 ）：
 
 &. 一開始的問題：
 
    * 在 FavoritesViewController 中一開始採用了全局 HUD (HUDManager.shared.showLoading) 顯示方式。
 
    * 問題發生於：
        - 當 Tab 切換到 UserProfile 的 FavoritesViewController，而同時在 Menu 的 DrinkDetailViewController 點擊我的最愛按鈕時，也會觸發 FavoritesViewController 的 HUD 顯示，這在操作反饋上很卡。
 
 &. 調整方式：
 
    * 後來改用局部 HUD (HUDManager.shared.showLoadingInView) 來處理，避免全局 HUD 在其他 Tab 或頁面上干擾用戶操作。
 
 &. HUD 設置：
 
    1.初步設置：
        - 先將 HUDManager.shared.showLoadingInView(self.view, text: "Loading Favorites...") 放置在 fetchDrinks 方法中，並在資料加載完成後通過 HUDManager.shared.dismiss() 隱藏 HUD。
        - dismiss() 正確隱藏了資料加載後的 HUD。
 
    2. HUD 顯示設置位置：
        - 設置於 fetchDrinks 中：由於 fetchDrinks 是資料加載的核心邏輯，因此在這裡設置 HUD 可以確保它只在加載資料時顯示，不會干擾其他操作。
 
    3. HUD 放在 fetchDrinks 還是 validateAndLoadUserDetails：
        - 將 HUD 放在 fetchDrinks 中更為合適，因為這是具體進行資料加載的地方，與 HUD 的顯示邏輯相關聯。
        - 放在 validateAndLoadUserDetails 需要更多的 DispatchQueue.main.async 來確保操作在主線程執行，會增加不必要的複雜性。
 
    4. 局部 HUD vs 全局 HUD：
        - 使用局部 HUD 可以避免 HUD 在其他 Tab 或頁面出現，並保持頁面操作的流暢性。
        - 測試結果顯示局部 HUD 表現良好，因為它僅在 FavoritesViewController 中顯示，不會干擾其他頁面。
 
 &. HUD 的頻繁出現是否會影響用戶體驗：
 
    * 實際測試下來當設置在 fetchDrinks 中會過於頻繁地去顯示到 HUD。因此我將其改到 viewWillAppear 中，並設置 全局HUD。
 
    1. HUD 放在 fetchDrinks 中：
        
        * 優點：
            - 每次加載資料（包括刪除或添加收藏飲品）時都會顯示 HUD，這能即時反映系統正在進行的操作，並向用戶提供反饋。
 
        * 缺點：
            - HUD 的過於頻繁出現，尤其是在快速操作（如刪除飲品）時，會顯得多餘並打斷用戶的操作流暢性。

    2. HUD 放在 viewWillAppear 中：

        * 優點：
            - HUD 只在進入 FavoritesViewController 並開始初始資料加載時顯示，避免在刪除或添加收藏時反覆出現 HUD，減少用戶干擾。

        * 缺點：
            - 如果用戶希望在每次操作後立即看到反饋，這種設置可能讓用戶感覺反饋不足。(但我這邊是直接更新UI)

    3. 想法：
 
        * 將 HUD 放在 viewWillAppear 中：
            - HUD 只在進入 FavoritesViewController 時顯示，表示正在加載資料，這樣可以避免刪除或添加我的最愛時頻繁出現 HUD，保持頁面操作的流暢性。

        * 後來測試幾次後又將 HUD 改到 viewDidLoad 中：
            - 因為在滑動 FavoritesViewController 回到 UserProfileViewController 時，因為 viewWillAppear 特性也都會出現 HUD。
            - 因此就改到 viewDidLoad，初次進入 FavoritesViewController 時顯示 HUD。
 */



// MARK: - 使用 push 調整 validateAndLoadUserDetails & 設置 viewWillAppear & 設置通知 & 處理 DrinkDetailViwController（async/await）
// 使用 NoFavoritesView，並且當在 FavoritesHandler 直接刪除掉最愛飲品項目之後，會立即更新顯示 NoFavoritesView
// 藉此練習 UICollectionViewDiffableDataSource（調整成三個參數、處理User頁面傳遞的部分、處理我的最愛視圖控制器刪除部分）
// 讓每個子類別的飲品都有各自的 header 進行區分，讓使用者可以根據子類別快速找到飲品。
// 收藏順序會被保留，且子類別與對應的飲品會按順序加入
// 設置HUD
// https://reurl.cc/6dGbxk
/*
import UIKit
import FirebaseAuth

/// 顯示使用者收藏的飲品清單
///
/// `FavoritesViewController` 會從 Firebase 獲取最新的 `userDetails`，並透過 `MenuController` 加載對應的飲品詳細資料，顯示在收藏清單中。
class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let favoritesView = FavoritesView()
    private var handler: FavoritesHandler!
    
    /// 使用者詳細資訊
    var userDetails: UserDetails?
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        view = favoritesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupCollectionView()
        setupHandlers()
        registerNotifications()
        HUDManager.shared.showLoading(text: "Loading Favorites...")     // 初次進入 FavoritesViewController 時顯示 HUD
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        HUDManager.shared.showLoading(text: "Loading Favorites...")   // 調整到 viewDidLoad
        // 每次視圖即將出現時，檢查並加載最新的使用者資料
        Task {
            await validateAndLoadUserDetails()
        }
    }
    
    // MARK: - deinit
    
    deinit {
        removeNotifications()
    }
    
    // MARK: - Setup Methods
    
    /// 設置 CollectionView 和其相關的處理器
    private func setupCollectionView() {
        handler = FavoritesHandler(collectionView: favoritesView.favoritesCollectionView)
        favoritesView.favoritesCollectionView.delegate = handler              // 設定 delegate
    }
    
    /// 設置處理器的事件處理
    private func setupHandlers() {
        // 設置閉包，當使用者點擊飲品時導航至 DrinkDetailViewController
        handler.didSelectDrinkHandler = { [weak self] drink in
            self?.navigateToDrinkDetail(with: drink)
        }
    }
    
    // MARK: - UserDetails Validation
    
    /// 檢查並從 Firebase 獲取最新的 `userDetails`，並根據結果進行資料加載或顯示錯誤
    private func validateAndLoadUserDetails() async {
        do {
            let updatedUserDetails = try await FirebaseController.shared.getCurrentUserDetails()
            self.userDetails = updatedUserDetails
            print("接收到的 userDetails: \(updatedUserDetails.favorites.map { $0.drinkId })")
            await fetchDrinks(for: updatedUserDetails.favorites)  // 加載收藏的飲品資料
        } catch {
            print("無法更新 userDetails: \(error)")
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Data Loading
    
    /// 根據使用者收藏的飲品資料，從 Firestore 中加載相應的`飲品`資料，並根據`子類別`進行分類後更新畫面，
    /// 保持與 `favoriteDrinks` 的順序一致。
    ///
    /// - Parameter favoriteDrinks: 使用者的收藏飲品資料，包含 categoryId、subcategoryId 和 drinkId。
    private func fetchDrinks(for favoriteDrinks: [FavoriteDrink]) async {
        /// 儲存有序的資料
        var orderedDrinksBySubcategory: [(String, [Drink])] = []
        
        /// 依照收藏順序處理每個飲品
        for favoriteDrink in favoriteDrinks {
            if let (subcategoryTitle, drink) = try? await loadSubcategoryAndDrink(for: favoriteDrink) {
                appendDrinkToSubcategory(subcategoryTitle: subcategoryTitle, drink: drink, in: &orderedDrinksBySubcategory)
                print("子類別：\(subcategoryTitle), 飲品：\(drink.name)")
            }
        }
        
        // 更新有序的飲品資料
        handler.updateSnapshot(with: orderedDrinksBySubcategory)
        print("已加載的飲品：\(orderedDrinksBySubcategory)")
        HUDManager.shared.dismiss()
    }
    
    /// 從 Firestore 加載指定的`subcategoryTitle`與對應的`drink`資料。
    ///
    /// - Parameter favoriteDrink: 使用者的收藏飲品資料，包含 categoryId、subcategoryId 和 drinkId。
    /// - Returns: 返回`subcategoryTitle`與對應的`drink`資料。
    private func loadSubcategoryAndDrink(for favoriteDrink: FavoriteDrink) async throws -> (String, Drink)? {
        
        let subcategory = try? await MenuController.shared.loadSubcategoryById(
            categoryId: favoriteDrink.categoryId,
            subcategoryId: favoriteDrink.subcategoryId
        )
        
        let drink = try? await MenuController.shared.loadDrinkById(
            categoryId: favoriteDrink.categoryId,
            subcategoryId: favoriteDrink.subcategoryId,
            drinkId: favoriteDrink.drinkId
        )
        
        if let subcategoryTitle = subcategory?.title, let drink = drink {
            return (subcategoryTitle, drink)
        }
        return nil
    }
    
    /// 將飲品加入到對應的子類別中。如果該子類別已存在，則添加到其對應的飲品列表；如果不存在，則新建子類別。
    ///
    /// - Parameters:
    ///   - subcategoryTitle: 子類別的標題
    ///   - drink: 要加入的飲品
    ///   - orderedDrinksBySubcategory: 儲存子類別及其飲品的有序陣列
    private func appendDrinkToSubcategory(subcategoryTitle: String, drink: Drink, in orderedDrinksBySubcategory: inout [(String, [Drink])]) {
        if let index = orderedDrinksBySubcategory.firstIndex(where: { $0.0 == subcategoryTitle }) {
            orderedDrinksBySubcategory[index].1.append(drink)
        } else {
            orderedDrinksBySubcategory.append((subcategoryTitle, [drink]))
        }
    }
    
    // MARK: - NavigationBar Title Setup
    
    /// 設置導航欄的標題
    private func setupNavigationTitle() {
        title = "My Favorite"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Navigation
    
    /// 導航至 `DrinkDetailViewController`，顯示選中飲品的詳細資訊
    ///
    /// - Parameter drink: 使用者選中的飲品物件 `Drink`
    private func navigateToDrinkDetail(with drink: Drink) {
        /// 從 `userDetails.favorites` 中找到與選中飲品匹配的 `FavoriteDrink`，以取得完整的識別資訊
        guard let favoriteDrink = userDetails?.favorites.first(where: { $0.drinkId == drink.id }) else {
            print("Error: 無法找到對應的 FavoriteDrink")
            return
        }
        
        let drinkDetailVC = DrinkDetailViewController()
        drinkDetailVC.categoryId = favoriteDrink.categoryId
        drinkDetailVC.subcategoryId = favoriteDrink.subcategoryId
        drinkDetailVC.drinkId = favoriteDrink.drinkId
        
        navigationController?.pushViewController(drinkDetailVC, animated: true)
    }
    
}

// MARK: - Notifications Handling

extension FavoritesViewController {
    
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
            await validateAndLoadUserDetails()
        }
    }
}
*/




















// MARK: - 暫時

// MARK: - `loadFavorites` 筆記
/**
 
 ## `loadFavorites` 筆記

 `* What`

 `loadFavorites` 是一個負責非同步加載使用者收藏清單的核心方法，執行以下功能：
 
 1. 從 `favoriteManager` 獲取收藏清單資料。
 2. 根據清單是否為空，動態更新背景提示視圖（顯示「沒有收藏」提示或隱藏背景）。
 3. 使用 `FavoritesHandler` 更新 `UICollectionView` 的內容，確保清單顯示最新資料。

 --------------------

 `* Why``

 `1. 非同步資料更新：`
 
    - 收藏清單是從遠端（ `Firebase`）獲取的，資料可能發生變動，因此需要動態更新顯示內容。
    - 確保使用者看到的清單是最新的收藏狀態。

 `2. 提升使用者體驗：`
 
    - 當收藏清單為空時，顯示「沒有收藏」的背景提示，避免讓使用者看到空白畫面。
    - 當有資料時，移除提示背景，並顯示收藏清單的內容。

 `3. 單一職責、易於維護：`
 
    - 使用 `NoFavoritesViewManager` 處理背景提示顯示邏輯，專注於背景的狀態管理。
    - 使用 `FavoritesHandler` 負責 `UICollectionView` 的資料管理和顯示邏輯，確保資料與 UI 分離。

 --------------------

 `* How `

 `1. 非同步獲取收藏清單：`
 
    ```swift
    let favorites = await favoriteManager.fetchFavorites() ?? []
    ```
 
    - 呼叫 `favoriteManager.fetchFavorites` 從後端獲取資料。
    - 使用 `?? []`，當獲取失敗時，將 `favorites` 指派為空陣列，避免程式崩潰。

 ----
 
` 2. 更新背景提示視圖：`
 
    ```swift
    noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
    ```
 
    - 判斷 `favorites.isEmpty`：
      - `true`：收藏清單為空，顯示「沒有收藏」提示，禁用滑動。
      - `false`：收藏清單有內容，移除背景提示，啟用滑動。

 ----

 `3. 更新 UICollectionView 的內容*`
 
    ```swift
    favoritesHandler?.updateSnapshot(with: favorites)
    ```
 
    - 呼叫 `FavoritesHandler` 的 `updateSnapshot` 方法：
      - 將 `favorites` 資料分組和排序。
      - 更新 `UICollectionView` 的快照，刷新顯示內容。

 --------------------

 `* 處理邏輯的完整步驟`

 `1. 初始化 favorites：`
 
    - 從遠端獲取資料，如果失敗則設為空陣列。

 `2. 更新背景提示視圖：`
 
    - 如果清單為空，顯示背景提示；否則移除提示背景。

 `3. 更新清單內容：`
 
    - 傳遞資料給 `FavoritesHandler`，更新 `UICollectionView` 的顯示內容。

 --------------------

 `* 處理邏輯的重點設計`

 `1. 容錯性：`
 
    - 使用 `?? []`，即使資料獲取失敗，也能穩定運行。

 `2. UI 與資料同步：`
 
    - 動態調整背景提示和清單內容，確保顯示與資料狀態一致。

 `3. 模組化設計：`
 
    - `NoFavoritesViewManager` 專注處理背景提示。
    - `FavoritesHandler` 專注管理清單資料和顯示。

 --------------------

 `* 範例程式碼整合`

 ```swift
 private func loadFavorites() {
     Task {
         // 1. 獲取收藏清單資料
         let favorites = await favoriteManager.fetchFavorites() ?? []
         
         // 2. 更新背景提示視圖
         noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
         
         // 3. 更新清單內容
         favoritesHandler?.updateSnapshot(with: favorites)
     }
 }
 ```
 */


// MARK: - FavoritesViewController 筆記
/**
 
 ## FavoritesViewController 筆記

 `* What `
 
 - `FavoritesViewController` 是用來管理「我的最愛」頁面的主要控制器，負責以下功能：
 
 1. 從 Firebase Firestore 加載使用者的收藏飲品清單。
 2. 將飲品收藏按分類呈現在 `UICollectionView` 中。
 3. 提供收藏的`刪除`與`點擊`進入飲品詳細頁的功能。
 4. 當沒有收藏飲品時，顯示「沒有收藏」的提示背景。

 ------------------

 `* Why`

` 1. 為什麼需要 FavoritesViewController？`
 
 - 集中處理「我的最愛」頁面的邏輯與展示，實現 單一責任原則，讓其他頁面能專注於自身的功能。
 - 提供收藏功能的完整體驗，包括：
   - 收藏飲品的顯示與管理。
   - 快速進入飲品詳細頁查看資訊。
   - 當沒有收藏飲品時，顯示友好的提示訊息。

 `2. 為什麼要設計「沒有收藏」提示？`
 
 - 當收藏清單為空時，避免使用者看到空白頁，提供更好的視覺回饋。
 - 讓使用者了解目前沒有資料可展示，並誘導他們探索飲品。

 `3. 為什麼要使用 UICollectionView 顯示收藏清單？`
 
 - `UICollectionView` 支持動態資料的分區（`Section`）展示，適合按照飲品分類顯示收藏。
 - 支援拖曳重排、刪除等互動操作，提升使用體驗。（`只處理刪除`）

 `4. 為什麼使用 categoryId、subcategoryId 和 drinkId？`
 
 - `categoryId` 和 `subcategoryId` 提供飲品的分類與次分類，幫助快速定位飲品在 Firestore 的位置。
 - `drinkId` 作為每個飲品的唯一標識，方便直接查詢與操作。

 ------------------

 `* How`

 `1. 結構與屬性設計`
 
 - `主要視圖（favoritesView）`：
 
   - 使用自定義的 `FavoritesView`，其中包含 `UICollectionView`，作為「我的最愛」頁面的主要 UI。

 - `資料處理器（favoritesHandler）`：
 
   - 使用 `FavoritesHandler` 管理 `UICollectionView` 的資料來源（`dataSource`）與互動邏輯（`delegate`）。
   - 負責處理飲品的顯示、分類，以及收藏的刪除與點選行為。

 - `提示視圖管理器（noFavoritesViewManager）`：
 
   - 使用 `NoFavoritesViewManager` 負責當收藏清單為空時顯示背景提示，否則隱藏提示。
   - 提升程式的模組化與可讀性，避免將提示視圖的邏輯直接寫在控制器內。

 - `資料管理器（favoriteManager）`：
 
   - `FavoriteManager` 負責與 Firestore 交互，從後端加載收藏飲品資料，並提供刪除收藏的功能。

 2`. 方法設計`
 
 - `收藏清單加載（loadFavorites）`
 
   - 使用 `Task` 從 Firestore 非同步獲取使用者的收藏飲品。
   - 如果清單為空，調用 `noFavoritesViewManager?.updateBackgroundView(isEmpty: true)` 顯示「沒有收藏」提示。
   - 否則更新 `UICollectionView` 的資料來源，並隱藏背景提示。

 - `導航至飲品詳細頁（navigateToDrinkDetail）`
 
   - 根據使用者點選的收藏飲品，傳遞 `categoryId`、`subcategoryId` 和 `drinkId` 到 `DrinkDetailViewController`，以加載對應的飲品詳細資訊。

 - `刪除收藏（didDeleteFavoriteDrink）`
   - 使用 `favoriteManager.removeFavorite` 從 Firestore 刪除指定飲品的收藏狀態，刪除完成後重新加載收藏清單。

 `3. UI 行為設計`
 
 - `當清單為空時：`
 
   - 顯示「沒有收藏」的背景提示，並禁用 `UICollectionView` 的滾動。

 - `當有收藏飲品時：`
 
   - 動態加載資料，並以分類為基礎呈現在 `UICollectionView` 中。

 ------------------

 `* 設計理念`

 `1. 單一責任原則`
 
 - `FavoritesViewController` 只專注於控制頁面邏輯，將細節邏輯（如資料處理與背景提示管理）分配給 `FavoritesHandler` 和 `NoFavoritesViewManager` 等模組。

 `2. 高內聚低耦合`
 
 - 將背景提示視圖邏輯封裝在 `NoFavoritesViewManager`，減少控制器的臃腫。
 - 使用 `FavoritesHandler` 專注於 `UICollectionView` 的資料管理，避免控制器直接處理資料更新細節。

 ` 3. 使用者友好設計`
 
 - 提供「沒有收藏」提示視圖，避免空白頁。
 - 點選收藏後導航至詳細頁，提升使用者探索飲品的體驗。

 ------------------

 `* 未來擴展（可能）`

 `1. 加入排序功能`
    - 支持按照收藏時間或飲品名稱排序清單。

 `2. 加入搜尋功能`
    - 支持在收藏飲品中進行快速搜尋。

 `3. 多樣化的分類展示`
    - 支持更多飲品分類層級，或自定義分類邏輯（如按熱銷排序）。
 */

// MARK: - 處理分類邏輯。(v)


import UIKit

/// 顯示使用者收藏的飲品清單。
///
/// `FavoritesViewController` 是負責管理「我的最愛」頁面的主控制器，
/// 包含以下功能：
/// - 顯示使用者的收藏飲品列表，並支持按分類呈現。
/// - 當無收藏飲品時，顯示提示背景視圖。
/// - 提供刪除收藏和點選查看飲品詳細資訊的功能。
/// - 從 Firestore 獲取收藏資料，並在 UI 上動態更新。
class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 資料管理器，用於從 Firestore 獲取使用者收藏清單。
    private let favoriteManager = FavoriteManager.shared
    
    /// 自定義的主要視圖，包含 `UICollectionView`。
    private let favoritesView = FavoritesView()
    
    /// 負責管理 `UICollectionView` 資料來源與互動邏輯的處理器。
    private var favoritesHandler: FavoritesHandler?
    
    /// 負責顯示或隱藏「沒有收藏」提示背景視圖的管理器。
    private var noFavoritesViewManager: NoFavoritesViewManager?
    
    /// 負責管理導航欄樣式與按鈕的管理器。
    private var navigationBarManager: FavoritesNavigationBarManager?
    
    
    // MARK: - Lifecycle Methods
    
    /// 加載自定義的主視圖。
    override func loadView() {
        view = favoritesView
    }
    
    /// 設置頁面相關功能，包括導航欄、收藏列表、及背景提示視圖。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupCollectionView()
        setupNoFavoritesViewManager()
        loadFavorites()
    }
    
    // MARK: - Setup Methods
    
    /// 設置導航欄樣式與標題。
    private func configureNavigationBar() {
        navigationBarManager = FavoritesNavigationBarManager(navigationItem: navigationItem, navigationController: navigationController)
        navigationBarManager?.configureNavigationBarTitle(title: "My Favorite", prefersLargeTitles: true)
    }
    
    /// 設置 `UICollectionView` 及其處理器。
    private func setupCollectionView() {
        favoritesHandler = FavoritesHandler(collectionView: favoritesView.favoritesCollectionView, favoritesHandlerDelegate: self)
        favoritesView.favoritesCollectionView.delegate = favoritesHandler
    }
    
    /// 初始化 `NoFavoritesViewManager`，負責管理「沒有收藏」提示背景。
    private func setupNoFavoritesViewManager() {
        noFavoritesViewManager = NoFavoritesViewManager(collectionView: favoritesView.favoritesCollectionView)
    }
    
    // MARK: - Data Loading
    
    /// 從 Firestore 加載使用者的收藏飲品，並更新 UI。
    ///
    /// 功能：
    /// 1. 當清單為空時，顯示「沒有收藏」提示背景。
    /// 2. 當有收藏飲品時，更新列表並移除提示背景。
    private func loadFavorites() {
        Task {
            let favorites = await favoriteManager.fetchFavorites() ?? []
            noFavoritesViewManager?.updateBackgroundView(isEmpty: favorites.isEmpty)
            favoritesHandler?.updateSnapshot(with: favorites)
        }
    }
    
    // MARK: - Navigator
    
    /// 導航至 `DrinkDetailViewController`，顯示飲品的詳細資訊。
    /// - Parameter favoriteDrink: 選中的收藏飲品。
    private func navigateToDrinkDetail(with favoriteDrink: FavoriteDrink) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let drinkDetailVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.drinkDetailViewController) as? DrinkDetailViewController else {
            print("Error: 無法找到 DrinkDetailViewController")
            return
        }
        
        drinkDetailVC.categoryId = favoriteDrink.categoryId
        drinkDetailVC.subcategoryId = favoriteDrink.subcategoryId
        drinkDetailVC.drinkId = favoriteDrink.drinkId
        
        navigationController?.pushViewController(drinkDetailVC, animated: true)
    }
    
}


// MARK: - FavoritesHandlerDelegate
extension FavoritesViewController: FavoritesHandlerDelegate {
    
    /// 當使用者刪除收藏時觸發。
    /// - Parameter favoriteDrink: 被刪除的收藏飲品。
    func didDeleteFavoriteDrink(_ favoriteDrink: FavoriteDrink) {
        Task {
            await favoriteManager.removeFavorite(for: favoriteDrink)
            loadFavorites()
        }
    }
    
    /// 當使用者選擇某個收藏飲品時觸發，導航至飲品詳細頁面。
    /// - Parameter favoriteDrink: 被選中的收藏飲品。
    func didSelectFavoriteDrink(_ favoriteDrink: FavoriteDrink) {
        navigateToDrinkDetail(with: favoriteDrink)
    }
    
}
