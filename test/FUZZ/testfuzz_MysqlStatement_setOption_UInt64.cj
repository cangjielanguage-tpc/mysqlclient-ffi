// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
from std import database.sql.*, io.*, time.*, regex.*, math.*
from mysqlclient import mysqlclient.*
from fuzz import fuzz.*

var returnFlag: Int32 = 0
let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        Array<(String, String)>())
let mysqlConnection: MysqlConnection = mysqlDatasource.connect()
        
func fuzz_MysqlStatement_setOption_UInt64(dp: DataProvider): Int32 {
    let mysqlStatement: MysqlStatement = mysqlConnection.prepareStatement("drop table if exists t_test1")
    // public func setOption(option: MysqlStmtAttrType, arg: UInt64): Unit
    try {
        mysqlStatement.setOption(MysqlStmtAttrType.STMT_ATTR_PREFETCH_ROWS,dp.consumeUInt64())
    } catch (e1: Exception) {
        returnFlag = 1
    }
    return returnFlag
}

main() {
    Fuzzer(fuzz_MysqlStatement_setOption_UInt64).startFuzz()

    return 0
}
