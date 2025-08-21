/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package mysqlclient_ffi

/*
 * 执行Select语句产生的结果
 */
public class MysqlQueryResult <: QueryResult {
    private var resultCount: Array<MysqlColumnInfo>
    private var stmt: CPointer<Unit>
    let closed = AtomicBool(false)
    private var resultSet: Array<Any>

    /*
     * 初始化 执行Select语句产生的结果
     *
     * 参数 mysql - 初始化的mysql
     * 参数 stmt - 初始化的stmt
     */
    init(stmt: CPointer<Unit>, resultCount: Array<MysqlColumnInfo>) {
        this.stmt = stmt
        this.resultCount = resultCount
        this.resultSet = Array<Any>(resultCount.size, repeat: Option<Any>.None)
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
     * 向后移动一行，必须先调用一次 next() 才能移动到第一行，第二次调用移动到第二行，依此类推。当返回 true 时，驱动会在结果集的当前行填入数据，当返回 false 时结束，且不会修改结果集当前行的内容。
     *
     * 返回值 Bool - 存在下一行则返回true，否则返回false
     * 异常 Exception - 传入参数错误
     */
    public override func next(): Bool {
        unsafe {
            var bindsCPInt8: CPointer<Int8> = LibC.malloc<Int8>(count: 8)
            var bindsCP: CPointer<Unit> = CPointer<Unit>(bindsCPInt8)
            if (bindsCP.isNull()) {
                throw SqlException("Native malloc Failed.")
            }
            if (resultCount.size > 0) {
                bindsCP = init_bind(resultCount.size)
            }
            if (bindsCP.isNull()) {
                // 初始化失败，有可能内存不足导致的malloc失败
                throw SqlException("Init Bind Failed!")
            }
            for (i in 0..resultCount.size) {
                var isBool: Bool = cjTypeToMysqlTypeQuery(resultCount[i].typeName, bindsCP, i, resultCount[i].length)
                if (!isBool) {
                    free_mysql_cj(bindsCP, i)
                    throw SqlException("Malloc  Failed!")
                }
            }
            let isBool: Bool = mysql_stmt_bind_result(stmt, bindsCP)
            if (isBool) {
                free_mysql_cj(bindsCP, resultCount.size)
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
            var intFetch: Int32 = mysql_stmt_fetch(stmt)
            if (intFetch == 1) {
                // 发生错误。
                free_mysql_cj(bindsCP, resultCount.size)
                throw SqlException(mysql_stmt_error(stmt).toString())
            } else if (intFetch == 100) {
                // 成功，不再存在数据。
                free_mysql_cj(bindsCP, resultCount.size)
                return false
            } else if (intFetch == 101) {
                // 发生数据截断。
            }

            // 成功存在数据或有数据发生数据截断
            for (i in 0..resultCount.size) {
                resultSet[i] = mysqlTypeTocjType(bindsCP, resultCount[i].typeName, i)
            }
            free_mysql_cj(bindsCP, resultCount.size)
            return true
        }
    }

    /*
     * 获取数据
     *
     * 参数 index - 位置
     * 返回值 T - 值
     * 异常 Exception - 传入参数错误
     */
    public override func get<T>(index: Int): T {
        return getOrNull<T>(index) ?? throw SqlException("data is null")
    }

    /*
     * 获取可以为null的数据
     *
     * 参数 index - 位置
     * 返回值 ?T - 值
     * 异常 Exception - 传入参数错误
     */
    public override func getOrNull<T>(index: Int): ?T {
        checkResource()
        if (index < 0) {
            throw SqlException("Index must be greater than or equal to 0")
        }
        if (index > resultCount.size) {
            throw SqlException("parameter index error")
        }
        return (resultSet[index] as ?T) ?? throw SqlException("data type error")
    }

    /*
     * 关闭资源
     *
     * 异常 SqlException - 关闭资源失败。
     */
    public override func close(): Unit {
        if (isClosed()) {
            return
        }
        closed.store(true)
        unsafe {
            // 释放预准备语句内存资源
            let isBool: Bool = mysql_stmt_free_result(stmt)
            if (isBool) {
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
        }
    }

    /*
     * 判断资源是否关闭
     * 返回值 Bool - 如果已经关闭返回true，否则返回false
     */
    public override func isClosed(): Bool {
        return closed.load()
    }

    /*
     * 向后移动一行，必须先调用一次next才能移动到第一行，第二次调用移动到第二行，依此类推。
     * 当返回true时，驱动会在values中填入行数据；当返回false时结束，且不会修改values的内容。 - todo：废弃
     *
     * 参数 values - 需要填充返回的数据
     * 返回值 Bool - 存在下一行则返回true，否则返回false
     * 异常 SqlException - 传入参数错误
     */
    @Deprecated
    public override func next(values: Array<SqlDbType>): Bool {
        unsafe {
            var bindsCPInt8: CPointer<Int8> = LibC.malloc<Int8>(count:8)
            var bindsCP: CPointer<Unit> = CPointer<Unit>(bindsCPInt8)
            if (bindsCP.isNull()) {
                throw SqlException("Native malloc Failed.")
            }
            if (values.size > 0) {
                bindsCP = init_bind(values.size)
            }
            if (bindsCP.isNull()) {
                // 初始化失败，有可能内存不足导致的malloc失败
                throw SqlException("Init Bind Failed!")
            }
            for (i in 0..values.size) {
                var isBool: Bool = cjTypeToMysqlOldTypeQuery(values[i], bindsCP, i, resultCount[i].length)
                if (!isBool) {
                    free_mysql_cj(bindsCP, i)
                    throw SqlException("Malloc  Failed!")
                }
            }
            let isBool: Bool = mysql_stmt_bind_result(stmt, bindsCP)
            if (isBool) {
                free_mysql_cj(bindsCP, values.size)
                throw SqlException(mysql_stmt_error(stmt).toString())
            }
            var intFetch: Int32 = mysql_stmt_fetch(stmt)
            if (intFetch == 1) {
                // 发生错误。
                free_mysql_cj(bindsCP, values.size)
                throw SqlException(mysql_stmt_error(stmt).toString())
            } else if (intFetch == 100) {
                // 成功，不再存在数据。
                free_mysql_cj(bindsCP, values.size)
                return false
            } else if (intFetch == 101) {
                // 发生数据截断。
            }

            // 成功存在数据或有数据发生数据截断
            for (i in 0..values.size) {
                values[i] = mysqlTypeTocjOldType(bindsCP, values[i], i)
            }
            free_mysql_cj(bindsCP, values.size)

            return true
        }
    }

    private func checkResource() {
        if (isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }
}

func cjTypeToMysqlTypeQuery(sqlDbType: String, bindsCP: CPointer<Unit>, index: Int64, length: Int64): Bool {
    unsafe {
        return match (sqlDbType) {
            case "SqlString" => get_string(bindsCP, index, length)
            case "SqlArrayByte" => get_blob(bindsCP, index, length)
            case "SqlInputStream" => get_blob(bindsCP, index, length)
            case "SqlBool" => get_bool(bindsCP, index)
            case "SqlInt8" => get_int8(bindsCP, index)
            case "SqlInt16" => get_int16(bindsCP, index)
            case "SqlInt32" => get_int32(bindsCP, index)
            case "SqlInt64" => get_int64(bindsCP, index)
            case "SqlFloat32" => get_float32(bindsCP, index)
            case "SqlFloat64" => get_float64(bindsCP, index)
            case "SqlDateTime" => get_date_time(bindsCP, index)
            case "SqlMysqlTypeDate" => get_date(bindsCP, index)
            case "SqlMysqlTypeTime" => get_time(bindsCP, index)
            case "SqlMysqlTypeTimeTimestamp" => get_timestamp(bindsCP, index)
            case "SqlDecimal" => get_decimal(bindsCP, index, length)
            case _ => throw SqlException("Unsupported data type.")
        }
    }
}

func mysqlTypeTocjType(bindsCP: CPointer<Unit>, value: String, index: Int64): Any {
    unsafe {
        var bufferTypeCpInt8: CPointer<Int8> = LibC.malloc<Int8>(count: 8)
        var bufferTypeCp: CPointer<Unit> = CPointer<Unit>(bufferTypeCpInt8)
        if (bufferTypeCp.isNull()) {
            throw SqlException("Native malloc Failed.")
        }
        var isNullCpCpInt8: CPointer<Int8> = LibC.malloc<Int8>(count: 8)
        var isNullCp: CPointer<Unit> = CPointer<Unit>(isNullCpCpInt8)
        if (isNullCp.isNull()) {
            LibC.free(bufferTypeCp)
            throw SqlException("Native malloc Failed.")
        }
        var lengthCp: CPointer<Int64> = LibC.malloc<Int64>(count: 8)
        if (lengthCp.isNull()) {
            LibC.free(bufferTypeCp)
            LibC.free(isNullCp)
            throw SqlException("Native malloc Failed.")
        }
        var bufferCp: CPointer<Unit> = get_sql_buffer(bindsCP, index, bufferTypeCp, isNullCp, lengthCp)
        let any: Any = match (value) {
            case "SqlString" => getString(bufferCp, isNullCp)
            case "SqlArrayByte" => getArrayByte(bufferCp, lengthCp.read(), isNullCp)
            case "SqlBool" => getBool(bufferCp, isNullCp)
            case "SqlInt8" => getInt8(bufferCp, isNullCp)
            case "SqlInt16" => getInt16(bufferCp, isNullCp)
            case "SqlInt32" => getInt32(bufferCp, isNullCp)
            case "SqlInt64" => getInt64(bufferCp, isNullCp)
            case "SqlFloat32" => getFloat32(bufferCp, isNullCp)
            case "SqlFloat64" => getFloat64(bufferCp, isNullCp)
            case "SqlDateTime" => getDateTime(bufferCp, isNullCp)
            case "SqlMysqlTypeDate" => getDate(bufferCp, isNullCp)
            case "SqlMysqlTypeTime" => getTime(bufferCp, isNullCp)
            case "SqlMysqlTypeTimeTimestamp" => getTimestamp(bufferCp, isNullCp)
            case "SqlDecimal" => getDecimal(bufferCp, isNullCp)
            case _ => throw SqlException("Unsupported data type.")
        }
        return any
    }
}

func getString(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?String {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<String>.None
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            return cstirng.toString()
        }
    }
}

func getArrayByte(buffer: CPointer<Unit>, length: Int64, isNull: CPointer<Unit>): ?Array<Byte> {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Array<Byte>>.None
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            var arr = Array<Byte>(length, repeat: 0)
            for (i in 0..length) {
                arr[i] = valueCPointer.read(i)
            }
            return arr
        }
    }
}

func getBool(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Bool {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Bool>.None
        } else {
            let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
            let sqlValue: Bool = intToBool(valueCPointer.read())
            return sqlValue
        }
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

func getInt8(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Int8 {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Int8>.None
        } else {
            let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
            let sqlValue: Int8 = valueCPointer.read()
            return sqlValue
        }
    }
}

func getInt16(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Int16 {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Int16>.None
        } else {
            let valueCPointer: CPointer<Int16> = CPointer<Int16>(buffer)
            let sqlValue: Int16 = valueCPointer.read()
            return sqlValue
        }
    }
}

func getInt32(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Int32 {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Int32>.None
        } else {
            let valueCPointer: CPointer<Int32> = CPointer<Int32>(buffer)
            let sqlValue: Int32 = valueCPointer.read()
            return sqlValue
        }
    }
}

func getInt64(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Int64 {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Int64>.None
        } else {
            let valueCPointer: CPointer<Int64> = CPointer<Int64>(buffer)
            let sqlValue: Int64 = valueCPointer.read()
            return sqlValue
        }
    }
}

func getFloat32(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Float32 {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Float32>.None
        } else {
            let valueCPointer: CPointer<Float32> = CPointer<Float32>(buffer)
            let sqlValue: Float32 = valueCPointer.read()
            return sqlValue
        }
    }
}

func getFloat64(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Float64 {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Float64>.None
        } else {
            let valueCPointer: CPointer<Float64> = CPointer<Float64>(buffer)
            let sqlValue: Float64 = valueCPointer.read()
            return sqlValue
        }
    }
}

func getDate(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?MysqlTypeDate {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<MysqlTypeDate>.None
        } else {
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp)
            let dateTime: DateTime = DateTime.of(
                year: Int64(yearCp.read()),
                month: Int64(monthCp.read()),
                dayOfMonth: Int64(dayCp.read())
            )
            let mysqlTypeDate: MysqlTypeDate = MysqlTypeDate(dateTime)
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return mysqlTypeDate
        }
    }
}

func getTime(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?MysqlTypeTime {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<MysqlTypeTime>.None
        } else {
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp)
            let dateTime: DateTime = DateTime.of(
                year: 1970,
                month: 1,
                dayOfMonth: 1,
                hour: Int64(hourCp.read()),
                minute: Int64(minuteCp.read()),
                second: Int64(secondCp.read())
            )
            let mysqlTypeTime: MysqlTypeTime = MysqlTypeTime(dateTime)
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return mysqlTypeTime
        }
    }
}

func getTimestamp(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?MysqlTypeTimeTimestamp {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<MysqlTypeTimeTimestamp>.None
        } else {
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp)
            let dateTime: DateTime = DateTime.of(
                year: Int64(yearCp.read()),
                month: Int64(monthCp.read()),
                dayOfMonth: Int64(dayCp.read()),
                hour: Int64(hourCp.read()),
                minute: Int64(minuteCp.read()),
                second: Int64(secondCp.read())
            )
            let mysqlTypeTimeTimestamp: MysqlTypeTimeTimestamp = MysqlTypeTimeTimestamp(dateTime)
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return mysqlTypeTimeTimestamp
        }
    }
}

func getDateTime(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?DateTime {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<DateTime>.None
        } else {
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp)
            let dateTime: DateTime = DateTime.of(
                year: Int64(yearCp.read()),
                month: Int64(monthCp.read()),
                dayOfMonth: Int64(dayCp.read()),
                hour: Int64(hourCp.read()),
                minute: Int64(minuteCp.read()),
                second: Int64(secondCp.read())
            )
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return dateTime
        }
    }
}

func getDecimal(buffer: CPointer<Unit>, isNull: CPointer<Unit>): ?Decimal {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return Option<Decimal>.None
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            return Decimal.parse(cstirng.toString())
        }
    }
}

func mysqlTypeTocjOldType(bindsCP: CPointer<Unit>, value: SqlDbType, index: Int64): SqlDbType {
    unsafe {
        var bufferTypeCpInt8: CPointer<Int8> = LibC.malloc<Int8>(count:8)
        var bufferTypeCp: CPointer<Unit> = CPointer<Unit>(bufferTypeCpInt8)
        if (bufferTypeCp.isNull()) {
            throw SqlException("Native malloc Failed.")
        }
        var isNullCpCpInt8: CPointer<Int8> = LibC.malloc<Int8>(count:8)
        var isNullCp: CPointer<Unit> = CPointer<Unit>(isNullCpCpInt8)
        if (isNullCp.isNull()) {
            LibC.free(bufferTypeCp)
            throw SqlException("Native malloc Failed.")
        }
        var lengthCp: CPointer<Int64> = LibC.malloc<Int64>(count: 8)
        if (lengthCp.isNull()) {
            LibC.free(bufferTypeCp)
            LibC.free(isNullCp)
            throw SqlException("Native malloc Failed.")
        }
        var bufferCp: CPointer<Unit> = get_sql_buffer(bindsCP, index, bufferTypeCp, isNullCp, lengthCp)
        let sqlDbType: SqlDbType = match (value) {
            // String----SqlChar----CHAR----CHAR----MYSQL_TYPE_STRING----char[]
            case _: SqlChar => getOldSqlChar(bufferCp)
            case _: SqlNullableChar => getOldSqlNullableChar(bufferCp, isNullCp)

            // String----SqlVarchar----VARCHAR----VARCHAR----MYSQL_TYPE_VAR_STRING----char[]
            case _: SqlVarchar => getOldSqlVarchar(bufferCp)
            case _: SqlNullableVarchar => getOldSqlNullableVarchar(bufferCp, isNullCp)

            // Array<Byte>----SqlBinary----BINARY----BINARY----MYSQL_TYPE_BLOB----char[]
            case _: SqlBinary => getOldSqlBinary(bufferCp, lengthCp.read())
            case _: SqlNullableBinary => getOldSqlNullableBinary(bufferCp, lengthCp.read(), isNullCp)

            // Array<Byte>----SqlVarBinary----VARBINARY----VARBINARY----MYSQL_TYPE_BLOB----char[]
            case _: SqlVarBinary => getOldSqlVarBinary(bufferCp, lengthCp.read())
            case _: SqlNullableVarBinary => getOldSqlNullableVarBinary(bufferCp, lengthCp.read(), isNullCp)

            // 长字符串，mysql输入对应表格没有给出，在输出表格有对应数据
            // Array<InputStream>----SqlClob----CLOB----LONGTEXT----MYSQL_TYPE_LONG_BLOB----char[]
            case _: SqlClob => getOldSqlClob(bufferCp, lengthCp.read())
            case _: SqlNullableClob => getOldSqlNullableClob(bufferCp, lengthCp.read(), isNullCp)

            // Array<InputStream>----SqlBlob----BLOB----BLOB----MYSQL_TYPE_BLOB----char[]
            case _: SqlBlob => getOldSqlBlob(bufferCp, lengthCp.read())
            case _: SqlNullableBlob => getOldSqlNullableBlob(bufferCp, lengthCp.read(), isNullCp)

            // 布尔类型在mysql数据库中表现形式是TINYINT
            // Bool----SqlBool----BOOLEAN----TINYINT----MYSQL_TYPE_TINY----signed char
            case _: SqlBool => getOldSqlBool(bufferCp)
            case _: SqlNullableBool => getOldSqlNullableBool(bufferCp, isNullCp)

            // Int8----SqlByte----TINYINT----TINYINT----MYSQL_TYPE_TINY----signed char
            case _: SqlByte => getOldSqlByte(bufferCp)
            case _: SqlNullableByte => getOldSqlNullableByte(bufferCp, isNullCp)

            // Int16----SqlSmallInt----SMALLINT----SMALLINT----MYSQL_TYPE_SHORT----short int
            case _: SqlSmallInt => getOldSqlSmallInt(bufferCp)
            case _: SqlNullableSmallInt => getOldSqlNullableSmallInt(bufferCp, isNullCp)

            // SQL类型不同，但是数据值相对应
            // Int32----SqlInteger----INTEGER----INT----MYSQL_TYPE_LONG----int
            case _: SqlInteger => getOldSqlInteger(bufferCp)
            case _: SqlNullableInteger => getOldSqlNullableInteger(bufferCp, isNullCp)

            // Int64----SqlBigInt----BIGINT----BIGINT----MYSQL_TYPE_LONGLONG----long long int
            case _: SqlBigInt => getOldSqlBigInt(bufferCp)
            case _: SqlNullableBigInt => getOldSqlNullableBigInt(bufferCp, isNullCp)

            // SQL类型不同，但是数据值相对应
            // Float32----SqlReal----REAL----FLOAT----MYSQL_TYPE_FLOAT----float
            case _: SqlReal => getOldSqlReal(bufferCp)
            case _: SqlNullableReal => getOldSqlNullableReal(bufferCp, isNullCp)

            // Float64----SqlDouble----DOUBLE----DOUBLE----MYSQL_TYPE_DOUBLE----double
            case _: SqlDouble => getOldSqlDouble(bufferCp)
            case _: SqlNullableDouble => getOldSqlNullableDouble(bufferCp, isNullCp)

            // DateTime----SqlDate----DATE----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
            case _: SqlDate => getOldSqlDate(bufferCp)
            case _: SqlNullableDate => getOldSqlNullableDate(bufferCp, isNullCp)

            // DateTime----SqlTime----TIME----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
            case _: SqlTime => getOldSqlTime(bufferCp)
            case _: SqlNullableTime => getOldSqlNullableTime(bufferCp, isNullCp)

            // DateTime----SqlTimeTz----TIMETZ----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
            // mysql不支持
            case _: SqlTimeTz => throw SqlException("Unsupported data type.")
            case _: SqlNullableTimeTz => throw SqlException("Unsupported data type.")

            // DateTime----SqlTimestamp----TIMESTAMP----TIMESTAMP----MYSQL_TYPE_TIMESTAMP----MYSQL_TIME
            case _: SqlTimestamp => getOldSqlTimestamp(bufferCp)
            case _: SqlNullableTimestamp => getOldSqlNullableTimestamp(bufferCp, isNullCp)

            // Duration----SqlInterval----INTERVAL----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
            // mysql不支持
            case _: SqlInterval => throw SqlException("Unsupported data type.")
            case _: SqlNullableInterval => throw SqlException("Unsupported data type.")

            // 自定义类
            // DATETIME----MYSQL_TYPE_DATETIME----MYSQL_TIME
            case _: SqlDateTime => getOldSqlDateTime(bufferCp)
            case _: SqlNullableDateTime => getOldSqlNullableDateTime(bufferCp, isNullCp)

            // 自定义类
            // DECIMAL----MYSQL_TYPE_NEWDECIMAL
            case _: SqlDecimal => getOldSqlDecimal(bufferCp)
            case _: SqlNullableDecimal => getOldSqlNullableDecimal(bufferCp, isNullCp)

            case _ => throw SqlException("Unsupported data type.")
        }
        return sqlDbType
    }
}

func getOldSqlChar(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        let cstirng: CString = CString(valueCPointer)
        return SqlChar(cstirng.toString())
    }
}

func getOldSqlNullableChar(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableChar(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            return SqlNullableChar(cstirng.toString())
        }
    }
}

func getOldSqlVarchar(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        let cstirng: CString = CString(valueCPointer)
        return SqlVarchar(cstirng.toString())
    }
}

func getOldSqlNullableVarchar(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableVarchar(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            return SqlNullableVarchar(cstirng.toString())
        }
    }
}

func getOldSqlBinary(buffer: CPointer<Unit>, length: Int64): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        var arr = Array<Byte>(length, repeat: 0)
        for (i in 0..length) {
            arr[i] = valueCPointer.read(i)
        }
        return SqlBinary(arr)
    }
}

func getOldSqlNullableBinary(buffer: CPointer<Unit>, length: Int64, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableBinary(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            var arr = Array<Byte>(length, repeat: 0)
            for (i in 0..length) {
                arr[i] = valueCPointer.read(i)
            }
            return SqlNullableBinary(arr)
        }
    }
}

func getOldSqlVarBinary(buffer: CPointer<Unit>, length: Int64): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        var arr = Array<Byte>(length, repeat: 0)
        for (i in 0..length) {
            arr[i] = valueCPointer.read(i)
        }
        return SqlVarBinary(arr)
    }
}

func getOldSqlNullableVarBinary(buffer: CPointer<Unit>, length: Int64, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableVarBinary(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            var arr = Array<Byte>(length, repeat: 0)
            for (i in 0..length) {
                arr[i] = valueCPointer.read(i)
            }
            return SqlNullableVarBinary(arr)
        }
    }
}

func getOldSqlClob(buffer: CPointer<Unit>, length: Int64): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        var arr = Array<Byte>(length, repeat: 0)
        for (i in 0..length) {
            arr[i] = valueCPointer.read(i)
        }
        var output = ByteBuffer()
        output.write(arr)
        return SqlClob(output)
    }
}

func getOldSqlNullableClob(buffer: CPointer<Unit>, length: Int64, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableClob(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            var arr = Array<Byte>(length, repeat: 0)
            for (i in 0..length) {
                arr[i] = valueCPointer.read(i)
            }
            var output = ByteBuffer()
            output.write(arr)
            return SqlNullableClob(output)
        }
    }
}

func getOldSqlBlob(buffer: CPointer<Unit>, length: Int64): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        var arr = Array<Byte>(length, repeat: 0)
        for (i in 0..length) {
            arr[i] = valueCPointer.read(i)
        }
        var output = ByteBuffer()
        output.write(arr)
        return SqlBlob(output)
    }
}

func getOldSqlNullableBlob(buffer: CPointer<Unit>, length: Int64, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableBlob(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            var arr = Array<Byte>(length, repeat: 0)
            for (i in 0..length) {
                arr[i] = valueCPointer.read(i)
            }
            var output = ByteBuffer()
            output.write(arr)
            return SqlNullableBlob(output)
        }
    }
}

func getOldSqlBool(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
        let sqlValue: Bool = intToBool(valueCPointer.read())
        return SqlBool(sqlValue)
    }
}

func getOldSqlNullableBool(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableBool(None)
        } else {
            let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
            let sqlValue: Bool = intToBool(valueCPointer.read())
            return SqlNullableBool(sqlValue)
        }
    }
}

func intToOldBool(typeInt: Int8): Bool {
    if (typeInt == 0) {
        return false
    } else if (typeInt == 1) {
        return true
    }
    throw SqlException("Unsupported data type.")
}

func getOldSqlByte(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
        let sqlValue: Int8 = valueCPointer.read()
        return SqlByte(sqlValue)
    }
}

func getOldSqlNullableByte(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableByte(None)
        } else {
            let valueCPointer: CPointer<Int8> = CPointer<Int8>(buffer)
            let sqlValue: Int8 = valueCPointer.read()
            return SqlNullableByte(sqlValue)
        }
    }
}

func getOldSqlSmallInt(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Int16> = CPointer<Int16>(buffer)
        let sqlValue: Int16 = valueCPointer.read()
        return SqlSmallInt(sqlValue)
    }
}

func getOldSqlNullableSmallInt(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableSmallInt(None)
        } else {
            let valueCPointer: CPointer<Int16> = CPointer<Int16>(buffer)
            let sqlValue: Int16 = valueCPointer.read()
            return SqlNullableSmallInt(sqlValue)
        }
    }
}

func getOldSqlInteger(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Int32> = CPointer<Int32>(buffer)
        let sqlValue: Int32 = valueCPointer.read()
        return SqlInteger(sqlValue)
    }
}

func getOldSqlNullableInteger(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableInteger(None)
        } else {
            let valueCPointer: CPointer<Int32> = CPointer<Int32>(buffer)
            let sqlValue: Int32 = valueCPointer.read()
            return SqlNullableInteger(sqlValue)
        }
    }
}

func getOldSqlBigInt(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Int64> = CPointer<Int64>(buffer)
        let sqlValue: Int64 = valueCPointer.read()
        return SqlBigInt(sqlValue)
    }
}

func getOldSqlNullableBigInt(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableBigInt(None)
        } else {
            let valueCPointer: CPointer<Int64> = CPointer<Int64>(buffer)
            let sqlValue: Int64 = valueCPointer.read()
            return SqlNullableBigInt(sqlValue)
        }
    }
}

func getOldSqlReal(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Float32> = CPointer<Float32>(buffer)
        let sqlValue: Float32 = valueCPointer.read()
        return SqlReal(sqlValue)
    }
}

func getOldSqlNullableReal(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableReal(None)
        } else {
            let valueCPointer: CPointer<Float32> = CPointer<Float32>(buffer)
            let sqlValue: Float32 = valueCPointer.read()
            return SqlNullableReal(sqlValue)
        }
    }
}

func getOldSqlDouble(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<Float64> = CPointer<Float64>(buffer)
        let sqlValue: Float64 = valueCPointer.read()
        return SqlDouble(sqlValue)
    }
}

func getOldSqlNullableDouble(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableDouble(None)
        } else {
            let valueCPointer: CPointer<Float64> = CPointer<Float64>(buffer)
            let sqlValue: Float64 = valueCPointer.read()
            return SqlNullableDouble(sqlValue)
        }
    }
}

func getOldSqlDate(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (yearCp.isNull()) {
            throw SqlException("Native malloc Failed.")
        }
        var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (monthCp.isNull()) {
            LibC.free(yearCp)
            throw SqlException("Native malloc Failed.")
        }
        var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (dayCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            throw SqlException("Native malloc Failed.")
        }
        var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (hourCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            throw SqlException("Native malloc Failed.")
        }
        var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (minuteCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            throw SqlException("Native malloc Failed.")
        }
        var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (secondCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            LibC.free(minuteCp)
            throw SqlException("Native malloc Failed.")
        }
        get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
        let dateTime: DateTime = DateTime.of(
            year: Int64(yearCp.read()),
            month: Int64(monthCp.read()),
            dayOfMonth: Int64(dayCp.read())
        )
        LibC.free<UInt32>(yearCp)
        LibC.free<UInt32>(monthCp)
        LibC.free<UInt32>(dayCp)
        LibC.free<UInt32>(hourCp)
        LibC.free<UInt32>(minuteCp)
        LibC.free<UInt32>(secondCp)
        return SqlDate(dateTime)
    }
}

func getOldSqlNullableDate(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
            let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
            if (isNullCp.read()) {
                return SqlNullableDate(None)
            } else {
                
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (yearCp.isNull()) {
                throw SqlException("Native malloc Failed.")
            }
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (monthCp.isNull()) {
                LibC.free(yearCp)
                throw SqlException("Native malloc Failed.")
            }
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (dayCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                throw SqlException("Native malloc Failed.")
            }
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (hourCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                throw SqlException("Native malloc Failed.")
            }
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (minuteCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                throw SqlException("Native malloc Failed.")
            }
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (secondCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                LibC.free(minuteCp)
                throw SqlException("Native malloc Failed.")
            }
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
            let dateTime: DateTime = DateTime.of(
                year: Int64(yearCp.read()),
                month: Int64(monthCp.read()),
                dayOfMonth: Int64(dayCp.read())
            )
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return SqlNullableDate(dateTime)
        }
    }
}

func getOldSqlTime(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        
        var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (yearCp.isNull()) {
            throw SqlException("Native malloc Failed.")
        }
        var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (monthCp.isNull()) {
            LibC.free(yearCp)
            throw SqlException("Native malloc Failed.")
        }
        var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (dayCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            throw SqlException("Native malloc Failed.")
        }
        var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (hourCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            throw SqlException("Native malloc Failed.")
        }
        var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (minuteCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            throw SqlException("Native malloc Failed.")
        }
        var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (secondCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            LibC.free(minuteCp)
            throw SqlException("Native malloc Failed.")
        }
        get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
        let dateTime: DateTime = DateTime.of(
            year: 1970,
            month: 1,
            dayOfMonth: 1,
            hour: Int64(hourCp.read()),
            minute: Int64(minuteCp.read()),
            second: Int64(secondCp.read())
        )
        LibC.free<UInt32>(yearCp)
        LibC.free<UInt32>(monthCp)
        LibC.free<UInt32>(dayCp)
        LibC.free<UInt32>(hourCp)
        LibC.free<UInt32>(minuteCp)
        LibC.free<UInt32>(secondCp)
        return SqlTime(dateTime)
    }
}

func getOldSqlNullableTime(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
            let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
            if (isNullCp.read()) {
                return SqlNullableTime(None)
            } else {
                
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (yearCp.isNull()) {
                throw SqlException("Native malloc Failed.")
            }
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (monthCp.isNull()) {
                LibC.free(yearCp)
                throw SqlException("Native malloc Failed.")
            }
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (dayCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                throw SqlException("Native malloc Failed.")
            }
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (hourCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                throw SqlException("Native malloc Failed.")
            }
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (minuteCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                throw SqlException("Native malloc Failed.")
            }
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (secondCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                LibC.free(minuteCp)
                throw SqlException("Native malloc Failed.")
            }
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
            let dateTime: DateTime = DateTime.of(
                year: 1970,
                month: 1,
                dayOfMonth: 1,
                hour: Int64(hourCp.read()),
                minute: Int64(minuteCp.read()),
                second: Int64(secondCp.read())
            )
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return SqlNullableTime(dateTime)
        }
    }
}

func getOldSqlTimestamp(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        
        var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (yearCp.isNull()) {
            throw SqlException("Native malloc Failed.")
        }
        var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (monthCp.isNull()) {
            LibC.free(yearCp)
            throw SqlException("Native malloc Failed.")
        }
        var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (dayCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            throw SqlException("Native malloc Failed.")
        }
        var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (hourCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            throw SqlException("Native malloc Failed.")
        }
        var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (minuteCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            throw SqlException("Native malloc Failed.")
        }
        var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (secondCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            LibC.free(minuteCp)
            throw SqlException("Native malloc Failed.")
        }
        get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
        let dateTime: DateTime = DateTime.of(
            year: Int64(yearCp.read()),
            month: Int64(monthCp.read()),
            dayOfMonth: Int64(dayCp.read()),
            hour: Int64(hourCp.read()),
            minute: Int64(minuteCp.read()),
            second: Int64(secondCp.read())
        )
        LibC.free<UInt32>(yearCp)
        LibC.free<UInt32>(monthCp)
        LibC.free<UInt32>(dayCp)
        LibC.free<UInt32>(hourCp)
        LibC.free<UInt32>(minuteCp)
        LibC.free<UInt32>(secondCp)
        return SqlTimestamp(dateTime)
    }
}

func getOldSqlNullableTimestamp(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
            let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
            if (isNullCp.read()) {
                return SqlNullableTimestamp(None)
            } else {
                
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (yearCp.isNull()) {
                throw SqlException("Native malloc Failed.")
            }
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (monthCp.isNull()) {
                LibC.free(yearCp)
                throw SqlException("Native malloc Failed.")
            }
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (dayCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                throw SqlException("Native malloc Failed.")
            }
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (hourCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                throw SqlException("Native malloc Failed.")
            }
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (minuteCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                throw SqlException("Native malloc Failed.")
            }
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (secondCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                LibC.free(minuteCp)
                throw SqlException("Native malloc Failed.")
            }
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
            let dateTime: DateTime = DateTime.of(
                year: Int64(yearCp.read()),
                month: Int64(monthCp.read()),
                dayOfMonth: Int64(dayCp.read()),
                hour: Int64(hourCp.read()),
                minute: Int64(minuteCp.read()),
                second: Int64(secondCp.read())
            )
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return SqlNullableTimestamp(dateTime)
        }
    }
}

func getOldSqlDateTime(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        
        var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (yearCp.isNull()) {
            throw SqlException("Native malloc Failed.")
        }
        var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (monthCp.isNull()) {
            LibC.free(yearCp)
            throw SqlException("Native malloc Failed.")
        }
        var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (dayCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            throw SqlException("Native malloc Failed.")
        }
        var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (hourCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            throw SqlException("Native malloc Failed.")
        }
        var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (minuteCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            throw SqlException("Native malloc Failed.")
        }
        var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
        if (secondCp.isNull()) {
            LibC.free(yearCp)
            LibC.free(monthCp)
            LibC.free(dayCp)
            LibC.free(hourCp)
            LibC.free(minuteCp)
            throw SqlException("Native malloc Failed.")
        }
        get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
        let dateTime: DateTime = DateTime.of(
            year: Int64(yearCp.read()),
            month: Int64(monthCp.read()),
            dayOfMonth: Int64(dayCp.read()),
            hour: Int64(hourCp.read()),
            minute: Int64(minuteCp.read()),
            second: Int64(secondCp.read())
        )
        LibC.free<UInt32>(yearCp)
        LibC.free<UInt32>(monthCp)
        LibC.free<UInt32>(dayCp)
        LibC.free<UInt32>(hourCp)
        LibC.free<UInt32>(minuteCp)
        LibC.free<UInt32>(secondCp)
        return SqlDateTime(dateTime)
    }
}

func getOldSqlNullableDateTime(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
            let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
            if (isNullCp.read()) {
                return SqlNullableDateTime(None)
            } else {
                
            var yearCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (yearCp.isNull()) {
                throw SqlException("Native malloc Failed.")
            }
            var monthCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (monthCp.isNull()) {
                LibC.free(yearCp)
                throw SqlException("Native malloc Failed.")
            }
            var dayCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (dayCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                throw SqlException("Native malloc Failed.")
            }
            var hourCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (hourCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                throw SqlException("Native malloc Failed.")
            }
            var minuteCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (minuteCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                throw SqlException("Native malloc Failed.")
            }
            var secondCp: CPointer<UInt32> = LibC.malloc<UInt32>(count: 4)
            if (secondCp.isNull()) {
                LibC.free(yearCp)
                LibC.free(monthCp)
                LibC.free(dayCp)
                LibC.free(hourCp)
                LibC.free(minuteCp)
                throw SqlException("Native malloc Failed.")
            }
            get_sql_time(buffer, yearCp, monthCp, dayCp, hourCp, minuteCp, secondCp);
            let dateTime: DateTime = DateTime.of(
                year: Int64(yearCp.read()),
                month: Int64(monthCp.read()),
                dayOfMonth: Int64(dayCp.read()),
                hour: Int64(hourCp.read()),
                minute: Int64(minuteCp.read()),
                second: Int64(secondCp.read())
            )
            LibC.free<UInt32>(yearCp)
            LibC.free<UInt32>(monthCp)
            LibC.free<UInt32>(dayCp)
            LibC.free<UInt32>(hourCp)
            LibC.free<UInt32>(minuteCp)
            LibC.free<UInt32>(secondCp)
            return SqlNullableDateTime(dateTime)
        }
    }
}

func getOldSqlDecimal(buffer: CPointer<Unit>): SqlDbType {
    unsafe {
        let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
        let cstirng: CString = CString(valueCPointer)
        return SqlDecimal(Decimal.parse(cstirng.toString()))
    }
}

func getOldSqlNullableDecimal(buffer: CPointer<Unit>, isNull: CPointer<Unit>): SqlDbType {
    unsafe {
        let isNullCp: CPointer<Bool> = CPointer<Bool>(isNull)
        if (isNullCp.read()) {
            return SqlNullableDecimal(None)
        } else {
            let valueCPointer: CPointer<UInt8> = CPointer<UInt8>(buffer)
            let cstirng: CString = CString(valueCPointer)
            return SqlNullableDecimal(Decimal.parse(cstirng.toString()))
        }
    }
}

func cjTypeToMysqlOldTypeQuery(sqlDbType: SqlDbType, bindsCP: CPointer<Unit>, index: Int64, length: Int64): Bool {
    unsafe {
        return match (sqlDbType) {
            // String----SqlChar----CHAR----CHAR----MYSQL_TYPE_STRING----char[]
            case _: SqlChar => get_string(bindsCP, index, length)
            case _: SqlNullableChar => get_string(bindsCP, index, length)

            // String----SqlVarchar----VARCHAR----VARCHAR----MYSQL_TYPE_VAR_STRING----char[]
            case _: SqlVarchar => get_string(bindsCP, index, length)
            case _: SqlNullableVarchar => get_string(bindsCP, index, length)

            // Array<Byte>----SqlBinary----BINARY----BINARY----MYSQL_TYPE_BLOB----char[]
            case _: SqlBinary => get_bytes(bindsCP, index, length)
            case _: SqlNullableBinary => get_bytes(bindsCP, index, length)

            // Array<Byte>----SqlVarBinary----VARBINARY----VARBINARY----MYSQL_TYPE_BLOB----char[]
            case _: SqlVarBinary => get_bytes(bindsCP, index, length)
            case _: SqlNullableVarBinary => get_bytes(bindsCP, index, length)

            // 长字符串，mysql输入对应表格没有给出，在输出表格有对应数据
            // Array<InputStream>----SqlClob----CLOB----LONGTEXT----MYSQL_TYPE_LONG_BLOB----char[]
            case _: SqlClob => get_clob(bindsCP, index, length)
            case _: SqlNullableClob => get_clob(bindsCP, index, length)

            // Array<InputStream>----SqlBlob----BLOB----BLOB----MYSQL_TYPE_BLOB----char[]
            case _: SqlBlob => get_blob(bindsCP, index, length)
            case _: SqlNullableBlob => get_blob(bindsCP, index, length)

            // 布尔类型在mysql数据库中表现形式是TINYINT
            // Bool----SqlBool----BOOLEAN----TINYINT----MYSQL_TYPE_TINY----signed char
            case _: SqlBool => get_bool(bindsCP, index)
            case _: SqlNullableBool => get_bool(bindsCP, index)

            // Int8----SqlByte----TINYINT----TINYINT----MYSQL_TYPE_TINY----signed char
            case _: SqlByte => get_int8(bindsCP, index)
            case _: SqlNullableByte => get_int8(bindsCP, index)

            // Int16----SqlSmallInt----SMALLINT----SMALLINT----MYSQL_TYPE_SHORT----short int
            case _: SqlSmallInt => get_int16(bindsCP, index)
            case _: SqlNullableSmallInt => get_int16(bindsCP, index)

            // SQL类型不同，但是数据值相对应
            // Int32----SqlInteger----INTEGER----INT----MYSQL_TYPE_LONG----int
            case _: SqlInteger => get_int32(bindsCP, index)
            case _: SqlNullableInteger => get_int32(bindsCP, index)

            // Int64----SqlBigInt----BIGINT----BIGINT----MYSQL_TYPE_LONGLONG----long long int
            case _: SqlBigInt => get_int64(bindsCP, index)
            case _: SqlNullableBigInt => get_int64(bindsCP, index)

            // SQL类型不同，但是数据值相对应
            // Float32----SqlReal----REAL----FLOAT----MYSQL_TYPE_FLOAT----float
            case _: SqlReal => get_float32(bindsCP, index)
            case _: SqlNullableReal => get_float32(bindsCP, index)

            // Float64----SqlDouble----DOUBLE----DOUBLE----MYSQL_TYPE_DOUBLE----double
            case _: SqlDouble => get_float64(bindsCP, index)
            case _: SqlNullableDouble => get_float64(bindsCP, index)

            // DateTime----SqlDate----DATE----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
            case _: SqlDate => get_date(bindsCP, index)
            case _: SqlNullableDate => get_date(bindsCP, index)

            // DateTime----SqlTime----TIME----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
            case _: SqlTime => get_time(bindsCP, index)
            case _: SqlNullableTime => get_time(bindsCP, index)

            // DateTime----SqlTimeTz----TIMETZ----TIME----MYSQL_TYPE_TIME----MYSQL_TIME
            // mysql不支持
            case _: SqlTimeTz => throw SqlException("Unsupported data type.")
            case _: SqlNullableTimeTz => throw SqlException("Unsupported data type.")

            // DateTime----SqlTimestamp----TIMESTAMP----TIMESTAMP----MYSQL_TYPE_TIMESTAMP----MYSQL_TIME
            case _: SqlTimestamp => get_timestamp(bindsCP, index)
            case _: SqlNullableTimestamp => get_timestamp(bindsCP, index)

            // Duration----SqlInterval----INTERVAL----DATE----MYSQL_TYPE_DATE----MYSQL_TIME
            // mysql不支持
            case _: SqlInterval => throw SqlException("Unsupported data type.")
            case _: SqlNullableInterval => throw SqlException("Unsupported data type.")

            // 自定义类
            // DATETIME----MYSQL_TYPE_DATETIME----MYSQL_TIME
            case _: SqlDateTime => get_date_time(bindsCP, index)
            case _: SqlNullableDateTime => get_date_time(bindsCP, index)

            // 自定义类
            // DECIMAL----MYSQL_TYPE_NEWDECIMAL
            case _: SqlDecimal => get_decimal(bindsCP, index, length)
            case _: SqlNullableDecimal => get_decimal(bindsCP, index, length)

            case _ => throw SqlException("Unsupported data type.")
        }
    }
}
