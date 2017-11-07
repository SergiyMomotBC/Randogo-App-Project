//
//  TagsCollectionView.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/26/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol TagsSelectionDelegate: class {
    func tagsSelectionDidChange()
}

class TagCell: UICollectionViewCell {
    let tagLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = TagsCollectionView.tagFont
        label.textColor = TagsCollectionView.tagColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(tagLabel)
        tagLabel.centerInSuperview()
        
        contentView.layer.cornerRadius = contentView.frame.height / 2
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = TagsCollectionView.tagColor.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? TagsCollectionView.tagColor : .clear
            tagLabel.textColor = isSelected ? .white : TagsCollectionView.tagColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TagsCollectionView: UICollectionView {
    static let tagColor = UIColor.flatDarkTeal
    static let tagFont = UIFont(name: "AvenirNext-Regular", size: 16.0)!
    
    weak var selectionDelegate: TagsSelectionDelegate?
    
    var selectedTags: [String] = []
    var tags: [String] = []
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: CenterAlignedCollectionViewFlowLayout())
        
        register(TagCell.self, forCellWithReuseIdentifier: String(describing: TagCell.self))
        backgroundColor = .clear
        delegate = self
        dataSource = self
        allowsMultipleSelection = true
        bounces = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        super.reloadData()
        selectedTags.removeAll()
        self.setContentOffset(.zero, animated: false)
    }
}

extension TagsCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: TagCell.self), for: indexPath) as! TagCell
        cell.tagLabel.text = tags[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (tags[indexPath.row] as NSString).size(attributes: [NSFontAttributeName: TagsCollectionView.tagFont])
        return CGSize(width: size.width + 20.0, height: size.height + 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return self.selectedTags.count < 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTags.append(tags[indexPath.row])
        selectionDelegate?.tagsSelectionDidChange()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedTags.index(of: tags[indexPath.row]) {
            selectedTags.remove(at: index)
        }
        selectionDelegate?.tagsSelectionDidChange()
    }
}
