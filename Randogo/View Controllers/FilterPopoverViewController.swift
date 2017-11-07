//
//  FilterPopoverViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/10/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import TGPControls
import MultiSelectSegmentedControl

protocol FilterPopoverViewControllerDelegate: class {
    func filterController(_ filterController: FilterPopoverViewController, didCommitChanges changes: Bool)
}

struct FilterOptions {
    let prices: [Int]
    var distance: Double
    
    init() {
        if let distance = UserDefaults.standard.object(forKey: FilterPopoverViewController.userDefaultDistanceIndexKey) as? Int {
            self.distance = FilterPopoverViewController.distanceValues[distance]
        } else {
            self.distance = FilterPopoverViewController.distanceValues[FilterPopoverViewController.defaultDistanceIndex]
            UserDefaults.standard.set(FilterPopoverViewController.defaultDistanceIndex, forKey: FilterPopoverViewController.userDefaultDistanceIndexKey)
        }
        
        if let prices = UserDefaults.standard.array(forKey: FilterPopoverViewController.userDefaultPricesKey) as? [Int] {
            self.prices = prices
        } else {
            self.prices = FilterPopoverViewController.defaultPrices
            UserDefaults.standard.set(FilterPopoverViewController.defaultPrices, forKey: FilterPopoverViewController.userDefaultPricesKey)
        }
    }
    
    init(prices: [Int], distance: Double) {
        self.distance = distance
        self.prices = prices
    }
}

class FilterPopoverViewController: UIViewController {
    static let defaultDistanceIndex = 3
    static let defaultPrices = [1, 2, 3]
    static let distanceValues = [0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0]
    
    static let userDefaultDistanceIndexKey = "userDefaultDistanceIndex"
    static let userDefaultPricesKey = "userDefaultPrices"
    
    lazy var distanceSlider: TGPDiscreteSlider = {
        let slider = TGPDiscreteSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.backgroundColor = .clear
        slider.minimumValue = 0.0
        slider.tickCount = 8
        slider.incrementValue = 1
        slider.tickStyle = 2
        slider.minimumTrackTintColor = UIColor.flatDarkTeal
        slider.maximumTrackTintColor = UIColor.lightGray
        slider.tintColor = .white
        slider.trackThickness = 10.0
        slider.tickSize = CGSize(width: 7.0, height: 7.0)
        slider.addTarget(self, action: #selector(distanceValueChanged), for: .valueChanged)
        return slider
    }()
    
    lazy var labels: TGPCamelLabels = {
        let labels = TGPCamelLabels()
        labels.translatesAutoresizingMaskIntoConstraints = false
        labels.downFontName = "AvenirNext-Regular"
        labels.downFontColor = UIColor.white
        labels.downFontSize = 14.0
        labels.upFontName = "AvenirNext-Demibold"
        labels.upFontColor = UIColor.flatDarkTeal
        labels.upFontSize = 18.0
        labels.names = ["1/4", "1/2", "3/4", "1", "2", "3", "4", "5"]
        return labels
    }()
    
    lazy var priceRangeSelector: MultiSelectSegmentedControl = {
        let control = MultiSelectSegmentedControl(items: ["$", "$$", "$$$", "$$$$"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = UIColor.flatDarkTeal
        control.delegate = self
        return control
    }()
    
    lazy var buttons: UIStackView = {
        func createButton(withTitle title: String) -> UIButton {
            let button = UIButton()
            button.setTitleColor(UIColor.flatPurple, for: .normal)
            button.setTitleColor(UIColor.gray, for: .highlighted)
            button.setTitleColor(UIColor.lightGray, for: .disabled)
            button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            button.setTitle(title, for: .normal)
            return button
        }
        
        let resetButton = createButton(withTitle: "Reset to defaults")
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        
        self.applyButton = createButton(withTitle: "Apply")
        self.applyButton.titleLabel?.font = UIFont(name: "AvenirNext-Demibold", size: 20.0)
        self.applyButton.addTarget(self, action: #selector(apply), for: .touchUpInside)
        
        self.saveButton = createButton(withTitle: "Save as defaults")
        self.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [resetButton, self.applyButton, self.saveButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = UIStackViewAlignment.bottom
        
        return stack
    }()
    
    fileprivate var applyButton: UIButton!
    fileprivate var saveButton: UIButton!
    var currentOptions = FilterOptions()
    weak var delegate: FilterPopoverViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.flatLightTeal
        view.isOpaque = true
        
        let headerLabel = createLabel(font: UIFont(name: "AvenirNext-Demibold", size: 24.0)!, alignment: .center)
        headerLabel.text = "Filter Options"
        view.addSubview(headerLabel)
        headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12.0).isActive = true
        
        let distanceHeaderLabel = createLabel(font: UIFont(name: "AvenirNext-Demibold", size: 18.0)!, alignment: .left)
        distanceHeaderLabel.text = "Distance (in miles):"
        view.addSubview(distanceHeaderLabel)
        distanceHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.0).isActive = true
        distanceHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18.0).isActive = true
        distanceHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18.0).isActive = true
        
        let line1 = createLine()
        view.addSubview(line1)
        line1.topAnchor.constraint(equalTo: distanceHeaderLabel.bottomAnchor, constant: 0.0).isActive = true
        line1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0).isActive = true
        line1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0).isActive = true
        
        view.addSubview(labels)
        labels.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0).isActive = true
        labels.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0).isActive = true
        labels.topAnchor.constraint(equalTo: distanceHeaderLabel.bottomAnchor, constant: 12.0).isActive = true
        labels.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        distanceSlider.ticksListener = labels
        view.addSubview(distanceSlider)
        distanceSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0).isActive = true
        distanceSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0).isActive = true
        distanceSlider.topAnchor.constraint(equalTo: labels.bottomAnchor, constant: -10.0).isActive = true
        distanceSlider.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        let priceHeaderLabel = createLabel(font: UIFont(name: "AvenirNext-Demibold", size: 18.0)!, alignment: .left)
        priceHeaderLabel.text = "Price categories (if applicable):"
        view.addSubview(priceHeaderLabel)
        priceHeaderLabel.topAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 12.0).isActive = true
        priceHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18.0).isActive = true
        priceHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18.0).isActive = true
        
        let line2 = createLine()
        view.addSubview(line2)
        line2.topAnchor.constraint(equalTo: priceHeaderLabel.bottomAnchor, constant: 0.0).isActive = true
        line2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0).isActive = true
        line2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0).isActive = true
        
        view.addSubview(priceRangeSelector)
        priceRangeSelector.topAnchor.constraint(equalTo: line2.bottomAnchor, constant: 12.0).isActive = true
        priceRangeSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18.0).isActive = true
        priceRangeSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18.0).isActive = true
        priceRangeSelector.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        view.addSubview(buttons)
        buttons.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12.0).isActive = true
        buttons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0).isActive = true
        buttons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0).isActive = true
        buttons.topAnchor.constraint(equalTo: priceRangeSelector.bottomAnchor, constant: 8.0).isActive = true
    }
    
    func prepare() {
        self.applyButton.isEnabled = false
        self.distanceSlider.value = CGFloat(FilterPopoverViewController.distanceValues.index(of: self.currentOptions.distance)!)
        self.labels.value = UInt(self.distanceSlider.value)
        self.priceRangeSelector.selectedSegmentIndexes = IndexSet(currentOptions.prices.map{ $0 - 1 }) as NSIndexSet
    }
    
    @objc private func reset() {
        self.distanceSlider.value = CGFloat(FilterPopoverViewController.defaultDistanceIndex)
        self.labels.value = UInt(self.distanceSlider.value)
        self.priceRangeSelector.selectedSegmentIndexes = IndexSet(FilterPopoverViewController.defaultPrices.map{ $0 - 1 }) as NSIndexSet
        self.save()
        self.applyButton.isEnabled = true
    }
    
    @objc private func apply() {
        self.currentOptions = FilterOptions(prices: [Int](priceRangeSelector.selectedSegmentIndexes as IndexSet).map{ $0 + 1 },
                                            distance: FilterPopoverViewController.distanceValues[Int(distanceSlider.value)])
        self.delegate?.filterController(self, didCommitChanges: true)
    }
    
    @objc private func save() {
        UserDefaults.standard.set(Int(distanceSlider.value), forKey: FilterPopoverViewController.userDefaultDistanceIndexKey)
        UserDefaults.standard.set([Int](priceRangeSelector.selectedSegmentIndexes as IndexSet).map{ $0 + 1 }, forKey: FilterPopoverViewController.userDefaultPricesKey)
        self.saveButton.isEnabled = false
    }
    
    private func createLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        return view
    }
    
    private func createLabel(font: UIFont, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = .white
        label.textAlignment = alignment
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }
    
    @objc private func distanceValueChanged() {
        self.applyButton.isEnabled = true
        self.saveButton.isEnabled = true
    }
}

extension FilterPopoverViewController: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, at index: UInt) {
        self.applyButton.isEnabled = true
        self.saveButton.isEnabled = true
        
        if !value && multiSelecSegmendedControl.selectedSegmentIndexes.count == 0 {
            multiSelecSegmendedControl.selectedSegmentIndexes = NSIndexSet(index: Int(index))
        }
    }
}
