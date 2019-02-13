//
//  DownloaderVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/5/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2
import UIKit
import Alamofire

class DownloaderVC: UIViewController {

    /*
    override func viewDidLoad() {
        var localPath: NSURL?
        
        Alamofire.request(.GET, "https://googledrive.com/host/0B_NILOaL31gTd0loTnpwRUxvSnc/arrows%283%29@3x%20%281%29.png", parameters: nil, encoding: .URL).responseString(completionHandler: {response in
            print(response.result.value)
        })*/
        /*Alamofire.download(.GET,
            //"https://docs.google.com/uc?id=0B_NILOaL31gTRFJfWEw3TGJrTnM&export=download",
            "https://googledrive.com/host/0B_NILOaL31gTd0loTnpwRUxvSnc/arrows%283%29@3x%20%281%29.png",
            destination: { (temporaryURL, response) in
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = response.suggestedFilename
                
                localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
                return localPath!
        })
            .response { (request, response, _, error) in
                print(response)
                print("Downloaded file to \(localPath!)")
        }
    }*/
    
    private let kKeychainItemName = "Drive API"
    private let kClientID = "104876447951-njd2s63r9h36va8q31q4ohvkqkt5o0rs.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDriveMetadataReadonly]
    
    private let service = GTLServiceDrive()
    let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Drive API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.frame = view.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(output);
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
                service.authorizer = auth
        }
        
    }
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
                //fetchFiles()
                fetchFile("0B_NILOaL31gTRFJfWEw3TGJrTnM")
                //download()
                //fetchFolder()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    func download() {
        
        //GTLServiceDrive *driveService = ...;
        let id = "0B_NILOaL31gTd0loTnpwRUxvSnc"
        let query = GTLQueryDrive.queryForFilesGetWithFileId(id)
        service.executeQuery(query, completionHandler: {(ticket, file, error) in
            if error == nil {
                let url = NSString(format: "https://googledrive.com/host/0B_NILOaL31gTd0loTnpwRUxvSnc/cellphone.png", "")
                //NSString(format:"http://%@", urlString) as String
                //[NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media",
                //file.identifier]
                let fetcher: GTMSessionFetcher = self.service.fetcherService.fetcherWithURLString(url as String)
                
                fetcher.beginFetchWithCompletionHandler({(data, error) in
                    if error == nil {
                        //print(data)
                    } else {
                        //print(error)
                    }
                })
            }
        })
        
    }
    
    func fetchFolder() {
        //NSString *parentId = @"root";
        let parentId: NSString = "0B_NILOaL31gTd0loTnpwRUxvSnc"
        //GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
        let query: GTLQueryDrive = GTLQueryDrive.queryForFilesList()
        query.q = NSString(format: "'%@' in parents", parentId) as String
        //query.q = [NSString stringWithFormat:@"'%@' in parents", parentId];
        service.executeQuery(query, completionHandler: {(ticket, fileList, error) in
            if error == nil {
                let files = (fileList as! GTLDriveFileList).files as! [GTLDriveFile]
                for each in files {
                    //print(each.additionalPropertyForName("webViewLink"))
                    var localPath: NSURL?
                    Alamofire.download(.GET,
                        //"https://docs.google.com/uc?id=0B_NILOaL31gTRFJfWEw3TGJrTnM&export=download",
                        "https://googledrive.com/host/0B_NILOaL31gTd0loTnpwRUxvSnc/arrows%283%29@3x%20%281%29.png)",
                        destination: { (temporaryURL, response) in
                            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                            let pathComponent = response.suggestedFilename
                            
                            localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
                            return localPath!
                    })
                        .response { (request, response, _, error) in
                            //print(response)
                            //print("Downloaded file to \(localPath!)")
                    }

                }
            }
        })
    }
    
    func fetchFile(fieldId: String!) {
        output.text = "Getting files..."
        
        let query = GTLQueryDrive.queryForFilesGetWithFileId(fieldId)
        //query.pageSize = 1
        query.fields = "webViewLink"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(DownloaderVC.downloadResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    // Construct a query to get names and IDs of 10 files using the Google Drive API
    func fetchFiles() {
        output.text = "Getting files..."
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        query.fields = "nextPageToken, files(id, name, webViewLink)"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(DownloaderVC.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    // Parse results and display
    func displayResultWithTicket(ticket : GTLServiceTicket,
        finishedWithObject response : GTLDriveFileList,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
            
            var filesString = ""
            if let files = response.files where !files.isEmpty {
                filesString += "Files:\n"
                for file in files as! [GTLDriveFile] {
                    filesString += "\(file.name) (\(file.identifier)) (\(file.webViewLink))\n"
                }
            } else {
                filesString = "No files found."
            }
            
            output.text = filesString
    }
    
    // Parse results and download
    func downloadResultWithTicket(ticket : GTLServiceTicket,
        finishedWithObject response : GTLDriveFileList,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
    }

    
    
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(DownloaderVC.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    func viewController(vc : UIViewController,
        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
            
            if let error = error {
                service.authorizer = nil
                showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
            
            service.authorizer = authResult
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
