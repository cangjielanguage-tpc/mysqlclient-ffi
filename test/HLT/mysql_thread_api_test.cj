// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
// 3rd_party_lib_ohos:mysqlclient-ffi/build/aarch64-linux-ohos/mysqlclient
from mysqlclient import mysqlclient.*
from std import unittest.*
from std import unittest.testmacro.*

@Test
public class MysqlThreadApiTest {
    @TestCase
    func mysqlThreadApiTest001(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )

        // 返回一个可用的链接
        let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

        let mysqlthreadApi: MysqlthreadApi = MysqlthreadApi(mysqlConnection)

        let ret1 = mysqlthreadApi.mysqlThreadId()
        mysqlthreadApi.mysqlThreadEnd()

        let retBool = mysqlthreadApi.mysqlThreadInit()
        let ret2 = mysqlthreadApi.mysqlThreadId()

        @Assert(ret1, ret2)
        @Assert(false, retBool)

        mysqlConnection.close()
    }
}
