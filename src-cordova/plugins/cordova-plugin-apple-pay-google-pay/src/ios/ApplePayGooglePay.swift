//
//  ApplePayGooglePay.swift
//
//
//  Created by Oleksii on 11.01.2021.
//  Modified by Lazin Danil 02.09.2021

import Foundation
import PassKit

@objc(ApplePayGooglePay) class ApplePayGooglePay : CDVPlugin, PKPaymentAuthorizationViewControllerDelegate {
    var paymentCallbackId : String?
    var successfulPayment = false

    /**
     * Check device for ApplePay capability
     */
    @objc(canMakePayments:) func canMakePayments(command: CDVInvokedUrlCommand){
        let callbackID = command.callbackId;

        let canMakePayments = PKPaymentAuthorizationViewController.canMakePayments()

        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: canMakePayments)
        commandDelegate.send(result, callbackId: callbackID)
    }

    /**
     * Request payment token
     */
    @objc(makePaymentRequest: ) func makePaymentRequest(command: CDVInvokedUrlCommand){
        self.paymentCallbackId = command.callbackId;

        do {
            let countryCode = try getFromRequest(fromArguments: command.arguments, key: "countryCode") as! String
            let currencyCode = try getFromRequest(fromArguments: command.arguments, key: "currencyCode") as! String
            let merchantId = try getFromRequest(fromArguments: command.arguments, key: "merchantId") as! String

            let request = PKPaymentRequest()
            request.merchantIdentifier = merchantId
            request.supportedNetworks = [.visa, .masterCard, .amex, .chinaUnionPay]
            request.merchantCapabilities = .capability3DS
            request.countryCode = countryCode
            request.currencyCode = currencyCode

            let payPurpose = try getFromRequest(fromArguments: command.arguments, key: "purpose") as! String

            let amount = try getFromRequest(fromArguments: command.arguments, key: "amount") as! NSNumber
            let nsamount = NSDecimalNumber(decimal: amount.decimalValue);

            request.paymentSummaryItems = [PKPaymentSummaryItem(label: payPurpose, amount: nsamount)]

            if let c = PKPaymentAuthorizationViewController(paymentRequest: request) {
                c.delegate = self
                viewController.present(c, animated: true)
            }
        } catch ValidationError.missingArgument(let message) {
            failWithError(message)
        } catch {
            failWithError(error.localizedDescription)
        }
    }

    private func failWithError(_ error: String){
        let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
        commandDelegate.send(result, callbackId: paymentCallbackId)
    }

    private func getFromRequest(fromArguments arguments: [Any]?, key: String) throws -> Any {
        let val = (arguments?[0] as? [AnyHashable : Any])?[key]

        if val == nil {
            throw ValidationError.missingArgument("\(key) is required")
        }

        return val!
    }

    /**
     * Delegate methods
     */
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
        successfulPayment = true

        let paymentDataDictionary: [AnyHashable: Any]? = try? JSONSerialization.jsonObject(with: payment.token.paymentData, options: .mutableContainers) as! [AnyHashable : Any]
        var paymentType: String = "debit"

        var paymentMethodDictionary: [AnyHashable: Any] = ["network": "", "type": paymentType, "displayName": ""]

        switch payment.token.paymentMethod.type {
            case .debit:
                paymentType = "debit"
            case .credit:
                paymentType = "credit"
            case .store:
                paymentType = "store"
            case .prepaid:
                paymentType = "prepaid"
            default:
                paymentType = "unknown"
        }

        paymentMethodDictionary = ["network": payment.token.paymentMethod.network ?? "", "type": paymentType, "displayName": payment.token.paymentMethod.displayName ?? ""]

        let cryptogramDictionary: [AnyHashable: Any] = ["paymentData": paymentDataDictionary ?? "", "transactionIdentifier": payment.token.transactionIdentifier, "paymentMethod": paymentMethodDictionary]
        let cardCryptogramPacketDictionary: [AnyHashable: Any] = cryptogramDictionary
        let cardCryptogramPacketData: Data? = try? JSONSerialization.data(withJSONObject: cardCryptogramPacketDictionary, options: [])

        if (cardCryptogramPacketData != nil){
            do{
                let JSonEncoder = JSONEncoder()
                JSonEncoder.outputFormatting = .prettyPrinted
                let applePaymentData = try JSonEncoder.encode(cardCryptogramPacketData)

                //let applePaymentString = String(describing: cardCryptogramPacketData!)
                let applePaymentString = String(data: applePaymentData, encoding: .utf8)!
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: applePaymentString)

                commandDelegate.send(result, callbackId: paymentCallbackId)
            } catch{

            }
        } else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Payment error")
            commandDelegate.send(result, callbackId: paymentCallbackId)
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if !successfulPayment {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Payment cancelled")
            commandDelegate.send(result, callbackId: paymentCallbackId)
        }

        controller.dismiss(animated: true, completion: nil)
    }
}

enum ValidationError : Error {
    case missingArgument(String)
}
