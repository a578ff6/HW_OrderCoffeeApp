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
 
 */


// MARK: - 使用 push 調整 validateAndLoadUserDetails & 設置 viewWillAppear & 設置通知 & 處理 DrinkDetailViwController
// 使用 NoFavoritesView，並且當在 FavoritesHandler 直接刪除掉最愛飲品項目之後，會立即更新顯示 NoFavoritesView
// 藉此練習 UICollectionViewDiffableDataSource（調整成三個參數、處理User頁面傳遞的部分、處理我的最愛視圖控制器刪除部分）
// https://reurl.cc/6dGbxk

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次視圖即將出現時，檢查並加載最新的使用者資料
        validateAndLoadUserDetails()
    }
    
    // MARK: - deinit
    
    deinit {
        removeNotifications()
    }
     
    // MARK: - Setup Methods

    /// 設置 CollectionView 和其相關的處理器
    private func setupCollectionView() {
        handler = FavoritesHandler(collectionView: favoritesView.collectionView)
        favoritesView.collectionView.delegate = handler              // 設定 delegate
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
    private func validateAndLoadUserDetails() {
        FirebaseController.shared.getCurrentUserDetails { [weak self] result in
            switch result {
            case .success(let updatedUserDetails):
                self?.userDetails = updatedUserDetails
                print("接收到的userDetails: \(updatedUserDetails.favorites.map { $0.drinkId })")
                self?.fetchDrinks(for: updatedUserDetails.favorites)                 // 加載收藏的飲品資料
            case .failure(let error):
                print("無法更新 userDetails: \(error)")
            }
        }
    }

    // MARK: - Data Loading
    
    /// 根據使用者的收藏資料（`FavoriteDrink`）從 Firebase 加載飲品的詳細資料
    ///
    /// 會透過 `categoryId`、`subcategoryId` 和 `drinkId` 加載每個收藏的飲品資訊，並更新到 `UICollectionView`。
    private func fetchDrinks(for favoriteDrinks: [FavoriteDrink]) {
        Task {
            var drinks: [Drink] = []
            
            /// 依照每個收藏飲品的 ID 加載飲品詳細資料（categoryId, subcategoryId 和 drinkId 加載飲品詳細資料）
            for favoriteDrink in favoriteDrinks {
                print("正在加載飲品詳細資料：\(favoriteDrink.drinkId)")
                if let drink = try? await MenuController.shared.loadDrinkById(
                    categoryId: favoriteDrink.categoryId,
                    subcategoryId: favoriteDrink.subcategoryId,
                    drinkId: favoriteDrink.drinkId
                ) {
                    drinks.append(drink)
                }
            }
            print("已加載的飲品：\(drinks.map { $0.name })")
            // 更新 UICollectionView 的數據快照，顯示收藏的飲品清單
            handler.updateSnapshot(with: drinks)
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
        validateAndLoadUserDetails()
    }
}
