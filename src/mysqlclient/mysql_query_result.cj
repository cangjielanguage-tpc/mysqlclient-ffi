package mysqlclient

let bufferLengthUInt64: UInt64 = 1024

let bufferLengthInt64: Int64 = 1024

/*
 * 执行Select语句产生的结果
 */
public class MysqlQueryResult <: QueryResult {
    private var resultCount: Array<MysqlColumnInfo>
    private var stmt: CPointer<Unit>

    /*
     * 初始化 执行Select语句产生的结果
     *
     * 参数 mysql - 初始化的mysql
     * 参数 stmt - 初始化的stmt
     */
    init(stmt: CPointer<Unit>, resultCount: Array<MysqlColumnInfo>) {
        this.stmt = stmt
        this.resultCount = resultCount
    }

    /*
     * 返回结果集的列信息，比如列名，列类型，列长度，是否允许数据库Null值等（不支持）
     */
    public override prop columnInfos: Array<ColumnInfo> {
        get() {
            Array<ColumnInfo>(resultCount.size, {i => (resultCount[i] as MysqlColumnInfo).getOrThrow()})
        }
    }

    /*
     * 返回结果集的列信息，比如列名，列类型，列长度，是否允许数据库Null值等
     */
    public prop mysqlColumnInfos: Array<MysqlColumnInfo> {
        get() {
            return resultCount
        }
    }

    /*
     * 向后移动一行，必须先调用一次next才能移动到第一行，第二次调用移动到第二行，依此类推。
     * 当返回true时，驱动会在values中填入行数据；当返回false时结束，且不会修改values的内容。
     *
     * 参数 values - 需要填充返回的数据
     * 返回值 Bool - 存在下一行则返回true，否则返回false
     */
    public override func next(values: Array<SqlDbType>): Bool {
        unsafe {
            // 112是MYSQL_BIND的指针长度
            var bindsCp: CPointer<MYSQL_BIND> = LibC.malloc<MYSQL_BIND>(count: values.size)
            for (i in 0..values.size) {
                var bind: MYSQL_BIND = cjTypeToMysqlTypeQuery(values[i], resultCount[i].length)
                bindsCp.write(i, bind)
            }
            let isBool: Bool = mysql_stmt_bind_result(stmt, bindsCp)
            if (isBool) {
                freeQueryCPointer(values.size, bindsCp)
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
            var intFetch: Int32 = mysql_stmt_fetch(stmt)
            if (intFetch == 101) {
                // 发生数据截断。
                for (i in 0..values.size) {
                    var mysqlBind: MYSQL_BIND = bindsCp.read(i)
                    if (mysqlBind.buffer_type == MYSQL_TYPE_LONG || mysqlBind.buffer_type == MYSQL_TYPE_STRING ||
                        mysqlBind.buffer_type == MYSQL_TYPE_VAR_STRING || mysqlBind.buffer_type == MYSQL_TYPE_BLOB ||
                        mysqlBind.buffer_type == MYSQL_TYPE_DATE || mysqlBind.buffer_type == MYSQL_TYPE_TIME || mysqlBind.
                    buffer_type == MYSQL_TYPE_DATETIME || mysqlBind.buffer_type == MYSQL_TYPE_TIMESTAMP) {
                        var len: UInt64 = mysqlBind.length.read()
                        if (len > UInt64(resultCount[i].length)) {
                            LibC.free<Unit>(mysqlBind.buffer)
                            mysqlBind.buffer = CPointer<Unit>(LibC.malloc<UInt8>(count: Int64(len + 1)))
                            mysqlBind.buffer_length = len + 1
                            bindsCp.write(i, mysqlBind)
                            var ret: Int32 = mysql_stmt_fetch_column(stmt, bindsCp + i, UInt32(i), 0)
                            if (ret != 0) {
                                freeQueryCPointer(values.size, bindsCp)
                                throw SqlException(mysql_stmt_error(stmt).toString())
                            }
                        } else {
                            bindsCp.write(i, mysqlBind)
                        }
                    } else {
                        bindsCp.write(i, mysqlBind)
                    }
                }
            } else if (intFetch == 1) {
                // 发生错误。
                freeQueryCPointer(values.size, bindsCp)
                throw SqlException(mysql_stmt_error(stmt).toString())
            } else if (intFetch == 100) {
                // 成功，不再存在数据。
                freeQueryCPointer(values.size, bindsCp)
                return false
            }

            // 成功存在数据或有数据发生数据截断
            for (i in 0..values.size) {
                var mysqlBind: MYSQL_BIND = bindsCp.read(i)
                values[i] = mysqlTypeTocjType(mysqlBind, values[i])
            }
            freeQueryCPointer(values.size, bindsCp)
            return true
        }
    }

    /*
     * 关闭资源
     */
    public override func close(): Unit {
        unsafe {
            // 释放预准备语句内存资源
            let isBool: Bool = mysql_stmt_free_result(stmt)
            if (isBool) {
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
        }
    }

    /*
     * 判断资源是否关闭(不支持)
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
func freeQueryCPointer(index: Int64, binds: CPointer<MYSQL_BIND>): Unit {
    unsafe {
        for (i in 0..index) {
            var bind: MYSQL_BIND = binds.read(i)
            if (!bind.buffer.isNull()) {
                LibC.free<Unit>(bind.buffer)
            }
            if (!bind.length.isNull()) {
                LibC.free<UInt64>(bind.length)
            }
            if (!bind.is_null.isNull()) {
                LibC.free<UInt8>(bind.is_null)
            }
            if (!bind.error.isNull()) {
                LibC.free<UInt8>(bind.error)
            }
        }
        LibC.free<MYSQL_BIND>(binds)
    }
}

func cjTypeToMysqlTypeQuery(sqlDbType: SqlDbType, length: Int64): MYSQL_BIND {
    return match (sqlDbType) {
        // String----SqlChar----CHAR----CHAR----MYSQL_TYPE_STRING----char[]
        case _: SqlChar => setStringQuery(MYSQL_TYPE_STRING, length)
        case _: SqlNullableChar => setStringQuery(MYSQL_TYPE_STRING, length)

        // String----SqlVarchar----VARCHAR----VARCHAR----MYSQL_TYPE_VAR_STRING----char[]
        case _: SqlVarchar => setStringQuery(MYSQL_TYPE_VAR_STRING, length)
        case _: SqlNullableVarchar => setStringQuery(MYSQL_TYPE_VAR_STRING, length)

        // Array<Byte>----SqlBinary----BINARY----BINARY----MYSQL_TYPE_STRING----char[]
        case _: SqlBinary => setBytesQuery(MYSQL_TYPE_STRING, length)
        case _: SqlNullableBinary => setBytesQuery(MYSQL_TYPE_STRING, length)

        // Array<Byte>----SqlVarBinary----VARBINARY----VARBINARY----MYSQL_TYPE_VAR_STRING----char[]
        case _: SqlVarBinary => setBytesQuery(MYSQL_TYPE_VAR_STRING, length)
        case _: SqlNullableVarBinary => setBytesQuery(MYSQL_TYPE_VAR_STRING, length)

        // 长字符串，mysql输入对应表格没有给出，在输出表格有对应数据
        // Array<InputStream>----SqlClob----CLOB----LONGTEXT----MYSQL_TYPE_LONG_BLOB----char[]
        case _: SqlClob => setClobQuery(MYSQL_TYPE_LONG_BLOB, length)
        case _: SqlNullableClob => setClobQuery(MYSQL_TYPE_LONG_BLOB, length)

        // Array<InputStream>----SqlBlob----BLOB----BLOB----MYSQL_TYPE_BLOB----char[]
        case _: SqlBlob => setBlobQuery(MYSQL_TYPE_BLOB, length)
        case _: SqlNullableBlob => setBlobQuery(MYSQL_TYPE_BLOB, length)

        // 布尔类型在mysql数据库中表现形式是TINYINT
        // Bool----SqlBool----BOOLEAN----TINYINT----MYSQL_TYPE_TINY----signed char
        case _: SqlBool => setBoolQuery(MYSQL_TYPE_TINY)
        case _: SqlNullableBool => setBoolQuery(MYSQL_TYPE_TINY)

        // Int8----SqlByte----TINYINT----TINYINT----MYSQL_TYPE_TINY----signed char
        case _: SqlByte => setInt8Query(MYSQL_TYPE_TINY)
        case _: SqlNullableByte => setInt8Query(MYSQL_TYPE_TINY)

        // Int16----SqlSmallInt----SMALLINT----SMALLINT----MYSQL_TYPE_SHORT----short int
        case _: SqlSmallInt => setInt16Query(MYSQL_TYPE_SHORT)
        case _: SqlNullableSmallInt => setInt16Query(MYSQL_TYPE_SHORT)

        // SQL类型不同，但是数据值相对应
        // Int32----SqlInteger----INTEGER----INT----MYSQL_TYPE_LONG----int
        case _: SqlInteger => setInt32Query(MYSQL_TYPE_LONG)
        case _: SqlNullableInteger => setInt32Query(MYSQL_TYPE_LONG)

        // Int64----SqlBigInt----BIGINT----BIGINT----MYSQL_TYPE_LONGLONG----long long int
        case _: SqlBigInt => setInt64Query(MYSQL_TYPE_LONGLONG)
        case _: SqlNullableBigInt => setInt64Query(MYSQL_TYPE_LONGLONG)

        // SQL类型不同，但是数据值相对应
        // Float32----SqlReal----REAL----FLOAT----MYSQL_TYPE_FLOAT----float
        case _: SqlReal => setFloat32Query(MYSQL_TYPE_FLOAT)
        case _: SqlNullableReal => setFloat32Query(MYSQL_TYPE_FLOAT)

        // Float64----SqlDouble----DOUBLE----DOUBLE----MYSQL_TYPE_DOUBLE----double
        case _: SqlDouble => setFloat64Query(MYSQL_TYPE_DOUBLE)
        case _: SqlNullableDouble => setFloat64Query(MYSQL_TYPE_DOUBLE)

        // DateTime----SqlDate----DATE----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
        case _: SqlDate => setDateQuery(MYSQL_TYPE_DATE)
        case _: SqlNullableDate => setDateQuery(MYSQL_TYPE_DATE)

        // DateTime----SqlTime----TIME----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
        case _: SqlTime => setTimeQuery(MYSQL_TYPE_TIME)
        case _: SqlNullableTime => setTimeQuery(MYSQL_TYPE_TIME)

        // DateTime----SqlTimeTz----TIMETZ----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
        // mysql不支持
        case _: SqlTimeTz => throw SqlException("Unsupported data type.")
        case _: SqlNullableTimeTz => throw SqlException("Unsupported data type.")

        // DateTime----SqlTimestamp----TIMESTAMP----TIMESTAMP----MYSQL_TYPE_TIMESTAMP----MYSQL_TIME
        case _: SqlTimestamp => setTimestampQuery(MYSQL_TYPE_TIMESTAMP)
        case _: SqlNullableTimestamp => setTimestampQuery(MYSQL_TYPE_TIMESTAMP)

        // Duration----SqlInterval----INTERVAL----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
        // mysql不支持
        case _: SqlInterval => throw SqlException("Unsupported data type.")
        case _: SqlNullableInterval => throw SqlException("Unsupported data type.")

        // 自定义类
        // DATETIME----MYSQL_TYPE_DATETIME----MYSQL_TIME
        case _: SqlDateTime => setDateTimeQuery(MYSQL_TYPE_DATETIME)
        case _: SqlNullableDateTime => setDateTimeQuery(MYSQL_TYPE_DATETIME)

        case _ => throw SqlException("Unsupported data type.")
    }
}

func setStringQuery(sqlType: Int32, length: Int64): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = UInt64(length)
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<UInt8>(count: length))
    return mysqlBind
}

func setBytesQuery(sqlType: Int32, length: Int64): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = UInt64(length)
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<UInt8>(count: length))
    return mysqlBind
}

func setClobQuery(sqlType: Int32, length: Int64): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = UInt64(length)
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<UInt8>(count: length))
    return mysqlBind
}

func setBlobQuery(sqlType: Int32, length: Int64): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = UInt64(length)
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<UInt8>(count: length))
    return mysqlBind
}

func setBoolQuery(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<UInt8>())
    return mysqlBind
}

func setInt8Query(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<Int8>())
    return mysqlBind
}

func setInt16Query(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<Int16>())
    return mysqlBind
}

func setInt32Query(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<Int32>())
    return mysqlBind
}

func setInt64Query(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<Int64>())
    return mysqlBind
}

func setFloat32Query(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<Float32>())
    return mysqlBind
}

func setFloat64Query(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<Float64>())
    return mysqlBind
}

func setDateQuery(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = bufferLengthUInt64
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<MYSQL_TIME>())
    return mysqlBind
}

func setTimeQuery(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = bufferLengthUInt64
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<MYSQL_TIME>())
    return mysqlBind
}

func setTimestampQuery(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = bufferLengthUInt64
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<MYSQL_TIME>())
    return mysqlBind
}

func setDateTimeQuery(sqlType: Int32): MYSQL_BIND {
    var mysqlBind: MYSQL_BIND = MYSQL_BIND()
    mysqlBind.buffer_type = sqlType
    mysqlBind.buffer_length = bufferLengthUInt64
    mysqlBind.length = LibC.malloc<UInt64>()
    mysqlBind.is_null = LibC.malloc<UInt8>()
    mysqlBind.error = LibC.malloc<UInt8>()
    mysqlBind.buffer = CPointer<Unit>(LibC.malloc<MYSQL_TIME>())
    return mysqlBind
}

func mysqlTypeTocjType(mysqlBind: MYSQL_BIND, value: SqlDbType): SqlDbType {
    var buffer: CPointer<Unit> = mysqlBind.buffer
    let bBool: Bool = buffer.isNotNull()

    let cpBool: CPointer<UInt8> = mysqlBind.is_null
    var bindUint: UInt8 = 0
    unsafe {
        bindUint = cpBool.read()
    }
    let bufferBool = bBool && (bindUint == 0)

    var valueBool = true
    if (value.name.contains("Nullable")) {
        valueBool = false
    }

    if (value.name.contains("SqlBool") || value.name.contains("SqlNullableBool")) {
        return setBool(buffer, bufferBool, valueBool)
    }

    if (mysqlBind.buffer_type == MYSQL_TYPE_LONG) {
        return setInteger(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_STRING) {
        return setChar(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_VAR_STRING) {
        return setVarchar(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_LONG_BLOB) {
        return setClob(buffer, bufferBool, valueBool, mysqlBind)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_BLOB) {
        return setBlob(buffer, bufferBool, valueBool, mysqlBind)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_TINY) {
        return setByte(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_SHORT) {
        return setSmallInt(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_LONGLONG) {
        return setBigInt(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_FLOAT) {
        return setReal(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_DOUBLE) {
        return setDouble(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_DATE) {
        return setDate(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_TIME) {
        return setTime(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_DATETIME) {
        return setDateTime(buffer, bufferBool, valueBool)
    } else if (mysqlBind.buffer_type == MYSQL_TYPE_TIMESTAMP) {
        return setTimestamp(buffer, bufferBool, valueBool)
    } else {
        throw SqlException("Unsupported data type.")
    }
}

func setInteger(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Int32> = CPointer<Int32>(buffer)
            if (valueBool) {
                return SqlInteger(valueCPointer.read())
            } else {
                return SqlNullableInteger(valueCPointer.read())
            }
        }
    } else {
        return SqlNullableInteger(None)
    }
}

func setChar(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            if (valueBool) {
                return SqlChar(cstirng.toString())
            } else {
                return SqlNullableChar(cstirng.toString())
            }
        }
    } else {
        return SqlNullableChar(None)
    }
}

func setVarchar(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            if (valueBool) {
                return SqlVarchar(cstirng.toString())
            } else {
                return SqlNullableVarchar(cstirng.toString())
            }
        }
    } else {
        return SqlNullableVarchar(None)
    }
}

func setBlob(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool, mysqlBind: MYSQL_BIND): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)

            let bufferLength: Int64 = Int64(mysqlBind.length.read())
            var arr = Array<Byte>(bufferLength, item: 0)
            for (i in 0..bufferLength) {
                arr[i] = valueCPointer.read(i)
            }

            var output = ByteArrayStream()
            output.write(arr)
            if (valueBool) {
                return SqlBlob(output)
            } else {
                return SqlNullableBlob(output)
            }
        }
    } else {
        return SqlNullableBlob(None)
    }
}

func setClob(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool, mysqlBind: MYSQL_BIND): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)

            let bufferLength: Int64 = Int64(mysqlBind.length.read())
            var arr = Array<Byte>(bufferLength, item: 0)
            for (i in 0..bufferLength) {
                arr[i] = valueCPointer.read(i)
            }

            var output = ByteArrayStream()
            output.write(arr)
            if (valueBool) {
                return SqlClob(output)
            } else {
                return SqlNullableClob(output)
            }
        }
    } else {
        return SqlNullableClob(None)
    }
}

func setBool(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
            let sqlValue: Bool = intToBool(valueCPointer.read())
            if (valueBool) {
                return SqlBool(sqlValue)
            } else {
                return SqlNullableBool(sqlValue)
            }
        }
    } else {
        return SqlNullableBool(None)
    }
}

func intToBool(typeInt: Int8): Bool {
    if (typeInt == 0) {
        return false
    } else if (typeInt == 1) {
        return true
    }
    throw SqlException("Unsupported data type.")
}

func setByte(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
            if (valueBool) {
                return SqlByte(valueCPointer.read())
            } else {
                return SqlNullableByte(valueCPointer.read())
            }
        }
    } else {
        return SqlNullableByte(None)
    }
}

func setSmallInt(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Int16> = CPointer<Int16>(buffer)
            if (valueBool) {
                return SqlSmallInt(valueCPointer.read())
            } else {
                return SqlNullableSmallInt(valueCPointer.read())
            }
        }
    } else {
        return SqlNullableSmallInt(None)
    }
}

func setBigInt(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Int64> = CPointer<Int64>(buffer)
            if (valueBool) {
                return SqlBigInt(valueCPointer.read())
            } else {
                return SqlNullableBigInt(valueCPointer.read())
            }
        }
    } else {
        return SqlNullableBigInt(None)
    }
}

func setReal(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Float32> = CPointer<Float32>(buffer)
            if (valueBool) {
                return SqlReal(valueCPointer.read())
            } else {
                return SqlNullableReal(valueCPointer.read())
            }
        }
    } else {
        return SqlNullableReal(None)
    }
}

func setDouble(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<Float64> = CPointer<Float64>(buffer)
            if (valueBool) {
                return SqlDouble(valueCPointer.read())
            } else {
                return SqlNullableDouble(valueCPointer.read())
            }
        }
    } else {
        return SqlNullableDouble(None)
    }
}

func setDate(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<MYSQL_TIME> = CPointer<MYSQL_TIME>(buffer)
            let mysqlTime = valueCPointer.read()
            var t = DateTime.of(year: Int64(mysqlTime.year), month: Int64(mysqlTime.month),
                dayOfMonth: Int64(mysqlTime.day))
            if (valueBool) {
                return SqlDate(t)
            } else {
                return SqlNullableDate(t)
            }
        }
    } else {
        return SqlNullableDate(None)
    }
}

func setTime(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<MYSQL_TIME> = CPointer<MYSQL_TIME>(buffer)
            let mysqlTime = valueCPointer.read()
            var t = DateTime.of(year: 0, month: 1, dayOfMonth: 1, hour: Int64(mysqlTime.hour),
                minute: Int64(mysqlTime.minute), second: Int64(mysqlTime.second))
            if (valueBool) {
                return SqlTime(t)
            } else {
                return SqlNullableTime(t)
            }
        }
    } else {
        return SqlNullableTime(None)
    }
}

func setDateTime(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<MYSQL_TIME> = CPointer<MYSQL_TIME>(buffer)
            let mysqlTime = valueCPointer.read()
            var t = DateTime.of(year: Int64(mysqlTime.year), month: Int64(mysqlTime.month),
                dayOfMonth: Int64(mysqlTime.day), hour: Int64(mysqlTime.hour), minute: Int64(mysqlTime.minute),
                second: Int64(mysqlTime.second))
            if (valueBool) {
                return SqlDateTime(t)
            } else {
                return SqlNullableDateTime(t)
            }
        }
    } else {
        return SqlNullableDateTime(None)
    }
}

func setTimestamp(buffer: CPointer<Unit>, bufferBool: Bool, valueBool: Bool): SqlDbType {
    if (bufferBool) {
        unsafe {
            let valueCPointer: CPointer<MYSQL_TIME> = CPointer<MYSQL_TIME>(buffer)
            let mysqlTime = valueCPointer.read()
            var t = DateTime.of(year: Int64(mysqlTime.year), month: Int64(mysqlTime.month),
                dayOfMonth: Int64(mysqlTime.day), hour: Int64(mysqlTime.hour), minute: Int64(mysqlTime.minute),
                second: Int64(mysqlTime.second))
            if (valueBool) {
                return SqlTimestamp(t)
            } else {
                return SqlNullableTimestamp(t)
            }
        }
    } else {
        return SqlNullableTimestamp(None)
    }
}
