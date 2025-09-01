// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import std.time.*

main(): Int64 {
    let mysqlTest: MysqlTest = MysqlTest()

    mysqlTest.test01()

    return 0
}

@Test
public class MysqlTest {
    @TestCase
    public func test01(): Unit {
        let dateTime1: DateTime = DateTime.nowUTC()

        let mysqlTypeTime: MysqlTypeTime = MysqlTypeTime(dateTime1)
        mysqlTypeTime.value = dateTime1
        @Assert("TIME", mysqlTypeTime.name)

        let mysqlTypeTimeTimestamp: MysqlTypeTimeTimestamp = MysqlTypeTimeTimestamp(dateTime1)
        mysqlTypeTimeTimestamp.value = dateTime1
        @Assert("TIMESTAMP", mysqlTypeTimeTimestamp.name)

        let mysqlTypeDate: MysqlTypeDate = MysqlTypeDate(dateTime1)
        mysqlTypeDate.value = dateTime1
        @Assert("DATE", mysqlTypeDate.name)

        let mysqlTypeEnum1: MysqlTypeEnum  = MysqlTypeEnum.SqlString
        let mysqlTypeEnum2: MysqlTypeEnum  = MysqlTypeEnum.SqlArrayByte
        let mysqlTypeEnum3: MysqlTypeEnum  = MysqlTypeEnum.SqlInputStream
        let mysqlTypeEnum4: MysqlTypeEnum  = MysqlTypeEnum.SqlBool
        let mysqlTypeEnum5: MysqlTypeEnum  = MysqlTypeEnum.SqlInt8
        let mysqlTypeEnum6: MysqlTypeEnum  = MysqlTypeEnum.SqlInt16
        let mysqlTypeEnum7: MysqlTypeEnum  = MysqlTypeEnum.SqlInt32
        let mysqlTypeEnum8: MysqlTypeEnum  = MysqlTypeEnum.SqlInt64
        let mysqlTypeEnum9: MysqlTypeEnum  = MysqlTypeEnum.SqlFloat32
        let mysqlTypeEnum10: MysqlTypeEnum  = MysqlTypeEnum.SqlFloat64
        let mysqlTypeEnum11: MysqlTypeEnum  = MysqlTypeEnum.SqlDateTime
        let mysqlTypeEnum12: MysqlTypeEnum  = MysqlTypeEnum.SqlMysqlTypeDate
        let mysqlTypeEnum13: MysqlTypeEnum  = MysqlTypeEnum.SqlMysqlTypeTime
        let mysqlTypeEnum14: MysqlTypeEnum  = MysqlTypeEnum.SqlMysqlTypeTimeTimestamp
        let mysqlTypeEnum15: MysqlTypeEnum  = MysqlTypeEnum.SqlDecimal
        let mysqlTypeEnum16: MysqlTypeEnum  = MysqlTypeEnum.SqlNull
        let mysqlTypeEnum17: MysqlTypeEnum  = MysqlTypeEnum.SqlBigInt
        let mysqlTypeEnum18: MysqlTypeEnum  = MysqlTypeEnum.SqlOther

        
        @Assert(true, mysqlTypeEnum1 == mysqlTypeEnum1)
        @Assert(true, mysqlTypeEnum2 == mysqlTypeEnum2)
        @Assert(true, mysqlTypeEnum3 == mysqlTypeEnum3)
        @Assert(true, mysqlTypeEnum4 == mysqlTypeEnum4)
        @Assert(true, mysqlTypeEnum5 == mysqlTypeEnum5)
        @Assert(true, mysqlTypeEnum6 == mysqlTypeEnum6)
        @Assert(true, mysqlTypeEnum7 == mysqlTypeEnum7)
        @Assert(true, mysqlTypeEnum8 == mysqlTypeEnum8)
        @Assert(true, mysqlTypeEnum9 == mysqlTypeEnum9)
        @Assert(true, mysqlTypeEnum10 == mysqlTypeEnum10)
        @Assert(true, mysqlTypeEnum11 == mysqlTypeEnum11)
        @Assert(true, mysqlTypeEnum12 == mysqlTypeEnum12)
        @Assert(true, mysqlTypeEnum13 == mysqlTypeEnum13)
        @Assert(true, mysqlTypeEnum14 == mysqlTypeEnum14)
        @Assert(true, mysqlTypeEnum15 == mysqlTypeEnum15)
        @Assert(true, mysqlTypeEnum16 == mysqlTypeEnum16)
        @Assert(true, mysqlTypeEnum17 == mysqlTypeEnum17)
        @Assert(true, mysqlTypeEnum18 == mysqlTypeEnum18)
        @Assert(false, mysqlTypeEnum18 == mysqlTypeEnum1)
        @Assert(false, mysqlTypeEnum1 != mysqlTypeEnum1)
        @Assert(true, mysqlTypeEnum18 != mysqlTypeEnum1)

        @Assert("SqlString", mysqlTypeEnum1.toString())
        @Assert("SqlArrayByte", mysqlTypeEnum2.toString())
        @Assert("SqlInputStream", mysqlTypeEnum3.toString())
        @Assert("SqlBool", mysqlTypeEnum4.toString())
        @Assert("SqlInt8", mysqlTypeEnum5.toString())
        @Assert("SqlInt16", mysqlTypeEnum6.toString())
        @Assert("SqlInt32", mysqlTypeEnum7.toString())
        @Assert("SqlInt64", mysqlTypeEnum8.toString())
        @Assert("SqlFloat32", mysqlTypeEnum9.toString())
        @Assert("SqlFloat64", mysqlTypeEnum10.toString())
        @Assert("SqlDateTime", mysqlTypeEnum11.toString())
        @Assert("SqlMysqlTypeDate", mysqlTypeEnum12.toString())
        @Assert("SqlMysqlTypeTime", mysqlTypeEnum13.toString())
        @Assert("SqlMysqlTypeTimeTimestamp", mysqlTypeEnum14.toString())
        @Assert("SqlDecimal", mysqlTypeEnum15.toString())
        @Assert("SqlNull", mysqlTypeEnum16.toString())
        @Assert("SqlBigInt", mysqlTypeEnum17.toString())
        @Assert("SqlOther", mysqlTypeEnum18.toString())

        @Assert(MysqlTypeEnum.fromToString("SqlString"), mysqlTypeEnum1)
        @Assert(MysqlTypeEnum.fromToString("SqlArrayByte"), mysqlTypeEnum2)
        @Assert(MysqlTypeEnum.fromToString("SqlInputStream"), mysqlTypeEnum3)
        @Assert(MysqlTypeEnum.fromToString("SqlBool"), mysqlTypeEnum4)
        @Assert(MysqlTypeEnum.fromToString("SqlInt8"), mysqlTypeEnum5)
        @Assert(MysqlTypeEnum.fromToString("SqlInt16"), mysqlTypeEnum6)
        @Assert(MysqlTypeEnum.fromToString("SqlInt32"), mysqlTypeEnum7)
        @Assert(MysqlTypeEnum.fromToString("SqlInt64"), mysqlTypeEnum8)
        @Assert(MysqlTypeEnum.fromToString("SqlFloat32"), mysqlTypeEnum9)
        @Assert(MysqlTypeEnum.fromToString("SqlFloat64"), mysqlTypeEnum10)
        @Assert(MysqlTypeEnum.fromToString("SqlDateTime"), mysqlTypeEnum11)
        @Assert(MysqlTypeEnum.fromToString("SqlMysqlTypeDate"), mysqlTypeEnum12)
        @Assert(MysqlTypeEnum.fromToString("SqlMysqlTypeTime"), mysqlTypeEnum13)
        @Assert(MysqlTypeEnum.fromToString("SqlMysqlTypeTimeTimestamp"), mysqlTypeEnum14)
        @Assert(MysqlTypeEnum.fromToString("SqlDecimal"), mysqlTypeEnum15)
        @Assert(MysqlTypeEnum.fromToString("SqlNull"), mysqlTypeEnum16)
        @Assert(MysqlTypeEnum.fromToString("SqlBigInt"), mysqlTypeEnum17)
        @Assert(MysqlTypeEnum.fromToString("SqlOther"), mysqlTypeEnum18)
        try{
            MysqlTypeEnum.fromToString("")
            @Assert(1, 0)
        }catch(e:SqlException){
            @Assert("The Statement has been closed, errorCode: 0", e.message)
        }

        let mysqlStmtAttrType1: MysqlStmtAttrType  = MysqlStmtAttrType.STMT_ATTR_UPDATE_MAX_LENGTH
        let mysqlStmtAttrType2: MysqlStmtAttrType  = MysqlStmtAttrType.STMT_ATTR_CURSOR_TYPE
        let mysqlStmtAttrType3: MysqlStmtAttrType  = MysqlStmtAttrType.STMT_ATTR_PREFETCH_ROWS

        let mysqlShutdownLevel: MysqlShutdownLevel  = MysqlShutdownLevel.SHUTDOWN_DEFAULT
        let mysqlShutdownLeve2: MysqlShutdownLevel  = MysqlShutdownLevel.SHUTDOWN_WAIT_CONNECTIONS
        let mysqlShutdownLeve3: MysqlShutdownLevel  = MysqlShutdownLevel.SHUTDOWN_WAIT_TRANSACTIONS
        let mysqlShutdownLeve4: MysqlShutdownLevel  = MysqlShutdownLevel.SHUTDOWN_WAIT_UPDATES
        let mysqlShutdownLeve5: MysqlShutdownLevel  = MysqlShutdownLevel.SHUTDOWN_WAIT_ALL_BUFFERS
        let mysqlShutdownLeve6: MysqlShutdownLevel  = MysqlShutdownLevel.SHUTDOWN_WAIT_CRITICAL_BUFFERS
        let mysqlShutdownLeve7: MysqlShutdownLevel  = MysqlShutdownLevel.KILL_QUERY
        let mysqlShutdownLeve8: MysqlShutdownLevel  = MysqlShutdownLevel.KILL_CONNECTION

    }
}