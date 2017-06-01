//
//  LoginController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/27/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    lazy var logoContainerView: UIView = {
        let view = UIView()
        
        // Lendify logo
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "lendify-logo"))
        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        // Center the logo in the view.
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Light blue color
        view.backgroundColor = UIColor.rgb(red: 111, green: 208, blue: 243)
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email..."
        textField.backgroundColor = UIColor(white: 0, alpha: 0.02)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password..."
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.02)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return textField
    }()
    
    func handleTextInputChange() {
        let isFormValid = emailTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.alpha = 1
            loginButton.backgroundColor = topBarBackgroundColor
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
            loginButton.backgroundColor = topBarBackgroundColor
        }
    }
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.5
        button.backgroundColor = topBarBackgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Log In", for: .normal)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {(user, err) in
            if let err = err {
                print("Failed to sign in with email", err.localizedDescription)
                return
            }
            
            print("Successfully logged back in with user:", user?.uid ?? "")
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign Up", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = appBackgroundColor
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 160)
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 160)
        
    }
}
