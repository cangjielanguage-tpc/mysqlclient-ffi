// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
from std import database.sql.*, io.*, time.*, regex.*, math.*
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
        var tran = conn.createTransaction()
        tran.begin()
        var prepareStatement = conn.prepareStatement("drop table if exists test")
        var rowCount = prepareStatement.update()
        tran.commit()
        @Assert(0, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("create table test(data int NOT NULL, datanull int)")
        rowCount = prepareStatement.update()
        tran.commit()
        @Assert(0, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        rowCount = prepareStatement.update([SqlInteger(Int32.Max), SqlNullableInteger(None)])
        rowCount = prepareStatement.update([SqlInteger(Int32.Max), SqlNullableInteger(None)])
        tran.commit()
        @Assert(1, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        var arr: Array<SqlDbType> = [SqlInteger(Int32.Max), SqlNullableInteger(None)]
        queryResult.next(arr)
        @Assert("SqlInteger", queryResult.columnInfos[0].typeName)
        match (arr[0]) {
            case v: SqlInteger => @Assert(Int32.Max, v.value)
            case _ => @Assert("abc", "123")
        }
        @Assert("SqlNullableInteger", queryResult.columnInfos[1].typeName)
        match (arr[1]) {
            case v: SqlNullableInteger => @Assert(None, v.value)
            case _ => @Assert("abc", "123")
        }
        queryResult.close()
        tran.commit()

        prepareStatement = conn.prepareStatement("update test set datanull = 10")
        rowCount = prepareStatement.update()
        @Assert(2, rowCount.rowCount)
        tran.commit()

        // 删除test名称数据表
        let mysqlStatement9: MysqlStatement = conn.prepareStatement("drop table if exists test")
        mysqlStatement9.update()
        tran.commit()
    }
}
