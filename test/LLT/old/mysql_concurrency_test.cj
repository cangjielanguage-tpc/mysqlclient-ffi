// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*
import std.math.*
import std.sync.*

main(): Int64 {
    let mysqlConcurrencyTest :MysqlConcurrencyTest = MysqlConcurrencyTest()

    mysqlConcurrencyTest.mysqlConcurrencyTest01()

    mysqlConcurrencyTest.mysqlConcurrencyTest02()

    return 0

}


@Test
public class MysqlConcurrencyTest {
    @TestCase
    public func mysqlConcurrencyTest01(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )

        // 返回一个可用的链接
        let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

        // 删除t_test名称数据表
        var mysqlStatement: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test_concurrency")

        mysqlStatement.update([])

        mysqlStatement.close()

        // 创建t_test名称数据表
        mysqlStatement = mysqlConnection.prepareStatement(
            "create table t_test_concurrency(id bigint not null, varcharValue1 varchar(5500) not null, varcharValue2 varchar(50)) CHARSET=utf8"
        )
        mysqlStatement.update([])

        mysqlStatement.close()

        // 插入数据预执行语句
        mysqlStatement = mysqlConnection.prepareStatement(
            "insert into  t_test_concurrency(id,varcharValue1,varcharValue2)  VALUES(?,?,?)")
        @Assert(3, mysqlStatement.parameterCount)

        // 插入一条数据
        var id1: SqlBigInt = SqlBigInt(1)
        var varcharValueOne1: SqlVarchar = SqlVarchar("lihao")
        var varcharValueTwo1: SqlNullableVarchar = SqlNullableVarchar("no.1")
        var arrDb1: Array<SqlDbType> = [id1, varcharValueOne1, varcharValueTwo1]
        var mysqlUpdateResult1: MysqlUpdateResult = mysqlStatement.update(arrDb1)
        @Assert(1, mysqlUpdateResult1.rowCount)

        mysqlStatement.close()
        
        mysqlConnection.close()
    }

    @TestCase
    public func mysqlConcurrencyTest02(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            Array<(String, String)>()
        )
        for(i in 0..200){
            let s = spawn{  
                // sleep(Duration.millisecond * i * 10) 
                // 返回一个可用的链接
                 let mysqlConnection: MysqlConnection = mysqlDatasource.connect()  
                // 查询语句
                let mysqlStatement4: MysqlStatement = mysqlConnection.prepareStatement(
                    "select * from t_test_concurrency where id = ?")
                // 查询字段
                let id6: SqlBigInt = SqlBigInt(1)
                var arrDb6: Array<SqlDbType> = [id6]
                // 开始查询
                var mysqlQueryResult2: MysqlQueryResult = mysqlStatement4.query(arrDb6)
                // 结果集字段
                var id7: SqlBigInt = SqlBigInt(1)
                var varcharValueOne7: SqlVarchar = SqlVarchar("")
                var varcharValueTwo7: SqlNullableVarchar = SqlNullableVarchar("")
                var arrDb7: Array<SqlDbType> = [id7, varcharValueOne7, varcharValueTwo7]
                // 查询结果集
                var isBool2: Bool = mysqlQueryResult2.next(arrDb7)
                @Assert(true, isBool2)
                // 关闭结果集
                mysqlQueryResult2.close()
                // 关闭预执行语句
                mysqlStatement4.close() 
                // 关闭链接
                mysqlConnection.close()
                println("chenggong ${i}")
            }
        }
        sleep(Duration.second * 15)
    }
}