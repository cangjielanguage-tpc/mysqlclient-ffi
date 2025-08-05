// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
import std.database.sql.*
import std.io.*
import std.time.*
import std.regex.*
import std.math.*
import mysqlclient_ffi.*

@Test
public class OdbcTest {
    init() {}
    @TestCase
    public func test001(): Unit {
        var driver = MysqlDriver("mysql")
        var database = driver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )
        var conn = database.connect()
        var prepareStatement = conn.prepareStatement("drop table if exists test")
        var rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("create table test(data TIMESTAMP NOT NULL, datanull TIMESTAMP)")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        var date = DateTime.of(
            year: 2009,
            month: 11,
            dayOfMonth: 21,
            hour: 13,
            minute: 15,
            second: 35,
            nanosecond: 0,
        )
        prepareStatement.set<MysqlTypeTimeTimestamp>(0, MysqlTypeTimeTimestamp(date))
        prepareStatement.setNull(1)
        rowCount = prepareStatement.update()
        @Assert(1, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        queryResult.next()
        @Assert("SqlMysqlTypeTimeTimestamp", queryResult.columnInfos[0].typeName)
        @Assert("SqlMysqlTypeTimeTimestamp", queryResult.columnInfos[1].typeName)
        let dateTimeQuery1: DateTime = queryResult.get<MysqlTypeTimeTimestamp>(0).value
        @Assert(date.hour, dateTimeQuery1.hour)
        @Assert(date.minute, dateTimeQuery1.minute)
        @Assert(date.second, dateTimeQuery1.second)
        @Assert(date.hour, dateTimeQuery1.hour)
        @Assert(date.minute, dateTimeQuery1.minute)
        @Assert(date.second, dateTimeQuery1.second)
        let dateTimeQuery2: ?MysqlTypeTimeTimestamp = queryResult.getOrNull<MysqlTypeTimeTimestamp>(1)
        match (dateTimeQuery2) {
            case Some(_) => @Assert(0, 1)
            case None => @Assert(1, 1)
        }
        prepareStatement.close()

        // 删除test名称数据表
        let mysqlStatement9: MysqlStatement = conn.prepareStatement("drop table if exists test")
        mysqlStatement9.update()
        mysqlStatement9.close()
        conn.close()
    }
}
