//
//  UserProfileView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/14.
//

import UIKit

/// 個人資訊頁面佈局
class UserProfileView: UIView {
    
    // MARK: - UI Elements
    let profileImageView = createProfileImageView()
    let nameLabel = UserProfileView.createLabel(fontSize: 24, weight: .bold, textColor: .black, alignment: .center)
    let emailLabel = UserProfileView.createLabel(fontSize: 16, weight: .regular, textColor: .gray, alignment: .center)

    private let personStackView: UIStackView = UserProfileView.createStackView(axis: .vertical, spacing: 12, alignment: .center)
    
    let backgroundCenteredView = createbackgroundCenteredView(backgroundColor: .deepGreen)
    
    // MARK: - UI Elements (Buttons)
    let changePhotoButton = createChangePhotoButton()
    let editProfileButton = createButton()
    let orderHistoryButton = createButton()
    let favoritesButton = createButton()
    let logoutButton = createButton()
    
    private let actionStackView: UIStackView = createStackView(axis: .vertical, spacing: 10, alignment: .fill)
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
        
        // 配置按鈕的外觀
        configureButton(editProfileButton, withTitle: "Edit Profile", sfSymbolName: "person.circle")
        configureButton(orderHistoryButton, withTitle: "Order History", sfSymbolName: "clock")
        configureButton(favoritesButton, withTitle: "Favorites", sfSymbolName: "heart")
        configureButton(logoutButton, withTitle: "Logout", sfSymbolName: "arrow.backward.circle")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout Setup
    
    /// 佈局
    private func setupLayout() {
        addSubview(backgroundCenteredView)
        addSubview(profileImageView)
        addSubview(changePhotoButton)
        
        personStackView.addArrangedSubview(nameLabel)
        personStackView.addArrangedSubview(emailLabel)
        addSubview(personStackView)
        
        actionStackView.addArrangedSubview(editProfileButton)
        actionStackView.addArrangedSubview(orderHistoryButton)
        actionStackView.addArrangedSubview(favoritesButton)
        actionStackView.addArrangedSubview(logoutButton)
        addSubview(actionStackView)
        
        NSLayoutConstraint.activate([
            // 設置背景視圖的約束，使其覆蓋從螢幕頂部到大頭照水平中間位置的範圍
            backgroundCenteredView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundCenteredView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundCenteredView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundCenteredView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            // 設置大頭照約束
            profileImageView.widthAnchor.constraint(equalToConstant: 180),
            profileImageView.heightAnchor.constraint(equalToConstant: 180),
            profileImageView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            // 將 changePhotoButton 放在 profileImageView 的右下角
            changePhotoButton.widthAnchor.constraint(equalToConstant: 40),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 40),
            changePhotoButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 0),
            changePhotoButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0),
            
            // 設置 personStackView 和 actionStackView 的約束
            personStackView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            personStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            
            actionStackView.topAnchor.constraint(equalTo: personStackView.bottomAnchor, constant: 20),
            actionStackView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    
    /// 創建標籤
    private static func createLabel(fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.textAlignment = alignment
        label.numberOfLines = 0
        return label
    }
    
    /// 創建背景視圖（背景色）
    private static func createbackgroundCenteredView(backgroundColor: UIColor) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        return view
    }
    
    /// 創建通用按鈕
    private static func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    /// 創建更改照片按鈕
    private static func createChangePhotoButton() -> UIButton {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "camera.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 創建大頭照圖片視圖
    private static func createProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 90
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.black.cgColor
        return imageView
    }
    
    /// 創建堆疊視圖
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 配置按鈕外觀
    private func configureButton(_ button: UIButton, withTitle title: String, sfSymbolName: String) {
        // 設置邊框和圓角
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.backgroundColor = .lightGray.withAlphaComponent(0.3)

        // 手動創建圖示
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let image = UIImage(systemName: sfSymbolName, withConfiguration: configuration)
        let iconImageView = UIImageView(image: image)
        iconImageView.tintColor = .deepBrown
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置 ">" 符號
        let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: configuration)
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .deepBrown
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置按鈕文字
        let label = UILabel()
        label.text = title
        label.textAlignment = .left
        label.textColor = .deepBrown
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 圖示、文字、 ">" 符號的 StackView
        let stackView = UIStackView(arrangedSubviews: [iconImageView, label, chevronImageView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false                      // 禁止 stackView 攔截互動事件（因為 stackView 再按鈕圖層上方，讓按鈕本身接收所有的互動事件。）
        
        // 清除按鈕標題，並將自定義的堆疊視圖作為按鈕的子視圖
        button.setTitle(nil, for: .normal)
        button.addSubview(stackView)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 55),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // 添加處理按鈕點擊時的高亮效果
        button.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: [.touchUpInside, .touchDragExit])
    }

    // MARK: - 按鈕點擊效果處理

    @objc private func buttonTouchedDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
    }

    @objc private func buttonTouchedUp(_ sender: UIButton) {
        sender.backgroundColor = .lightGray.withAlphaComponent(0.3)
    }

}
