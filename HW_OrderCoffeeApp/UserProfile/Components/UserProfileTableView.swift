//
//  UserProfileTableView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/9.
//

import UIKit

/// 自定義 UITableView，用於個人資訊頁面
class UserProfileTableView: UITableView {

    // MARK: - Initializers

    init() {
        super.init(frame: .zero, style: .insetGrouped)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 設定 TableView 的初始配置
    private func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 80
    }
}
