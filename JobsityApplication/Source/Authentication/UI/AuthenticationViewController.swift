//
//  AuthenticationViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import UIKit

protocol AuthenticationCoordinator: AnyObject {
    func loadContent()
}

class AuthenticationViewModel {
    
    enum Failure: Error {
        case invalidPassword
    }
    
    var isBiometryEnabled: Bool {
        authenticationDAO.isBiometryEnabled
    }
    
    private let authenticationDAO: AuthenticationDAO
    private weak var router: AuthenticationCoordinator?
    
    init(authenticationDAO: AuthenticationDAO = AuthenticationKeychainDAO.shared, router: AuthenticationCoordinator) {
        self.authenticationDAO = authenticationDAO
        self.router = router
    }
    
    @MainActor
    func callBiometry() {
        guard authenticationDAO.isBiometryEnabled else { return }
        Task {
            if await authenticationDAO.callBiometryAuthentication() {
                router?.loadContent()
            }
        }
    }
    
    func login(withPassoword password: String?) throws {
        if let password = password, authenticationDAO.validatePassword(value: password) {
            router?.loadContent()
        } else {
            throw Failure.invalidPassword
        }
    }
}

class AuthenticationViewController: UIViewController {
    
    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.keyboardType = .numberPad
        field.backgroundColor = .secondarySystemBackground
        field.font = .systemFont(ofSize: 24)
        field.inputAccessoryView = passwordToolbar
        field.placeholder = "Please enter your PIN"
        return field
    }()
    
    lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "Invalid password!!!"
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    lazy var passwordToolbar: UIToolbar = {
        let bar = UIToolbar()
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneTapped))
        bar.items = [spacing, done]
        bar.sizeToFit()
        return bar
    }()
    
    let viewModel: AuthenticationViewModel
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.callBiometry()
    }
    
    @objc
    func handleDoneTapped() {
        passwordField.resignFirstResponder()
        
        do {
            try viewModel.login(withPassoword: passwordField.text)
        } catch {
            displayError()
        }
    }
    
    func displayError() {
        UIView.animate(withDuration: 0.2, delay: .zero) { [weak self] in
            self?.instructionLabel.isHidden = false
        }
    }
}

extension AuthenticationViewController: ViewCodable {
    func setupViewHierarchy() {
        view.addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(passwordField)
        rootStackView.addArrangedSubview(instructionLabel)
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
