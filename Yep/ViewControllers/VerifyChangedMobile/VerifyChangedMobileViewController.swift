//
//  VerifyChangedMobileViewController.swift
//  Yep
//
//  Created by NIX on 16/5/4.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import UIKit
import YepKit
import YepNetworking
import Ruler
import RxSwift
import RxCocoa

final class VerifyChangedMobileViewController: BaseVerifyMobileViewController {

    deinit {
        println("deinit VerifyChangedMobile")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = NavigationTitleLabel(title: String.trans_titleChangeMobile)

        nextButton.title = NSLocalizedString("Submit", comment: "")

        verifyMobileNumberPromptLabel.text = NSLocalizedString("Input verification code sent to", comment: "")
    }

    override func requestCallMe() {

        sendVerifyCodeOfNewMobile(mobile, withAreaCode: areaCode, useMethod: .Call, failureHandler: { [weak self] reason, errorMessage in
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)

            self?.requestCallMeFailed(errorMessage)

        }, completion: { success in
            println("sendVerifyCodeOfNewMobile .Call \(success)")
        })
    }

    override func next() {
        confirmNewMobile()
    }

    private func confirmNewMobile() {

        view.endEditing(true)

        guard let verifyCode = verifyCodeTextField.text else {
            return
        }

        YepHUD.showActivityIndicator()

        comfirmNewMobile(mobile, withAreaCode: areaCode, verifyCode: verifyCode, failureHandler: { (reason, errorMessage) in
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)

            YepHUD.hideActivityIndicator()

            SafeDispatch.async { [weak self] in
                self?.nextButton.enabled = false
            }

            let errorMessage = errorMessage ?? ""

            YepAlert.alertSorry(message: errorMessage, inViewController: self, withDismissAction: {
                SafeDispatch.async { [weak self] in
                    self?.verifyCodeTextField.text = nil
                    self?.verifyCodeTextField.becomeFirstResponder()
                }
            })

        }, completion: {
            YepHUD.hideActivityIndicator()

            SafeDispatch.async { [weak self] in
                if let strongSelf = self {
                    YepUserDefaults.areaCode.value = strongSelf.areaCode
                    YepUserDefaults.mobile.value = strongSelf.mobile
                }
            }

            YepAlert.alert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("You have successfully updated your mobile for Yep! For now on, using the new number to login.", comment: ""), dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: self, withDismissAction: { [weak self] in

                self?.performSegueWithIdentifier("unwindToEditProfile", sender: nil)
            })
        })
    }
}

