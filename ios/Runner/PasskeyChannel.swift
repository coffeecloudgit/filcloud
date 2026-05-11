import Foundation
import Flutter
import AuthenticationServices

final class PasskeyChannel: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var result: FlutterResult?
    private var anchor: ASPresentationAnchor?
    
    static func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "com.fil.links/passkey", binaryMessenger: controller.binaryMessenger)
        let instance = PasskeyChannel()
        channel.setMethodCallHandler { call, result in
            instance.anchor = controller.view.window
            instance.result = result
            
            guard let args = call.arguments as? [String: Any],
                  let rpId = args["rpId"] as? String,
                  let publicKey = args["publicKey"] as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                return
            }
            
            switch call.method {
            case "register":
                instance.handleRegister(rpId: rpId, publicKey: publicKey)
            case "authenticate":
                instance.handleAuthenticate(rpId: rpId, publicKey: publicKey)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleRegister(rpId: String, publicKey: [String: Any]) {
        guard let challengeB64 = publicKey["challenge"] as? String,
              let user = publicKey["user"] as? [String: Any],
              let userIdB64 = user["id"] as? String,
              let name = user["name"] as? String,
              let displayName = user["displayName"] as? String else {
            self.result?(FlutterError(code: "bad_options", message: "Missing publicKey fields", details: nil))
            return
        }
        
        guard let challenge = Data(base64URLEncoded: challengeB64),
              let userId = Data(base64URLEncoded: userIdB64) else {
            self.result?(FlutterError(code: "bad_b64", message: "Invalid base64url", details: nil))
            return
        }
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = provider.createCredentialRegistrationRequest(challenge: challenge, name: name, userID: userId)
        request.displayName = displayName
        request.userVerificationPreference = .required
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func handleAuthenticate(rpId: String, publicKey: [String: Any]) {
        guard let challengeB64 = publicKey["challenge"] as? String else {
            self.result?(FlutterError(code: "bad_options", message: "Missing challenge", details: nil))
            return
        }
        guard let challenge = Data(base64URLEncoded: challengeB64) else {
            self.result?(FlutterError(code: "bad_b64", message: "Invalid base64url", details: nil))
            return
        }
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        request.userVerificationPreference = .required
        
        // Optional allowCredentials support
        if let allow = publicKey["allowCredentials"] as? [[String: Any]] {
            let ids: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = allow.compactMap { item in
                guard let idB64 = item["id"] as? String, let id = Data(base64URLEncoded: idB64) else { return nil }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: id)
            }
            if !ids.isEmpty {
                request.allowedCredentials = ids
            }
        }
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return anchor ?? ASPresentationAnchor()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let reg = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            let payload: [String: Any] = [
                "id": reg.credentialID.base64URLEncodedString(),
                "rawId": reg.credentialID.base64URLEncodedString(),
                "type": "public-key",
                "response": [
                    "clientDataJSON": reg.rawClientDataJSON.base64URLEncodedString(),
                    "attestationObject": reg.rawAttestationObject?.base64URLEncodedString() ?? ""
                ],
                "clientExtensionResults": [:]
            ]
            finishOK(payload)
            return
        }
        
        if let assertion = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            let payload: [String: Any] = [
                "id": assertion.credentialID.base64URLEncodedString(),
                "rawId": assertion.credentialID.base64URLEncodedString(),
                "type": "public-key",
                "response": [
                    "clientDataJSON": assertion.rawClientDataJSON.base64URLEncodedString(),
                    "authenticatorData": assertion.rawAuthenticatorData.base64URLEncodedString(),
                    "signature": assertion.signature.base64URLEncodedString(),
                    "userHandle": assertion.userID.base64URLEncodedString()
                ],
                "clientExtensionResults": [:]
            ]
            finishOK(payload)
            return
        }
        
        self.result?(FlutterError(code: "unsupported_credential", message: "Unsupported credential type", details: nil))
        self.result = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Map common user-driven cancellation to a stable error code so Flutter can ignore it.
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            self.result?(FlutterError(code: "passkey_cancelled", message: error.localizedDescription, details: nil))
            self.result = nil
            return
        }
        self.result?(FlutterError(code: "passkey_error", message: error.localizedDescription, details: nil))
        self.result = nil
    }
    
    private func finishOK(_ obj: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: obj, options: [])
            let s = String(data: data, encoding: .utf8) ?? "{}"
            self.result?(s)
        } catch {
            self.result?(FlutterError(code: "json_error", message: error.localizedDescription, details: nil))
        }
        self.result = nil
    }
}

private extension Data {
    init?(base64URLEncoded: String) {
        var s = base64URLEncoded.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let pad = s.count % 4
        if pad > 0 {
            s += String(repeating: "=", count: 4 - pad)
        }
        self.init(base64Encoded: s)
    }
    
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

