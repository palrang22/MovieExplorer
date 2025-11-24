//
//  MainMovieHeaderView.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit


final class MainMovieHeaderView: UICollectionReusableView {
    
    static let identifier = "MainMovieHeaderView"
    
    //MARK: UI Components
    private let titleLabel = UILabel()
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    //MARK: configure
    func configure(title: String) {
        titleLabel.text = title
    }
    
    //MARK: layout
    private func setLayout() {
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
}
