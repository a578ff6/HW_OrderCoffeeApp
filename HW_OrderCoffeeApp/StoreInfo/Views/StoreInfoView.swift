//
//  StoreInfoView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

// MARK: - StoreInfoView 筆記
/**
 
 ## StoreInfoView 筆記

 - 本來視圖的顯示隱藏、按鈕行為都是在`StoreInfoViewController`，想說也沒有很多東西，後來發現在職責的處理上變得很分散，因此才調整到StoreInfoView集中處理。
 - 過程中有在思考 `StoreInfoView` 使否為必要，如果調整成在 `StoreInfoViewController` 直接處理 `StoreDefaultInfoView`、`SelectStoreInfoView` 是否更直觀。
 - 但是測試後，發現會讓 StoreInfoViewController 變得更加肥大，且職責模糊。
 
 ----------

 `* What`
 
 - `StoreInfoView` 是一個用於顯示門市資訊的自定義視圖，包含兩種狀態：
 
 1. 預設狀態：當用戶尚未選擇門市時，顯示提示訊息（透過 `StoreDefaultInfoView`）。
 2. 詳細狀態：當用戶選擇門市後，顯示門市詳細資訊（透過 `SelectStoreInfoView`）。

 ----------

 `* Why`
 
` 1. 視圖狀態管理：`
 
    - 當使用者操作不同場景（如尚未選擇門市或已選擇門市）時，需要顯示不同的內容。
    - 提供清晰的結構來管理狀態切換，避免在控制器中加入過多的顯示邏輯。
    
 `2. 解耦與可讀性：`
 
    - 將視圖狀態與顯示邏輯集中在 `StoreInfoView`，提升模組化程度。
    - `StoreInfoViewController` 專注於業務邏輯，而視圖的顯示細節由 `StoreInfoView` 負責，符合單一職責原則。
    
` 3. 彈性擴展：`
 
    - `StoreInfoView` 的結構清晰，易於新增或修改子視圖（例如：未來需要顯示其他資訊）。

 ----------

 `* How`

 `1. 結構設計：`
 
    - 包含兩個主要子視圖：
      - `StoreDefaultInfoView`：顯示預設的提示訊息。
      - `SelectStoreInfoView`：顯示已選擇門市的詳細資訊。
 
    - 透過隱藏與顯示子視圖 (`isHidden`)，切換不同狀態。

 `2. 狀態管理：`
 
    - 提供 `updateView(for:)` 方法，根據 `StoreInfoState` 切換顯示內容：
      - `.initial(message: String)`：顯示 `StoreDefaultInfoView` 並隱藏 `SelectStoreInfoView`。
      - `.details(viewModel: StoreInfoViewModel)`：顯示 `SelectStoreInfoView` 並隱藏 `StoreDefaultInfoView`。

 `3. 行為回調：`
 
    - 提供 `configureActions(callPhoneAction:selectStoreAction:)` 方法，設定 `SelectStoreInfoView` 中按鈕的行為：
      - `callPhoneAction`：用於撥打電話。
      - `selectStoreAction`：用於選擇門市。

 `4. 使用方式：`
 
    - 在 `StoreInfoViewController` 中：
      - 初始化 `StoreInfoView` 作為主要視圖。
      - 使用 `updateView(for:)` 切換狀態。
      - 使用 `configureActions` 設置按鈕回調行為。

 ----------

 `* 優勢`

 1. 責任清晰：
 
    - `StoreInfoViewController` 處理業務邏輯。
    - `StoreInfoView` 處理視圖狀態與顯示邏輯。

 2. 高可維護性：
 
    - 集中狀態切換與按鈕行為配置，降低邏輯重複。

 3. 易擴展性：
 
    - 未來若需要新增其他狀態或功能，僅需在 `StoreInfoView` 中進行調整，避免影響控制器層。

 */


// MARK: - (v)

import UIKit

/// `StoreInfoView` 是用來顯示門市資訊的視圖，包含兩種狀態：
/// - 預設狀態（尚未選擇門市）
/// - 顯示選擇的門市詳細資訊
///
/// ### 功能說明
/// - 提供兩個子視圖：
///   1. `StoreDefaultInfoView`：當用戶尚未選擇門市時，顯示提示訊息。
///   2. `SelectStoreInfoView`：當用戶選擇門市後，顯示門市的詳細資訊。
/// - 支援狀態切換與按鈕回調行為的設定。
///
/// ### 設計目標
/// - 單一職責：專注於管理與顯示門市資訊的視圖狀態。
/// - 解耦性：透過 `configureActions` 提供按鈕行為的回調設定，與控制器層保持分離。
class StoreInfoView: UIView {
    
    // MARK: - UI Elements
    
    /// 用於顯示預設提示資訊的視圖
    private let storeDefaultInfoView = StoreDefaultInfoView()
    
    /// 用於顯示門市詳細資訊的視圖
    private let selectStoreInfoView = SelectStoreInfoView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置子視圖與佈局約束
    private func setupViews() {
        backgroundColor = .white
        addSubview(storeDefaultInfoView)
        addSubview(selectStoreInfoView)
        
        storeDefaultInfoView.translatesAutoresizingMaskIntoConstraints = false
        selectStoreInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            storeDefaultInfoView.topAnchor.constraint(equalTo: topAnchor),
            storeDefaultInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            storeDefaultInfoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            storeDefaultInfoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            selectStoreInfoView.topAnchor.constraint(equalTo: topAnchor),
            selectStoreInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectStoreInfoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectStoreInfoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    // MARK: - State Management
    
    /// 更新視圖顯示的狀態
    ///
    /// 根據 `StoreInfoViewController.StoreInfoState` 的狀態切換顯示內容：
    /// - `.initial`：顯示 `StoreDefaultInfoView` 並隱藏 `SelectStoreInfoView`。
    /// - `.details`：顯示 `SelectStoreInfoView` 並隱藏 `StoreDefaultInfoView`。
    ///
    /// - Parameter state: 需要更新的狀態
    func updateView(for state: StoreInfoViewController.StoreInfoState) {
        switch state {
        case .initial(let message):
            storeDefaultInfoView.configure(with: message)
            storeDefaultInfoView.isHidden = false
            selectStoreInfoView.isHidden = true
        case .details(let viewModel):
            selectStoreInfoView.configure(with: viewModel)
            storeDefaultInfoView.isHidden = true
            selectStoreInfoView.isHidden = false
        }
    }
    
    // MARK: - Action Configuration
    
    /// 配置按鈕的回調行為
    ///
    /// 用於設定 `SelectStoreInfoView` 中按鈕的點擊行為：
    /// - `撥打電話` 行為
    /// - `選擇門市` 行為
    ///
    /// - Parameters:
    ///   - callPhoneAction: 撥打電話的回調行為
    ///   - selectStoreAction: 選擇門市的回調行為
    func configureActions(
        callPhoneAction: @escaping () -> Void,
        selectStoreAction: @escaping () -> Void
    ) {
        selectStoreInfoView.onCallPhoneTapped = callPhoneAction
        selectStoreInfoView.onSelectStoreTapped = selectStoreAction
    }
    
}
