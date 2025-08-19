// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*

/*
 * 超长Stirng类型数据报错
 */
main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        Array<(String, String)>()
    )

    // 返回一个可用的链接
    let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

    // 删除t_test名称数据表
    var mysqlStatement: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_varchar_long")
    mysqlStatement.update()
    mysqlStatement.close()

    // 创建t_test名称数据表
    var mysqlStatement0: MysqlStatement = mysqlConnection.prepareStatement(
        "create table t_test_varchar_long(varcharValue1 varchar(5500) not null)")
    mysqlStatement0.update()
    mysqlStatement0.close()

    // 插入数据预执行语句
    var mysqlStatement1: MysqlStatement = mysqlConnection.prepareStatement(
        "insert into  t_test_varchar_long(varcharValue1)  VALUES(?)")
    @Assert(1, mysqlStatement1.parameterCount)

    // 插入一条数据
    mysqlStatement1.set<String>(0, "lihao")
    var mysqlUpdateResult1: MysqlUpdateResult = mysqlStatement1.update()
    @Assert(1, mysqlUpdateResult1.rowCount)

    // 插入一条数据
    // 长度过长bug
    let longStr: String = "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
    mysqlStatement1.set<String>(0, longStr)
    var mysqlUpdateResult2: MysqlUpdateResult = mysqlStatement1.update()
    @Assert(1, mysqlUpdateResult2.rowCount)

    // 插入一条数据
    mysqlStatement1.set<String>(0, "菜鸟课程")
    var mysqlUpdateResult3: MysqlUpdateResult = mysqlStatement1.update()
    @Assert(1, mysqlUpdateResult3.rowCount)
    mysqlStatement1.close()

    // 查询语句预执行语句
    var mysqlStatement2: MysqlStatement = mysqlConnection.prepareStatement(
        "select * from t_test_varchar_long where varcharValue1 = ?")
    @Assert(1, mysqlStatement2.parameterCount)

    mysqlStatement2.set<String>(0, longStr)
    var mysqlQueryResult1: MysqlQueryResult = mysqlStatement2.query()

    var isBool1: Bool = mysqlQueryResult1.next()
    @Assert(true, isBool1)
    @Assert(longStr, mysqlQueryResult1.get<String>(0))
    mysqlStatement2.close()

    // 删除语句预执行语句
    var mysqlStatement3: MysqlStatement = mysqlConnection.prepareStatement(
        "delete from t_test_varchar_long where varcharValue1 = ?")
    @Assert(1, mysqlStatement3.parameterCount)

    mysqlStatement3.set<String>(0, longStr)
    var mysqlUpdateResult4: MysqlUpdateResult = mysqlStatement3.update()
    @Assert(1, mysqlUpdateResult4.rowCount)
    mysqlStatement3.close()

    // 查询语句预执行语句
    var mysqlStatement4: MysqlStatement = mysqlConnection.prepareStatement(
        "select * from t_test_varchar_long where varcharValue1 = ?")
    @Assert(1, mysqlStatement4.parameterCount)

    mysqlStatement4.set<String>(0, longStr)
    var mysqlQueryResult2: MysqlQueryResult = mysqlStatement4.query()

    var isBool2: Bool = mysqlQueryResult2.next()
    @Assert(false, isBool2)
    mysqlStatement4.close()

    // 更新语句预执行语句
    let mysqlStatement7: MysqlStatement = mysqlConnection.prepareStatement(
        "update t_test_varchar_long set varcharValue1 = ?  where varcharValue1 = ?")
    @Assert(2, mysqlStatement7.parameterCount)

    // 执行更新语句
    mysqlStatement7.set<String>(0, "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111")
    mysqlStatement7.set<String>(1, "lihao")
    let mysqlUpdateResult5: MysqlUpdateResult = mysqlStatement7.update()
    @Assert(1, mysqlUpdateResult5.rowCount)
    mysqlStatement7.close()

    // 查询语句预执行语句
    let mysqlStatement8: MysqlStatement = mysqlConnection.prepareStatement(
        "select * from t_test_varchar_long where varcharValue1 = '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'"
    )

    // 执行查询语句
    var mysqlQueryResult3: MysqlQueryResult = mysqlStatement8.query()

    // 获取数据
    let isBool10: Bool = mysqlQueryResult3.next()
    @Assert(true, isBool10)
    @Assert("11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111", mysqlQueryResult3.get<String>(0))
    mysqlStatement8.close()

    // 删除t_test名称数据表
    let mysqlStatement9: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_varchar_long")
    mysqlStatement9.update()

    // 释放预执行语句内存
    mysqlStatement9.close()

    // 关闭链接
    mysqlConnection.close()

    return 0
}
