package mysqlclient

/*
 * sql语句预执行
 */
public class MysqlStatement <: Statement {
    private var mysql: CPointer<Unit>
    var stmt: CPointer<Unit>

    /*
     * 初始化sql语句预执行
     *
     * 参数 mysql - 初始化的mysql
     * 参数 stmt - 初始化的stmt
     */
    init(mysql: CPointer<Unit>, stmt: CPointer<Unit>) {
        this.mysql = mysql
        this.stmt = stmt
    }

    /*
     * 预执行sql语句中，占位的参数个数
     */
    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return []
        }
    }

    /*
     * 预执行sql语句中，占位的参数个数
     */
    public prop parameterCount: Int64 {
        get() {
            var count: UInt64 = 0
            unsafe {
                // 预准备语句中的参数数
                count = mysql_stmt_param_count(stmt)
            }
            return Int64(count)
        }
    }

    /**
     * 设置预执行sql语句选项(不支持)
     *
     * 参数 key - key
     * 参数 value - value
     */
    public override func setOption(key: String, value: String): Unit {
        (key, value)
    }

    /**
     * 设置预执行sql语句选项
     *
     * 参数 option - C中枚举 enum enum_stmt_attr_type
     * 参数 arg - 值
     */
    public func setOption(option: MysqlStmtAttrType, arg: Bool): Unit {
        unsafe {
            let argCPointer: CPointer<Byte> = LibC.malloc<Byte>()
            if (arg) {
                argCPointer.write(1)
            } else {
                argCPointer.write(0)
            }
            let argCPointer1: CPointer<Unit> = CPointer<Unit>(argCPointer)

            // 设置预准备语句的属性值
            let isBool: Bool = mysql_stmt_attr_set(stmt, option.toInt32(), argCPointer1)
            if (isBool) {
                // 发生错误为非零值
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
            LibC.free<Byte>(argCPointer)
        }
    }

    /**
     * 设置预执行sql语句选项
     *
     * 参数 option - C中枚举 enum enum_stmt_attr_type
     * 参数 arg - 值
     */
    public func setOption(option: MysqlStmtAttrType, arg: UInt64): Unit {
        unsafe {
            let argCPointer: CPointer<UInt64> = LibC.malloc<UInt64>()
            argCPointer.write(arg)
            let argCPointer1: CPointer<Unit> = CPointer<Unit>(argCPointer)

            // 设置预准备语句的属性值
            let isBool: Bool = mysql_stmt_attr_set(stmt, option.toInt32(), argCPointer1)
            if (isBool) {
                // 发生错误为非零值
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
            LibC.free<UInt64>(argCPointer)
        }
    }

    /**
     * 执行sql语句，得到更新结果
     *
     * 参数 params - 填充预执行语句中问号的数据。
     * 返回值 UpdateResult - 更新结果。
     */
    public override func update(params: Array<SqlDbType>): MysqlUpdateResult {
        let rows: Int64
        if (parameterCount == params.size) {
            unsafe {
                // 112是MYSQL_BIND的指针长度
                var binds: CPointer<MYSQL_BIND> = LibC.malloc<MYSQL_BIND>(count: params.size)
                for (i in 0..params.size) {
                    var bind = cjTypeToMysqlType(params[i])
                    binds.write(i, bind)
                }

                // 将应用程序数据缓冲区与prepared语句中的参数标记关联
                let isBool: Bool = mysql_stmt_bind_param(stmt, binds)
                if (isBool) {
                    freeCPointer(params.size, binds)

                    // 发生错误非零值，true在c语言中是1，false是0.
                    throw SqlException(mysql_stmt_error(stmt).toString())
                }

                // 	执行预准备语句
                let execute: Int32 = mysql_stmt_execute(stmt)
                if (execute != 0) {
                    freeCPointer(params.size, binds)

                    // 发生错误非零值
                    throw SqlException(mysql_stmt_error(stmt).toString())
                }

                // 释放指针
                freeCPointer(params.size, binds)

                // 上次更新、删除或插入语句更改/删除/插入的行数
                rows = Int64(mysql_stmt_affected_rows(stmt))
                return MysqlUpdateResult(rows, this.mysql)
            }
        } else {
            throw SqlException("update wrong number of parameters.")
        }
    }

    /**
     * 执行sql语句，得到查询结果
     *
     * 参数 params - 填充预执行语句中问号的数据。
     * 返回值 QueryResult - 查询结果。
     */
    public override func query(params: Array<SqlDbType>): MysqlQueryResult {
        if (parameterCount == params.size) {
            unsafe {
                let metadataUnit: CPointer<Unit> = mysql_stmt_result_metadata(stmt)
                if (metadataUnit.isNull()) {
                    // 不存在准备好的元信息申明，返回NULL
                    throw SqlException(mysql_stmt_error(stmt).toString())
                }
                let columnCount: UInt32 = mysql_stmt_field_count(stmt)
                let metadata: CPointer<MYSQL_RES> = CPointer<MYSQL_RES>(metadataUnit)
                var res: MYSQL_RES = metadata.read()
                var fields: CPointer<MYSQL_FIELD> = res.fields
                if (fields.isNull()) {
                    throw SqlException(mysql_stmt_error(stmt).toString())
                }
                let columnCountInt64: Int64 = Int64(columnCount)
                var mysqlColumnInfos: Array<MysqlColumnInfo> = Array<MysqlColumnInfo>(columnCountInt64,
                    item: MysqlColumnInfo("", "", 0, 0, 0, false))
                for (i in 0..columnCountInt64) {
                    var field: MYSQL_FIELD = fields.read(Int64(i))

                    // field.flags为单数表示非空
                    var mysqlColumnInfo: MysqlColumnInfo = MysqlColumnInfo(field.name.toString(),
                        mysqlType(field.types), Int64(field.max_length), Int64(field.length), Int64(field.decimals),
                        field.flags % 2 != 0)
                    mysqlColumnInfos[i] = mysqlColumnInfo
                }

                // 112是MYSQL_BIND的指针长度
                var bindsCp: CPointer<MYSQL_BIND> = LibC.malloc<MYSQL_BIND>(count: params.size)
                for (i in 0..params.size) {
                    var bind: MYSQL_BIND = cjTypeToMysqlType(params[i])

                    bindsCp.write(i, bind)
                }

                // 将应用程序数据缓冲区与prepared语句中的参数标记关联
                let isBool: Bool = mysql_stmt_bind_param(stmt, bindsCp)
                if (isBool) {
                    freeCPointer(params.size, bindsCp)

                    // 发生错误非零值，true在c语言中是1，false是0.
                    throw SqlException(mysql_stmt_error(stmt).toString())
                }
                let execute: Int32 = mysql_stmt_execute(stmt)
                if (execute != 0) {
                    freeCPointer(params.size, bindsCp)

                    // 发生错误非零值
                    throw SqlException(mysql_stmt_error(stmt).toString())
                }
                freeCPointer(params.size, bindsCp)
                return MysqlQueryResult(stmt, mysqlColumnInfos)
            }
        } else {
            throw SqlException("query wrong number of parameters.")
        }
    }

    /*
     * 关闭资源
     */
    public override func close(): Unit {
        unsafe {
            // 释放预准备语句内存资源
            let isBool: Bool = mysql_stmt_close(stmt)
            if (isBool) {
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
        }
    }

    /*
     * 判断资源是否关闭(不支持)
     *
     * 返回值 Bool - 如果已经关闭返回true，否则返回false
     */
    public override func isClosed(): Bool {
        return false
    }
}

/*
 * 释放指针内存
 *
 * 参数 index - 条数
 * 参数 binds - 指针
 */
func freeCPointer(index: Int64, binds: CPointer<MYSQL_BIND>): Unit {
    unsafe {
        for (i in 0..index) {
            var bind: MYSQL_BIND = binds.read(i)
            if (!bind.buffer.isNull()) {
                if (bind.buffer_type == MYSQL_TYPE_LONG_BLOB || bind.buffer_type == MYSQL_TYPE_BLOB) {
                    let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(bind.buffer)
                    let bufferLength: Int64 = Int64(bind.buffer_length)
                    var arr = Array<Byte>(bufferLength, item: 0)
                    for (i in 0..bufferLength) {
                        arr[i] = valueCPointer.read(i)
                    }
                    releaseArrayRawData<Byte>(CPointerHandle<Byte>(valueCPointer, arr))
                } else if (bind.buffer_type == MYSQL_TYPE_STRING) {
                    let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(bind.buffer)
                    let valueCString: CString = CString(valueCPointer)
                    LibC.free(valueCString)
                } else {
                    LibC.free<Unit>(bind.buffer)
                }
            }
            if (!bind.is_null.isNull()) {
                LibC.free<UInt8>(bind.is_null)
            }
        }
        LibC.free<MYSQL_BIND>(binds)
    }
}

func cjTypeToMysqlType(sqlDbType: SqlDbType): MYSQL_BIND {
    return match (sqlDbType) {
        // String----SqlChar----CHAR----CHAR----MYSQL_TYPE_STRING----char[]
        case v: SqlChar => setString(v.value, MYSQL_TYPE_STRING)
        case v: SqlNullableChar => setString(v.value, MYSQL_TYPE_STRING)

        // String----SqlVarchar----VARCHAR----VARCHAR----MYSQL_TYPE_STRING----char[]
        case v: SqlVarchar => setString(v.value, MYSQL_TYPE_STRING)
        case v: SqlNullableVarchar => setString(v.value, MYSQL_TYPE_STRING)

        // Array<Byte>----SqlBinary----BINARY----BINARY----MYSQL_TYPE_BLOB----char[]
        case v: SqlBinary => setBytes(v.value, MYSQL_TYPE_BLOB)
        case v: SqlNullableBinary => setBytes(v.value, MYSQL_TYPE_BLOB)

        // Array<Byte>----SqlVarBinary----VARBINARY----VARBINARY----MYSQL_TYPE_BLOB----char[]
        case v: SqlVarBinary => setBytes(v.value, MYSQL_TYPE_BLOB)
        case v: SqlNullableVarBinary => setBytes(v.value, MYSQL_TYPE_BLOB)

        // 长字符串，mysql输入对应表格没有给出，在输出表格有对应数据
        // Array<InputStream>----SqlClob----CLOB----LONGTEXT----MYSQL_TYPE_LONG_BLOB----char[]
        case v: SqlClob => setClob(v.value, MYSQL_TYPE_LONG_BLOB)
        case v: SqlNullableClob => setClob(v.value, MYSQL_TYPE_LONG_BLOB)

        // Array<InputStream>----SqlBlob----BLOB----BLOB----MYSQL_TYPE_BLOB----char[]
        case v: SqlBlob => setBlob(v.value, MYSQL_TYPE_BLOB)
        case v: SqlNullableBlob => setBlob(v.value, MYSQL_TYPE_BLOB)

        // 布尔类型在mysql数据库中表现形式是TINYINT
        // Bool----SqlBool----BOOLEAN----TINYINT----MYSQL_TYPE_TINY----signed char
        case v: SqlBool => setBool(v.value, MYSQL_TYPE_TINY)
        case v: SqlNullableBool => setBool(v.value, MYSQL_TYPE_TINY)

        // Int8----SqlByte----TINYINT----TINYINT----MYSQL_TYPE_TINY----signed char
        case v: SqlByte => setInt8(v.value, MYSQL_TYPE_TINY)
        case v: SqlNullableByte => setInt8(v.value, MYSQL_TYPE_TINY)

        // Int16----SqlSmallInt----SMALLINT----SMALLINT----MYSQL_TYPE_SHORT----short int
        case v: SqlSmallInt => setInt16(v.value, MYSQL_TYPE_SHORT)
        case v: SqlNullableSmallInt => setInt16(v.value, MYSQL_TYPE_SHORT)

        // SQL类型不同，但是数据值相对应
        // Int32----SqlInteger----INTEGER----INT----MYSQL_TYPE_LONG----int
        case v: SqlInteger => setInt32(v.value, MYSQL_TYPE_LONG)
        case v: SqlNullableInteger => setInt32(v.value, MYSQL_TYPE_LONG)

        // Int64----SqlBigInt----BIGINT----BIGINT----MYSQL_TYPE_LONGLONG----long long int
        case v: SqlBigInt => setInt64(v.value, MYSQL_TYPE_LONGLONG)
        case v: SqlNullableBigInt => setInt64(v.value, MYSQL_TYPE_LONGLONG)

        // SQL类型不同，但是数据值相对应
        // Float32----SqlReal----REAL----FLOAT----MYSQL_TYPE_FLOAT----float
        case v: SqlReal => setFloat32(v.value, MYSQL_TYPE_FLOAT)
        case v: SqlNullableReal => setFloat32(v.value, MYSQL_TYPE_FLOAT)

        // Float64----SqlDouble----DOUBLE----DOUBLE----MYSQL_TYPE_DOUBLE----double
        case v: SqlDouble => setFloat64(v.value, MYSQL_TYPE_DOUBLE)
        case v: SqlNullableDouble => setFloat64(v.value, MYSQL_TYPE_DOUBLE)

        // DateTime----SqlDate----DATE----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
        case v: SqlDate => setDate(v.value, MYSQL_TYPE_DATE)
        case v: SqlNullableDate => setDate(v.value, MYSQL_TYPE_DATE)

        // DateTime----SqlTime----TIME----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
        case v: SqlTime => setTime(v.value, MYSQL_TYPE_TIME)
        case v: SqlNullableTime => setTime(v.value, MYSQL_TYPE_TIME)

        // DateTime----SqlTimeTz----TIMETZ----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
        // mysql不支持
        case _: SqlTimeTz => throw SqlException("Unsupported data type.")
        case _: SqlNullableTimeTz => throw SqlException("Unsupported data type.")

        // DateTime----SqlTimestamp----TIMESTAMP----TIMESTAMP----MYSQL_TYPE_TIMESTAMP----MYSQL_TIME
        case v: SqlTimestamp => setTimestamp(v.value, MYSQL_TYPE_TIMESTAMP)
        case v: SqlNullableTimestamp => setTimestamp(v.value, MYSQL_TYPE_TIMESTAMP)

        // Duration----SqlInterval----INTERVAL----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
        // mysql不支持
        case _: SqlInterval => throw SqlException("Unsupported data type.")
        case _: SqlNullableInterval => throw SqlException("Unsupported data type.")

        // 自定义类
        // DATETIME----MYSQL_TYPE_DATETIME----MYSQL_TIME
        case v: SqlDateTime => setDateTime(v.value, MYSQL_TYPE_DATETIME)
        case v: SqlNullableDateTime => setDateTime(v.value, MYSQL_TYPE_DATETIME)

        case _ => throw SqlException("Unsupported data type.")
    }
}

func setString(value: Option<String>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let strCtring: CString = LibC.mallocCString(v)
                mysqlBind.buffer_length = UInt64(strCtring.size() + 1)
                mysqlBind.buffer = CPointer<Unit>(strCtring.getChars())
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setBytes(value: Option<Array<Byte>>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            mysqlBind.buffer_length = UInt64(v.size)
            unsafe {
                var cp: CPointerHandle<Byte> = acquireArrayRawData<Byte>(v)
                let bytesCPointer: CPointer<UInt8> = cp.pointer
                mysqlBind.buffer = CPointer<Unit>(bytesCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setClob(value: Option<InputStream>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            var arr: Array<Byte> = Array<Byte>(1, item: 0)
            var list: ArrayList<Byte> = ArrayList<Byte>()
            var length: Int64 = 0
            while (true) {
                var date: Int64 = v.read(arr)
                if (date == 0) {
                    break
                }
                list.append(arr[0])
                length++
            }
            mysqlBind.buffer_length = UInt64(list.size)
            unsafe {
                var cp: CPointerHandle<Byte> = acquireArrayRawData<Byte>(list.toArray())
                let bytesCPointer: CPointer<UInt8> = cp.pointer
                mysqlBind.buffer = CPointer<Unit>(bytesCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setBlob(value: Option<InputStream>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            var arr: Array<Byte> = Array<Byte>(1, item: 0)
            var list: ArrayList<Byte> = ArrayList<Byte>()
            var length: Int64 = 0
            while (true) {
                var date: Int64 = v.read(arr)
                if (date == 0) {
                    break
                }
                list.append(arr[0])
                length++
            }
            mysqlBind.buffer_length = UInt64(list.size)
            unsafe {
                var cp: CPointerHandle<Byte> = acquireArrayRawData<Byte>(list.toArray())
                let bytesCPointer: CPointer<UInt8> = cp.pointer
                mysqlBind.buffer = CPointer<Unit>(bytesCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setBool(value: Option<Bool>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<UInt8> = LibC.malloc<UInt8>()
                if (v) {
                    valueCPointer.write(1)
                } else {
                    valueCPointer.write(0)
                }
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setInt8(value: Option<Int8>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<Int8> = LibC.malloc<Int8>()
                valueCPointer.write(v)
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setInt16(value: Option<Int16>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<Int16> = LibC.malloc<Int16>()
                valueCPointer.write(v)
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setInt32(value: Option<Int32>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<Int32> = LibC.malloc<Int32>()
                valueCPointer.write(v)
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setInt64(value: Option<Int64>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<Int64> = LibC.malloc<Int64>()
                valueCPointer.write(v)
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setFloat32(value: Option<Float32>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<Float32> = LibC.malloc<Float32>()
                valueCPointer.write(v)
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setFloat64(value: Option<Float64>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                let valueCPointer: CPointer<Float64> = LibC.malloc<Float64>()
                valueCPointer.write(v)
                mysqlBind.buffer = CPointer<Unit>(valueCPointer)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setDate(value: Option<DateTime>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                // 41是MYSQL_TIME的指针长度
                var parameterValuePtr: CPointer<MYSQL_TIME> = LibC.malloc<MYSQL_TIME>()
                var date: MYSQL_TIME = MYSQL_TIME()
                date.year = UInt32(v.year)
                date.month = UInt32(v.monthValue)
                date.day = UInt32(v.dayOfMonth)

                // 年、月、日
                date.time_type = 0
                parameterValuePtr.write(date)
                mysqlBind.buffer = CPointer<Unit>(parameterValuePtr)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setTime(value: Option<DateTime>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                // 41是MYSQL_TIME的指针长度
                var parameterValuePtr: CPointer<MYSQL_TIME> = LibC.malloc<MYSQL_TIME>()
                var date: MYSQL_TIME = MYSQL_TIME()
                date.hour = UInt32(v.hour)
                date.minute = UInt32(v.minute)
                date.second = UInt32(v.second)

                // 时、分、秒
                date.time_type = 2
                parameterValuePtr.write(date)
                mysqlBind.buffer = CPointer<Unit>(parameterValuePtr)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setTimestamp(value: Option<DateTime>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                // 41是MYSQL_TIME的指针长度
                var parameterValuePtr: CPointer<MYSQL_TIME> = LibC.malloc<MYSQL_TIME>()

                var date: MYSQL_TIME = MYSQL_TIME()
                date.year = UInt32(v.year)
                date.month = UInt32(v.monthValue)
                date.day = UInt32(v.dayOfMonth)
                date.hour = UInt32(v.hour)
                date.minute = UInt32(v.minute)
                date.second = UInt32(v.second)

                // 年、月、日、时、分、秒
                date.time_type = 1
                parameterValuePtr.write(date)
                mysqlBind.buffer = CPointer<Unit>(parameterValuePtr)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func setDateTime(value: Option<DateTime>, sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    match (value) {
        case Some(v) =>
            unsafe {
                // 41是MYSQL_TIME的指针长度
                var parameterValuePtr: CPointer<MYSQL_TIME> = LibC.malloc<MYSQL_TIME>()

                var date: MYSQL_TIME = MYSQL_TIME()
                date.year = UInt32(v.year)
                date.month = UInt32(v.monthValue)
                date.day = UInt32(v.dayOfMonth)
                date.hour = UInt32(v.hour)
                date.minute = UInt32(v.minute)
                date.second = UInt32(v.second)

                // 年、月、日、时、分、秒
                date.time_type = 1
                parameterValuePtr.write(date)
                mysqlBind.buffer = CPointer<Unit>(parameterValuePtr)
            }
        case None =>
            unsafe {
                mysqlBind.buffer_length = 0
                var isNull: CPointer<UInt8> = LibC.malloc<UInt8>()
                isNull.write(1)
                mysqlBind.is_null = isNull
                mysqlBind.is_null_value = true
                mysqlBind.buffer = CPointer<Unit>()
            }
    }
    return mysqlBind
}

func mysqlType(types: Int32): String {
    if (types == MYSQL_TYPE_DECIMAL) {
        return "MYSQL_TYPE_DECIMAL"
    }
    if (types == MYSQL_TYPE_TINY) {
        return "SqlByte"
    }
    if (types == MYSQL_TYPE_SHORT) {
        return "SqlSmallInt"
    }
    if (types == MYSQL_TYPE_LONG) {
        return "SqlInteger"
    }
    if (types == MYSQL_TYPE_FLOAT) {
        return "SqlReal"
    }
    if (types == MYSQL_TYPE_DOUBLE) {
        return "SqlDouble"
    }
    if (types == MYSQL_TYPE_NULL) {
        return "MYSQL_TYPE_NULL"
    }
    if (types == MYSQL_TYPE_TIMESTAMP) {
        return "SqlTimestamp"
    }
    if (types == MYSQL_TYPE_LONGLONG) {
        return "SqlBigInt"
    }
    if (types == MYSQL_TYPE_INT24) {
        return "SqlInteger"
    }
    if (types == MYSQL_TYPE_DATE) {
        return "SqlDate"
    }
    if (types == MYSQL_TYPE_TIME) {
        return "SqlTime"
    }

    // 自定义类型
    if (types == MYSQL_TYPE_DATETIME) {
        return "SqlDateTime"
    }
    if (types == MYSQL_TYPE_YEAR) {
        return "MYSQL_TYPE_YEAR"
    }
    if (types == MYSQL_TYPE_NEWDATE) {
        return "MYSQL_TYPE_NEWDATE"
    }
    if (types == MYSQL_TYPE_VARCHAR) {
        return "MYSQL_TYPE_VARCHAR"
    }
    if (types == MYSQL_TYPE_BIT) {
        return "MYSQL_TYPE_BIT"
    }
    if (types == MYSQL_TYPE_TIMESTAMP2) {
        return "MYSQL_TYPE_TIMESTAMP2"
    }
    if (types == MYSQL_TYPE_DATETIME2) {
        return "MYSQL_TYPE_DATETIME2"
    }
    if (types == MYSQL_TYPE_TIME2) {
        return "MYSQL_TYPE_TIME2"
    }
    if (types == MYSQL_TYPE_TYPED_ARRAY) {
        return "MYSQL_TYPE_TYPED_ARRAY"
    }
    if (types == MYSQL_TYPE_INVALID) {
        return "MYSQL_TYPE_INVALID"
    }
    if (types == MYSQL_TYPE_BOOL) {
        return "MYSQL_TYPE_BOOL"
    }
    if (types == MYSQL_TYPE_JSON) {
        return "MYSQL_TYPE_JSON"
    }
    if (types == MYSQL_TYPE_NEWDECIMAL) {
        return "MYSQL_TYPE_NEWDECIMAL"
    }
    if (types == MYSQL_TYPE_ENUM) {
        return "MYSQL_TYPE_ENUM"
    }
    if (types == MYSQL_TYPE_SET) {
        return "MYSQL_TYPE_SET"
    }
    if (types == MYSQL_TYPE_TINY_BLOB) {
        return "SqlBlob"
    }
    if (types == MYSQL_TYPE_MEDIUM_BLOB) {
        return "SqlBlob"
    }
    if (types == MYSQL_TYPE_LONG_BLOB) {
        return "SqlBlob"
    }
    if (types == MYSQL_TYPE_BLOB) {
        return "SqlBlob"
    }
    if (types == MYSQL_TYPE_VAR_STRING) {
        return "SqlVarchar"
    }
    if (types == MYSQL_TYPE_STRING) {
        return "SqlChar"
    }
    if (types == MYSQL_TYPE_GEOMETRY) {
        return "MYSQL_TYPE_GEOMETRY"
    }
    return "unknownType"
}
