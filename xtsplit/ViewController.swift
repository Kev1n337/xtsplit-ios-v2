//
//  ViewController.swift
//  xtsplit
//
//  Created by Kevin Linne on 22.02.17.
//  Copyright © 2017 XTsolutions. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SCLAlertView

class ViewController: UIViewController {

    @IBOutlet weak var triangleIndicator: UIImageView!
    @IBOutlet weak var googleButton: LeftAlignedIconButton!
    @IBOutlet weak var fbButton: LeftAlignedIconButton!
    @IBOutlet weak var loginButton: LeftAlignedIconButton!
    @IBOutlet weak var emailField: PaddingTextField!
    @IBOutlet weak var passwordField: PaddingTextField!
    @IBOutlet weak var loginTab: UIButton!
    @IBOutlet weak var registerTab: UIButton!
    @IBOutlet weak var trianglePadding: NSLayoutConstraint!
    
    
    @IBOutlet weak var errorView: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    private var login = true
    
    override func viewWillLayoutSubviews() {
        if login {
            trianglePadding.constant = loginTab.center.x - triangleIndicator.frame.width / 2
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional button styling
        fbButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        fbButton.titleLabel?.textAlignment = NSTextAlignment.center
        googleButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        googleButton.titleLabel?.textAlignment = NSTextAlignment.center
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        
        //registerTab.titleLabel?.textColor = UIColor.black
        
        self.hideKeyboardWhenTappedAround()
        
        if UserDefaults.standard.object(forKey: KEY_UID) != nil {
            //performSegue(withIdentifier: GROUP_SEGUE, sender: nil)
        }
        
        
        self.view.layoutIfNeeded()
        
        loginTab.setTitleColor(XT_BLUE, for: .normal)
        registerTab.setTitleColor(UIColor.black, for: .normal)
        view.layoutIfNeeded()
        
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightRecognized(gesture:)))
        self.view.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftRecognized(gesture:)))
        swipeLeftRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeLeftRecognizer)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showErrorAlert))
        errorLabel.addGestureRecognizer(tap)
        errorLabel.isUserInteractionEnabled = true
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func facebookLoginPressed(_ sender: Any) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if (result?.isCancelled)! {
                print("Cancelled")
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                print("Successfully logged in with Facebook. \(String(describing: accessToken))")
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken!)
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        print("Firebase login failed. \(String(describing: error))")
                    } else {
                        print("Logged in \(String(describing: user))")
                        
                        
                        let fireUser = ["provider": user!.providerID]
                        
                        FIRDatabase.database().reference().child("users").child(user!.uid).updateChildValues(fireUser)
                        
                        UserDefaults.standard.setValue(user?.uid, forKeyPath: "uid")
                        
                        self.performSegue(withIdentifier: GROUP_SEGUE, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func googleLoginPressed(_ sender: Any) {
    }
    
    @IBAction func loginTabPressed(_ sender: Any) {
        switchToLogin()
    }
    
    @IBAction func registerTabPressed(_ sender: Any) {
        switchToRegister()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if validInput() {
            print("VALID")
            if login {
                loginWith(email: emailField.text!, password: passwordField.text!)
            } else {
                registerWith(email: emailField.text!, password: passwordField.text!)
            }
        } else {
            print("NOT VALID")
        }
    }
    
    
    func switchToLogin(){
        loginTab.setTitleColor(XT_BLUE, for: .normal)
        registerTab.setTitleColor(UIColor.black, for: .normal)
        
        trianglePadding.constant = loginTab.center.x - triangleIndicator.frame.width / 2
        
        login = true
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func switchToRegister(){
        registerTab.setTitleColor(XT_BLUE, for: .normal)
        loginTab.setTitleColor(UIColor.black, for: .normal)
        
        trianglePadding.constant = registerTab.center.x - triangleIndicator.frame.width / 2
        
        login = false
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func swipeRightRecognized(gesture: UIGestureRecognizer) {
        switchToRegister()
    }
    
    func swipeLeftRecognized(gesture: UIGestureRecognizer) {
        switchToLogin()
    }

    
    func loginWith(email: String, password: String) {
        
    }
    
    func registerWith(email: String, password: String) {
        
    }
    
    func validInput() -> Bool {
        guard emailField != nil && emailField.text!.characters.count > 0 && passwordField != nil && passwordField.text!.characters.count > 0 else {
            print("Field nil")
            return false
        }
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        
        let passwordFormat = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordFormat)
        
        if emailPredicate.evaluate(with: emailField.text) {
            //errorLabel.text = "Email valid"
        } else {
            errorLabel.text = "Email ungültig"
            return false
        }
        
        if passwordPredicate.evaluate(with: passwordField.text) {
            errorLabel.text! += "Password valid"
        } else {
            errorLabel.text! = "Passwort muss 8 Zeichen, Buchstaben und ein Sonderzeichen enthalten"
            return false
        }
        return true
        
        
        
    }
    
    func showErrorAlert() {
        SCLAlertView().showError("Fehler beim Anmelden", subTitle: errorLabel.text!)
    }
    
}

