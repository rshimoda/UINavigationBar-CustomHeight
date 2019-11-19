//
//  ViewController.swift
//  Navigation Bar Height Test
//
//  Created by Sergi on 19/11/2019.
//  Copyright © 2019 Readdle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func openDefaultNavBar(_ sender: UIBarButtonItem) {
        let navigationController = UINavigationController(rootViewController: CustomVC())
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func openCustomNavBar(_ sender: UIBarButtonItem) {
        let navigationController = CustomNavVC(rootViewController: CustomVC())
        navigationController.navigationBarHeight = 72.0
        navigationController.contentVerticalAlignment = .middle

        if (sender.title == "Automatic") {
            navigationController.modalPresentationStyle = .automatic
        }
        else {
            navigationController.modalPresentationStyle = .fullScreen
        }
        
        let navigationBar = navigationController.navigationBar
        navigationBar.tintColor = .systemRed
        navigationBar.barTintColor = .systemGreen
        
        present(navigationController, animated: true, completion: nil)
    }
    
    
    
}

class CustomVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupContent()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Custom Bar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))
    }
    
    private func setupContent() {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // mark: -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    // mark: -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = "\(indexPath.item)"
        
        return cell
    }
    
    // mark: -
    
    @objc
    func actionDone() {
        dismiss(animated: true, completion: nil)
    }
}

class CustomNavVC: UINavigationController {
    
    private var defaultNavigationBarHeight: CGFloat {
        return customNavBar?.defaultHeight ?? 44.0
    }
    private var _navigationBarHeight: CGFloat?
    
    // mark: -
    
    var contentVerticalAlignment: CustomNBContentVerticalAlignment {
        get {
            return customNavBar?.contentVerticalAlignment ?? .middle
        }
        set {
            customNavBar?.contentVerticalAlignment = newValue
        }
    }
    
    var navigationBarHeight: CGFloat {
        get {
            return _navigationBarHeight ?? defaultNavigationBarHeight
        }
        set {
            guard _navigationBarHeight != newValue else {
                return
            }
            
            _navigationBarHeight = newValue
            customNavBar?.customHeight = newValue
            
            let topAdditionalSafeAreaInset = max(0.0, newValue - defaultNavigationBarHeight)
            self.additionalSafeAreaInsets = .init(top: topAdditionalSafeAreaInset, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    private var customNavBar: CustomNB? {
        return navigationBar as? CustomNB
    }
    
    // mark: -
    
    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: CustomNB.self, toolbarClass: UIToolbar.self)
        viewControllers = [rootViewController]
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        fatalError("init(navigationBarClass:toolbarClass:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // mark: -
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let customNavBar = customNavBar else {
            return
        }
        
        customNavBar.topOffset = customNavBar.preferredTopOffset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let customNavBar = customNavBar else {
            return
        }
        
        let navigationBarFrame = customNavBar.frame
        let navigationBarTopOffset = customNavBar.topOffset
        navigationBar.frame = .init(x: navigationBarFrame.minX, y: navigationBarTopOffset, width: navigationBarFrame.width, height: navigationBarHeight)
    }
    
    // mark: -

    enum CustomNBContentVerticalAlignment {
        case top
        case middle
        case bottom
    }
    
    
    
    // mark: -
    
    private class CustomNB: UINavigationBar {
        
        var useSystemHeight = true {
            didSet {
                guard oldValue != useSystemHeight else {
                    return
                }
                setNeedsLayout()
            }
        }
        
        var contentVerticalAlignment: CustomNBContentVerticalAlignment = .middle {
            didSet {
                guard oldValue != contentVerticalAlignment else {
                    return
                }
                setNeedsLayout()
            }
        }
        
        var defaultHeight: CGFloat {
            guard let window = self.window else {
                return 44.0
            }
            
            let defaultSizeThatFits = super.sizeThatFits(window.bounds.size)
            return defaultSizeThatFits.height
        }
        
        var customHeight: CGFloat = 44.0 {
            didSet {
                guard oldValue != customHeight else {
                    return
                }
                setNeedsLayout()
            }
        }
        
        var preferredTopOffset: CGFloat {
            let topOffset: CGFloat

            let statusBarFrame: CGRect
            if #available(iOS 13.0, *) {
                statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
            }
            else {
                statusBarFrame = UIApplication.shared.statusBarFrame
            }

            if let superview = superview,
               let superviewFrameInWindowCoordinates = window?.convert(superview.bounds, from: superview) {
                topOffset = superviewFrameInWindowCoordinates.intersects(statusBarFrame) ? statusBarFrame.height : 0.0
            }
            else {
                topOffset = 0.0
            }
            
            return topOffset
        }
        
        var topOffset: CGFloat = 0.0 {
            didSet {
                guard oldValue != topOffset else {
                    return
                }
                setNeedsLayout()
            }
        }
        
        // mark: -
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let defaultValue = super.sizeThatFits(size)
            
            guard useSystemHeight == false else {
                return defaultValue
            }
            
            let width = self.window?.bounds.width ?? defaultValue.width
            let height = customHeight
            
            return CGSize(width: width, height: height)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard useSystemHeight == false else {
                return
            }
            
            let defaultHeight = self.defaultHeight
            
            for subview in self.subviews {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                
                if stringFromClass.contains("BarBackground") {
                    subview.frame = CGRect(x: subview.frame.minX, y: -topOffset, width: bounds.width, height: customHeight + topOffset)
                }
                else if stringFromClass.contains("BarContent") {
                    let barContentViewMinY: CGFloat
                    let barContentHeight: CGFloat
                    
                    switch contentVerticalAlignment {
                    case .top:
                        barContentViewMinY = 0.0
                        barContentHeight = customHeight
                        
                    case .middle:
                        barContentViewMinY = (customHeight - defaultHeight) / 2.0
                        barContentHeight = defaultHeight
                        
                    case .bottom:
                        barContentViewMinY = customHeight - defaultHeight
                        barContentHeight = defaultHeight
                    }
                    
                    subview.frame = CGRect(x: subview.frame.minX, y: barContentViewMinY, width: subview.bounds.width, height: barContentHeight)
                }
            }
        }
    }
}
