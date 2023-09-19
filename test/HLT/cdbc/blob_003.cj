// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
from std import database.sql.*, io.*, time.*, regex.*
from mysqlclient import mysqlclient.*

@Test
public class blob_003 {
    var conn: MysqlConnection
    var prepareStatement: MysqlStatement
    var rowCount: MysqlUpdateResult
    init() {
        var driver = MysqlDriver("mysql")
        var database = driver.open(
            "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )
        conn = database.connect()
        prepareStatement = conn.prepareStatement("drop table if exists test")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("create table test(data blob(20) NOT NULL, datanull blob(20))")
        rowCount = prepareStatement.update()
        @Assert(0, rowCount.rowCount)
    }
    @TestCase
    public func blob_003(): Unit {
        prepareStatement = conn.prepareStatement("insert into test values(?,?)")
        var str = ByteArrayStream(20)
        str.write([11, 22, 33, 44, 55, 66, 77, 88])
        rowCount = prepareStatement.update([SqlBlob(str), SqlNullableBlob(None)])
        @Assert(1, rowCount.rowCount)
        prepareStatement = conn.prepareStatement("select * from test")
        var queryResult = prepareStatement.query()
        var arr: Array<SqlDbType> = [SqlBlob(str), SqlNullableBlob(None)]
        queryResult.next(arr)
        @Assert("SqlBlob", queryResult.columnInfos[0].typeName)
        match (arr[0]) {
            case v: SqlBlob =>
                var a = Array<UInt8>(v.value.length, item: 0)
                v.value.read(a)
                @Assert([11, 22, 33, 44, 55, 66, 77, 88].toString(), a.toString())
            case _ => @Assert("abc", "123")
        }
        @Assert("SqlNullableBlob", queryResult.columnInfos[1].typeName)
        match (arr[1]) {
            case v: SqlNullableBlob =>
                match (v.value) {
                    case Some(v) =>
                        var a = Array<UInt8>(v.length, item: 0)
                        v.read(a)
                        @Assert(None<Array<UInt8>>, a)
                    case None => @Assert(None<String>, None<String>)
                }
            case _ => @Assert("abc", "123")
        }

        // 删除test名称数据表
        let mysqlStatement9: MysqlStatement = conn.prepareStatement("drop table if exists test")
        mysqlStatement9.update()
    }
}
