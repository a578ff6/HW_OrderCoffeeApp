//
//  ProfileHeaderCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/29.
//

import UIKit

/// Section 0, Row 0 - 顯示大頭照、姓名、email 的自定義 Cell
class ProfileHeaderCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "ProfileHeaderCell"
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Elements
    let profileImageView = createImageView()
    let nameLabel = createLabel(fontSize: 18, weight: .medium, textColor: .black)
    let emailLabel = createLabel(fontSize: 13, weight: .regular, textColor: .gray)

    // MARK: - Layout Setup

    private func setupLayout() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Helper Functions

    private static func createLabel(fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        return label
    }
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightWhiteGray
        return imageView
    }
    
    // MARK: - Configuration Method

    func configure(profileImage: UIImage?, name: String, email: String) {
        profileImageView.image = profileImage
        nameLabel.text = name
        emailLabel.text = email
    }
    
}
