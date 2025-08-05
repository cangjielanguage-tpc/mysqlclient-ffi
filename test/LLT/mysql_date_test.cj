// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*

main(): Int64 {
    let mysqlDateTest: MysqlDateTest = MysqlDateTest()

    mysqlDateTest.mysqlDateTest01()

    return 0
}

/*
 * +------------+--------+------+-----+---------+-------+
 * | Field      | Type   | Null | Key | Default | Extra |
 * +------------+--------+------+-----+---------+-------+
 * | id         | bigint | NO   |     | NULL    |       |
 * | dateValue1 | date   | NO   |     | NULL    |       |
 * | dateValue2 | date   | YES  |     | NULL    |       |
 * +------------+--------+------+-----+---------+-------+
 */
@Test
public class MysqlDateTest {
    @TestCase
    public func mysqlDateTest01(): Unit {
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
        var mysqlStatement1: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_date")
        mysqlStatement1.update()
        mysqlStatement1.close()

        // 创建t_test2名称数据表
        var mysqlStatement2: MysqlStatement = mysqlConnection.prepareStatement(
            "create table t_test_date(id bigint not null, dateValue1 date not null, dateValue2 date)")
        mysqlStatement2.update()
        mysqlStatement2.close()

        // 通过传入的 sql 语句，返回一个预执行的 Statement 对象实例
        var mysqlStatement3: MysqlStatement = mysqlConnection.prepareStatement(
            "insert into  t_test_date(id,dateValue1,dateValue2)  VALUES(?,?,?)")
        @Assert(3, mysqlStatement3.parameterCount)

        // 执行插入语句插入数据
        let dateTime1: DateTime = DateTime.nowUTC()
        mysqlStatement3.set<Int64>(0, 1)
        mysqlStatement3.set<MysqlTypeDate>(1, MysqlTypeDate(dateTime1))
        mysqlStatement3.setNull(2)
        var mysqlUpdateResult1: MysqlUpdateResult = mysqlStatement3.update()
        @Assert(1, mysqlUpdateResult1.rowCount)

        // 执行插入语句插入数据
        let dateTime2: DateTime = DateTime.of(year: 2011, month: 10, dayOfMonth: 30)
        let dateTime3: DateTime = DateTime.of(year: 1993, month: 5, dayOfMonth: 3)
        mysqlStatement3.set<Int64>(0, 2)
        mysqlStatement3.set<MysqlTypeDate>(1, MysqlTypeDate(dateTime2))
        mysqlStatement3.set<MysqlTypeDate>(2, MysqlTypeDate(dateTime3))
        var mysqlUpdateResult2: MysqlUpdateResult = mysqlStatement3.update()
        @Assert(1, mysqlUpdateResult2.rowCount)

        // 执行插入语句插入数据
        let dateTime4: DateTime = DateTime.of(year: 2010, month: 9, dayOfMonth: 29)
        let dateTime5: DateTime = DateTime.of(year: 1992, month: 4, dayOfMonth: 18)
        mysqlStatement3.set<Int64>(0, 3)
        mysqlStatement3.set<MysqlTypeDate>(1, MysqlTypeDate(dateTime4))
        mysqlStatement3.set<MysqlTypeDate>(2, MysqlTypeDate(dateTime5))
        var mysqlUpdateResult3: MysqlUpdateResult = mysqlStatement3.update()
        @Assert(1, mysqlUpdateResult3.rowCount)
        mysqlStatement3.close()

        // 查询语句预执行语句
        var mysqlStatement4: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_date where id = 1")
        @Assert(0, mysqlStatement4.parameterCount)
        var mysqlQueryResult: MysqlQueryResult = mysqlStatement4.query()
        let mysqlColumnInfos: Array<MysqlColumnInfo> = mysqlQueryResult.mysqlColumnInfos

        @Assert("id", mysqlColumnInfos[0].name)
        @Assert("SqlInt64", mysqlColumnInfos[0].typeName)
        @Assert(0, mysqlColumnInfos[0].displaySize)
        @Assert(20, mysqlColumnInfos[0].length)
        @Assert(0, mysqlColumnInfos[0].scale)
        @Assert(true, mysqlColumnInfos[0].nullable)

        @Assert("dateValue1", mysqlColumnInfos[1].name)
        @Assert("SqlMysqlTypeDate", mysqlColumnInfos[1].typeName)
        @Assert(0, mysqlColumnInfos[1].displaySize)
        @Assert(10, mysqlColumnInfos[1].length)
        @Assert(0, mysqlColumnInfos[1].scale)
        @Assert(true, mysqlColumnInfos[1].nullable)

        @Assert("dateValue2", mysqlColumnInfos[2].name)
        @Assert("SqlMysqlTypeDate", mysqlColumnInfos[2].typeName)
        @Assert(0, mysqlColumnInfos[2].displaySize)
        @Assert(10, mysqlColumnInfos[2].length)
        @Assert(0, mysqlColumnInfos[2].scale)
        @Assert(false, mysqlColumnInfos[2].nullable)

        var isBool: Bool = mysqlQueryResult.next()
        @Assert(true, isBool)
        @Assert(1, mysqlQueryResult.get<Int64>(0))
        let dateTimeQuery: DateTime = mysqlQueryResult.get<MysqlTypeDate>(1).value
        @Assert(dateTime1.year, dateTimeQuery.year)
        @Assert(dateTime1.month, dateTimeQuery.month)
        @Assert(dateTime1.dayOfMonth, dateTimeQuery.dayOfMonth)
        let mysqlTypeDate: ?MysqlTypeDate = mysqlQueryResult.getOrNull<MysqlTypeDate>(2)
        match (mysqlTypeDate) {
            case Some(_) => @Assert(0, 1)
            case None => @Assert(1, 1)
        }

        isBool = mysqlQueryResult.next()
        @Assert(false, isBool)
        mysqlStatement4.close()

        // 删除语句预执行语句
        let mysqlStatement5: MysqlStatement = mysqlConnection.prepareStatement("delete from t_test_date where id = ?")
        @Assert(1, mysqlStatement5.parameterCount)

        // 执行删除语句
        mysqlStatement5.set<Int64>(0, 1)
        let mysqlUpdateResult4: MysqlUpdateResult = mysqlStatement5.update()
        @Assert(1, mysqlUpdateResult4.rowCount)
        mysqlStatement5.close()

        // 查询语句预执行语句
        let mysqlStatement6: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_date where id = 1")

        // 执行查询语句
        let mysqlQueryResult1: MysqlQueryResult = mysqlStatement6.query()

        // 获取数据
        isBool = mysqlQueryResult1.next()
        @Assert(false, isBool)
        mysqlStatement6.close()

        // 更新语句预执行语句
        let mysqlStatement7: MysqlStatement = mysqlConnection.prepareStatement(
            "update t_test_date set dateValue1 = ?, dateValue2 = ?  where id = ?")
        @Assert(3, mysqlStatement7.parameterCount)

        // 执行更新语句
        let dateTime6: DateTime = DateTime.of(year: 1840, month: 1, dayOfMonth: 1)
        let dateTime7: DateTime = DateTime.of(year: 1841, month: 2, dayOfMonth: 2)
        mysqlStatement7.set<Int64>(2, 2)
        mysqlStatement7.set<MysqlTypeDate>(0, MysqlTypeDate(dateTime6))
        mysqlStatement7.set<MysqlTypeDate>(1, MysqlTypeDate(dateTime7))
        let mysqlUpdateResult5: MysqlUpdateResult = mysqlStatement7.update()
        @Assert(1, mysqlUpdateResult5.rowCount)
        mysqlStatement7.close()

        // 查询语句预执行语句
        let mysqlStatement8: MysqlStatement = mysqlConnection.prepareStatement("select * from t_test_date where id = 2")

        // 执行查询语句
        var mysqlQueryResult2: MysqlQueryResult = mysqlStatement8.query()

        // 获取数据
        isBool = mysqlQueryResult2.next()
        @Assert(true, isBool)
        @Assert(2, mysqlQueryResult2.get<Int64>(0))
        let dateTimeQuery1: DateTime = mysqlQueryResult2.get<MysqlTypeDate>(1).value
        @Assert(1840, dateTimeQuery1.year)
        @Assert(1, dateTimeQuery1.month.toInteger())
        @Assert(1, dateTimeQuery1.dayOfMonth)
        let dateTimeQuery2: DateTime = mysqlQueryResult2.get<MysqlTypeDate>(2).value
        @Assert(1841, dateTimeQuery2.year)
        @Assert(2, dateTimeQuery2.month.toInteger())
        @Assert(2, dateTimeQuery2.dayOfMonth)
        mysqlStatement8.close()

        // 删除t_test名称数据表
        let mysqlStatement9: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_date")
        mysqlStatement9.update()
        mysqlStatement9.close()

        // 关闭链接
        mysqlConnection.close()
    }
}
