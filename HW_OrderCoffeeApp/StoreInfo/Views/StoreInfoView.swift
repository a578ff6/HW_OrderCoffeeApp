//
//  StoreInfoView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

import UIKit

/// StoreInfoView 用於顯示`預設資訊`或`門市詳細資訊`
///
/// - StoreInfoView 包含兩個視圖：
///   - `DefaultInfoView`：當用戶還沒有選擇門市時顯示提示信息。
///   - `SelectStoreInfoView`：顯示已選擇的門市詳細資訊。
class StoreInfoView: UIView {
    
    // MARK: - UI Elements
    
    // 預設和選擇的門市資訊視圖
    let defaultInfoView = DefaultInfoView()
    let selectStoreInfoView = SelectStoreInfoView()
    
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
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(defaultInfoView)
        addSubview(selectStoreInfoView)
        
        defaultInfoView.translatesAutoresizingMaskIntoConstraints = false
        selectStoreInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            defaultInfoView.topAnchor.constraint(equalTo: topAnchor),
            defaultInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            defaultInfoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            defaultInfoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            selectStoreInfoView.topAnchor.constraint(equalTo: topAnchor),
            selectStoreInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectStoreInfoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectStoreInfoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 初始狀態下隱藏 SelectStoreInfoView
        selectStoreInfoView.isHidden = true
    }
    
}
