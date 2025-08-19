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
        var tran = conn.createTransaction()
        tran.begin()
        var prepareStatement = conn.prepareStatement("drop table if exists test")
        var rowCount = prepareStatement.update()
        tran.commit()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("create table test(data int NOT NULL, datanull int)")
        rowCount = prepareStatement.update()
        tran.commit()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        prepareStatement.set<Int32>(0, Int32.Max)
        prepareStatement.setNull(1)
        rowCount = prepareStatement.update()
        prepareStatement.set<Int32>(0, Int32.Max)
        prepareStatement.setNull(1)
        rowCount = prepareStatement.update()
        tran.commit()
        @Assert(1, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        queryResult.next()
        @Assert("SqlInt32", queryResult.columnInfos[0].typeName)
        @Assert(Int32.Max, queryResult.get<Int32>(0))
        @Assert(None, queryResult.getOrNull<Int32>(1))
        queryResult.close()
        tran.commit()
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("update test set datanull = 10")
        rowCount = prepareStatement.update()
        @Assert(2, rowCount.rowCount)
        tran.commit()
        prepareStatement.close()

        // 删除test名称数据表
        let mysqlStatement9: MysqlStatement = conn.prepareStatement("drop table if exists test")
        mysqlStatement9.update()
        tran.commit()
        mysqlStatement9.close()
        conn.close()
    }
}
