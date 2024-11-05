//
//  OrderConfirmationCheckmarkCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/2.
//

import UIKit

/// 顯示提交成功後的打勾圖示的 Cell
class OrderConfirmationCheckmarkCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderConfirmationCheckmarkCell"
    
    // MARK: - UI Elements
    
    private let checkmarkImageView = createCheckmarkImageView(imageName: "checkmark.circle.fill", tintColor: .deepGreen, width: 150, height: 150)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Factory Method
    
    /// 創建並配置 UIImageView
    private static func createCheckmarkImageView(imageName: String, tintColor: UIColor, width: CGFloat, height: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: imageName)
        imageView.tintColor = tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置寬度和高度的約束
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        return imageView
    }
    
}
