//
//  DBManager.swift
//  FMDBOperator
//
//  Created by mac on 16/2/17.
//  Copyright © 2016年 yanshinian. All rights reserved.
//

import Foundation

extension NSObject {
    private struct AssociatedKeys {
        static var tableNameKey = "tableNameKey"
        static var createTableSqlKey = "createTableSqlKey"
    }
    var createTableSql: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.createTableSqlKey) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.createTableSqlKey, newValue as NSString?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    var tableName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tableNameKey) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.tableNameKey, newValue as NSString?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    var dbOperator: FMDBOperator {
        let db = FMDBOperator.sharedInstance
        db.f_tableName = tableName
        db.f_createTable(createTableSql!)
        return db
    }
    func insert(any:AnyObject? = nil) -> NSObject {
        if let a = any {
            dbOperator.f_insert(a)
        } else {
            dbOperator.f_insert(self)
        }
        return self
    }
    func remove(id: Int? = nil) {
        dbOperator.f_remove(id)
    }
    func save(dict:[String: AnyObject]) -> NSObject {
        dbOperator.f_save(dict)
        return self
    }
    func find(items: Int? = nil) -> NSObject {
        dbOperator.f_find(items)
        return self
    }
    func condition(whereStr: String) -> NSObject {
        dbOperator.f_condition(whereStr)
        return self
    }
}