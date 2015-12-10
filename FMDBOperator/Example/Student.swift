//
//  Student.swift
//  FMDBOperator
//
//  Created by iOS on 15/12/8.
//  Copyright © 2015年 yanshinian. All rights reserved.
//

import UIKit

class Student: FMDBOperator {
    var name: String?
    var age: Int = 0
    var birthDay: String?
    // MARK: - 构造函数
    override init() {
        super.init()
        tableName = "Student"
    }
    override func returnCreateTableSentence() -> String {
        return "CREATE TABLE IF NOT EXISTS Student (sid integer primary key AutoIncrement,name varchar(20),age varchar(20), birthDay varchar(20))"
    }
}