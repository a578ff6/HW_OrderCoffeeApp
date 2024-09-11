//
//  ColumnItemCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/28.
//

import UIKit
import Kingfisher

/// 列布局的 Cell（預設）
class ColumnItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ColumnItemCell"

    // MARK: - UI Elements

    let imageView = createImageView(cornerRadius: 15)
    let titleLabel = createLabel(fontSize: 16, numberOfLines: 1, textColor: .deepBrown, isBold: true)
    let subtitleNameLabel = createLabel(fontSize: 14, numberOfLines: 0, textColor: .gray, isBold: false)
    let stackView: UIStackView = createStackView(axis: .vertical, spacing: 4)
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup Methods
    
    /// 設置 Cell 外觀
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray                       // 設置 contentView 背景颜色
    }
    
    /// 配置 Cell 的視圖佈局
    private func setupViews() {
         contentView.addSubview(imageView)
         contentView.addSubview(stackView)
         
         stackView.addArrangedSubview(titleLabel)
         stackView.addArrangedSubview(subtitleNameLabel)
         
         NSLayoutConstraint.activate([
             // 垂直置中圖片
             imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
             imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 70),
             imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
             
             // 讓 stackView 中心與圖片的中心對齊
             stackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
             stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
         ])
     }
    
    // MARK: - Factory Methods

    private static func createLabel(fontSize: CGFloat, numberOfLines: Int, textColor: UIColor, isBold: Bool) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }

    private static func createImageView(cornerRadius: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    // MARK: - Configure Method

    /// 設置 飲品圖片、名稱、副名稱
    func configure(with drink: Drink) {
        imageView.kf.setImage(with: drink.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = drink.name
        subtitleNameLabel.text = drink.subName
    }
    
    // MARK: - Lifecycle Methods

    /// 重置圖片和文字
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        subtitleNameLabel.text = nil
    }
    
}


