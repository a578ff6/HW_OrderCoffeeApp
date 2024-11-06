//
//  OrderrConfirmationCloseButtonCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/3.
//

import UIKit

/// 包含 "關閉" 按鈕，讓用戶確認後返回。
class OrderrConfirmationCloseButtonCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderrConfirmationCloseButtonCell"

    // MARK: - UI Elements

    private let closeButton = createButton(title: "Close", font: UIFont.systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, titleColor: .white, iconName: "xmark.circle.fill", height: 55)
    
    // MARK: - Callback Closure

    var onCloseButtonTapped: (() -> Void)?
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupLayout() {
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    /// 添加按鈕的點擊事件
    private func setupAction() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Handler

    /// 當`關閉`按鈕被點擊時呼叫，關閉 `OrderConfirmationViewController` ，並且返回到主頁，以及清空Order。
    @objc private func closeButtonTapped() {
        closeButton.addSpringAnimation(scale: 1.05) { _ in
            self.onCloseButtonTapped?()
        }
    }

    // MARK: - Factory Methods
    
    /// 建立一個帶有`圖標`和`文字`的按鈕
    private static func createButton(title: String, font: UIFont, backgroundColor: UIColor, titleColor: UIColor, iconName: String, height: CGFloat) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        // 使用 UIButton.Configuration 來配置按鈕外觀
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = titleColor
        config.baseBackgroundColor = backgroundColor
        config.image = UIImage(systemName: iconName)
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.cornerStyle = .medium

        // 設置字體
        var titleAttr = AttributedString(title)
        titleAttr.font = font
        config.attributedTitle = titleAttr
        
        button.configuration = config
        return button
    }
    
}
