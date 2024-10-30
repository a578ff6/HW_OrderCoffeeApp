//
//  DefaultInfoView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

import UIKit

/// 用於顯示預設資訊的 View（未選取門市時）
class DefaultInfoView: UIView {
    
    // MARK: - UI Elements
    
    private let titleLabel = createLabel(text: "請選擇門市", font: UIFont.systemFont(ofSize: 24, weight: .bold), textColor: .black, alignment: .left)
    private let infoLabel = createLabel(font: UIFont.systemFont(ofSize: 18, weight: .bold), textColor: .lightGray, alignment: .center)
    
    private let separatorView = createSeparatorView(height: 1)
    
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
        addSubview(titleLabel)
        addSubview(separatorView)
        addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // Separator View Constraints
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Info Label Constraints
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Factory Method
    
    /// 創建 UILabel
    private static func createLabel(text: String? = nil, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 建立分隔視圖
    private static func createSeparatorView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightWhiteGray
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    // MARK: - Configure Method
    
    /// 配置 DefaultInfoView 以顯示預設提示訊息
    /// - Parameter message: 預設訊息
    func configure(with message: String) {
        infoLabel.text = message
    }
    
}
