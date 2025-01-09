//
//  StoreInfoViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/29.
//

// MARK: - StoreInfoViewController 筆記
/**
 
 ## StoreInfoViewController 筆記
 
 `* What`
 
 - `StoreInfoViewController` 是一個負責顯示門市資訊的視圖控制器，支援兩種主要狀態：
 
 1. 初始狀態 (`initial`)：顯示提示訊息（如：「請選擇門市」）。
 2. 詳細狀態 (`details`)：顯示已選擇門市的詳細資訊（如：門市名稱、地址、營業時間）。

 - 核心功能：
 
 1.根據狀態切換 UI 顯示。
 2.提供行為回調（如撥打電話、選擇門市）的處理邏輯。

 -----------

 `* Why`
 
 1. 用戶需求：
 
    - 提供用戶友好的界面，當未選擇門市時顯示提示，選擇後提供詳細資訊。
    - 支援用戶快速撥打電話或選擇門市作為取件點。
    
 2. 模組化設計：
 
    - 使用 `StoreInfoView` 作為視圖容器，分離視圖顯示與邏輯處理，提升代碼的可讀性與可維護性。
    - 讓狀態管理集中在控制器，確保邏輯清晰。

 3. 符合 MVC 設計原則：
 
    - 視圖 (`StoreInfoView`) 和邏輯 (`StoreInfoViewController`) 明確分工，降低耦合度。
    - 便於未來擴展或修改（如新增狀態或功能）。

 * How

 1. 狀態管理
 
 - 透過 `StoreInfoState` 列舉來管理狀態：
   - `.initial(message: String)`：用於顯示初始提示訊息。
   - `.details(viewModel: StoreInfoViewModel)`：用於顯示門市的詳細資訊。

 2. 視圖更新
 
 - 使用 `storeInfoView.updateView(for:)` 根據狀態切換 UI：
   - 初始狀態顯示 `StoreDefaultInfoView`。
   - 詳細狀態顯示 `SelectStoreInfoView`，並配置相關行為回調。

 3. 行為回調
 
 - 透過 `storeInfoView.configureActions` 設置撥打電話和選擇門市的行為。
 - 在控制器內集中處理回調邏輯（`handleCallPhone`、`handleSelectStore`），保持視圖單純。

 -----------

 `* Code Implementation Summary`
 
 ```swift
 // 狀態管理
 func setState(_ state: StoreInfoState) {
     storeInfoView.updateView(for: state)
     updateActions(for: state)
 }

 // 設置行為回調
 private func updateActions(for state: StoreInfoState) {
     if case .details(let viewModel) = state {
         storeInfoView.configureActions(
             callPhoneAction: { [weak self] in
                 self?.handleCallPhone(for: viewModel)
             },
             selectStoreAction: { [weak self] in
                 self?.handleSelectStore(for: viewModel)
             }
         )
     }
 }

 // 行為處理
 private func handleCallPhone(for viewModel: StoreInfoViewModel) {
     // 顯示撥打電話的警告並執行撥號操作
 }
 private func handleSelectStore(for viewModel: StoreInfoViewModel) {
     // 顯示選擇門市的確認彈窗並通知主畫面
 }
 ```

 -----------

 `* 優化的設計與益處`

 `1. 集中狀態與行為管理：`
 
    - `setState` 明確分工：`updateView` 負責視圖切換，`updateActions` 設置回調。
    - 增強邏輯的可讀性，便於擴展新功能（如新增按鈕或狀態）。

 `2. 視圖與控制器分工明確：`
 
    - `StoreInfoView` 僅負責 UI 組織與基本行為設定。
    - 行為邏輯集中於控制器內，符合 MVC 設計原則。

 `3. 低耦合、高可測試性：`
 
    - 行為回調使用閉包處理，便於測試與替換。
    - 未來若需新增狀態或擴展功能，能快速進行修改。
 
 `4.StoreSelectionResultDelegate 的設置：`
 
    - 設置 `StoreSelectionResultDelegate`，用於在用戶選擇完門市後通知主畫面更新顯示，實現了「店鋪選擇畫面」與主畫面之間的鬆耦合。
 
 `5. 設計考量`
    
    - `資料一致性`：
        - 使用代理模式 (`StoreSelectionResultDelegate`) 來通知主畫面選擇結果，確保`選擇的門市`能即時`同步至訂單顯示`。
    
    - `用戶確認`：
        - 在選擇店鋪前加入確認提示 (`Alert`)，減少誤操作的可能性，提升用戶體驗。
 */


// MARK: - (v)

import UIKit

/// `StoreInfoViewController`
///
/// 此控制器負責顯示「預設提示資訊」或「門市詳細資訊」的 UI。
///
/// - 功能說明：
///   - 根據不同的狀態顯示對應的視圖。
///   - 提供撥打電話和選擇門市的行為回調。
///
/// - 支援的狀態：
///   1. 初始狀態：顯示預設提示訊息（例如：「請選擇門市」）。
///   2. 詳細狀態：顯示選定門市的詳細資訊（例如：地址、電話、營業時間）。
///
/// - 核心組件：
///   - `StoreInfoView`：內含 `StoreDefaultInfoView` 和 `SelectStoreInfoView`。
///
/// - 設計目標：
///   - 使用單一職責原則（SRP）：
///    - 控制器負責業務邏輯和狀態管理。
///    - `StoreInfoView` 專注於視圖顯示和行為配置。
///
/// - 使用場景：
///   - 作為浮動面板（Floating Panel）的內容，配合地圖功能顯示選定門市的資訊。
class StoreInfoViewController: UIViewController {
    
    
    // MARK: - Nested Types
    
    /// 表示 `StoreInfoViewController` 的狀態
    ///
    /// - `initial`：初始狀態，僅顯示提示訊息。
    /// - `details`：詳細資訊狀態，顯示門市詳細資料。
    enum StoreInfoState {
        case initial(message: String)
        case details(viewModel: StoreInfoViewModel)
    }
    
    // MARK: - Properties
    
    /// 主要顯示的視圖，包含「預設提示資訊視圖」與「選擇的門市資訊視圖」
    private let storeInfoView = StoreInfoView()
    
    // MARK: - Delegate
    
    /// 用於通知主畫面選擇的門市結果，保持主畫面與門市選擇間的同步
    weak var storeSelectionResultDelegate: StoreSelectionResultDelegate?
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = storeInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Public Methods
    
    /// 根據狀態更新 StoreInfoViewController 的 UI
    ///
    /// - Parameter state: 浮動面板的狀態
    func setState(_ state: StoreInfoState) {
        storeInfoView.updateView(for: state)
        updateActions(for: state)
    }
    
    // MARK: - Private Methods
    
    /// 更新按鈕的行為回調
    ///
    /// 根據當前狀態設置 `SelectStoreInfoView` 的按鈕行為。
    ///
    /// - Parameter state: 當前的狀態
    private func updateActions(for state: StoreInfoState) {
        if case .details(let viewModel) = state {
            storeInfoView.configureActions(
                callPhoneAction: { [weak self] in
                    self?.handleCallPhone(for: viewModel)
                },
                selectStoreAction: { [weak self] in
                    self?.handleSelectStore(for: viewModel)
                }
            )
        }
    }
    
    // MARK: - Action Handlers

    /// 處理撥打電話的邏輯
    ///
    /// - Parameter viewModel: 門市相關的 ViewModel
    private func handleCallPhone(for viewModel: StoreInfoViewModel) {
        AlertService.showActionSheet(
            withTitle: "撥打電話",
            message: "確定要撥打電話給「\(viewModel.name)」嗎？",
            inViewController: self,
            confirmButtonTitle: "撥打",
            showCancelButton: true
        ) {
            guard let phoneURL = URL(string: "tel://\(viewModel.formattedPhoneNumber)") else { return }
            UIApplication.shared.open(phoneURL, options: [:])
        }
    }
    
    /// 處理選擇門市的邏輯
    ///
    /// - Parameter viewModel: 門市相關的 ViewModel
    private func handleSelectStore(for viewModel: StoreInfoViewModel) {
        AlertService.showAlert(
            withTitle: "選擇門市",
            message: "你確定要選擇「\(viewModel.name)」作為取件門市嗎？",
            inViewController: self,
            showCancelButton: true
        ) {
            self.storeSelectionResultDelegate?.storeSelectionDidComplete(with: viewModel.name)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
