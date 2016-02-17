# FMDBOperator

简单的封装了一下FMDB，支持链式操作，继承，更加面向对象的操作！支持缓存时间设置！

其实写的比较简陋，还需要合理的完善！目前，应用是足够了！

之前是继承使用！我感觉继承使用耦合度还是有的！所以加了一个NSObject分类——`DBManager`。这样不用继承就直接使用了。



##特征：

1.字段验证。保证 插入数据中的字典 的 key 跟数据库的字段相匹配

```
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
```

2.swift的反射。自动拼接`sql`中的字段以及对应的值

```
......
let v = p.value
let propertyMirrorType: Mirror = Mirror(reflecting:v)
print(propertyMirrorType.subjectType)
let typeName = "\(propertyMirrorType.subjectType)".trimOptional()
let vend = "\(v)".trimOptional()
if typeName == "String" {
    value += "\(vend),"
} else if typeName == "Int" {
    value += "\(vend),"
}
.......
```

3.链式操作。增（add）删（remove）改（save）查（find）支持链式操作。

```
student.condition("name='野原新之助'").save(["birthDay": "7.22"])
```

4.缓存设置。支持缓存时间设置。内置了一张缓存表。记录其他表的缓存时间。方便数据的重复使用。减少网络更新。

内置了一张`Cache`表。字段`last_time`记录上一次的缓存时间。

```
func createCacheTable() {
    let sql = "CREATE TABLE IF NOT EXISTS Cache (cache_id integer primary key AutoIncrement,table_name varchar(20),last_time REAL)"
    db.executeUpdate(sql, withArgumentsInArray: nil)
}
```

设置表格的`cacheTime`。

我们通过类设置一次就在`Cache`中有了一条记录。以后每次使用这个类不会重复的插入了。

```
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
            let sql = "INSERT INTO  Cache (table_name, last_time) VALUES ('\(f_tableName!)',\(timeStamp))"
            db!.executeUpdate(sql, withArgumentsInArray: nil)
        }
    }
}
```
判断缓存是否过期并更新缓存时间。

```
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
            self.f_table("Cache").f_condition("table_name='\(f_tableName!)'").f_save(["last_time": currentTime + cacheTime])
            print("当前时间是\(currentTime)--数据库时间\(c)")
        }
        return currentTime > c
    }
    return true
}
```

例子：你有几条信息。设置的`cacheTime`是`90s`。那么，过期之后把表中的数据可以通过 `remove()`干掉。然后从网络从新更新。然后再更新缓存时间。下一次就用缓存中的数据了。

```
// 然后开始遍历
let banner = Banner()
// 过期后 删除缓存 重新缓存
if (banner.isExpired) {
    print("过期了请更新")
    banner.remove()
     print("banner 取自于 网络")
    for dict in arr {
        let banner = Banner(dict: dict)
        bannerList.append(banner)
        banner.insert()
    }
} else {
    print("banner 取自于 缓存")
    let arr = banner.find() as! [[String: AnyObject]]
    for dict in arr {
        let banner = Banner(dict: dict)
        bannerList.append(banner)
    }
}
```

##示例：

声明一个`Student`类继承`FMDBOperator`

```
class Student: NSObject {
    var name: String?
    var age: Int = 0
    var birthDay: String?
    // MARK: - 构造函数
    override init() {
        super.init()
        tableName = "Student"
        createTableSql = "CREATE TABLE IF NOT EXISTS Student (sid integer primary key AutoIncrement,name varchar(20),age varchar(20), birthDay varchar(20))"
    }
}
```

###增（add）

```
student.name = "野原新之助"
student.age = 5
student.birthDay = "7月22日"
student.insert()
```
或者你还可以

```
student.insert(["name": "阿呆", "age": 6, "birthDay": "11月30"])
```
或者插入多条

```
let arr = [
	["name": "风间", "age": 6, "birthDay": "10月33"],
	["name": "妮妮", "age": 5, "birthDay": "01月21"]
]
student.insertAll(arr)
```

###删（remove）

根据ID删除（这个似乎有些鸡肋，不过我会增加条件删除的）

```
student.remove(id的值)
```

删除全部
```
student.remove()
```

###改（save）

```
student.condition("name='野原新之助'").save(["birthDay": "7.22"])
```

###查（find）

查询单条数据
```
student.find(id的值) as! [String: AnyObject]
```
条件查询

```
student.condition("age=2").find()
```

查询所有数据

```
student.find() as! [[String: AnyObject]]
```

### 其他操作方式


```
// 查询 表 Student 中所有 age 为 2的小朋友
self.table('Student').condition("age=2").find() 

// 更新 表 Student 中叫 野原新之助 的信息
self.table('Student').condition("name='野原新之助'").save(["birthDay": "7.22"])
```

## 总结

没有你想象的那么好。我也希望自己能力提升。作出好的东西！
