// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
from mysqlclient import mysqlclient.*
from std import unittest.*
from std import unittest.testmacro.*
from std import database.sql.*
from std import time.*

@Test
public class MysqlSslApiTest {
    @TestCase
    func mysqlSslApiTest001(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )

        // 返回一个可用的链接
        let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

        let mysqlSslApi: MysqlSslApi = MysqlSslApi(mysqlConnection)

        var isBool: Bool = mysqlSslApi.mysqlSslSet("", "", "", "", "")
        @Assert(false, isBool)

        var strCipher: String = mysqlSslApi.mysqlGetSslCipher()
        @Assert("", strCipher)

        isBool = mysqlSslApi.mysqlGetSslSessionReused()
        @Assert(false, isBool)

        mysqlSslApi.mysqlGetSslSessionData(0, CPointer<UInt32>())

        isBool = mysqlSslApi.mysqlFreeSslSessionData(CPointer<Unit>())
        @Assert(true, isBool)

        mysqlConnection.close()
    }
}
