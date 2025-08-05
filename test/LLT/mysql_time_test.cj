// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*

main(): Int64 {
    let mysqlTimeTest: MysqlTimeTest = MysqlTimeTest()

    mysqlTimeTest.mysqlTimeTest01()

    return 0
}

/*
 * +------------+--------+------+-----+---------+-------+
 * | Field      | Type   | Null | Key | Default | Extra |
 * +------------+--------+------+-----+---------+-------+
 * | id         | bigint | NO   |     | NULL    |       |
 * | timeValue1 | time   | NO   |     | NULL    |       |
 * | timeValue2 | time   | YES  |     | NULL    |       |
 * +------------+--------+------+-----+---------+-------+
 */
@Test
public class MysqlTimeTest {
    @TestCase
    public func mysqlTimeTest01(): Unit {
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
        var mysqlStatement1: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_time")
        mysqlStatement1.update()
        mysqlStatement1.close()

        // 创建t_test2名称数据表
        var mysqlStatement2: MysqlStatement = mysqlConnection.prepareStatement(
            "create table t_test_time(id bigint not null, timeValue1 time not null, timeValue2 time)")
        mysqlStatement2.update()
        mysqlStatement2.close()

        // 通过传入的 sql 语句，返回一个预执行的 Statement 对象实例
        var mysqlStatement3: MysqlStatement = mysqlConnection.prepareStatement(
            "insert into  t_test_time(id,timeValue1,timeValue2)  VALUES(?,?,?)")
        @Assert(3, mysqlStatement3.parameterCount)

        // 执行插入语句插入数据  
        let dateTime1: DateTime = DateTime.nowUTC()
        mysqlStatement3.set<Int64>(0, 1)
        mysqlStatement3.set<MysqlTypeTime>(1, MysqlTypeTime(dateTime1))
        mysqlStatement3.setNull(2)
        var mysqlUpdateResult1: MysqlUpdateResult = mysqlStatement3.update()
        @Assert(1, mysqlUpdateResult1.rowCount)
        @Assert(0, mysqlUpdateResult1.lastInsertId)

        // 执行插入语句插入数据       
        let dateTime2: DateTime = DateTime.of(year: 1, month: 1, dayOfMonth: 1, hour: 8, minute: 10, second: 30)
        let dateTime3: DateTime = DateTime.of(year: 1, month: 1, dayOfMonth: 1, hour: 12, minute: 5, second: 3)
        mysqlStatement3.set<Int64>(0, 2)
        mysqlStatement3.set<MysqlTypeTime>(1, MysqlTypeTime(dateTime2))
        mysqlStatement3.set<MysqlTypeTime>(2, MysqlTypeTime(dateTime3))
        var mysqlUpdateResult2: MysqlUpdateResult = mysqlStatement3.update()
        @Assert(1, mysqlUpdateResult2.rowCount)

        // 执行插入语句插入数据
        let dateTime4: DateTime = DateTime.of(year: 1, month: 1, dayOfMonth: 1, hour: 18, minute: 20, second: 40)
        let dateTime5: DateTime = DateTime.of(year: 1, month: 1, dayOfMonth: 1, hour: 22, minute: 35, second: 53)
        mysqlStatement3.set<Int64>(0, 3)
        mysqlStatement3.set<MysqlTypeTime>(1, MysqlTypeTime(dateTime4))
        mysqlStatement3.set<MysqlTypeTime>(2, MysqlTypeTime(dateTime5))
        var mysqlUpdateResult3: MysqlUpdateResult = mysqlStatement3.update()
        @Assert(1, mysqlUpdateResult3.rowCount)
        mysqlStatement3.close()

        // 查询语句预执行语句
        var mysqlStatement4: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_time where id = 1")
        @Assert(0, mysqlStatement4.parameterCount)
        var mysqlQueryResult: MysqlQueryResult = mysqlStatement4.query()
        let mysqlColumnInfos: Array<MysqlColumnInfo> = mysqlQueryResult.mysqlColumnInfos

        @Assert("id", mysqlColumnInfos[0].name)
        @Assert("SqlInt64", mysqlColumnInfos[0].typeName)
        @Assert(0, mysqlColumnInfos[0].displaySize)
        @Assert(20, mysqlColumnInfos[0].length)
        @Assert(0, mysqlColumnInfos[0].scale)
        @Assert(true, mysqlColumnInfos[0].nullable)

        @Assert("timeValue1", mysqlColumnInfos[1].name)
        @Assert("SqlMysqlTypeTime", mysqlColumnInfos[1].typeName)
        @Assert(0, mysqlColumnInfos[1].displaySize)
        @Assert(10, mysqlColumnInfos[1].length)
        @Assert(0, mysqlColumnInfos[1].scale)
        @Assert(true, mysqlColumnInfos[1].nullable)

        @Assert("timeValue2", mysqlColumnInfos[2].name)
        @Assert("SqlMysqlTypeTime", mysqlColumnInfos[2].typeName)
        @Assert(0, mysqlColumnInfos[2].displaySize)
        @Assert(10, mysqlColumnInfos[2].length)
        @Assert(0, mysqlColumnInfos[2].scale)
        @Assert(false, mysqlColumnInfos[2].nullable)

        var isBool: Bool = mysqlQueryResult.next()
        @Assert(true, isBool)
        @Assert(1, mysqlQueryResult.get<Int64>(0))
        let dateTimeQuery: DateTime = mysqlQueryResult.get<MysqlTypeTime>(1).value
        @Assert(dateTime1.hour, dateTimeQuery.hour)
        @Assert(dateTime1.minute, dateTimeQuery.minute)
        @Assert(dateTime1.second, dateTimeQuery.second)
        let mysqlTypeDate: ?MysqlTypeTime = mysqlQueryResult.getOrNull<MysqlTypeTime>(2)
        match (mysqlTypeDate) {
            case Some(_) => @Assert(0, 1)
            case None => @Assert(1, 1)
        }

        isBool = mysqlQueryResult.next()
        @Assert(false, isBool)
        mysqlStatement4.close()

        // 删除语句预执行语句
        let mysqlStatement5: MysqlStatement = mysqlConnection.prepareStatement("delete from t_test_time where id = ?")
        @Assert(1, mysqlStatement5.parameterCount)

        // 执行删除语句 
        mysqlStatement5.set<Int64>(0, 1)
        let mysqlUpdateResult4: MysqlUpdateResult = mysqlStatement5.update()
        @Assert(1, mysqlUpdateResult4.rowCount)
        mysqlStatement5.close()

        // 查询语句预执行语句
        let mysqlStatement6: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_time where id = 1")

        // 执行查询语句
        let mysqlQueryResult1: MysqlQueryResult = mysqlStatement6.query()

        // 获取数据
        isBool = mysqlQueryResult1.next()
        @Assert(false, isBool)
        mysqlStatement6.close()

        // 更新语句预执行语句
        let mysqlStatement7: MysqlStatement = mysqlConnection.prepareStatement(
            "update t_test_time set timeValue1 = ?, timeValue2 = ?  where id = ?")
        @Assert(3, mysqlStatement7.parameterCount)

        // 执行更新语句 
        let dateTime6: DateTime = DateTime.of(year: 1, month: 1, dayOfMonth: 1, hour: 9, minute: 11, second: 31)
        let dateTime7: DateTime = DateTime.of(year: 1, month: 1, dayOfMonth: 1, hour: 13, minute: 6, second: 4)
        mysqlStatement7.set<Int64>(2, 2)
        mysqlStatement7.set<MysqlTypeTime>(0, MysqlTypeTime(dateTime6))
        mysqlStatement7.set<MysqlTypeTime>(1, MysqlTypeTime(dateTime7))
        let mysqlUpdateResult5: MysqlUpdateResult = mysqlStatement7.update()
        @Assert(1, mysqlUpdateResult5.rowCount)
        mysqlStatement7.close()

        // 查询语句预执行语句
        let mysqlStatement8: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_time where id = 2")

        // 执行查询语句
        var mysqlQueryResult2: MysqlQueryResult = mysqlStatement8.query()

        // 获取数据
        isBool = mysqlQueryResult2.next()
        @Assert(true, isBool)
        @Assert(2, mysqlQueryResult2.get<Int64>(0))
        let dateTimeQuery1: DateTime = mysqlQueryResult2.get<MysqlTypeTime>(1).value
        @Assert(9, dateTimeQuery1.hour)
        @Assert(11, dateTimeQuery1.minute)
        @Assert(31, dateTimeQuery1.second)
        let dateTimeQuery2: DateTime = mysqlQueryResult2.get<MysqlTypeTime>(2).value
        @Assert(13, dateTimeQuery2.hour)
        @Assert(6, dateTimeQuery2.minute)
        @Assert(4, dateTimeQuery2.second)
        mysqlStatement8.close()

        // 删除t_test名称数据表
        let mysqlStatement9: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_time")
        mysqlStatement9.update()
        mysqlStatement9.close()

        // 关闭链接
        mysqlConnection.close()
    }
}
