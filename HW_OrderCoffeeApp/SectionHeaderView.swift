//
//  SectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/20.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
        
    static let headerIdentifier = "SectionHeaderView" 

    
    let titlelabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        titlelabel.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        addSubview(titlelabel)
        
        NSLayoutConstraint.activate([
            titlelabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titlelabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titlelabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titlelabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
}


