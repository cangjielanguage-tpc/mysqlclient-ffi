// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*
import std.io.*

main(): Int64 {
    let mysqlVarVarBinaryTest: MysqlVarVarBinaryTest = MysqlVarVarBinaryTest()

    mysqlVarVarBinaryTest.MysqlVarVarBinaryTest01()

    return 0
}

@Test
public class MysqlVarVarBinaryTest {
    /*
     * +-------+-------------+------+-----+---------+-------+
     * | Field | Type        | Null | Key | Default | Extra |
     * +-------+-------------+------+-----+---------+-------+
     * | id    | bigint      | YES  |     | NULL    |       |
     * | name  | VarBinary(50)| YES |     | NULL    |       |
     * +-------+-------------+------+-----+---------+-------+
     */
    @TestCase
    public func MysqlVarVarBinaryTest01(): Unit {
        // 初始化数据库驱动
        let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
        @Assert(true, mysqlDriver.name.size > 0)
        @Assert(true, mysqlDriver.version.size > 0)
        let arr: Array<(String, String)> = Array<(String, String)>()

        // 通过connectionString和选项打开数据源
        let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
            "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
            arr
        )

        // 返回一个可用的链接
        let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

        // 删除t_test名称数据表
        var mysqlStatement: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test")
        mysqlStatement.update()
        mysqlStatement.close()

        // 创建t_test名称数据表
        mysqlStatement = mysqlConnection.prepareStatement("create table t_test(id bigint, name VarBinary(50))")
        mysqlStatement.update()
        mysqlStatement.close()

        // 插入数据预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("insert into  t_test(id,name)  VALUES(?,?)")
        @Assert(2, mysqlStatement.parameterCount)

        // 执行插入语句插入数据
        mysqlStatement.set<Int64>(0, 1)
        mysqlStatement.set<Array<Byte>>(1, Array<Byte>(50, repeat: 89))
        var mysqlUpdateResult: MysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)

        // 执行插入语句插入空数据2
        mysqlStatement.set<Int64>(0, 2)
        mysqlStatement.set<Array<Byte>>(1, Array<Byte>())
        mysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)
        mysqlStatement.close()

        // 查询语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("select * from t_test where id = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行查询语句
        mysqlStatement.set<Int64>(0, 2)
        var mysqlQueryResult: MysqlQueryResult = mysqlStatement.query()
        let mysqlColumnInfos: Array<MysqlColumnInfo> = mysqlQueryResult.mysqlColumnInfos
        @Assert(2, mysqlColumnInfos.size)

        @Assert("id", mysqlColumnInfos[0].name)
        @Assert("SqlInt64", mysqlColumnInfos[0].typeName)
        @Assert(0, mysqlColumnInfos[0].displaySize)
        @Assert(20, mysqlColumnInfos[0].length)
        @Assert(0, mysqlColumnInfos[0].scale)
        @Assert(false, mysqlColumnInfos[0].nullable)

        @Assert("name", mysqlColumnInfos[1].name)
        @Assert("SqlString", mysqlColumnInfos[1].typeName)
        @Assert(0, mysqlColumnInfos[1].displaySize)
        @Assert(50, mysqlColumnInfos[1].length)
        @Assert(0, mysqlColumnInfos[1].scale)
        @Assert(false, mysqlColumnInfos[1].nullable)

        // 获取数据
        var isBool: Bool = mysqlQueryResult.next()
        @Assert(true, isBool)
        @Assert(2, mysqlQueryResult.get<Int64>(0))
        @Assert("", mysqlQueryResult.get<String>(1))
        mysqlStatement.close()

        // 删除语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("delete from t_test where name = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行删除语句
        mysqlStatement.set<Array<Byte>>(0, Array<Byte>(50, repeat: 89))
        mysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)
        mysqlStatement.close()

        // 查询语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("select * from t_test where id = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行查询语句
        mysqlStatement.set<Int64>(0, 1)
        mysqlQueryResult = mysqlStatement.query()

        // 获取数据
        isBool = mysqlQueryResult.next()
        @Assert(false, isBool)
        mysqlStatement.close()

        // 更新语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("update t_test set name = ? where id = ?")
        @Assert(2, mysqlStatement.parameterCount)

        // 执行更新语句
        mysqlStatement.set<Int64>(1, 2)
        mysqlStatement.set<Array<Byte>>(0, Array<Byte>(10, repeat: 55))
        mysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)
        mysqlStatement.close()

        // 查询语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("select * from t_test where id = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行查询语句
        mysqlStatement.set<Int64>(0, 2)
        mysqlQueryResult = mysqlStatement.query()

        @Assert(2, mysqlColumnInfos.size)

        @Assert("id", mysqlColumnInfos[0].name)
        @Assert("SqlInt64", mysqlColumnInfos[0].typeName)
        @Assert(0, mysqlColumnInfos[0].displaySize)
        @Assert(20, mysqlColumnInfos[0].length)
        @Assert(0, mysqlColumnInfos[0].scale)
        @Assert(false, mysqlColumnInfos[0].nullable)

        @Assert("name", mysqlColumnInfos[1].name)
        @Assert("SqlString", mysqlColumnInfos[1].typeName)
        @Assert(0, mysqlColumnInfos[1].displaySize)
        @Assert(50, mysqlColumnInfos[1].length)
        @Assert(0, mysqlColumnInfos[1].scale)
        @Assert(false, mysqlColumnInfos[1].nullable)

        // 获取数据
        isBool = mysqlQueryResult.next()
        @Assert(true, isBool)
        @Assert(2, mysqlQueryResult.get<Int64>(0))
        @Assert(String.fromUtf8(Array<Byte>(10, repeat: 55)), mysqlQueryResult.get<String>(1))
        mysqlStatement.close()

        //删除t_test名称数据表
        mysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test")
        mysqlStatement.update()
        mysqlStatement.close()

        // 关闭链接
        mysqlConnection.close()
    }
}
