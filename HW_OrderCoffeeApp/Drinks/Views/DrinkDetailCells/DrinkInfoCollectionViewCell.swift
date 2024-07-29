//
//  DrinkInfoCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/12.
//

/*
 1. 佈局的更改：
        - 先前將imageView、nameLabel、subNameLabel、descriptionLabel放在同一個StakcView中，導致約束衝突。
 */

import UIKit
import Kingfisher

/// 展示飲品圖片、名稱、描述
class DrinkInfoCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkInfoCollectionViewCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    let subNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    let labelStackView: UIStackView = {
          let stackView = UIStackView()
          stackView.axis = .vertical
          stackView.spacing = 8
          stackView.distribution = .fill
          stackView.alignment = .fill
          return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 設置視圖
    private func setupViews() {
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(subNameLabel)
        labelStackView.addArrangedSubview(descriptionLabel)
        
        contentView.addSubview(imageView)
        contentView.addSubview(labelStackView)
    }
    
    /// 設置約束
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),          // 保持圖片寬高比例
            
            labelStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// 配置cell顯示的內容
    func configure(with drink: Drink) {
        imageView.kf.setImage(with: drink.imageUrl)
        nameLabel.text = drink.name
        subNameLabel.text = drink.subName
        descriptionLabel.text = drink.description
    }
}



