//
//  CategoryCell.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/21/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol CategoryCellDelegate: class {
    func categoryCell(_ cell: CategoryCell, didMakeSelection selection: [String])
}

class CategoryCell: UITableViewCell, TagsSelectionDelegate
{
    static let verticalPadding: CGFloat = 8.0
    static let normalHeight: CGFloat = UIScreen.main.bounds.height * 0.155
    var expandedHeight: CGFloat = 0.0
    
    private var categoryImageView: UIImageView!
    private var categoryNameLabel: UILabel!
    private var categorySubtitleLabel: UILabel!
    private var selectedEffectView: UIView!
    
    var tagsView: TagsCollectionView!
    var chooseButton: UIButton!
    var anySelection: [String] = []
    
    weak var delegate: CategoryCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.isOpaque = true
        self.applyShadow(ofRadius: 8.0, andOpacity: 0.75)
        self.setupViews()
    }
    
    @objc private func chooseButtonPressed() {
        let selection = tagsView.selectedTags.isEmpty ? anySelection : tagsView.selectedTags.map { CategoriesDataSource.allSubcategories[$0]! }
        delegate?.categoryCell(self, didMakeSelection: selection)
    }
    
    func tagsSelectionDidChange() {
        chooseButton.setTitle(tagsView.selectedTags.isEmpty ? "Choose any" : "Choose selected", for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(category: CategoryInfo) {
        categoryImageView.image = UIImage(named: category.coverImageName)
        categoryNameLabel.text = category.title
        categorySubtitleLabel.text = category.subtitle
        tagsView.tags = [String](category.subcategories.keys.sorted())
        anySelection = category.anySelectionCategories
        tagsView.reloadData()
        tagsView.layoutIfNeeded()
        self.expandedHeight = 1.5 * CategoryCell.normalHeight + tagsView.contentSize.height + 36.0
    }
    
    private func setupViews() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        contentView.addSubview(view)
        let vc1 = view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CategoryCell.verticalPadding)
        vc1.priority = UILayoutPriorityDefaultHigh
        vc1.isActive = true
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        let vc2 = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CategoryCell.verticalPadding)
        vc2.priority = UILayoutPriorityDefaultHigh
        vc2.isActive = true
        
        let foregroundView = UIView()
        foregroundView.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.clipsToBounds = true
        view.addSubview(foregroundView)
        foregroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        foregroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        foregroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        foregroundView.heightAnchor.constraint(equalToConstant: CategoryCell.normalHeight).isActive = true
        
        let imageView = UIImageView(image: nil)
        imageView.isOpaque = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.addSubview(imageView)
        imageView.clipToSuperview()
        
        let overlay = UIView()
        overlay.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.addSubview(overlay)
        overlay.clipToSuperview()
        
        let subtitle = UILabel()
        subtitle.textAlignment = .left
        subtitle.textColor = .white
        subtitle.adjustsFontSizeToFitWidth = true
        subtitle.minimumScaleFactor = 0.5
        subtitle.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.addSubview(subtitle)
        subtitle.bottomAnchor.constraint(equalTo: foregroundView.bottomAnchor, constant: -10.0).isActive = true
        subtitle.leadingAnchor.constraint(equalTo: foregroundView.leadingAnchor, constant: 13.0).isActive = true
        subtitle.trailingAnchor.constraint(equalTo: foregroundView.trailingAnchor, constant: -13.0).isActive = true
        subtitle.layer.masksToBounds = false
        subtitle.layer.shadowOpacity = 1.0
        subtitle.layer.shadowRadius = 6.0
        subtitle.layer.shadowColor = UIColor.black.cgColor
        
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.flatLightTeal
        label.font = UIFont(name: "AvenirNext-Demibold", size: 28.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.addSubview(label)
        label.bottomAnchor.constraint(equalTo: subtitle.topAnchor, constant: 8.0).isActive = true
        label.leadingAnchor.constraint(equalTo: foregroundView.leadingAnchor, constant: 13.0).isActive = true
        label.trailingAnchor.constraint(equalTo: foregroundView.trailingAnchor, constant: -13.0).isActive = true
        
        label.layer.masksToBounds = false
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 6.0
        label.layer.shadowColor = UIColor.black.cgColor
        
        self.selectedEffectView = UIView()
        selectedEffectView.backgroundColor = UIColor.flatLightTeal
        selectedEffectView.alpha = 0.0
        selectedEffectView.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.addSubview(selectedEffectView)
        selectedEffectView.clipToSuperview()
        
        let expandedView = UIView()
        expandedView.backgroundColor = UIColor.flatLightTeal
        expandedView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(expandedView, belowSubview: foregroundView)
        
        let ec1 = expandedView.topAnchor.constraint(equalTo: foregroundView.bottomAnchor)
        ec1.priority = UILayoutPriorityDefaultLow
        ec1.isActive = true
        expandedView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        expandedView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        expandedView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        chooseButton = UIButton()
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        chooseButton.backgroundColor = TagsCollectionView.tagColor
        chooseButton.clipsToBounds = true
        chooseButton.layer.cornerRadius = 8.0
        chooseButton.setTitle("Choose any", for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseButtonPressed), for: .touchUpInside)
        expandedView.addSubview(chooseButton)
        chooseButton.bottomAnchor.constraint(equalTo: expandedView.bottomAnchor, constant: -12.0).isActive = true
        chooseButton.leadingAnchor.constraint(equalTo: expandedView.leadingAnchor, constant: 12.0).isActive = true
        chooseButton.trailingAnchor.constraint(equalTo: expandedView.trailingAnchor, constant: -12.0).isActive = true
        chooseButton.heightAnchor.constraint(equalToConstant: CategoryCell.normalHeight * 0.5).isActive = true
        
        tagsView = TagsCollectionView(frame: CGRect.zero)
        tagsView.selectionDelegate = self
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        expandedView.addSubview(tagsView)
        tagsView.topAnchor.constraint(equalTo: expandedView.topAnchor, constant: 12.0).isActive = true
        tagsView.bottomAnchor.constraint(equalTo: chooseButton.topAnchor, constant: -12.0).isActive = true
        tagsView.leadingAnchor.constraint(equalTo: expandedView.leadingAnchor, constant: 12.0).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: expandedView.trailingAnchor, constant: -12.0).isActive = true
        
        self.categoryImageView = imageView
        self.categoryNameLabel = label
        self.categorySubtitleLabel = subtitle
        
        contentView.layoutIfNeeded()
    }
}
