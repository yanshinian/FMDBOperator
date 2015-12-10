//
//  FMDBOperator.swift
//  FMDBOperator
//
//  Created by iOS on 15/12/8.
//  Copyright © 2015年 yanshinian. All rights reserved.
//

import UIKit
/// 默认的数据库名称
private let dbName = "app.db"
class FMDBOperator : NSObject {
    lazy var typeDict = []
    var db: FMDatabase
    var tableName: String?
    var querySql: String?
    var error: String?
    lazy var options:[String: String] = [String: String]()
    var cacheTime: Double = 0.0 {
        didSet {
            if cacheTime > 0.0 {
                let cTime = getCacheTime()
                if let _ = cTime {
                    return
                }
                // 計算
                let timeStamp = NSDate().timeIntervalSince1970 + cacheTime
                print("表格：\(self.classForCoder),緩存時間：\(self.cacheTime)")
                let sql = "INSERT INTO  Cache (table_name, last_time) VALUES ('\(tableName!)',\(timeStamp))"
                db.executeUpdate(sql, withArgumentsInArray: nil)
            }
        }
    }
    var isExpired:Bool {
        // 查詢出 緩存的時間
        let cTime = getCacheTime()
        if let c = cTime {
            // 当前时间
            // 加上 緩存秒數
            // 對比當前時間，返回 是否過期
            let currentTime =  NSDate().timeIntervalSince1970
            // 如果 过期 更新缓存表信息
            if currentTime > c {
                self.table("Cache").condition("table_name='\(tableName!)'").save(["last_time": currentTime + cacheTime])
                print("当前时间是\(currentTime)--数据库时间\(c)")
            }
            return currentTime > c
        }
        return true
    }
    
    override init() {
        
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        path = (path as NSString).stringByAppendingPathComponent(dbName)
        
        print(path)
        
        // path 同样是数据库文件的完整路径
        //        // 如果数据库不存在，会新建之后，再打开，否则会直接建立
        db = FMDatabase(path: path)
        db.open()
        super.init()
        createCacheTable()
        createTable()
    }
    func getCacheTime(name: String = "") -> Double? {
        var tbName: String?
        if name == "" {
            tbName = tableName!
        } else  {
            tbName = name
        }
        let result = self.table("Cache").condition("table_name='\(tbName!)'").find()?.lastObject as? [String: AnyObject]
        //        print("结果是：---")
        //        dump(self.table("Cache").condition("table_name='\(tbName!)'").find())
        if let r = result {
            return r["last_time"] as? Double
        } else  {
            return nil
        }
    }
    func createCacheTable() {
        let sql = "CREATE TABLE IF NOT EXISTS Cache (cache_id integer primary key AutoIncrement,table_name varchar(20),last_time REAL)"
        db.executeUpdate(sql, withArgumentsInArray: nil)
        
        
    }
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    func find(items: Int? = nil) -> AnyObject? {
        if let i = items {
            options["SELECT"] = "\(i)"
        } else {
            options["SELECT"] = ""
        }
        let sql = parseSql()
        
        print("find---parseSql")
        print(sql)
        if let i = items {
            // 通过主键查询
            return fetchRow(db.executeQuery(sql, withArgumentsInArray: nil)) as? AnyObject
        } else {
            //            print("结果怎么了：")
            //            dump( fetchAll(db.executeQuery(sql, withArgumentsInArray: nil)) as? AnyObject)
            return fetchAll(db.executeQuery(sql, withArgumentsInArray: nil)) as? AnyObject
        }
        return nil
    }
    func table(name: String) -> FMDBOperator{
        options["TABLE"] = name
        return self
    }
    func condition(whereStr: String)-> FMDBOperator {
        options["WHERE"] = whereStr
        return self
    }
    func save(dict:[String: AnyObject])->Bool {
        options["UPDATE"] = ""
        //        UPDATE table_name
        //        SET column1 = value1, column2 = value2...., columnN = valueN
        //        WHERE [condition];
        let tbName = options["TABLE"] ?? tableName
        
        var sql = "UPDATE \(tbName!) SET "
        // 如果是单条数据更新 那么就是字典了
        var set = [String]()
        for (k, v) in dict {
            // 一般来说，有个校验最好，校验 字典的key跟属性的键是否相同，
            //            set += "\(k)='\(v)'"
            set.append("\(k)='\(v)'")
        }
        // 如果是多条数据更新 那么就是 数组了
        sql += set.joinWithSeparator(",")
        // 如果是 多表更新 那么 又是另一种情况了
        // 断言， 如果没有
        assert(options["WHERE"] != nil, "must set condition \n")
        sql += " WHERE \(options["WHERE"]!)"
        
        print("更新的sql\(sql)")
        options.removeAll()
        if db.executeUpdate(sql, withArgumentsInArray: nil) {
            print("更新成功")
            return true
        } else {
            print("更新失败")
            return false
        }
    }
    // Mark: ﹣ 查詢限制 ﹣
    func limit(offset: Int, length: Int? = nil ) -> FMDBOperator{
        //        options!["LIMIT"] =
        if let l = length {
            if let q = querySql {
                querySql! += " LIMIT \(offset)  OFFSET \(l)"
            }
        } else {
            if let q = querySql {
                querySql! += " LIMIT \(offset)"
            }
        }
        
        return self
    }
    // Mark: - 解析Sql 語句-
    func parseSql() -> String{
        print(options)
        var sql = ""
        for (key, value) in options {
            if key == "SELECT" {
                if  value != "" {
                    // 這裡我得判斷 tableName 有沒有指定
                    
                    sql += "SELECT * FROM \(tableName!) WHERE \(getPk()!)="+value
                    return sql
                }
                // 如果 filed 有就显示字段，如果没有就显示 *
                let f = (options["FIELD"] == "" || options["FIELD"] == nil) ? "*": options["FIELD"]
                let tabName =  (options["TABLE"] != nil) ? options["TABLE"] : tableName!
                sql += "SELECT \(f!) FROM \(tabName!) "
            }else if key == "UPDATE" {
                if value != "" {
                    
                }
            }else if key == "WHERE" {
                sql += "WHERE \(value)"
            }
        }
        //        print("+++++++++")
        //        dump(sql)
        //        print("+++++++++")
        return sql
    }
    func field(fieldStr: String) -> FMDBOperator {
        options["field"] = fieldStr
        return self
    }
    // MARK: - 插入 数据库
    func insert(dict:[String: AnyObject]? = nil) -> Bool {
        // 如果有值，就把值给插入进去
        // 但是這裡一定要做一次驗證處理，否則的話，一旦表中沒有模型的屬性就完蛋了，所以，我們要做排除處理
        var sql = "INSERT INTO \(tableName!) ("
        
        if let d = dict {
            var filed = ""
            var value = ""
            for (k, v) in d {
                if !checkField(k) {
                    continue
                }
                // 一般来说，有个校验最好，校验 字典的key跟属性的键是否相同，
                filed += "\(k),"
                value += "'\(v)',"
            }
            sql += "\(filed.subStringWithOutTail(1))) VALUES (\(value.subStringWithOutTail(1)));"
        } else {
            let fields = getFields()
            var filed = ""
            var value = ""
            let mirror: Mirror = Mirror(reflecting:self)
            for p in mirror.children {
                
                // 如果不是 表中的字段就跳過
                print("]\(p.label!)]")
                if !checkField(p.label!) {
                    continue
                }
                if getPk()! == p.label! {
                    continue ;
                }
                filed += "\(p.label!),"
                print("000\(filed)")
                //                let propertyNameString = p.label!
                let v = p.value
                let propertyMirrorType: Mirror = Mirror(reflecting:v)
                print(propertyMirrorType.subjectType)
                let typeName = "\(propertyMirrorType.subjectType)".trimOptional()
                //                print("4444444444444")
                //                print(typeName)
                //                print("4444444444444")
                let vend = "\(v)".trimOptional()
                if typeName == "String" {
                    value += "\(vend),"
                } else if typeName == "Int" {
                    value += "\(vend),"
                }
            }
            sql += "\(filed.subStringWithOutTail(1))) VALUES (\(value.subStringWithOutTail(1)));"
        }
        options.removeAll()
        if db.executeUpdate(sql, withArgumentsInArray: nil) {
            print("插入成功")
            return true
        } else {
            print("插入失败")
            return false
        }
    }
    // MARK: - 保证 插入的数据中的 字典 的 key 能跟数据库的字段相匹配
    func checkField(name: String) -> Bool{
        let fields = getFields()
        var fieldNames = [String]()
        for f:[String:  AnyObject] in fields {
            let str = f.first!.0
            // 保存所有字段的名字
            fieldNames.append(str)
        }
        return fieldNames.contains(name)
    }
    // MARK: - 通过数组插入数据库
    func insertAll(arr: [[String: AnyObject]]? = nil) ->Bool {
        if let a = arr {
            for val in a {
                insert(val)
            }
            return true
        } else {
            error = "没有数据插入"
            return false
        }
    }
    // MARK: - 创建表格
    func createTable() {
        // 如果没有指定 returnTableName 根据 反射之后知道的类型去创建一张表（根据属性去创建一张默认的表）
        let mirror: Mirror = Mirror(reflecting:self)
        for p in mirror.children {
            let propertyNameString = p.label!
            let v = p.value
            print(v)
            let propertyMirrorType: Mirror = Mirror(reflecting:v)
            print(propertyMirrorType.subjectType)
            let typeName = "\(propertyMirrorType.subjectType)".trimOptional()
            let vend = "\(v)".trimOptional()
        }
        db.executeUpdate(returnCreateTableSentence()!, withArgumentsInArray: nil)
    }
    func returnCreateTableSentence() -> String? {
        return nil
    }
    // MARK: - 获取表中的所有字段 信息 -
    func getFields() -> [[String: [String: AnyObject]]]{
        options["TABLE"] =   (options["TABLE"] != nil) ? options["TABLE"] : tableName!
        let tabName =  options["TABLE"] //self.classForCoder
        let querySql = "PRAGMA table_info(\(tabName!))"
        let set = db.executeQuery(querySql, withArgumentsInArray: nil)
        var fieldsArr = [[String: [String: AnyObject]]]()
        while set.next() {
            var fieldDict = [String:  AnyObject]()
            fieldDict["name"] = set.objectForColumnName("name")
            
            fieldDict["type"] = set.objectForColumnName("type")
            fieldDict["pk"] = set.objectForColumnName("pk")
            fieldDict["dflt_value"] = set.objectForColumnName("dflt_value")
            fieldDict["notnull"] = set.objectForColumnName("notnull")
            fieldsArr.append([ fieldDict["name"] as! String: fieldDict])
        }
        assert(fieldsArr.count != 0, "表格没有被创建好")
        return fieldsArr
    }
    // MARK: - 查询出 返回的是数组
    func fetchAll(set: FMResultSet) ->[[String: AnyObject]]? {
        let fields = getFields()
        var resultArr = [[String: AnyObject]]()
        while set.next() {
            var fieldDict = [String:  AnyObject]()
            
            for f:[String:  AnyObject] in fields {
                let dict = f.first!.1
                fieldDict[dict["name"] as! String] = set.objectForColumnName(dict["name"] as! String)
            }
            resultArr.append(fieldDict)
        }
        options.removeAll()
        return resultArr
    }
    // MARK: - 查询出 返回的是字典
    func fetchRow(set: FMResultSet) ->[String: AnyObject]? {
        
        let fields = getFields()
        var resultArr = [[String: AnyObject]?]()
        
        while set.next() {
            var fieldDict = [String:  AnyObject]()
            
            for f:[String:  AnyObject] in fields {
                let dict = f.first!.1
                //                print("__+++++]-\(dict)")
                fieldDict[dict["name"] as! String] = set.objectForColumnName(dict["name"] as! String)
                //                print("-=+++]\(fieldDict)")
            }
            resultArr.append(fieldDict)
        }
        if resultArr.count > 0 {
            options.removeAll()
            return resultArr[0]
        }
        return nil
        
    }
    // MARK: - 删除 一条数据 // 返回删除记录个数
    func remove(id: Int? = nil) -> Bool {
        var sql = "DELETE FROM \(tableName!) "
        
        if let i = id {
            // 通过主键 删除
            sql += "\(getPk())=\(i)"
            if db.executeUpdate(parseSql(), withArgumentsInArray: nil) {
                print("删除成功")
                return true
            } else {
                print("删除失败")
                return false
            }
        } else {
            sql += options["WHRERE"] ?? ""
            if db.executeUpdate(sql, withArgumentsInArray: nil) {
                print("删除成功")
                return true
            } else {
                print("删除失败")
                return false
            }
        }
        
    }
    // MARK: - 获取主键值
    func getPk() -> String? {
        //        [[pid: [name: pid, dflt_value: <null>, pk: 1, notnull: 0, type: integer]], [name: [name: name, dflt_value: <null>, pk: 0, notnull: 0, type: varchar(20)]], [age: [name: age, dflt_value: <null>, pk: 0, notnull: 0, type: varchar(20)]]]
        
        let fields = getFields()
        for f:[String:  AnyObject] in fields {
            //            [pid: [name: pid, dflt_value: <null>, pk: 1, notnull: 0, type: integer]]
            print(f.first!)
            let e = f.first
            print(e!.1)
            let dict = f.first!.1
            if dict["pk"] as! Int == 1 {
                return dict["name"] as? String
            }
        }
        return nil
    }
    deinit {
        db.close()
    }
}
extension String {
    func subStringWithOutTail(count: Int) -> String {
        print(self)
        print("self.characters.count-\(self.characters.count)")
        return (self as NSString).substringToIndex(self.characters.count - count)
    }
    func replacingOccurrencesOfString(target: String, withString: String) -> String{
        return (self as NSString).stringByReplacingOccurrencesOfString(target, withString: withString)
    }
    func trimOptional() -> String {
        guard self.rangeOfString("Optional(")?.count == nil else {
            
            return self.replacingOccurrencesOfString("Optional(", withString: "").replacingOccurrencesOfString(")", withString: "")
        }
        guard self.rangeOfString("Optional<")?.count == nil else {
            
            return self.replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
        }
        return self
    }
}
