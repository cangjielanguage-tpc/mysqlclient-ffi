// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
import std.database.sql.*
import std.io.*
import std.time.*
import std.regex.*
import std.math.*
import mysqlclient_ffi.*

@Test
public class blob_003 {
    var conn: MysqlConnection
    var prepareStatement: MysqlStatement
    var rowCount: MysqlUpdateResult
    init() {
        var driver = MysqlDriver("mysql")
        var database = driver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )
        conn = database.connect()
        prepareStatement = conn.prepareStatement("drop table if exists test")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("create table test(data blob(20) NOT NULL, datanull blob(20))")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement.close()
    }

    @TestCase
    public func blob_003(): Unit {
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        let a: Array<Byte> = [11, 22, 33, 44, 55, 66, 77, 88]
        var str = ByteBuffer(20)
        str.write(a)
        prepareStatement.set<ByteBuffer>(0, str)
        prepareStatement.setNull(1)
        rowCount = prepareStatement.update()
        @Assert(1, rowCount.rowCount)
        prepareStatement.close()
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        queryResult.next()
        @Assert("SqlArrayByte", queryResult.columnInfos[0].typeName)
        @Assert(a, queryResult.get<Array<Byte>>(0))
        @Assert(None, queryResult.getOrNull<Array<Byte>>(1))
        prepareStatement.close()

        // 删除test名称数据表
        let mysqlStatement9: MysqlStatement = conn.prepareStatement("drop table if exists test")
        mysqlStatement9.update()
        mysqlStatement9.close()
        conn.close()
    }
}
