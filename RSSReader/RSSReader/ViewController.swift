//
//  ViewController.swift
//  RSSReader
//
//  Created by Papa, John L on 8/16/16.
//  Copyright © 2016 Papa, John L. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var okButton: UIButton!
  @IBOutlet var outputTextview: UITextView!
  @IBOutlet var outputMessage: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func getData(sender: UIButton) {
    // http://rss.itunes.apple.com/us/?urlDesc=%2Fgenerator
    let url = NSURL(string: "https://itunes.apple.com/us/rss/topgrossingapplications/limit=2/json")!
    
    let session = NSURLSession.sharedSession()
    
    print("Starting")
    
    let task = session.dataTaskWithURL(url) { (data, response, error) in
      if let response = response {
        print("Data encoding: \(response.textEncodingName)")
      }
      
      if let error = error {
        NSLog("Got an error!: \(error.localizedDescription)")
        return
      }
      
      if let data = data {
        NSLog("Got \(data.length) bytes.")
        let str = String(data: data, encoding: NSISOLatin1StringEncoding)

        print("*** Here are the string contents:")
        print(str)
        print("*** ***")
        
        let httpResponse = response as! NSHTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        if (statusCode == 200) {
          print("Status code = \(statusCode)")
          print("Everyone is fine, file downloaded successfully.")
          
          let possibleJson = self.parseJson(data)
          if let json = possibleJson {
            print(json["feed"])
            print(json["feed"]!.dynamicType)
            
            // This does not run ... we will learn more about getting json from background to ui thread later.

            dispatch_async(dispatch_get_main_queue()) {
                self.outputTextview.text = str
            }
            
            guard let dict = json["feed"] as? NSDictionary else { return }
            guard let entries = dict["entry"] as? NSArray else { return }
            
            print(dict["entry"])

            dispatch_async(dispatch_get_main_queue()) {
              let appCount = entries.count
              self.outputMessage.text = "\(appCount) returned"
            }
            for entry in entries {
              guard let entryDict = entry as? NSDictionary else { continue }
              
              guard let titleDict = entryDict["title"] as? NSDictionary else { continue }
              
              guard let label = titleDict["label"] as? String else { continue }
              
              print("*** label = \(label ?? " ")")
            }
            
          }
        }
      }
    }
    task.resume()
  }
  
  func parseJson(data: NSData) -> [String: AnyObject]? {
    let options = NSJSONReadingOptions()
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data, options: options) as? [String: AnyObject]
      if let json = json {
        print("*** Here is the JSON")
        print(json)
        print("*** ***")
      }
      
      return json
    }
    catch (let parsingError) {
      print(parsingError)
    }
    return nil
  }
  
}

