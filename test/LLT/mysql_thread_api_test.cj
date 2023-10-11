// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from mysqlclient import mysqlclient.*
from std import unittest.*
from std import unittest.testmacro.*
from std import database.sql.*
from std import time.*
from std import math.*

main(): Int64 {
    let mysqlThreadApiTest: MysqlThreadApiTest = MysqlThreadApiTest()

    mysqlThreadApiTest.mysqlThreadApiTest001()

    return 0
}

@Test
public class MysqlThreadApiTest {
    @TestCase
    func mysqlThreadApiTest001(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
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
