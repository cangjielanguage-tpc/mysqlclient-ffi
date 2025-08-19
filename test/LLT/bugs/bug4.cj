// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*
import std.io.*

/*
 * Clob类型未匹配
 */
main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
    @Assert("mysql", mysqlDriver.name)
    @Assert(true, mysqlDriver.version.size > 0)

    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        Array<(String, String)>()
    )

    // 返回一个可用的链接
    let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

    // 删除t_test2名称数据表
    var mysqlStatement1: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_clob")
    mysqlStatement1.update()
    mysqlStatement1.close()

    // 创建t_test2名称数据表
    var mysqlStatement2: MysqlStatement = mysqlConnection.prepareStatement(
        "create table t_test_clob(id bigint not null, value1 longtext not null, value2 longtext)")
    mysqlStatement2.update()
    mysqlStatement2.close()

    // 通过传入的 sql 语句，返回一个预执行的 Statement 对象实例
    var mysqlStatement3: MysqlStatement = mysqlConnection.prepareStatement(
        "insert into  t_test_clob(id,value1,value2)  VALUES(?,?,?)")
    @Assert(3, mysqlStatement3.parameterCount)

    // 执行插入语句插入数据
    mysqlStatement3.set<Int64>(0, 1)
    mysqlStatement3.set<Array<Byte>>(1, Array<Byte>(5, repeat: 89))
    mysqlStatement3.setNull(2)
    var mysqlUpdateResult1: MysqlUpdateResult = mysqlStatement3.update()
    @Assert(1, mysqlUpdateResult1.rowCount)

    // 执行插入语句插入数据
    let stream11 = ByteBuffer()
    stream11.write(Array<Byte>(5, repeat: 88))
    let stream22 = ByteBuffer()
    stream22.write(Array<Byte>(5, repeat: 87))
    mysqlStatement3.set<Int64>(0, 2)
    mysqlStatement3.set<ByteBuffer>(1, stream11)
    mysqlStatement3.set<ByteBuffer>(2, stream22)
    var mysqlUpdateResult2: MysqlUpdateResult = mysqlStatement3.update()
    @Assert(1, mysqlUpdateResult2.rowCount)

    // 执行插入语句插入数据
    let stream111 = ByteBuffer()
    stream111.write(Array<Byte>(5, repeat: 86))
    let stream222 = ByteBuffer()
    stream222.write(Array<Byte>(5, repeat: 85))
    mysqlStatement3.set<Int64>(0, 3)
    mysqlStatement3.set<ByteBuffer>(1, stream111)
    mysqlStatement3.set<ByteBuffer>(2, stream222)
    var mysqlUpdateResult3: MysqlUpdateResult = mysqlStatement3.update()
    @Assert(1, mysqlUpdateResult3.rowCount)
    mysqlStatement3.close()

    // 查询语句预执行语句
    var mysqlStatement4: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_clob where id = 1")
    @Assert(0, mysqlStatement4.parameterCount)
    var mysqlQueryResult: MysqlQueryResult = mysqlStatement4.query()

    var isBool: Bool = mysqlQueryResult.next()
    @Assert(true, isBool)
    @Assert(1, mysqlQueryResult.get<Int64>(0))
    @Assert(Array<Byte>(5, repeat: 89), mysqlQueryResult.get<Array<Byte>>(1))
    @Assert(None, mysqlQueryResult.getOrNull<Array<Byte>>(2))

    isBool = mysqlQueryResult.next()
    @Assert(false, isBool)
    mysqlStatement4.close()

    // 删除语句预执行语句
    let mysqlStatement5: MysqlStatement = mysqlConnection.prepareStatement("delete from t_test_clob where id = ?")
    @Assert(1, mysqlStatement5.parameterCount)

    // 执行删除语句
    mysqlStatement5.set<Int64>(0, 1)
    let mysqlUpdateResult4: MysqlUpdateResult = mysqlStatement5.update()
    @Assert(1, mysqlUpdateResult4.rowCount)
    mysqlStatement5.close()

    // 查询语句预执行语句
    let mysqlStatement6: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_clob where id = 1")

    // 执行查询语句
    let mysqlQueryResult1: MysqlQueryResult = mysqlStatement6.query()

    // 获取数据
    isBool = mysqlQueryResult1.next()
    @Assert(false, isBool)
    mysqlStatement6.close()

    // 更新语句预执行语句
    let mysqlStatement7: MysqlStatement = mysqlConnection.prepareStatement(
        "update t_test_clob set value1 = ?, value2 = ?  where id = ?")
    @Assert(3, mysqlStatement7.parameterCount)

    // 执行更新语句
    let stream1111 = ByteBuffer()
    stream1111.write(Array<Byte>(5, repeat: 84))
    let stream2222 = ByteBuffer()
    stream2222.write(Array<Byte>(5, repeat: 83))
    mysqlStatement7.set<Int64>(2, 2)
    mysqlStatement7.set<ByteBuffer>(0, stream1111)
    mysqlStatement7.set<ByteBuffer>(1, stream2222)
    let mysqlUpdateResult5: MysqlUpdateResult = mysqlStatement7.update()
    @Assert(1, mysqlUpdateResult5.rowCount)
    mysqlStatement7.close()

    // 查询语句预执行语句
    let mysqlStatement8: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_clob where id = 2")

    // 执行查询语句
    var mysqlQueryResult2: MysqlQueryResult = mysqlStatement8.query()

    // 获取数据
    isBool = mysqlQueryResult2.next()
    @Assert(true, isBool)
    @Assert(2, mysqlQueryResult2.get<Int64>(0))
    @Assert(Array<Byte>(5, repeat: 84), mysqlQueryResult2.get<Array<Byte>>(1))
    @Assert(Array<Byte>(5, repeat: 83), mysqlQueryResult2.get<Array<Byte>>(2))
    mysqlStatement8.close()

    // 删除t_test名称数据表
    let mysqlStatement9: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_clob")
    mysqlStatement9.update()
    mysqlStatement9.close()

    // 关闭链接
    mysqlConnection.close()

    return 0
}
