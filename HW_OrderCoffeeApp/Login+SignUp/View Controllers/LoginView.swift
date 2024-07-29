//
//  LoginView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/17.
//

/*
 
 A. 佈局部分：
    * titleLabel.topAnchor 使用 view.safeAreaLayoutGuide.topAnchor 而不是 view.topAnchor 。是為了確保在所有設備上（尤其是帶有瀏海的設備）都有一致的佈局。
    
    * Safe Area：
        - 避免被遮擋： safeAreaLayoutGuide 確保視圖的內容不會被系統 UI 元件（狀態欄、NavigationBar、工具欄、瀏海）遮擋。
 
    * 適應不同的設備：
        - 尤其是 iPhone X 及後續機種引入了瀏海。safeAreaLayoutGuide 動態調整，使內容區域適應遮些變化，而 topAnchor 是固定的，可能會導致內容被系統願見覆蓋。
*/

// MARK: - 整理func
import UIKit

/// 處理 LoginViewController 相關 UI 元件佈局
class LoginView: UIView {
    
    // MARK: - UI Elements
    let imageView = creatImageView(imageName: "starbucksLogo2")
    let titleLabel = createLabel(text: "Log in to your account", fontSize: 28, weight: .black, textColor: UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1))
    let signInLabel = createLabel(text: "Sign in with email", fontSize: 14, weight: .medium, textColor: .lightGray)
    let emailTextField = createBottomLineTextField(placeholder: "Email", iconName: "envelope")
    let passwordTextField = createBottomLineTextField(placeholder: "Password", isSecure: true)
    let loginButton = createButton(title: "Login", fontSize: 18, fontWeight: .black, textColor: .white, applyStyle: true)
    let googleLoginButton = createSocialButton(imageName: "google48", title: "Login with Google", imageOffsetY: -7.0)
    let appleLoginButton = createSocialButton(imageName: "apple50", title: "Login with Apple", imageOffsetY: -5.0)
    let separatorView = createSeparatorView()
    let rememberMeButton = createCheckBoxButton(title: " Remember Me")
    let forgotPasswordButton = createButton(title: "Forgot your password?", fontSize: 14, fontWeight: .medium, textColor: .gray)
    let signUpButton = createAttributedButton(mainText: "Don't have an account? ", highlightedText: "Sign up", fontSize: 14, mainTextColor: .gray, highlightedTextColor: UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1))
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods

    /// 設置佈局
    private func setupLayout() {
        let rememberForgotStackView = UIStackView(arrangedSubviews: [rememberMeButton, forgotPasswordButton])
        rememberForgotStackView.axis = .horizontal
        rememberForgotStackView.distribution = .equalSpacing
        rememberForgotStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            signInLabel,
            emailTextField,
            passwordTextField,
            rememberForgotStackView,
            loginButton,
            separatorView,
            googleLoginButton,
            appleLoginButton,
            signUpButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 13
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        setViewHeights()
    }
    
    // 設置元件高度
    private func setViewHeights() {
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signInLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        googleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        appleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Factory Methods

    /// 圖片設置
    private static func creatImageView(imageName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    /// Label 設置
    private static func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor = .black) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 輸入欄
     private static func createBottomLineTextField(placeholder: String, isSecure: Bool = false, iconName: String? = nil) -> BottomLineTextField {
         let textField = BottomLineTextField()
         textField.placeholder = placeholder
         textField.isSecureTextEntry = isSecure
         textField.translatesAutoresizingMaskIntoConstraints = false
         
         if let iconName = iconName {
             let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
             let iconImage = UIImage(systemName: iconName, withConfiguration: configuration)
             let iconImageView = UIImageView(image: iconImage)
             iconImageView.tintColor = .gray
             iconImageView.contentMode = .scaleAspectFit
             iconImageView.translatesAutoresizingMaskIntoConstraints = false
             textField.rightView = iconImageView
             textField.rightViewMode = .always
             
             NSLayoutConstraint.activate([
                 iconImageView.widthAnchor.constraint(equalToConstant: 30),
                 iconImageView.heightAnchor.constraint(equalToConstant: 22)
             ])
         }
         
         return textField
     }
    
    /// 設置按鈕
    private static func createButton(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = .black, applyStyle: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        button.setTitleColor(textColor, for: .normal)
        
        if applyStyle {
            button.styleFilledButton()
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 與 Apple、google 按鈕外觀設置相關
    private static func createSocialButton(imageName: String, title: String, imageOffsetY: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true

        // 建立帶圖示、文字的 NSAttributedString
        let image = UIImage(named: imageName)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageOffsetY: CGFloat = imageOffsetY
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 25, height: 25)

        let fullString = NSMutableAttributedString()
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: "  \(title)", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]))

        button.setAttributedTitle(fullString, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// square 確認按鈕
    private static func createCheckBoxButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.tintColor = .gray
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    ///分隔線（Or continue with）
    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorStackView = UIStackView()
        separatorStackView.axis = .horizontal
        separatorStackView.alignment = .center
        separatorStackView.spacing = 3
        separatorStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let line1 = createLineView()
        let line2 = createLineView()
        let label = createSeparatorLabel(text: "Or continue with")
        
        separatorStackView.addArrangedSubview(line1)
        separatorStackView.addArrangedSubview(label)
        separatorStackView.addArrangedSubview(line2)
        
        view.addSubview(separatorStackView)

        NSLayoutConstraint.activate([
            separatorStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    /// 搭配分格線專用的 Label
    private static func createSeparatorLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 分格線
    private static func createLineView() -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 95).isActive = true
        return lineView
    }
    
    /// 設置密碼圖示
    func setPasswordTextFieldIcon(target: Any?, action: Selector?) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let eyeImage = UIImage(systemName: "eye", withConfiguration: configuration)
        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(eyeImage, for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.contentMode = .scaleAspectFit
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always

        guard let target = target, let action = action else { return }
        eyeButton.addTarget(target, action: action, for: .touchUpInside)

        NSLayoutConstraint.activate([
            eyeButton.widthAnchor.constraint(equalToConstant: 30),
            eyeButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
}
