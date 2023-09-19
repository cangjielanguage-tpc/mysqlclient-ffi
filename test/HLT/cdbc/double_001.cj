// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
from std import database.sql.*, io.*, time.*, regex.*
from mysqlclient import mysqlclient.*

@Test
public class OdbcTest {
    init() {}
    @TestCase
    public func test001(): Unit {
        var driver = MysqlDriver("mysql")
        var database = driver.open(
            "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )
        var conn = database.connect()
        var prepareStatement = conn.prepareStatement("drop table if exists test")
        var rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("create table test(data double(5,2) NOT NULL, datanull double)")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        rowCount = prepareStatement.update([SqlDouble(123.45), SqlNullableDouble(None)])
        @Assert(1, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        var arr: Array<SqlDbType> = [SqlDouble(123.45), SqlNullableDouble(None)]
        queryResult.next(arr)
        @Assert("SqlDouble", queryResult.columnInfos[0].typeName)
        match (arr[0]) {
            case v: SqlDouble => @Assert(123.45, v.value)
            case _ => @Assert("abc", "123")
        }
        @Assert("SqlNullableDouble", queryResult.columnInfos[1].typeName)
        match (arr[1]) {
            case v: SqlNullableDouble => @Assert(None, v.value)
            case _ => @Assert("abc", "123")
        }

        // 删除test名称数据表
        let mysqlStatement9: MysqlStatement = conn.prepareStatement("drop table if exists test")
        mysqlStatement9.update()
    }
}
