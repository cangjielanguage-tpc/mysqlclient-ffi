package mysqlclient

/*
 * 数据库连接
 */
public class MysqlConnection <: Connection {
    var mysql: CPointer<Unit>
    private var stmt: CPointer<Unit>

    /*
     * 初始化数据库连接
     *
     * 参数 mysql - 初始化的mysql
     */
    init(mysql: CPointer<Unit>) {
        this.mysql = mysql
        unsafe {
            // 为结构分配和初始化内存MYSQL_STMT 
            this.stmt = mysql_stmt_init(mysql)
            if (stmt.isNull()) {
                // 内存不足返回NULL
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
        }
    }

    /**
     * 描述与数据源连接的当前状态
     */
    public override prop state: ConnectionState {
        get() {
            unsafe {
                // 服务器状态
                if (mysql.isNull()) {
                    return ConnectionState.Broken
                }
                let ping_result = mysql_ping(mysql)
                if (ping_result == 0) {
                    // The ping was successful, return CONNECTED status
                    return ConnectionState.Connected
                } else {
                    let error_code = mysql_errno(mysql)

                    // CR_SERVER_GONE_ERROR: 2006
                    // CR_SERVER_LOST: 2013
                    // The server has gone away or lost, return BROKEN status
                    if (error_code == 2006 || error_code == 2013) {
                        return ConnectionState.Broken
                    } else if (error_code == 2014) {
                        // CR_COMMANDS_OUT_OF_SYNC: 2014
                        // The commands are out of sync, return CONNECTING status
                        return ConnectionState.Connecting
                    } else {
                        // Some other error occurred, return CLOSED status
                        return ConnectionState.Closed
                    }
                }
            }
        }
    }

    /**
     * 返回连接到的数据源元数据(不支持)
     *
     * 返回值 Map<String, String> - 数据源元数据
     */
    public override func getMetaData(): Map<String, String> {
        return HashMap<String, String>()
    }

    /*
     * 设置连接选项
     *
     * 参数 option - C中枚举 enum enum_mysql_set_option
     */
    public func setOption(option: MysqlSetOption): Unit {
        unsafe {
            // 设置当前连接的选项
            let option: Int32 = mysql_set_server_option(mysql, option.toInt32())
            if (option != 0) {
                // 发生错误为非零值
                throw SqlException(mysql_error(mysql).toString())
            }
        }
    }

    /**
     * 通过传入的 sql 语句，返回一个预执行的 Statement 对象实例
     *
     * 参数 sql - 预执行的 sql 语句，sql 语句的参数只支持 ? 符号占位符
     * 返回值 Statement - 一个可以执行 sql 语句的实例对象
     */
    public override func prepareStatement(sql: String): MysqlStatement {
        unsafe {
            let sqlCp: CPointerHandle<UInt8> = sql.getRaw()
            let sqlCString: CString = CString(sqlCp.pointer)

            // 准备要执行的语句
            let stmtPrepare: Int32 = mysql_stmt_prepare(stmt, sqlCString, UInt64(sql.size))
            sql.releaseRaw(sqlCp)
            if (stmtPrepare != 0) {
                // 发生错误为非零值
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
        }
        return MysqlStatement(mysql, stmt)
    }

    /**
     * 创建事务对象
     *
     * 返回值 MysqlTransaction - 事务对象
     */
    public override func createTransaction(): MysqlTransaction {
        return MysqlTransaction(mysql)
    }

    /*
     * 关闭资源
     */
    public override func close(): Unit {
        unsafe {
            // 关闭与服务器的连接
            mysql_close(mysql)
        }
    }

    /*
     * 判断资源是否关闭
     * 无原生接口，要判断一个连接是否已经关闭，可以使用 mysql_ping() 函数，它会尝试与服务器进行通信，并在连接断开时自动重连。
     * 如果 mysql_ping() 返回 0，表示连接正常；如果返回非 0 值，表示连接已经关闭或出现错误2。
     * 另外，也可以使用 mysql_get_host_info() 函数来获取连接的信息，如果返回 NULL 或空字符串，表示连接已经关闭或无效2。
     *
     * 返回值 Bool - 如果已经关闭返回true，否则返回false
     */
    public override func isClosed(): Bool {
        unsafe {
            if (mysql_ping(mysql) == 0) {
                return false
            }
            return true
        }
    }

    /*
     * ping服务器，保持连接
     */
    public func mysqlPing(): Unit {
        unsafe {
            mysql_ping(mysql)
        }
    }
}
