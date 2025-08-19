// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*

main(): Int64 {
    let mysqlBigintVarcharTest: MysqlBigintVarcharTest = MysqlBigintVarcharTest()

    mysqlBigintVarcharTest.mysqlBigintVarcharTest01()

    return 0
}

public class MysqlBigintVarcharTest {
    /*
     * +-------+-------------+------+-----+---------+-------+
     * | Field | Type        | Null | Key | Default | Extra |
     * +-------+-------------+------+-----+---------+-------+
     * | id    | bigint      | YES  |     | NULL    |       |
     * | name  | varchar(50) | YES  |     | NULL    |       |
     * | intt  | int         | YES  |     | NULL    |       |
     * | char1 | char(50)    | YES  |     | NULL    |       |
     * | tiny  | tinyint     | YES  |     | NULL    |       |
     * | small | smallint    | YES  |     | NULL    |       |
     * | flo   | float       | YES  |     | NULL    |       |
     * | dou   | double      | YES  |     | NULL    |       |
     * +-------+-------------+------+-----+---------+-------+
     * 1、初始化数据库驱动
     * 2、打开数据源
     * 3、返回可用链接
     * 4、删除t_test表,  清除缓存影响
     * 5、创建新的t_test表
     * 6、往t_test表中插入两条数据（1，"lihao111"）（2，"lihao222"）
     * 7、查询id为2的数据，查询到数据
     * 8、删除查询的数据（2，"lihao222"）
     * 9、重新查询id为2的数据，未查询到数据
     * 10、修改剩下的一条数据（1，"lihao111"）-->（1，"lihao333"）
     * 11、查询修改后id为1的数据，查询到数据
     * 12、删除t_test表
     * 13、关闭缓存，关闭连接
     */
    public func mysqlBigintVarcharTest01(): Unit {
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
        mysqlStatement = mysqlConnection.prepareStatement(
            "create table t_test(id bigint, name varchar(50),intt int, char1 char(50), tiny tinyint, small smallint, flo float, dou double)"
        )
        mysqlStatement.update()
        mysqlStatement.close()

        // 插入数据预执行语句
        mysqlStatement = mysqlConnection.prepareStatement(
            "insert into t_test(id, name, intt, char1, tiny, small, flo, dou)  VALUES(?,?,?,?,?,?,?,?)")

        // 执行插入语句插入数据
        mysqlStatement.set<Int64>(0, 1)
        mysqlStatement.set<String>(1, "lihao111")
        mysqlStatement.set<Int32>(2, 1)
        mysqlStatement.set<String>(3, "lihao111")
        mysqlStatement.set<Byte>(4, 1)
        mysqlStatement.set<Int16>(5, 1)
        mysqlStatement.set<Float32>(6, 0.0)
        mysqlStatement.set<Float64>(7, 0.0)
        var mysqlUpdateResult: MysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)

        // 执行插入语句插入数据
        mysqlStatement.set<Int64>(0, 2)
        mysqlStatement.set<String>(1, "lihao222")
        mysqlStatement.set<Int32>(2, 1)
        mysqlStatement.set<String>(3, "lihao222")
        mysqlStatement.set<Byte>(4, 1)
        mysqlStatement.set<Int16>(5, 1)
        mysqlStatement.set<Float32>(6, 0.0)
        mysqlStatement.set<Float64>(7, 0.0)
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
        @Assert(8, mysqlColumnInfos.size)

        @Assert("id", mysqlColumnInfos[0].name)
        @Assert("SqlInt64", mysqlColumnInfos[0].typeName)
        @Assert(0, mysqlColumnInfos[0].displaySize)
        @Assert(20, mysqlColumnInfos[0].length)
        @Assert(0, mysqlColumnInfos[0].scale)
        @Assert(false, mysqlColumnInfos[0].nullable)

        @Assert("name", mysqlColumnInfos[1].name)
        @Assert("SqlString", mysqlColumnInfos[1].typeName)
        @Assert(0, mysqlColumnInfos[1].displaySize)
        @Assert(200, mysqlColumnInfos[1].length)
        @Assert(0, mysqlColumnInfos[1].scale)
        @Assert(false, mysqlColumnInfos[1].nullable)

        @Assert("intt", mysqlColumnInfos[2].name)
        @Assert("SqlInt32", mysqlColumnInfos[2].typeName)
        @Assert(0, mysqlColumnInfos[2].displaySize)
        @Assert(11, mysqlColumnInfos[2].length)
        @Assert(0, mysqlColumnInfos[2].scale)
        @Assert(false, mysqlColumnInfos[2].nullable)

        @Assert("char1", mysqlColumnInfos[3].name)
        @Assert("SqlString", mysqlColumnInfos[3].typeName)
        @Assert(0, mysqlColumnInfos[3].displaySize)
        @Assert(200, mysqlColumnInfos[3].length)
        @Assert(0, mysqlColumnInfos[3].scale)
        @Assert(false, mysqlColumnInfos[3].nullable)

        @Assert("tiny", mysqlColumnInfos[4].name)
        @Assert("SqlInt8", mysqlColumnInfos[4].typeName)
        @Assert(0, mysqlColumnInfos[4].displaySize)
        @Assert(4, mysqlColumnInfos[4].length)
        @Assert(0, mysqlColumnInfos[4].scale)
        @Assert(false, mysqlColumnInfos[4].nullable)

        @Assert("small", mysqlColumnInfos[5].name)
        @Assert("SqlInt16", mysqlColumnInfos[5].typeName)
        @Assert(0, mysqlColumnInfos[5].displaySize)
        @Assert(6, mysqlColumnInfos[5].length)
        @Assert(0, mysqlColumnInfos[5].scale)
        @Assert(false, mysqlColumnInfos[5].nullable)

        @Assert("flo", mysqlColumnInfos[6].name)
        @Assert("SqlFloat32", mysqlColumnInfos[6].typeName)
        @Assert(0, mysqlColumnInfos[6].displaySize)
        @Assert(12, mysqlColumnInfos[6].length)
        @Assert(31, mysqlColumnInfos[6].scale)
        @Assert(false, mysqlColumnInfos[6].nullable)

        @Assert("dou", mysqlColumnInfos[7].name)
        @Assert("SqlFloat64", mysqlColumnInfos[7].typeName)
        @Assert(0, mysqlColumnInfos[7].displaySize)
        @Assert(22, mysqlColumnInfos[7].length)
        @Assert(31, mysqlColumnInfos[7].scale)
        @Assert(false, mysqlColumnInfos[7].nullable)

        // 获取数据
        var isBool: Bool = mysqlQueryResult.next()
        @Assert(true, isBool)
        @Assert(2, mysqlQueryResult.get<Int64>(0))
        @Assert("lihao222", mysqlQueryResult.get<String>(1))
        @Assert(1, mysqlQueryResult.get<Int32>(2))
        @Assert("lihao222", mysqlQueryResult.get<String>(3))
        @Assert(1, mysqlQueryResult.get<Int8>(4))
        @Assert(1, mysqlQueryResult.get<Int16>(5))
        @Assert(0.0, mysqlQueryResult.get<Float32>(6))
        @Assert(0.0, mysqlQueryResult.get<Float64>(7))
        mysqlStatement.close()

        // 删除语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("delete from t_test where name = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行删除语句        
        mysqlStatement.set<String>(0, "lihao222")
        mysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)
        mysqlStatement.close()

        // 查询语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("select * from t_test where id = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行查询语句
        mysqlStatement.set<Int64>(0, 2)
        mysqlQueryResult = mysqlStatement.query()

        // 获取数据
        isBool = mysqlQueryResult.next()
        @Assert(false, isBool)
        mysqlStatement.close()

        // 更新语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("update t_test set name = ?, intt = ? where id = ?")
        @Assert(3, mysqlStatement.parameterCount)

        // 执行更新语句
        mysqlStatement.set<Int64>(2, 1)
        mysqlStatement.set<String>(0, "lihao333")
        mysqlStatement.set<Int64>(1, 11)
        mysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)
        mysqlStatement.close()

        // 查询nullable----------------
        mysqlStatement = mysqlConnection.prepareStatement(
            "update t_test set name = ?, intt = ?, char1 = ?, tiny = ?, small = ?, flo = ?, dou = ?  where id = ?")
        @Assert(8, mysqlStatement.parameterCount)

        // 执行更新语句        
        mysqlStatement.set<Int64>(7, 1)
        mysqlStatement.setNull(0)
        mysqlStatement.setNull(1)
        mysqlStatement.setNull(2)
        mysqlStatement.setNull(3)
        mysqlStatement.setNull(4)
        mysqlStatement.setNull(5)
        mysqlStatement.setNull(6)
        mysqlUpdateResult = mysqlStatement.update()
        @Assert(1, mysqlUpdateResult.rowCount)
        mysqlStatement.close()

        // 查询语句预执行语句
        mysqlStatement = mysqlConnection.prepareStatement("select * from t_test where id = ?")
        @Assert(1, mysqlStatement.parameterCount)

        // 执行查询语句
        mysqlStatement.set<Int64>(0, 1)
        mysqlQueryResult = mysqlStatement.query()
        @Assert(8, mysqlColumnInfos.size)

        // 获取数据
        isBool = mysqlQueryResult.next()
        @Assert(true, isBool)
        @Assert(1, mysqlQueryResult.get<Int64>(0))
        @Assert(None, mysqlQueryResult.getOrNull<String>(1))
        @Assert(None, mysqlQueryResult.getOrNull<Int32>(2))
        @Assert(None, mysqlQueryResult.getOrNull<String>(3))
        @Assert(None, mysqlQueryResult.getOrNull<Int8>(4))
        @Assert(None, mysqlQueryResult.getOrNull<Int16>(5))
        @Assert(None, mysqlQueryResult.getOrNull<Float32>(6))
        @Assert(None, mysqlQueryResult.getOrNull<Float64>(7))
        mysqlStatement.close()

        // 删除t_test名称数据表
        mysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test")
        mysqlStatement.update()
        mysqlStatement.close()

        // 关闭链接
        mysqlConnection.close()
    }
}
