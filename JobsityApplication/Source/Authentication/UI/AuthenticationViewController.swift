//
//  AuthenticationViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.text = "Please enter your PIN"
        return label
    }()
    
    lazy var passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.keyboardType = .numberPad
        field.backgroundColor = .secondarySystemBackground
        field.font = .systemFont(ofSize: 32)
        field.inputAccessoryView = passwordToolbar
        return field
    }()
    
    lazy var passwordToolbar: UIToolbar = {
        let bar = UIToolbar()
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneTapped))
        bar.items = [spacing, done]
        bar.sizeToFit()
        return bar
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.backgroundColor = .systemBackground
    }
    
    @objc
    func handleDoneTapped() {
        passwordField.resignFirstResponder()
    }
    
}

extension AuthenticationViewController: ViewCodable {
    func setupViewHierarchy() {
        view.addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(instructionLabel)
        rootStackView.addArrangedSubview(passwordField)
    }
    
    func setupConstraints() {
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate {
            rootStackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
            
            rootStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
            
            rootStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            rootStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        }
    }
}
