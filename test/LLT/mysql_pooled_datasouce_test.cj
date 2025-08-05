// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*

main(): Int64 {
    let mysqlPooledDatasouceTest: MysqlPooledDatasouceTest = MysqlPooledDatasouceTest()

    mysqlPooledDatasouceTest.mysqlPooledDatasouceTest01()

    return 0
}

@Test
public class MysqlPooledDatasouceTest {
    @TestCase
    public func mysqlPooledDatasouceTest01(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0")
        // 数据库连接池
        var pooledDatasource: PooledDatasource = PooledDatasource(mysqlDatasource)
        // 获取链接
        let connection: Connection = pooledDatasource.connect()
        // 删除表格，防止表格冲突
        var statement: Statement = connection.prepareStatement("drop table if exists t_test10000")
        @Assert(0, statement.parameterColumnInfos.size)
        statement.update()
        statement.close()
        // 创建t_test10000名称数据表
        var statement1: Statement = connection.prepareStatement("create table t_test10000(id bigint,name varchar(50))")
        @Assert(0, statement1.parameterColumnInfos.size)
        statement1.update()
        statement1.close()
        // 通过传入的 sql 语句，返回一个预执行的 Statement 对象实例，插入数据
        var statement2: Statement = connection.prepareStatement("insert into t_test10000(id,name) VALUES(?,?)")
        statement2.set<Int64>(0, 1)
        statement2.set<String>(1, "lihao111")
        var updateResult: UpdateResult = statement2.update()
        @Assert(1, updateResult.rowCount)
        statement2.close()
        // 查询语句预执行语句
        var statement3: Statement = connection.prepareStatement("select * from t_test10000 where id = ?")
        statement3.set<Int64>(0, 1)
        var queryResult: QueryResult = statement3.query()
        let columnInfos: Array<ColumnInfo> = queryResult.columnInfos
        @Assert(2, columnInfos.size)
        var isBool: Bool = queryResult.next()
        @Assert(true, isBool)
        @Assert(1, queryResult.get<Int64>(0))
        @Assert("lihao111", queryResult.get<String>(1))
        var isBool1: Bool = queryResult.next()
        @Assert(false, isBool1)
        queryResult.close()
        statement3.close()
        // 关闭当前链接
        connection.close()
        // 关闭连接池中的所有连接并阻止其它连接请求调用该方法会阻塞至所有连接关闭并归还到连接池
        if (pooledDatasource.isClosed()) {
            pooledDatasource.close()
        }
    }
}
