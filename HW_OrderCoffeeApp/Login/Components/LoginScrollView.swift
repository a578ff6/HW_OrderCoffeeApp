//
//  LoginScrollView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/29.
//

// MARK: -  LoginScrollView 筆記
/**
 
 ## LoginScrollView
 
 `* What`
 
 - LoginScrollView 是一個自訂的 UIScrollView 類別，設計目的是為了提供標準化的 ScrollView 配置，特別用於 Login 相關的視圖中。它繼承自 UIScrollView，並提供簡單的方法來配置約束。

 `* Why`
 
 - 統一風格：在應用中多次使用 ScrollView 時，可以保證所有的 ScrollView 具有一致的初始設置，確保 Login 視圖中各個部分風格一致。
 - 減少重複代碼：避免在每個 ScrollView 的初始化中重複設置 translatesAutoresizingMaskIntoConstraints，減少代碼重複度，讓代碼更簡潔。
 - 降低 LoginView 的肥大：將 ScrollView 的配置抽取到這個自訂類別中，使得 LoginView 更加專注於佈局邏輯，符合單一職責原則。
 - 簡化約束設置：提供一個公共方法來設置 ScrollView 的約束，保持佈局邏輯清晰簡單，提高可讀性和維護性。
 
 `* How`
 
 - 使用 LoginScrollView 類別時，只需簡單地初始化並調用 setupConstraints 方法來設置約束：
 
 ```swift
 let mainScrollView = LoginScrollView()
 mainScrollView.setupConstraints(in: parentView)
 ```
 
 - LoginScrollView 自動配置了 translatesAutoresizingMaskIntoConstraints = false，讓自動佈局過程更加流暢和直觀，簡化了配置過程。
 */


import UIKit

/// 自訂的 ScrollView 類別，用於 Login 相關視圖中，提供標準化設置與佈局
class LoginScrollView: UIScrollView {
    
    // MARK: - Initializers
    
    /// 初始化 LoginScrollView，並配置標準設置與佈局
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    /// 設置 ScrollView 的約束條件
    /// - Parameter parentView: 父視圖，ScrollView 將設置其在此視圖中的約束
    func setupConstraints(in parentView: UIView) {
        parentView.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
