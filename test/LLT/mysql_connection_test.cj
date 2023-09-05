// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from mysqlclient import mysqlclient.*
from std import unittest.*
from std import unittest.testmacro.*
from std import database.sql.*
from std import time.*

main(): Int64 {
    let mysqlConnectionTest: MysqlConnectionTest = MysqlConnectionTest()

    mysqlConnectionTest.mysqlConnectionTest01()

    return 0
}

@Test
public class MysqlConnectionTest {
    @TestCase
    public func mysqlConnectionTest01(): Unit {
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )

        // 返回一个可用的链接
        let mysqlConnection: MysqlConnection = mysqlDatasource.connect()
        mysqlConnection.getMetaData()
        mysqlConnection.setOption(MysqlSetOption.MYSQL_OPTION_MULTI_STATEMENTS_OFF)
        mysqlConnection.setOption(MysqlSetOption.MYSQL_OPTION_MULTI_STATEMENTS_ON)
        mysqlConnection.mysqlPing()
        @Assert(false, mysqlConnection.isClosed())
    }
}
