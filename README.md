<div align="center">
<h1>mysqlclient-ffi</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.39.7-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-91.2%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/> 介绍

依照CDBC标准封装的mysql的c语言libmysqlclient库

### 特性

- 🚀 连接数据库

- 🚀 创建删除数据表

- 💪 对数据库内容增删改查

## <img alt="" src="./doc/assets/readme-icon-framework.png" style="display: inline-block;" width=3%/> 软件架构

### 源码目录

```shell
.
├─ .gitee
│   └─ PULL_REQUEST_TEMPLATE.zh-CN.md
├─ .gitignore
├─ CHANGELOG.md
├─ gitee_gate.cfg
├─ module.json
├─ LICENSE
├─ README.md
├─ README.OpenSource
├─ doc
│   ├─ assets
│   └─ feature_api.md
├─ src
│  └─ mysqlclient
└─ test
    ├─ HLT
    └─ LLT
```

- `doc`  文档目录，用于存放API接口等文档
- `src`  源码目录
- `test` 测试目录
- `test DOC` 演示样例
- `test HLT` HLT用例
- `test LLT` LLT用例

### 接口说明

主要是核心类和成员函数说明，详情见 [API](./doc/feature_api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 使用说明

### 编译

1、本项目基于 mysqlclient8.0.33 开发，需要依赖 mysqlclient，下载地址 https://downloads.mysql.com/archives/community/

2、克隆 mysqlclient-ffi 项目

```shell
git clone https://gitee.com/HW-PLLab/mysqlclient-ffi.git
```

3、切换目录

```shell
cd mysqlclient-ffi
```

4、在当前目录新建 lib 文件夹

5、迁移lib

linux 环境下 将 libmysqlclient.so libmysqlclient.so.21 libmysqlclient.so.21.2.33三个so复制到lib中,目录结构如下

```shell
├─ lib
│   ├─ libmysqlclient.so
│   ├─ libmysqlclient.so.21
│   └─ libmysqlclient.so.21.2.33
```

libmysqlclient.so libmysqlclient.so.21 libmysqlclient.so.21.2.33 三个文件通常在 /usr/lib/mysql/ 目录下或者在 /usr/lib/x86_64-linux-gnu/ 目录下

如果没有运行如下指令，再去目录下寻找so包

```shell
sudo apt-get install libmysqlclient-dev
```

window 环境下 将 libmysql.dll复制两份到lib中，一份保持原样，一份修改名称为libmysqlclient.dll，,目录结构如下

```shell
├─ lib
│   ├─ libmysql.dll
│   └─ libmysqlclient.dll
```

libmysql.dll 通常在mysql安装目录 lib 目录下

6、编译

```shell
cjpm build -V
```

编译结果

```shell
cjpm build success
```

7、运行示例

示例文件在 test/DOC/mysql_examples.cj 

linux 运行指令，其中的 [path]是本地路径，e.g /[path]/mysqlclient-ffi 改成 /home/cangjie/cjdemo/mysqlclient-ffi

```shell
cjc  --import-path /[path]/mysqlclient-ffi --import-path /[path]/mysqlclient-ffi/build --import-path /[path]/mysqlclient-ffi/build  -L /[path]/mysqlclient-ffi/build -L /[path]/mysqlclient-ffi/build/bin -L /[path]/mysqlclient-ffi/build/mysqlclient -l mysqlclient_mysqlclient -l mysqlclient /[path]/mysqlclient-ffi/test/DOC/examples/mysql_examples.cj -O2 -o /[path]/mysqlclient-ffi/build/mysqlclient/
```

windows 运行指令，其中的 [path]是本地路径，e.g [path]\mysqlclient-ffi 改成 D:\Cangjie\mysqlclient-ffi

```cmd
cjc --import-path [path]\mysqlclient-ffi --import-path [path]\mysqlclient-ffi\build --import-path [path]\mysqlclient-ffi\build -L [path]\mysqlclient-ffi\build -L [path]\mysqlclient-ffi\build\bin -L [path]\mysqlclient-ffi\build\mysqlclient -l mysql -l mysqlclient -l mysqlclient_mysqlclient  [path]\mysqlclient-ffi\test\DOC\examples\mysql_examples.cj -O2 -o [path]\mysqlclient-ffi\build\mysqlclient\
```

8、切换运行目录

```shell
cd build/mysqlclient/
```

9、运行执行文件

linux 运行

```shell
./main
```

windows 运行

```cmd
./main.exe
```

### 功能示例

```cangjie
from mysqlclient import mysqlclient.*
from std import database.sql.*
from std import time.*

main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
    if (mysqlDriver.name.equals("mysql")) {
        println("pass1")
    }
    if (mysqlDriver.version.size > 0) {
        println("pass2")
    }
    let arr: Array<(String, String)> = Array<(String, String)>()

    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        arr
    )

    // 返回一个可用的链接
    let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

    // 删除t_test名称数据表
    var mysqlStatement: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test")
    mysqlStatement.update()

    // 创建t_test名称数据表
    mysqlStatement = mysqlConnection.prepareStatement(
        "create table t_test(id bigint, name varchar(50))"
    )
    mysqlStatement.update()

    // 插入数据预执行语句
    mysqlStatement = mysqlConnection.prepareStatement(
        "insert into  t_test(id,name)  VALUES(?,?)"
    )
    if (mysqlStatement.parameterCount == 2) {
        println("pass3")
    }

    var id: SqlBigInt = SqlBigInt(1)
    var name: SqlVarchar = SqlVarchar("lihao111")
    var arrDb: Array<SqlDbType> = [id, name]

    // 执行插入语句插入数据
    var mysqlUpdateResult: MysqlUpdateResult = mysqlStatement.update(arrDb)
    if (mysqlUpdateResult.rowCount == 1) {
        println("pass4")
    }

    id = SqlBigInt(2)
    name = SqlVarchar("lihao222")
    arrDb = [id, name]

    // 执行插入语句插入数据
    mysqlUpdateResult = mysqlStatement.update(arrDb)
    if (mysqlUpdateResult.rowCount == 1) {
        println("pass5")
    }

    // 查询语句预执行语句
    mysqlStatement = mysqlConnection.prepareStatement(
        "select * from t_test where id = ?"
    )
    if (mysqlStatement.parameterCount == 1) {
        println("pass6")
    }

    id = SqlBigInt(2)
    arrDb = [id]

    // 执行查询语句
    var mysqlQueryResult: MysqlQueryResult = mysqlStatement.query(arrDb)
    let mysqlColumnInfos: Array<MysqlColumnInfo> = mysqlQueryResult.mysqlColumnInfos
    if (mysqlColumnInfos.size == 2) {
        println("pass7")
    }
    if (mysqlColumnInfos[0].name.equals("id")) {
        println("pass8")
    }
    if (mysqlColumnInfos[0].typeName.equals("SqlNullableBigInt")) {
        println("pass9")
    }
    if (mysqlColumnInfos[0].displaySize == 0) {
        println("pass10")
    }
    if (mysqlColumnInfos[0].length == 20) {
        println("pass11")
    }
    if (mysqlColumnInfos[0].scale == 0) {
        println("pass12")
    }
    if (!mysqlColumnInfos[0].nullable) {
        println("pass13")
    }
    if (mysqlColumnInfos[1].name.equals("name")) {
        println("pass14")
    }
    if (mysqlColumnInfos[1].typeName.equals("SqlNullableVarchar")) {
        println("pass15")
    }
    if (mysqlColumnInfos[1].displaySize == 0) {
        println("pass16")
    }
    if (mysqlColumnInfos[1].length == 200) {
        println("pass17")
    }
    if (mysqlColumnInfos[1].scale == 0) {
        println("pass18")
    }
    if (!mysqlColumnInfos[1].nullable) {
        println("pass19")
    }

    id = SqlBigInt(0)
    name = SqlVarchar("")
    arrDb = [id, name]

    // 获取数据
    var isBool: Bool = mysqlQueryResult.next(arrDb)

    if (isBool) {
        println("pass20")
    }
    if ((arrDb[0] as SqlBigInt).getOrThrow().value == 2) {
        println("pass21")
    }
    if ((arrDb[1] as SqlVarchar).getOrThrow().value.equals("lihao222")) {
        println("pass22")
    }

    // 删除语句预执行语句
    mysqlStatement = mysqlConnection.prepareStatement(
        "delete from t_test where name = ?"
    )
    if (mysqlStatement.parameterCount == 1) {
        println("pass23")
    }

    name = SqlVarchar("lihao222")
    arrDb = [name]

    // 执行删除语句
    mysqlUpdateResult = mysqlStatement.update(arrDb)
    if (mysqlUpdateResult.rowCount == 1) {
        println("pass24")
    }

    // 查询语句预执行语句
    mysqlStatement = mysqlConnection.prepareStatement(
        "select * from t_test where id = ?"
    )
    if (mysqlStatement.parameterCount == 1) {
        println("pass25")
    }

    id = SqlBigInt(2)
    arrDb = [id]

    // 执行查询语句
    mysqlQueryResult = mysqlStatement.query(arrDb)

    // 获取数据
    arrDb = [id, name]
    isBool = mysqlQueryResult.next(arrDb)
    if (!isBool) {
        println("pass26")
    }

    // 更新语句预执行语句
    mysqlStatement = mysqlConnection.prepareStatement(
        "update t_test set name = ? where id = ?"
    )
    if (mysqlStatement.parameterCount == 2) {
        println("pass27")
    }

    name = SqlVarchar("lihao333")
    id = SqlBigInt(1)
    arrDb = [name, id]

    // 执行更新语句
    mysqlUpdateResult = mysqlStatement.update(arrDb)
    if (mysqlUpdateResult.rowCount == 1) {
        println("pass28")
    }

    // 查询语句预执行语句
    mysqlStatement = mysqlConnection.prepareStatement(
        "select * from t_test where id = ?"
    )
    if (mysqlStatement.parameterCount == 1) {
        println("pass29")
    }

    id = SqlBigInt(1)
    arrDb = [id]

    // 执行查询语句
    mysqlQueryResult = mysqlStatement.query(arrDb)
    if (mysqlColumnInfos.size == 2) {
        println("pass30")
    }

    id = SqlBigInt(1)
    name = SqlVarchar("")
    arrDb = [id, name]

    // 获取数据
    isBool = mysqlQueryResult.next(arrDb)
    if (isBool) {
        println("pass31")
    }
    if ((arrDb[0] as SqlBigInt).getOrThrow().value == 1) {
        println("pass32")
    }
    if ((arrDb[1] as SqlVarchar).getOrThrow().value.equals("lihao333")) {
        println("pass33")
    }

    // 删除t_test名称数据表
    mysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test")
    mysqlStatement.update()

    // 释放预执行语句内存
    mysqlStatement.close()

    // 关闭链接
    mysqlConnection.close()

    return 0
}
```

执行结果如下：

```shell
pass1
pass2
pass3
pass4
pass5
pass6
pass7
pass8
pass9
pass10
pass11
pass12
pass13
pass14
pass15
pass16
pass17
pass18
pass19
pass20
pass21
pass22
pass23
pass24
pass25
pass26
pass27
pass28
pass29
pass30
pass31
pass32
pass33
```

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。
