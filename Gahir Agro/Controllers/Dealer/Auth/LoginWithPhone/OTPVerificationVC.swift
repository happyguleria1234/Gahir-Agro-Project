//
//  OTPVerificationVC.swift
//  Gahir Agro
//
//  Created by Apple on 23/02/21.
//

import UIKit
import Firebase

class OTPVerificationVC: UIViewController  ,UITextFieldDelegate{
    
    @IBOutlet weak var numberButton: UIButton!
    @IBOutlet weak var textSixth: UITextField!
    @IBOutlet weak var textFifth: UITextField!
    @IBOutlet weak var textFour: UITextField!
    @IBOutlet weak var textTheww: UITextField!
    @IBOutlet weak var textTwo: UITextField!
    @IBOutlet weak var textOne: UITextField!
    var phoneNumber = String()
    var otpText = String()
    var message = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        getOtp()
        numberButton.setTitle(phoneNumber, for: .normal)
        
        if #available(iOS 12.0, *) {
            textOne.textContentType = .oneTimeCode
            textTwo.textContentType = .oneTimeCode
            textTheww.textContentType = .oneTimeCode
            textFour.textContentType = .oneTimeCode
            textFifth.textContentType = .oneTimeCode
            textSixth.textContentType = .oneTimeCode
        }
        
        textOne.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textTwo.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textTheww.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textFour.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textFifth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        textSixth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        
        self.view.resignFirstResponder()
    }
    
    //    MARK:- Get Otp
    
    func getOtp() {
        PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber, uiDelegate: nil) { (verificationID, error) in
            PKWrapperClass.svprogressHudShow(title: Constant.shared.appTitle, view: self)
            if let error = error {
                PKWrapperClass.svprogressHudDismiss(view: self)
                print(error.localizedDescription)
                if error.localizedDescription == "Invalid format."{
                    alert(Constant.shared.appTitle, message: "please enter valid phone number.", view: self)
                }else{
                    alert(Constant.shared.appTitle, message: error.localizedDescription, view: self)
                }
                
            }else{
                PKWrapperClass.svprogressHudDismiss(view: self)
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
            PKWrapperClass.svprogressHudDismiss(view: self)
        }
        PKWrapperClass.svprogressHudDismiss(view: self)
    }
    
    //    MARK:- Text Field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if  text?.count == 1 {
            switch textField{
            
            case textOne:
                textTwo.becomeFirstResponder()
                
            case textTwo:
                textTheww.becomeFirstResponder()
                
            case textTheww:
                textFour.becomeFirstResponder()
                
            case textFour:
                textFifth.becomeFirstResponder()
                
            case textFifth:
                textSixth.becomeFirstResponder()
                
            case textSixth:
                textSixth.becomeFirstResponder()
                self.dismissKeyboard()
            default:
                break
            }
        }
        if  text?.count == 0 {
            switch textField{
            case textOne:
                textOne.becomeFirstResponder()
            case textTwo:
                textOne.becomeFirstResponder()
            case textTheww:
                textTwo.becomeFirstResponder()
            case textFour:
                textTheww.becomeFirstResponder()
            case textFifth:
                textFour.becomeFirstResponder()
            case textSixth:
                textFifth.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            
        }
    }
    
    func dismissKeyboard(){
        
        self.otpText = "\(self.textOne.text ?? "")\(self.textTwo.text ?? "")\(self.textTheww.text ?? "")\(self.textFour.text ?? "")\(self.textFifth.text ?? "")\(self.textSixth.text ?? "")"
        
        print(self.otpText)
        self.view.endEditing(true)
        
    }
    
    //    MARK:- Button Action
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyButton(_ sender: Any) {
        let comesFrom = UserDefaults.standard.value(forKey: "comesFromPhoneLogin") as? Bool
        if comesFrom == false{
            
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: otpText)
            
            Auth.auth().signIn(with: credential) { (success, error) in
                if error == nil{
                    print(success ?? "")
                    let vc = SignUpVC.instantiate(fromAppStoryboard: .Auth)
                    vc.phoneNumber = self.phoneNumber
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    alert(Constant.shared.appTitle, message: error?.localizedDescription ?? "", view: self)
                }
            }
        }else{
            phoneLogin()
        }
    }
    
    //    MARK:- Resend Otp
    
    @IBAction func resendOtpButtonAction(_ sender: Any) {
        textOne.text = ""
        textTwo.text = ""
        textTheww.text = ""
        textFour.text = ""
        textFifth.text = ""
        textSixth.text = ""
        getOtp()
    }
    
    
    //    MARK:- Service Call Function
    
    func phoneLogin() {
        PKWrapperClass.svprogressHudShow(title: Constant.shared.appTitle, view: self)
        let url = Constant.shared.baseUrl + Constant.shared.PhoneLogin
        var deviceID = UserDefaults.standard.value(forKey: "deviceToken") as? String
        print(deviceID ?? "")
        if deviceID == nil  {
            deviceID = "777"
        }
        let params = ["phone": phoneNumber,"device_token": deviceID ?? "","device_type":"1"] as? [String : AnyObject] ?? [:]
        print(params)
        PKWrapperClass.requestPOSTWithFormData(url, params: params, imageData: []) { (response) in
            print(response.data)
            PKWrapperClass.svprogressHudDismiss(view: self)
            //            let signUpStatus = response.data["app_signup"] as? String ?? ""
            let status = response.data["status"] as? String ?? ""
            self.message = response.data["message"] as? String ?? ""
            UserDefaults.standard.setValue(response.data["access_token"] as? String ?? "", forKey: "accessToken")
            if status == "1"{
                UserDefaults.standard.set(true, forKey: "tokenFString")
                let allData = response.data as? [String:Any] ?? [:]
                let data = allData["user_detail"] as? [String:Any] ?? [:]
                print(data)
                UserDefaults.standard.set(1, forKey: "tokenFString")
                UserDefaults.standard.set(data["id"], forKey: "id")
                UserDefaults.standard.setValue(data["role"], forKey: "checkRole")
                UserDefaults.standard.setValue(data["serial_no"], forKey: "serialNumber")
                
                if data["role"] as? String ?? "" == "admin"{
                    DispatchQueue.main.async {
                        let story = UIStoryboard(name: "AdminMain", bundle: nil)
                        let rootViewController:UIViewController = story.instantiateViewController(withIdentifier: "AdminSideMenuControllerID")
                        self.navigationController?.pushViewController(rootViewController, animated: true)
                    }
                }else if data["role"] as? String ?? "" == "Sales"{
                    
                    DispatchQueue.main.async {
                        let story = UIStoryboard(name: "AdminMain", bundle: nil)
                        let rootViewController:UIViewController = story.instantiateViewController(withIdentifier: "AdminSideMenuControllerID")
                        self.navigationController?.pushViewController(rootViewController, animated: true)
                    }
                    
                }else if data["role"] as? String ?? "" == "Customer"{
                    DispatchQueue.main.async {
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let rootViewController:UIViewController = story.instantiateViewController(withIdentifier: "SideMenuControllerID")
                        self.navigationController?.pushViewController(rootViewController, animated: true)
                    }
                    
                }else if data["role"] as? String ?? "" == "Dealer"{
                    DispatchQueue.main.async {
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let rootViewController:UIViewController = story.instantiateViewController(withIdentifier: "SideMenuControllerID")
                        self.navigationController?.pushViewController(rootViewController, animated: true)
                    }
                }
            }else {
                alert(Constant.shared.appTitle, message: self.message, view: self)
            }
        } failure: { (error) in
            print(error)
            showAlertMessage(title: Constant.shared.appTitle, message: error as? String ?? "", okButton: "Ok", controller: self, okHandler: nil)
        }
    }
}
