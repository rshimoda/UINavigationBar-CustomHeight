//
//  ViewController.swift
//  Navigation Bar Height Test
//
//  Created by Sergi on 19/11/2019.
//  Copyright © 2019 Readdle. All rights reserved.
//

import UIKit
import RDAdjustableNavigationController

class ViewController: UIViewController {
    
    @IBAction func openDefaultNavBar(_ sender: UIBarButtonItem) {
        let navigationController = UINavigationController(rootViewController: CustomVC())
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func openCustomNavBar(_ sender: UIBarButtonItem) {
        let navigationController = RDAdjustableNavigationController(rootViewController: CustomVC())
        navigationController.useSystemHeight = false
        navigationController.navigationBarHeight = 100.0
        navigationController.contentVerticalAlignment = .bottom

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
