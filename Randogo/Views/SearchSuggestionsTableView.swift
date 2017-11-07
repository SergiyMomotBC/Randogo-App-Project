//
//  SearchSuggestionsTableView.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol SuggestionsDelegate: class {
    func didSelectSuggestion(_ suggestion: String)
}

class SuggestionCell: UITableViewCell {
    enum CellType {
        case top, middle, bottom, single
    }
    
    var type = CellType.middle
    var shape: CAShapeLayer?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: String(describing: UITableViewCell.self))
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        textLabel?.font = UIFont(name: "AvenirNext-Demibold", size: 18.0)
        textLabel?.textColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            var path: UIBezierPath
            
            switch type {
            case .top:
                path = UIBezierPath(roundedRect: self.contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 24, height: 24))
            case .middle:
                path = UIBezierPath(rect: self.contentView.bounds)
            case .bottom:
                path = UIBezierPath(roundedRect: self.contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 24, height: 24))
            case .single:
                 path = UIBezierPath(roundedRect: self.contentView.bounds, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 24, height: 24))
            }
            
            shape = CAShapeLayer()
            shape!.path = path.cgPath
            shape!.fillColor = UIColor(white: 1.0, alpha: 0.5).cgColor
            self.contentView.layer.addSublayer(shape!)
        } else {
            shape?.removeFromSuperlayer()
            shape = nil
        }
    }
}

class SearchSuggestionsTableView: UITableView
{
    fileprivate var suggestions: [String] = []
    fileprivate let maxSuggestions = 6
    fileprivate let initialFrame: CGRect
    fileprivate var isSearchBarEmpty: Bool = false
    
    var emptyStateText = ""
    var noSuggestionsStateText = "No suggestions..."
    
    weak var suggestionDelegate: SuggestionsDelegate?
    
    lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: "AvenirNext-Demibold", size: 24.0)
        label.textAlignment = .center
        return label
    }()
    
    init(frame: CGRect) {
        self.initialFrame = frame
        super.init(frame: frame, style: .plain)
        setupView()
        update(withSuggestions: [], isSearchBarEmpty: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.flatDarkTeal
        self.separatorStyle = .singleLine
        self.separatorInset = UIEdgeInsets.zero
        self.isScrollEnabled = false
        self.delegate = self
        self.dataSource = self
        self.layer.cornerRadius = 24.0
        self.clipsToBounds = true
        self.rowHeight = frame.height / CGFloat(maxSuggestions)
        self.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.0000001))
        self.register(SuggestionCell.self, forCellReuseIdentifier: String(describing: SuggestionCell.self))
        self.applyShadow(ofRadius: 8.0, andOpacity: 0.45)
    }
    
    func update(withSuggestions suggestions: [String], isSearchBarEmpty: Bool = false) {
        self.suggestions = suggestions
        self.isSearchBarEmpty = isSearchBarEmpty
        self.reloadData()
        
        if !suggestions.isEmpty {
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.width, height: self.rowHeight * CGFloat(min(suggestions.count, maxSuggestions))))
        } else {
            self.frame = initialFrame
        }
    }
}

extension SearchSuggestionsTableView: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if suggestions.isEmpty {
            backgroundView = emptyStateLabel
            separatorStyle = .none
            emptyStateLabel.text = isSearchBarEmpty ? emptyStateText : noSuggestionsStateText
            emptyStateLabel.sizeToFit()
            return 0
        } else {
            backgroundView = nil
            separatorStyle = .singleLine
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(suggestions.count, maxSuggestions)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: String(describing: SuggestionCell.self), for: indexPath) as! SuggestionCell
        
        cell.textLabel?.text = suggestions[indexPath.row]
        
        if indexPath.row == 0 && indexPath.row == min(suggestions.count, maxSuggestions) - 1 {
            cell.type = .single
        } else if indexPath.row == 0 {
            cell.type = .top
        } else if indexPath.row == min(suggestions.count, maxSuggestions) - 1 {
            cell.type = .bottom
        } else {
            cell.type = .middle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.deselectRow(at: indexPath, animated: true)
        suggestionDelegate?.didSelectSuggestion(suggestions[indexPath.row])
    }
}
