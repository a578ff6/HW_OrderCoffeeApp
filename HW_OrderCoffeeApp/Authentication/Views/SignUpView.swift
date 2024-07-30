//
//  SignUpView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/18.
//



/*
 1. 實現使用者在點擊查看「註冊須知連結」後才能點擊「確認框」並完成註冊：
        * 在 SignUpViewController 設置 didViewTerms 來追蹤使用者是否點擊了「註冊須知連結」。
        * 禁用「確認框」，直到使用者點擊「註冊須知連結」。
        * 在使用者點擊「註冊須知連結」後啟用「確認框」。
        * 在檢查「確認框」是否被選中後再允許使用者進行註冊！！
 */


// MARK: - 備份（已經完成確認框）
import UIKit

/// 處理 SignUpViewController 相關 UI元件 佈局
class SignUpView: UIView {
    
    // MARK: - UI Elements
    
    let titleLabel = createLabel(text: "Sign up for an account", fontSize: 28, weight: .black, textColor: .deepGreen)
    let signUpLabel = createLabel(text: "Sign up with email", fontSize: 14, weight: .medium, textColor: .lightGray)
    
    let fullNameLabel = createLabel(text: "Full Name", fontSize: 14, weight: .medium, textColor: .darkGray)
    let fullNameTextField = createBottomLineTextField(placeholder: "Full Name", iconName: "person.fill")
    
    let emailLabel = createLabel(text: "Email", fontSize: 14, weight: .medium, textColor: .darkGray)
    let emailTextField = createBottomLineTextField(placeholder: "Email", iconName: "envelope")
    
    let passwordLabel = createLabel(text: "Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    let passwordTextField = createBottomLineTextField(placeholder: "Password", isSecure: true, textContentType: .newPassword)
    
    let confirmPasswordLabel = createLabel(text: "Confirm Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    let confirmPasswordTextField = createBottomLineTextField(placeholder: "Confirm Password", isSecure: true, textContentType: .newPassword)
    
    /// 確認框
    let termsCheckBox = createCheckBoxButton(title: " I agree to the terms")
    /// 註冊須知連結
    let termsButton = createAttributedButton(mainText: "", highlightedText: "Read the terms", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)

    let signUpButton = createFilledButton(title: "Sign Up", fontSize: 18, fontWeight: .black, textColor: .white)
    let separatorView = createSeparatorView()
    
    let googleLoginButton = createSocialButton(imageName: "google48", title: "Sign Up with Google", imageOffsetY: -7.0)
    let appleLoginButton = createSocialButton(imageName: "apple50", title: "Sign Up with Apple", imageOffsetY: -5.0)

    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        termsCheckBox.isEnabled = false  // 初始化的時候禁用「確認框」
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Private Methods
    
    private func setupLayout() {
        let fullNameStack = SignUpView.createLabelTextFieldStack(label: fullNameLabel, textField: fullNameTextField)
        let emailStack = SignUpView.createLabelTextFieldStack(label: emailLabel, textField: emailTextField)
        let passwordStack = SignUpView.createLabelTextFieldStack(label: passwordLabel, textField: passwordTextField)
        let confirmPasswordStack = SignUpView.createLabelTextFieldStack(label: confirmPasswordLabel, textField: confirmPasswordTextField)
        let termsStackView = createTermsStackView()
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            signUpLabel,
            fullNameStack,
            emailStack,
            passwordStack,
            confirmPasswordStack,
            termsStackView,
            signUpButton,
            separatorView,
            googleLoginButton,
            appleLoginButton
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
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        setViewHeights()
    }

    /// 設置元件高度
    private func setViewHeights() {
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signUpLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        fullNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        googleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        appleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    /// 設置 「確認框」、「注意須知連結按鈕」
    private func createTermsStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [termsCheckBox, termsButton])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// Label 與 TedtField 的 StackView
    private static func createLabelTextFieldStack(label: UILabel, textField: UITextField) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    
    /// 設置底線的 TextField
    private static func createBottomLineTextField(placeholder: String, isSecure: Bool = false, textContentType: UITextContentType? = nil, iconName: String? = nil) -> BottomLineTextField {
        let textField = BottomLineTextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.textContentType = textContentType
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

    /// 設置自訂的顏色按鈕
    private static func createFilledButton(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .bold, textColor: UIColor = .white) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        button.setTitleColor(textColor, for: .normal)
        button.styleFilledButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 分隔線（Or SignUp with）
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
        let label = createSeparatorLabel(text: "Or Sign Up with")
        
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
    
    /// 設置密碼或確認密碼欄位的眼睛圖示
    func setPasswordOrConfirmPasswordTextFieldIcon(for textField: UITextField, target: Any?, action: Selector?) {
         let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
         let eyeImage = UIImage(systemName: "eye", withConfiguration: configuration)
         let eyeButton = UIButton(type: .system)
         eyeButton.setImage(eyeImage, for: .normal)
         eyeButton.tintColor = .gray
         eyeButton.contentMode = .scaleAspectFit
         eyeButton.translatesAutoresizingMaskIntoConstraints = false
         textField.rightView = eyeButton
         textField.rightViewMode = .always
         
         guard let target = target, let action = action else { return }
         eyeButton.addTarget(target, action: action, for: .touchUpInside)
         
         NSLayoutConstraint.activate([
             eyeButton.widthAnchor.constraint(equalToConstant: 30),
             eyeButton.heightAnchor.constraint(equalToConstant: 22)
         ])
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
}




