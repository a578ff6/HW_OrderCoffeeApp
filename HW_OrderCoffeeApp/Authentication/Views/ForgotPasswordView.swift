//
//  ForgotPasswordView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/17.
//

import UIKit

/// 處理 ForgotPasswordViewController 相關 UI元件 佈局
class ForgotPasswordView: UIView {

    // MARK: - UI Elements
    
    let titleLabel = createLabel(text: "Forgot Password ?", fontSize: 26, weight: .black, textColor:  UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1))
    let descriptionLabel = createLabel(text: "Enter your email address below and we'll send your password reset instructions by email.", fontSize: 16, weight: .medium, textColor: .black, numberOfLines: 0)
    let emailTextField = createBottomLineTextField(placeholder: "Email")
    let resetPasswordButton = createButton(title: "Request Password Rest", fontSize: 16, fontWeight: .bold, textColor: .white, imageName: "key.horizontal.fill")
    let loginButton = createAttributedButton(mainText: "You remember your password? ", highlightedText: "Login", fontSize: 14, mainTextColor: .gray, highlightedTextColor: UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1))

    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setEmailTextFieldIcon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 設置信箱圖示
    private func setEmailTextFieldIcon() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let envelopeImage = UIImage(systemName: "envelope", withConfiguration: configuration)
        let envelopeImageView = UIImageView(image: envelopeImage)
        envelopeImageView.tintColor = .gray
        envelopeImageView.contentMode = .scaleAspectFit
        envelopeImageView.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.rightView = envelopeImageView
        emailTextField.rightViewMode = .always
        
        NSLayoutConstraint.activate([
            envelopeImageView.widthAnchor.constraint(equalToConstant: 30),
            envelopeImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    /// 設置佈局
    private func setupLayout() {
        let mainStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            emailTextField
        ])
    
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        addSubview(loginButton)
        addSubview(resetPasswordButton)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            loginButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
      
            resetPasswordButton.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -10),
            resetPasswordButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            resetPasswordButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            emailTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Factory Methods

    /// Label 建立
    private static func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor = .black, numberOfLines: Int = 1) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 文字欄
    private static func createBottomLineTextField(placeholder: String) -> BottomLineTextField {
        let textField = BottomLineTextField()
        textField.placeholder = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    /// 按鈕建立
    private static func createButton(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = .black, imageName: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        button.setTitleColor(textColor, for: .normal)
        button.styleFilledButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        if let imageName = imageName {
            let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            let image = UIImage(systemName: imageName, withConfiguration: configuration)
            button.setImage(image, for: .normal)
            button.tintColor = textColor
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        }
        
        return button
    }
    
    /// 文字型態按鈕
    private static func createAttributedButton(mainText: String, highlightedText: String, fontSize: CGFloat, mainTextColor: UIColor, highlightedTextColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: mainText, attributes: [
            .foregroundColor: mainTextColor,
            .font: UIFont.boldSystemFont(ofSize: fontSize)
        ])
        attributedTitle.append(NSAttributedString(string: highlightedText, attributes: [
            .foregroundColor: highlightedTextColor,
            .font: UIFont.boldSystemFont(ofSize: fontSize)
        ]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
}
