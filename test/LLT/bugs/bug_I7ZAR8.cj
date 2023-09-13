// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from mysqlclient import mysqlclient.*
from std import unittest.*
from std import unittest.testmacro.*
from std import database.sql.*
from std import time.*

/*
 * 事务设置ReadUncommitted级别报错
 */
main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        Array<(String, String)>()
    )

    // 返回一个可用的链接
    let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

    // 创建事务对象
    let mysqlTransaction: MysqlTransaction = mysqlConnection.createTransaction()

    mysqlTransaction.isoLevel = TransactionIsoLevel.ReadUncommitted

    let res = match (mysqlTransaction.isoLevel) {
        case TransactionIsoLevel.ReadUncommitted => 0
        case _ => 1
    }
    @Assert(0, res)

    mysqlConnection.close()

    return 0
}
