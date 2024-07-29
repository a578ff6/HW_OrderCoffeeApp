//
//  OrderSummaryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/12.
//


import UIKit

/// 展示訂單的總金額、準備時間
class OrderSummaryCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderSummaryCollectionViewCell"
    
    let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    let totalAmountValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let totalPrepTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    
    let totalPrepTimeValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
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
    
    private func setupViews() {
        let totalAmountStackView = createLabelStackView(titleLabel: totalAmountLabel, valueLabel: totalAmountValueLabel, icon: UIImage(systemName: "dollarsign.circle"))
        let totalPrepTimeStackView = createLabelStackView(titleLabel: totalPrepTimeLabel, valueLabel: totalPrepTimeValueLabel, icon: UIImage(systemName: "clock"))

        let stackView = UIStackView(arrangedSubviews: [totalAmountStackView, totalPrepTimeStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        guard let stackView = contentView.subviews.first as? UIStackView else { return }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    private func createLabelStackView(titleLabel: UILabel, valueLabel: UILabel, icon: UIImage?) -> UIStackView {
        let iconImageView = UIImageView(image: icon)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let titleStackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 4
        titleStackView.alignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [titleStackView, valueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 6
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        return stackView
    }
    
    func configure(totalAmount: Int, totalPrepTime: Int) {
        totalAmountLabel.text = "總金額"
        totalAmountValueLabel.text = "$ \(totalAmount)"

        totalPrepTimeLabel.text = "準備時間"
        totalPrepTimeValueLabel.text = "\(totalPrepTime) min"
    }
}


