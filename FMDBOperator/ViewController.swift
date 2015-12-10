//
//  ViewController.swift
//  FMDBOperator
//
//  Created by iOS on 15/12/8.
//  Copyright © 2015年 yanshinian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var student = Student()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func add(sender: AnyObject) {
        student.name = "野原新之助"
        student.age = 5
        student.birthDay = "7月22日"
        student.insert()
    }
    @IBAction func remove(sender: AnyObject) {
        student.remove()
    }
    @IBAction func save(sender: AnyObject) {
        student.condition("name='野原新之助'").save(["birthDay": "7.22"])
    }
    @IBAction func find(sender: AnyObject) {
        let arr = student.find() as! [[String: AnyObject]]
        dump(arr)
    }
    
    
    
}

