//
//  CategoriesTableView.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/21/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol CategorySelectionDelegate: class {
    func categoriesTableView(_ tableView: CategoriesTableView, didSelect selection: [String]?)
    func willExpandCategoryCell(_ tableView: CategoriesTableView)
}

class CategoriesTableView: UITableView
{
    fileprivate var cellHeights = [CGFloat](repeating: CategoryCell.normalHeight + 2 * CategoryCell.verticalPadding, count: 4)
    fileprivate var expandedRowIndexPath: IndexPath? = nil
    fileprivate static let defaultHeaderText = "What are you up to today?"
    fileprivate weak var menuBar: MenuBar?
    
    weak var categoriesSelectionDelegate: CategorySelectionDelegate?
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = CategoriesTableView.defaultHeaderText
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Demibold", size: 24.0)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(frame: CGRect, andMenuBar menuBar: MenuBar) {
        self.menuBar = menuBar
        super.init(frame: frame, style: .plain)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.separatorStyle = .none
        self.isScrollEnabled = false
        self.register(CategoryCell.self, forCellReuseIdentifier: String(describing: CategoryCell.self))
        self.delegate = self
        self.dataSource = self
        self.clipsToBounds = false
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 30.0))
        view.backgroundColor = .clear
        view.addSubview(headerLabel)
        
        headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        headerLabel.applyShadow(ofRadius: 8.0, andOpacity: 0.7)
        
        self.tableHeaderView = view
    }

    func collapse(completion: (() -> Void)?) {
        guard let indexPath = expandedRowIndexPath else { return }
        
        cellHeights[indexPath.row] = CategoryCell.normalHeight + 2 * CategoryCell.verticalPadding

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            self.beginUpdates()
            self.endUpdates()
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.expandedRowIndexPath = nil
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.beginUpdates()
                self.endUpdates()
            }, completion: { success in
                if let cell = self.cellForRow(at: indexPath) as? CategoryCell {
                    cell.tagsView.reloadData()
                    cell.chooseButton.setTitle("Choose any", for: .normal)
                }
                
                self.changeHeaderTextAnimated(to: CategoriesTableView.defaultHeaderText)
                self.menuBar?.showExtraLeftTabBarItem()
                self.menuBar?.showExtraRightTabBarItem()
                self.menuBar?.switchToNormalMode()
                completion?()
            })
        }
    }
    
    func changeHeaderTextAnimated(to text: String) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.headerLabel.alpha = 0.0
        }, completion: { success in
            self.headerLabel.text = text
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.headerLabel.alpha = 1.0
            }, completion: nil)
        })
    }
}

extension CategoriesTableView: CategoryCellDelegate {
    func categoryCell(_ cell: CategoryCell, didMakeSelection selection: [String]) {
        categoriesSelectionDelegate?.categoriesTableView(self, didSelect: selection)
    }
}

extension CategoriesTableView: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CategoryCell.self), for: indexPath) as! CategoryCell
        cell.setupCell(category: CategoriesDataSource.categoriesInfo[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (expandedRowIndexPath == nil || expandedRowIndexPath! == indexPath) ? cellHeights[indexPath.row] : 0.0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return expandedRowIndexPath == nil ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = cellForRow(at: indexPath) as? CategoryCell else { return }
        
        if self.expandedRowIndexPath == nil {
            categoriesSelectionDelegate?.willExpandCategoryCell(self)
            
            self.expandedRowIndexPath = indexPath
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.beginUpdates()
                self.endUpdates()
            }, completion: nil)
            
            self.menuBar?.hideExtraLeftTabBarItem()
            self.menuBar?.hideExtraRightTabBarItem()
            self.menuBar?.switchToSingleMode(withImage: UIImage(named: "close_icon")!.withRenderingMode(.alwaysTemplate), andAction: {
                self.categoriesSelectionDelegate?.categoriesTableView(self, didSelect: nil)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.cellHeights[indexPath.row] = min(cell.expandedHeight + 2 * CategoryCell.verticalPadding, self.frame.height - 30.0)
                
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                    self.beginUpdates()
                    self.endUpdates()
                }, completion: { success in
                    self.changeHeaderTextAnimated(to: "Choose up to 5 categories:")
                })
            }
        }
    }
}
