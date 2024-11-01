//
//  SelectStoreInfoView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//


import UIKit
import CoreLocation

/// 用於顯示門市詳細資訊的 View
class SelectStoreInfoView: UIView {
    
    // MARK: - Button Callbacks
    
    var onCallPhoneTapped: (() -> Void)?
    var onSelectStoreTapped: (() -> Void)?

    // MARK: - UI Elements

    private let nameLabel = createLabel(font: UIFont.systemFont(ofSize: 24, weight: .bold), textColor: .black)
    
    // Address StackView
    private let addressSymbolImageView = createSymbolImageView(systemName: "mappin.and.ellipse", tintColor: .deepGreen)
    private let addressValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16, weight: .medium), textColor: .gray, numberOfLines: 0)
    private let addressStackView = createStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // Distance StackView
    private let distanceSymbolImageView = createSymbolImageView(systemName: "figure.walk.diamond", tintColor: .deepGreen)
    private let distanceValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textColor: .lightGray)
    private let distanceStackView = createStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // Phone Number StackView
    private let phoneSymbolImageView = createSymbolImageView(systemName: "phone.connection", tintColor: .deepGreen)
    private let phoneNumberValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray)
    private let phoneNumberStackView = createStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)

    // Opening Hours StackView
    private let openingHoursSymbolImageView = createSymbolImageView(systemName: "clock", tintColor: .deepGreen)
    private let openingHoursValueLabel = createLabel(font: UIFont.systemFont(ofSize: 16), textColor: .gray, numberOfLines: 0)
    private let openingHoursStackView = createStackView(axis: .horizontal, spacing: 15, alignment: .center, distribution: .fill)
    
    // Button
    private let callButton = createButton(title: "Call Phone", font: UIFont.systemFont(ofSize: 18, weight: .semibold), backgroundColor: .lightWhiteGray, cornerStyle: .medium, titleColor: .white, iconName: "phone.circle.fill", height: 55)
    private let selectStoreButton = createButton(title: "Select Store", font: UIFont.systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, cornerStyle: .medium, titleColor: .white, iconName: "storefront.circle.fill", height: 55)
    
    // StackView
    private let contentStackView = createStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    private let buttonStackView = createStackView(axis: .horizontal, spacing: 12, alignment: .leading, distribution: .fill)

    // Separator
    private let separatorView1 = createSeparatorView(type: .solid(height: 1))
    private let separatorView2 = createSeparatorView(type: .solid(height: 1))
    private let spacingView = createSeparatorView(type: .spacer(height: 5))
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        addressStackView.addArrangedSubview(addressSymbolImageView)
        addressStackView.addArrangedSubview(addressValueLabel)
        
        distanceStackView.addArrangedSubview(distanceSymbolImageView)
        distanceStackView.addArrangedSubview(distanceValueLabel)
        
        phoneNumberStackView.addArrangedSubview(phoneSymbolImageView)
        phoneNumberStackView.addArrangedSubview(phoneNumberValueLabel)
        
        openingHoursStackView.addArrangedSubview(openingHoursSymbolImageView)
        openingHoursStackView.addArrangedSubview(openingHoursValueLabel)
        
        // 添加 views 到 content stack view
        buttonStackView.addArrangedSubview(callButton)
        buttonStackView.addArrangedSubview(selectStoreButton)
        
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(separatorView1)
        contentStackView.addArrangedSubview(addressStackView)
        contentStackView.addArrangedSubview(distanceStackView)
        contentStackView.addArrangedSubview(separatorView2)
        contentStackView.addArrangedSubview(phoneNumberStackView)
        contentStackView.addArrangedSubview(openingHoursStackView)
//        contentStackView.addArrangedSubview(spacingView)  // 用於增加 openingHoursStackView 與 buttonStackView 的間距
        contentStackView.addArrangedSubview(buttonStackView)
        
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    /// 設置按鈕的目標行為
    private func setupActions() {
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        selectStoreButton.addTarget(self, action: #selector(selectStoreButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Factory Method

    /// 創建 SF Symbol 的 UIImageView
    private static func createSymbolImageView(systemName: String, tintColor: UIColor = .black) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    /// 創建 UILabel
    private static func createLabel(text: String? = nil, font: UIFont, textColor: UIColor = .black, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 創建 UIButton
    private static func createButton(title: String, font: UIFont, backgroundColor: UIColor, cornerStyle: UIButton.Configuration.CornerStyle, titleColor: UIColor, iconName: String, height: CGFloat) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseForegroundColor = titleColor
        configuration.baseBackgroundColor = backgroundColor
        configuration.cornerStyle = cornerStyle
        
        // 設置圖標
        configuration.image = UIImage(systemName: iconName)
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        
        // 使用 NSAttributedString 設置字體
        var titleAttr = AttributedString(title)
        titleAttr.font = font
        configuration.attributedTitle = titleAttr
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置高度約束
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }
    
    /// 創建 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    /// 建立分隔視圖
    private static func createSeparatorView(type: SeparatorType) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        switch type {
        case .solid(let height):
            view.backgroundColor = .lightWhiteGray
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        case .spacer(let height):
            view.backgroundColor = .clear
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        return view
    }

    /// 分隔視圖類型
    private enum SeparatorType {
        case solid(height: CGFloat)
        case spacer(height: CGFloat)
    }
    
    // MARK: - Button Actions
    
    @objc private func callButtonTapped() {
        callButton.addSpringAnimation(scale: 1.05) { _ in
            self.onCallPhoneTapped?()
        }
    }
    
    @objc private func selectStoreButtonTapped() {
        selectStoreButton.addSpringAnimation(scale: 1.05) { _ in
            self.onSelectStoreTapped?()
        }
    }

    // MARK: - Configure Method
    
    /// 配置 SelectStoreInfoView 以顯示門市詳細資訊
    /// - Parameters:
    ///   - store: 門市資料
    ///   - formattedPhoneNumber: 格式化後的電話號碼
    ///   - distance: 與用戶的距離
    ///   - todayHours: 今日營業時間
    func configure(with store: Store, formattedPhoneNumber: String, distance: CLLocationDistance?, todayHours: String?) {
        nameLabel.text = store.name
        addressValueLabel.text = store.address
        distanceValueLabel.text = distance != nil ? String(format: "%.2f km", distance! / 1000) : "Not available"
        phoneNumberValueLabel.text = formattedPhoneNumber
        openingHoursValueLabel.text = todayHours ?? "No hours provided"
    }
}
