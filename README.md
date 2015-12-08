# FMDBOperator
简单的封装了一下FMDB，支持链式操作，继承，更加面向对象的操作！支持缓存时间设置！

其实写的比较简陋，还需要合理的完善！目前，应用是足够了！

##特征：

1.字段验证。利用swift 的反射，获取子类的属性跟值。进行字段验证

2.链式操作。增（add）删（remove）改（save）查（find）支持链式操作。

3.缓存设置。支持缓存时间设置。内置了一张缓存表。记录其他表的缓存时间。方便数据的重复使用。减少网络更新。

##实例：

声明一个`Student`类继承`FMDBOperator`

```
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

比如：我声明了一个其他的类。只要它继承自`FMDBOperator`。就会操作任意的表。

```
// 查询 表 Student 中所有 age 为 2的小朋友
self.table('Student').condition("age=2").find() 

// 更新 表 Student 中叫 野原新之助 的信息
self.table('Student').condition("name='野原新之助'").save(["birthDay": "7.22"])
```

## 总结

没有你想象的那么好。我也希望自己能力提升。作出好的东西！
