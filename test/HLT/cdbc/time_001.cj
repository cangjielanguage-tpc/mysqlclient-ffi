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
        prepareStatement = conn.prepareStatement("create table test(data time NOT NULL, datanull time)")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        var date = DateTime.of(
            year: 1970,
            month: 1,
            dayOfMonth: 1,
            hour: 10,
            minute: 10,
            second: 10,
            nanosecond: 0,
        )
        prepareStatement.set<MysqlTypeTime>(0, MysqlTypeTime(date))
        prepareStatement.setNull(1)
        rowCount = prepareStatement.update()
        @Assert(1, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        queryResult.next()
        @Assert("SqlMysqlTypeTime", queryResult.columnInfos[0].typeName)
        @Assert("SqlMysqlTypeTime", queryResult.columnInfos[1].typeName)
        let dateTimeQuery1: DateTime = queryResult.get<MysqlTypeTime>(0).value
        @Assert(10, dateTimeQuery1.hour)
        @Assert(10, dateTimeQuery1.minute)
        @Assert(10, dateTimeQuery1.second)
        let dateTimeQuery2: ?MysqlTypeTime = queryResult.getOrNull<MysqlTypeTime>(1)
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
