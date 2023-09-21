// 3rd_party_lib:mysqlclient-ffi/build/mysqlclient
from std import database.sql.*, io.*, time.*, regex.*, math.*
from mysqlclient import mysqlclient.*
from fuzz import fuzz.*

var returnFlag: Int32 = 0
let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        Array<(String, String)>())
let mysqlConnection: MysqlConnection = mysqlDatasource.connect()

func fuzz_MysqlConnectionApi_mysqlSelectDb(dp: DataProvider): Int32 {
    let mysqlConnectionApi: MysqlConnectionApi = MysqlConnectionApi(mysqlConnection)
    // public func mysqlSelectDb(db: String): Int32
    try {
        mysqlConnectionApi.mysqlSelectDb(dp.consumeString(10))
    } catch (e1: Exception) {
        returnFlag = 1
    }
    return returnFlag
}

main() {
    Fuzzer(fuzz_MysqlConnectionApi_mysqlSelectDb).startFuzz()

    return 0
}
