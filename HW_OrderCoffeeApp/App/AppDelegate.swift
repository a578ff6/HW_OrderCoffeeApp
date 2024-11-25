//
//  AppDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

// MARK: - 重點筆記：在 AppDelegate 使用 IQKeyboardManager

/*
 ## 重點筆記：在 AppDelegate 使用 IQKeyboardManager
 
 1. 集中管理鍵盤行為
    - 將 IQKeyboardManager 配置放在 AppDelegate 中，意味著它會在 App 啟動時被統一配置。
    - 這使得鍵盤管理成為全局設置， App 中所有視圖控制器的鍵盤行為會自動被管理，省去了每個控制器手動設置的麻煩。
 
 2. 自動處理鍵盤顯示和隱藏
    - 使用 IQKeyboardManager 可以自動處理鍵盤的彈出和收起，並相應地調整屏幕中輸入框的位置。這意味著在應用中使用任何輸入框時，都不需要再為每個視圖控制器設計單獨的鍵盤監聽和滾動邏輯。
    - 省略手動設置：不用再寫 setupKeyboardObservers() 來添加鍵盤顯示和隱藏的通知，或者 setUpHideKeyboardOntap() 來實現點擊空白處收起鍵盤的功能。

 3. 自動處理視圖滾動和輸入框定位
    - IQKeyboardManager 會根據鍵盤的位置，自動調整當前活動輸入框的位置，確保它們始終保持可見。這使得開發者不需要手動編寫代碼來控制滾動視圖和輸入框的位置。
    - 手動處理滾動行為可能會因鍵盤高度、視圖大小等因素變得複雜，而 IQKeyboardManager 提供了一個一致且可靠的滾動解決方案。
 
 4. 支持點擊空白區域收起鍵盤
    - 通過設置 IQKeyboardManager.shared.resignOnTouchOutside = true，可以輕鬆實現點擊空白區域收起鍵盤的功能，避免手動為每個視圖添加手勢識別器。
 
 5. 省略手動設置
    - 也因為這樣原本設計的 setUpHideKeyboardOntap()、setupKeyboardObservers()可以廢除掉。
 */


// MARK: - 筆記：在 AppDelegate 中使用 preloadDrinksData 進行預加載的考量

/**
 ## 筆記：在 AppDelegate 中使用 preloadDrinksData 進行預加載的考量
 
 `1. 為什麼在 AppDelegate 中進行預加載？`
 
 `* 提升使用者體驗：`
    - 將資料預加載的操作移到 AppDelegate，可以確保應用啟動後便立即進行飲品資料的加載，這樣當用戶進入搜尋頁面時，資料已經在本地快取中，搜尋結果可以即時呈現，避免首次進入搜尋時的等待時間，進而提升使用者體驗。
 
 `* 資料在首次使用前已準備好：`
    - 使用者一旦進入搜尋頁面，如果資料已經預先載入，可以立即開始操作，這樣用戶會感覺應用反應更加迅速。
 
 `* 減少首次資料加載的延遲：`
    - 如果等到用戶首次進入搜尋頁面才進行資料加載，可能會導致因網絡請求而造成的延遲，進而影響使用者感知。通過應用啟動時進行預加載，可以提前完成這一過程。
 
 `2. preloadDrinksData() 的作用與設計`
 
 `* 方法的作用：`
    - `preloadDrinksData() `方法是在 App 啟動時自動從 `Firebase Firestore` 預加載所有飲品資料並將其存入本地快取 (`cachedDrinks`)。
 
 `* 方法的使用場景：`
    - 此方法被放置於 `didFinishLaunchingWithOptions` 內，意味著在應用啟動的最初階段，資料就會被加載並準備好使用，這樣後續的搜尋過程中可以避免向 Firebase 的頻繁請求。
 
 `3. 優點與考量`
 
 `* 優點：`

 - `減少查詢延遲`：資料一旦被預加載，後續的搜尋操作只需要訪問本地快取，速度快且無需進行遠程查詢。
 - `降低後端負擔`：因為資料被本地快取了，所以可以減少對 Firebase 的多次查詢，從而降低請求成本並減少對網絡的依賴。
 - `共享快取`：通過設置 SearchManager 為單例 (static let shared)，可以確保快取在整個應用中被重複使用，避免多次重複加載資料，提升效能。
 
 `* 可能的缺點：`

 - `增加啟動時間`：在應用啟動時進行資料加載可能會稍微增加啟動時間，特別是在網絡狀況不理想的情況下，這會導致用戶感知到應用啟動變慢。
 - `內存佔用`：因為所有飲品資料被存儲在本地快取，當資料量增大時，這可能會佔用較多內存資源。
 
 `4. 如何在啟動時更好地實現資料加載？`
 
 `* 顯示 Loading Indicator / Launch Screen：`

 - 當應用啟動進行資料加載時，可以考慮在啟動過程中顯示 `加載指示器` 或是 `啟動畫面`，這樣用戶可以知道應用正在準備資料，避免誤以為應用卡住。
 
 `* 異步處理並非阻塞主執行緒：`

 - 使用 Swift 的 async/await 進行資料加載，以非同步方式處理資料請求，避免阻塞主執行緒，確保應用的啟動流程流暢。
 
 `* 資料有效期設置：`

 - 利用 `cacheValidityDuration` 設定快取的有效期（目前設定為 1 小時），確保資料不會過時，也減少 Firebase 的重複請求次數。
 - 在應用啟動時檢查上次資料加載時間，如果快取仍在有效期內，就無需重新加載資料。
 
 `5. 其他考量與改進點`
 
 `* 用戶通知：`
    - 如果資料加載失敗，應考慮通知用戶（例如顯示錯誤提示），讓用戶知道目前無法使用搜尋功能，這樣可以避免用戶在搜尋時遇到無結果的情況而感到困惑。
 
 `6. 使用 preloadDrinksData() 的最佳場景`
 
 `* 資料量有限：`
    - 當飲品資料筆數相對較少（如目前約 70 筆），在應用啟動時進行預加載是一個合理的選擇，因為加載時間可控且佔用內存不大。
 
 *` 頻繁訪問的資料：`
    - 如果用戶預期會頻繁進行搜尋操作，將資料預先加載好可以有效提升整體使用體驗。
 */


// MARK: - AppDelegate 中 preloadDrinksData 的處理方式
/**
 
 ## AppDelegate 中 preloadDrinksData 的處理方式
 
 - 主要是考量到啟動 App 預載資料如果失敗的話，該在哪邊去呈現 Alert 並且重新加載資料。
 
 `1. 設計考量`

 - 在 AppDelegate 中進行` preloadDrinksData() `的非同步資料加載，主要是為了在應用啟動時就提前加載飲品資料，提升用戶在進入特定頁面（如 SearchViewController）時的體驗。
 - 這是一個非同步操作，無論成功或失敗，都不會阻止應用的正常啟動。

 `2. 非同步操作的好處`

 - `不阻塞應用啟動`：
    - 在 `didFinishLaunchingWithOptions` 方法中進行非同步操作，即使加載失敗，應用仍然會返回 true，確保正常啟動。
    - 這意味著即使` preloadDrinksData()` 失敗，應用依然能夠繼續運行，用戶可以使用其他功能，而不受影響。

 - `靈活的錯誤處理`：
    - 由於 `preloadDrinksData() `失敗並不會影響應用啟動，因此可以選擇在加載失敗時打印錯誤信息，而不是阻止應用啟動。
    - 這樣用戶仍能使用應用的其他部分，避免因為非關鍵功能的失敗而無法啟動應用。

 `3. 處理資料不可用的情況`

 - 為了處理資料加載失敗的情況，可以在需要使用這些資料的具體頁面（如 `SearchViewController`）中加入重試機制或錯誤提示，例如：

    - `重新加載的選項`：當用戶進入 `SearchViewController` 並且資料不可用時，可以彈出提示用戶重新嘗試加載，這樣更加符合用戶行為的上下文。

    - `避免阻塞應用的正常使用`：即使初始化資料失敗，其他功能（如登入或靜態頁面）依然可用，這樣設計能夠提升用戶體驗。

 `4. 避免阻止應用啟動`

 - 在 `didFinishLaunchingWithOptions` 中，不建議在` preloadDrinksData() `失敗時返回 false 來阻止應用啟動，因為這樣會讓應用因為非關鍵功能的失敗而無法使用，從而影響用戶體驗。
 - 如果需要強制確保某些關鍵性資料必須成功加載，可以考慮在特定功能頁面中進行檢查和處理，而不是在應用啟動時阻止整個應用的運行。

 `5. 總結`

 - `保持資料加載在 AppDelegate 中進行`：這樣可以在應用啟動的早期就預加載資料，提升後續頁面訪問的效率。
 - `不使用 Alert 阻塞啟動流程`：在` preloadDrinksData() `中遇到錯誤時，不彈出警告，而是選擇打印錯誤日誌，確保應用可以正常啟動。
 - `在具體頁面處理資料不可用的情況`：例如在用戶進入 `SearchViewController` 並需要使用快取資料時，再彈出提示用戶重新加載或稍後再試，這樣更加符合用戶行為的上下文，並提升應用的容錯性和用戶體驗。
 */


import UIKit
import UserNotifications
import Firebase
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 初始化 Firebase，設置 Firebase 的第一步
        FirebaseApp.configure()
        
        // 請求用戶授權發送通知
        setupNotificationAuthorization()
        
        // 初始化 IQKeyboardManager
        setupIQKeyboardManager()
        
        // 加載飲品資料
        preloadDrinksData()
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    // MARK: - URL Handling for Google Sign-In

    /* 實現 App 委託中的 application:openURL:options: function。
     此方法應該調用 GIDSignIn 的 handleURL，該方法將對 App 在身份驗證過程結束時收到的網址進行適當處理。 */
        
    // Handle URL for Google Sign-In
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}

// MARK: - Extension
extension AppDelegate {
    
    // MARK: - Notification Authorization Setup
    
    /// 設置通知授權
    /// - 向用戶請求授權以顯示通知（含提醒、聲音和標章）。
    private func setupNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - IQKeyboardManager Setup
    
    /// 配置 IQKeyboardManager
    /// - 設定鍵盤管理工具的基本行為，包括啟用和點擊空白處收起鍵盤的功能。
    private func setupIQKeyboardManager() {
        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.resignOnTouchOutside = true         // 點擊空白處收起鍵盤
    }
    
    // MARK: - Preload Drinks Data
    
    /// 預加載飲品資料
    /// - 在 App 啟動時從 Firebase 預加載所有飲品資料並存入快取。
    private func preloadDrinksData() {
        Task {
            do {
                try await SearchDrinkDataLoader.shared.loadOrRefreshDrinksData()
                print("應用啟動時成功預加載飲品資料")
            } catch {
                print("應用啟動時預加載飲品資料失敗: \(error.localizedDescription)")
            }
        }
    }
    
}
