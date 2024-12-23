//
//  DrinkDetailNavigationBarManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/19.
//


// MARK: - DrinkDetailNavigationBarManager 筆記
/**
 
 ## DrinkDetailNavigationBarManager 筆記

 `* What`
 
 - `DrinkDetailNavigationBarManager` 是一個專門管理飲品詳情頁導航欄配置與按鈕事件處理的類別。

 - 負責以下功能：

 1.設置導航欄標題與樣式。
 2.添加導航欄按鈕（分享與收藏）。
 3.提供按鈕圖示的即時更新功能。
 4.通過代理模式處理按鈕點擊事件。

 --------------------------

 `* Why`
 
 `1. 分離關注點：`
 
 - 將導航欄的配置和按鈕邏輯從 `DrinkDetailViewController` 中抽離，避免視圖控制器臃腫。
 - 集中管理導航欄邏輯，更易於維護與調試。
    
 `2. 模組化設計：`
 
 - 將導航欄的功能抽離成獨立的管理器，便於重用與測試。
 - 清晰的職責劃分，確保每個類別專注於單一任務。

 `3. 支持即時狀態更新：`
 
 - 提供更新收藏按鈕圖示的方法，確保用戶在收藏狀態改變時獲得即時的視覺回饋。

 --------------------------

 `* How`

 `1.依賴與初始化：`

 - 依賴於 `UINavigationItem`，需要在初始化時注入。
 - 需要設定代理（`DrinkDetailNavigationBarDelegate`）以處理按鈕點擊事件。
 
` 2.核心功能：`

 - `configureNavigationBarTitle`： 設置導航欄的標題文字與樣式（支持大標題模式）。
 - `addNavigationButtons`： 添加分享與收藏按鈕，設置按鈕行為並將其添加至導航欄。
 - `updateFavoriteButton(isFavorite:)`： 根據收藏狀態即時更新收藏按鈕圖示。
 
 `3.代理模式：`

 - 通過代理方法將按鈕點擊事件傳遞給控制器，保持管理器的單一責任。
 
 `4.按鈕設置：`

 - 分享按鈕使用系統圖示（square.and.arrow.up）。
 - 收藏按鈕根據狀態切換圖示（heart 和 heart.fill）。
 
 --------------------------

 `* 注意事項`
 
 `1.單一責任原則：`

 - 僅負責導航欄的配置與按鈕邏輯，不處理收藏或分享的具體業務邏輯。
 - 收藏邏輯交由 `DrinkDetailFavoritesHandler` 處理。
 
` 2.代理設計：`

 - 確保 delegate 的實現類別（如 `DrinkDetailViewController`）正確處理點擊事件。
 
 `3.狀態同步：`

 - 收藏按鈕的狀態需由 `DrinkDetailViewController` 根據業務邏輯（例如 `Firebase` 操作）進行更新，並通過 `updateFavoriteButton` 方法反映在 UI 上。
 
 --------------------------
 
 `* 實現架構圖`
 
 - `DrinkDetailNavigationBarManager`：負責導航欄的按鈕邏輯和 UI 更新。
 - `DrinkDetailFavoritesHandler`：處理具體的收藏業務邏輯，控制器通過調用其方法執行收藏操作。
 
 ```
 [DrinkDetailViewController]
           |
           v
 [DrinkDetailNavigationBarManager]         [DrinkDetailFavoritesHandler]
           |                                         |
 [UINavigationItem]                      [FavoriteManager]
                                                |
                                        [Firebase Firestore]
 ```
 
 --------------------------

` * 總結`
 
 - `DrinkDetailNavigationBarManager` 經過重構後，專注於導航欄的按鈕邏輯與 UI 配置。
 - 將收藏業務邏輯交由 `DrinkDetailFavoritesHandler` 處理，明確了職責邊界，提升了代碼的清晰度與模組化程度。
 */


// MARK: - 大標題屬性筆記
/**
 
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


import UIKit

/// `DrinkDetailNavigationBarManager`
///
/// ### 功能概述
/// `DrinkDetailNavigationBarManager` 專注於管理導航欄的配置與按鈕邏輯，
/// 包括標題設置、按鈕添加及更新按鈕圖示。
///
/// ### 設計目標
/// - 單一責任：只處理導航欄相關的邏輯，按鈕點擊的業務邏輯由控制器處理。
/// - 分離關注點：將導航欄的配置邏輯從視圖控制器中抽離，提升可讀性與維護性。
/// - 代理模式：透過 `DrinkDetailNavigationBarDelegate` 與控制器通信，實現按鈕事件處理。
///
/// ### 功能說明
/// 1. 導航欄標題設置：
///    - 提供標題文字與大標題模式的配置方法。
/// 2. 按鈕設置：
///    - 添加分享按鈕與收藏按鈕，並綁定行為。
///    - 收藏按鈕支援根據狀態更新圖示。
/// 3. 按鈕點擊事件：
///    - 透過代理將按鈕點擊事件傳遞給控制器。
///
/// ### 注意事項
/// - 此類僅負責導航欄邏輯，按鈕點擊行為的具體業務邏輯應由控制器處理。
class DrinkDetailNavigationBarManager {
    
    // MARK: - Properties
    
    /// 對應的 `UINavigationItem`，用於配置導航欄
    private weak var navigationItem: UINavigationItem?
    
    /// 代理，處理按鈕點擊事件
    weak var delegate: DrinkDetailNavigationBarDelegate?
    
    /// 收藏按鈕
    private var favoriteButton: UIBarButtonItem?
    
    /// 分享按鈕
    private var shareButton: UIBarButtonItem?
    
    // MARK: - Initializer
    
    /// 初始化方法
    /// - Parameters:
    ///   - navigationItem: 要配置的 `UINavigationItem`
    init(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
    }
    
    // MARK: - Public Methods
    
    /// 配置導航欄標題
    /// - Parameters:
    ///   - title: 導航欄的標題文字（預設為空）
    ///   - largeTitleDisplayMode: 是否顯示大標題（預設為 `false`）
    func configureNavigationBarTitle(title: String? = nil, largeTitleDisplayMode: Bool = false) {
        navigationItem?.title = title
        navigationItem?.largeTitleDisplayMode = largeTitleDisplayMode ? .always : .never
    }
    
    /// 添加分享與收藏按鈕至導航欄
    ///
    /// - 分享按鈕：顯示分享圖示，觸發分享功能。
    /// - 收藏按鈕：顯示收藏圖示，支援狀態更新。
    func addNavigationButtons() {
        shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonTapped))
        favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favoriteButtonTapped))
        favoriteButton?.tintColor = .deepGreen
        navigationItem?.rightBarButtonItems = [shareButton, favoriteButton].compactMap { $0 }
    }
    
    /// 更新收藏按鈕的圖示
    ///
    /// - Parameter isFavorite: 是否已收藏
    func updateFavoriteButton(isFavorite: Bool) {
        favoriteButton?.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
    }
    
    // MARK: - Private Methods
    
    /// 處理分享按鈕點擊事件
    @objc private func shareButtonTapped() {
        delegate?.didTapShareButton()
    }
    
    /// 處理收藏按鈕點擊事件
    @objc private func favoriteButtonTapped() {
        delegate?.didTapFavoriteButton()
    }
    
}
