//
//  DBManager.swift
//  FMDBOperator
//
//  Created by mac on 16/2/17.
//  Copyright © 2016年 yanshinian. All rights reserved.
//

import Foundation

extension NSObject {
    // 运行时 关联的 key 名
    private struct AssociatedKeys {
        static var tableNameKey = "tableNameKey"
        static var createTableSqlKey = "createTableSqlKey"
    }
    // 运行时 关联 建表语句的 属性
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
    // 运行时关联 表明的属性
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
    // MARK: 插入数据库 操作
    func insert(any:AnyObject? = nil) -> Bool {
        if let a = any {
            return dbOperator.f_insert(a)
        } else {
            return dbOperator.f_insert(self)
        }
    }
    // MARK: 删除 操作
    func remove(id: Int? = nil) -> Bool {
        return dbOperator.f_remove(id)
    }
    // MARK: 更新 操作
    func save(dict:[String: AnyObject]) -> Bool {
        return dbOperator.f_save(dict)
    }
    // MARK: 查询操作
    func find(items: Int? = nil) -> AnyObject? {
        return dbOperator.f_find(items)
    }
    // MARK: 根据条件查询
    func condition(whereStr: String) -> NSObject {
        dbOperator.f_condition(whereStr)
        return self
    }
}