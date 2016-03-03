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
    // 绑定一个属性，用于建表使用
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
    // 绑定一个属性，传递表名
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
    // 实例化 FMDBOperator
    var dbOperator: FMDBOperator {
        let db = FMDBOperator.sharedInstance
        db.f_tableName = tableName
        db.f_createTable(createTableSql!)
        return db
    }
    func insert(any:AnyObject? = nil) -> Bool {
        if let a = any {
            return dbOperator.f_insert(a)
        } else {
            return dbOperator.f_insert(self)
        }
    }
    func remove(id: Int? = nil) -> Bool {
        return dbOperator.f_remove(id)
    }
    func save(dict:[String: AnyObject]) -> Bool {
        return dbOperator.f_save(dict)
    }
    func find(items: Int? = nil) -> AnyObject? {
        return dbOperator.f_find(items)
    }
    func condition(whereStr: String) -> NSObject {
        dbOperator.f_condition(whereStr)
        return self
    }
}