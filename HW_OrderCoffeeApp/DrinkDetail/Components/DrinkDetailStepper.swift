//
//  DrinkDetailStepper.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/16.
//

import UIKit

/// 自訂的 Stepper，專門用於飲品選項的數量選擇
///
/// ### 功能說明
/// `DrinkDetailStepper` 是一個自訂的 `UIStepper`，提供以下功能：
/// - 自定義最小值 (`minValue`)、最大值 (`maxValue`)、預設值 (`defaultValue`)。
///
/// ### 設計目標
/// 1. 簡化初始化邏輯：
///    - 預設值與邊界值可透過初始化參數設定，方便不同場景的使用。
/// 2. 提升重用性：
///    - 可適用於飲品數量調整等多場景需求。
///
/// ### 注意事項
/// - 若需自訂樣式（如背景或按鈕樣式），可繼承此類進行擴展。
/// - 預設值必須在 `minValue` 與 `maxValue` 範圍內。
class DrinkDetailStepper: UIStepper {
    
    // MARK: - Initializer
    
    /// 初始化 Stepper，提供自訂的最小值、最大值與預設值。
    /// - Parameters:
    ///   - minValue: Stepper 的最小值，預設為 1。
    ///   - maxValue: Stepper 的最大值，預設為 10。
    ///   - defaultValue: Stepper 的初始值，預設為 1。
    init(minValue: Double = 1, maxValue: Double = 10, defaultValue: Double = 1) {
        super.init(frame: .zero)
        setupStepper(minValue: minValue, maxValue: maxValue, defaultValue: defaultValue)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 配置 Stepper 的屬性
    /// - Parameters:
    ///   - minValue: Stepper 的最小值。
    ///   - maxValue: Stepper 的最大值。
    ///   - defaultValue: Stepper 的初始值。
    ///
    /// ### 功能：
    /// - 設定 Stepper 的值範圍與初始值。
    private func setupStepper(minValue: Double, maxValue: Double, defaultValue: Double) {
        self.minimumValue = minValue
        self.maximumValue = maxValue
        self.value = defaultValue
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
