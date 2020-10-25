import Contacts

@objc(ContactList)
class ContactList: NSObject {
    private let contactStore: CNContactStore = CNContactStore()
    private let photoPrefix: String = "react-native-contact-list_"
    private let keys: [CNKeyDescriptor] = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [CNKeyDescriptor]
    private var contactList: [[String: Any?]] = []
    
    func createFileWithRecordId(recordId: String, imageData: Data?) -> String {
        let fileName: String = recordId.replacingOccurrences(of: ":ABPerson", with: "")
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = paths.first ?? ""
        let filePath = "\(path)/\(self.photoPrefix)\(fileName).png"
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: imageData, attributes: nil)
        }
        return filePath
    }
    
    func isPermissionGranted() -> String {
        let authorizeStatus: CNAuthorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizeStatus {
        case .authorized:
            return "authorized"
        case .denied, .notDetermined, .restricted:
            return "denied"
        default:
            return "denied"
        }
    }
    
    @objc
    func checkPermission(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        resolve(self.isPermissionGranted())
    }
    
    @objc
    func requestPermission(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        self.contactStore.requestAccess(for: .contacts) { (granted: Bool, error: Error?) in
            if let _ = error {
                resolve("denied")
                return
            }
            resolve(granted ? "authorized" : "denied")
        }
    }
    
    @objc
    func getContactList(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        self.contactStore.requestAccess(for: .contacts) { (granted: Bool, error: Error?) in
            if let error = error {
                reject(nil, nil, error)
                return
            }
            
            if !granted {
                reject("ACCESS_DENIED", "ACCESS_DENIED", nil)
                return
            }
            
            let request = CNContactFetchRequest(keysToFetch: self.keys)
            
            do {
                try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact: CNContact, _: UnsafeMutablePointer<ObjCBool>) in
                    var filePath: String? = nil
                    if contact.imageDataAvailable {
                        filePath = self.createFileWithRecordId(recordId: contact.identifier, imageData: contact.thumbnailImageData)
                    }
                    self.contactList.append([
                        "displayName": "\(contact.familyName)\(contact.givenName)",
                        "givenName": contact.givenName,
                        "familyName": contact.familyName,
                        "phoneNumber": contact.phoneNumbers.first?.value.stringValue ?? nil,
                        "thumbnailPath": filePath
                    ])
                })
                resolve(self.contactList)
            } catch let error {
                reject(nil, nil, error)
            }
        }
    }
}
