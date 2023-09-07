package mysqlclient

/*--------------------- MySQL的列类型,C中枚举 enum enum_field_types ---------------------*/
public let MYSQL_TYPE_DECIMAL: Int32 = 0

public let MYSQL_TYPE_TINY: Int32 = 1

public let MYSQL_TYPE_SHORT: Int32 = 2

public let MYSQL_TYPE_LONG: Int32 = 3

public let MYSQL_TYPE_FLOAT: Int32 = 4

public let MYSQL_TYPE_DOUBLE: Int32 = 5

public let MYSQL_TYPE_NULL: Int32 = 6

public let MYSQL_TYPE_TIMESTAMP: Int32 = 7

public let MYSQL_TYPE_LONGLONG: Int32 = 8

public let MYSQL_TYPE_INT24: Int32 = 9

public let MYSQL_TYPE_DATE: Int32 = 10

public let MYSQL_TYPE_TIME: Int32 = 11

public let MYSQL_TYPE_DATETIME: Int32 = 12

public let MYSQL_TYPE_YEAR: Int32 = 13

/*
 * Internal to MySQL. Not used in protocol
 */
public let MYSQL_TYPE_NEWDATE: Int32 = 14

public let MYSQL_TYPE_VARCHAR: Int32 = 15

public let MYSQL_TYPE_BIT: Int32 = 16

public let MYSQL_TYPE_TIMESTAMP2: Int32 = 17

/*
 * Internal to MySQL. Not used in protocol
 */
public let MYSQL_TYPE_DATETIME2: Int32 = 18

/*
 * Internal to MySQL. Not used in protocol
 */
public let MYSQL_TYPE_TIME2: Int32 = 19

/*
 * Used for replication only
 */
public let MYSQL_TYPE_TYPED_ARRAY: Int32 = 20

public let MYSQL_TYPE_INVALID: Int32 = 243

/*
 * Currently just a placeholder
 */
public let MYSQL_TYPE_BOOL: Int32 = 244

public let MYSQL_TYPE_JSON: Int32 = 245

public let MYSQL_TYPE_NEWDECIMAL: Int32 = 246

public let MYSQL_TYPE_ENUM: Int32 = 247

public let MYSQL_TYPE_SET: Int32 = 248

public let MYSQL_TYPE_TINY_BLOB: Int32 = 249

public let MYSQL_TYPE_MEDIUM_BLOB: Int32 = 250

public let MYSQL_TYPE_LONG_BLOB: Int32 = 251

public let MYSQL_TYPE_BLOB: Int32 = 252

public let MYSQL_TYPE_VAR_STRING: Int32 = 253

public let MYSQL_TYPE_STRING: Int32 = 254

public let MYSQL_TYPE_GEOMETRY: Int32 = 255

/*--------------------- 服务器和客户端API之间共享的时间声明,C中枚举 enum enum_mysql_timestamp_type ---------------------*/
public let MYSQL_TIMESTAMP_NONE: Int32 = -2

public let MYSQL_TIMESTAMP_ERROR: Int32 = -1

/*
 * Stores year, month and day components.
 */
public let MYSQL_TIMESTAMP_DATE: Int32 = 0

/**
 * Stores all date and time components.
 * Value is in UTC for `TIMESTAMP` type.
 * Value is in local time zone for `DATETIME` type.
 */
public let MYSQL_TIMESTAMP_DATETIME: Int32 = 1

/*
 * Stores hour, minute, second and microsecond.
 */
public let MYSQL_TIMESTAMP_TIME: Int32 = 2

/**
 * A temporary type for `DATETIME` or `TIMESTAMP` types equipped with time
 * zone information. After the time zone information is reconciled, the type is
 * converted to MYSQL_TIMESTAMP_DATETIME.
 */
public let MYSQL_TIMESTAMP_DATETIME_TZ: Int32 = 3

/*--------------------- C中枚举 enum enum_stmt_attr_type ---------------------*/
/*
 * When doing mysql_stmt_store_result calculate max_length attribute
 * of statement metadata. This is to be consistent with the old API,
 * where this was done automatically.
 * In the new API we do that only by request because it slows down
 * mysql_stmt_store_result sufficiently.
 */
public let STMT_ATTR_UPDATE_MAX_LENGTH_INT: Int32 = 0

/*
 * unsigned long with combination of cursor flags (read only, for update,etc)
 */
public let STMT_ATTR_CURSOR_TYPE_INT: Int32 = 1

/*
 * Amount of rows to retrieve from server per one fetch if using cursors.
 * Accepts unsigned long attribute in the range 1 - ulong_max
 */
public let STMT_ATTR_PREFETCH_ROWS_INT: Int32 = 2

/*--------------------- C中枚举 enum enum_mysql_set_option ---------------------*/
public let MYSQL_OPTION_MULTI_STATEMENTS_ON_INT: Int32 = 0

public let MYSQL_OPTION_MULTI_STATEMENTS_OFF_INT: Int32 = 1

/*--------------------- C中枚举 enum mysql_option ---------------------*/
public let MYSQL_OPT_CONNECT_TIMEOUT_INT: Int32 = 0

public let MYSQL_OPT_COMPRESS_INT: Int32 = 1

public let MYSQL_OPT_NAMED_PIPE_INT: Int32 = 2

public let MYSQL_INIT_COMMAND_INT: Int32 = 3

public let MYSQL_READ_DEFAULT_FILE_INT: Int32 = 4

public let MYSQL_READ_DEFAULT_GROUP_INT: Int32 = 5

public let MYSQL_SET_CHARSET_DIR_INT: Int32 = 6

public let MYSQL_SET_CHARSET_NAME_INT: Int32 = 7

public let MYSQL_OPT_LOCAL_INFILE_INT: Int32 = 8

public let MYSQL_OPT_PROTOCOL_INT: Int32 = 9

public let MYSQL_SHARED_MEMORY_BASE_NAME_INT: Int32 = 10

public let MYSQL_OPT_READ_TIMEOUT_INT: Int32 = 11

public let MYSQL_OPT_WRITE_TIMEOUT_INT: Int32 = 12

public let MYSQL_OPT_USE_RESULT_INT: Int32 = 13

public let MYSQL_REPORT_DATA_TRUNCATION_INT: Int32 = 14

public let MYSQL_OPT_RECONNECT_INT: Int32 = 15

public let MYSQL_PLUGIN_DIR_INT: Int32 = 16

public let MYSQL_DEFAULT_AUTH_INT: Int32 = 17

public let MYSQL_OPT_BIND_INT: Int32 = 18

public let MYSQL_OPT_SSL_KEY_INT: Int32 = 19

public let MYSQL_OPT_SSL_CERT_INT: Int32 = 20

public let MYSQL_OPT_SSL_CA_INT: Int32 = 21

public let MYSQL_OPT_SSL_CAPATH_INT: Int32 = 22

public let MYSQL_OPT_SSL_CIPHER_INT: Int32 = 23

public let MYSQL_OPT_SSL_CRL_INT: Int32 = 24

public let MYSQL_OPT_SSL_CRLPATH_INT: Int32 = 25

public let MYSQL_OPT_CONNECT_ATTR_RESET_INT: Int32 = 26

public let MYSQL_OPT_CONNECT_ATTR_ADD_INT: Int32 = 27

public let MYSQL_OPT_CONNECT_ATTR_DELETE_INT: Int32 = 28

public let MYSQL_SERVER_PUBLIC_KEY_INT: Int32 = 29

public let MYSQL_ENABLE_CLEARTEXT_PLUGIN_INT: Int32 = 30

public let MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS_INT: Int32 = 31

public let MYSQL_OPT_MAX_ALLOWED_PACKET_INT: Int32 = 32

public let MYSQL_OPT_NET_BUFFER_LENGTH_INT: Int32 = 33

public let MYSQL_OPT_TLS_VERSION_INT: Int32 = 34

public let MYSQL_OPT_SSL_MODE_INT: Int32 = 35

public let MYSQL_OPT_GET_SERVER_PUBLIC_KEY_INT: Int32 = 36

public let MYSQL_OPT_RETRY_COUNT_INT: Int32 = 37

public let MYSQL_OPT_OPTIONAL_RESULTSET_METADATA_INT: Int32 = 38

public let MYSQL_OPT_SSL_FIPS_MODE_INT: Int32 = 39

public let MYSQL_OPT_TLS_CIPHERSUITES_INT: Int32 = 40

public let MYSQL_OPT_COMPRESSION_ALGORITHMS_INT: Int32 = 41

public let MYSQL_OPT_ZSTD_COMPRESSION_LEVEL_INT: Int32 = 42

public let MYSQL_OPT_LOAD_DATA_LOCAL_DIR_INT: Int32 = 43

public let MYSQL_OPT_USER_PASSWORD_INT: Int32 = 44

public let MYSQL_OPT_SSL_SESSION_DATA_INT: Int32 = 45

/*--------------------- MYSQL_FIELD参数中的flags ---------------------*/
/*
 * Field can't be NULL
 */
public let NOT_NULL_FLAG: Int32 = 1

/*
 * Field is part of a primary key
 */
public let PRI_KEY_FLAG: Int32 = 2

/*
 * Field is part of a unique key
 */
public let UNIQUE_KEY_FLAG: Int32 = 4

/*
 * Field is part of a key
 */
public let MULTIPLE_KEY_FLAG: Int32 = 8

/*
 * Field is a blob
 */
public let BLOB_FLAG: Int32 = 16

/*
 * Field is unsigned
 */
public let UNSIGNED_FLAG: Int32 = 32

/*
 * Field is zerofill
 */
public let ZEROFILL_FLAG: Int32 = 64

/*
 * Field is binary
 */
public let BINARY_FLAG: Int32 = 128

/*--------------------- int mysql_stmt_fetch(MYSQL_STMT *stmt)的返回值 ---------------------*/
/*
 * 	成功，数据已提取到应用程序数据缓冲区。
 */
public let MYSQL_STMT_FETCH_SUCCESS = 0

/*
 * 发生错误。错误代码和消息可以通过调用 mysql_stmt_errno（） 和 mysql_stmt_error（） 来获取。
 */
public let MYSQL_STMT_FETCH_ERROR = 1

/*
 * 成功，不再存在数据
 */
public let MYSQL_STMT_FETCH_NO_DATA = 100

/*
 * 发生数据截断
 */
public let MYSQL_STMT_FETCH_DATA_TRUNCATED = 101

@C
struct MYSQL_TIME {
    var year: UInt32 = 0

    var month: UInt32 = 0

    var day: UInt32 = 0

    var hour: UInt32 = 0

    var minute: UInt32 = 0

    var second: UInt32 = 0

    /*
     * microseconds
     */
    var second_part: UInt64 = 0

    var neg: Bool = false

    var time_type: Int32 = 0

    /*
     * The time zone displacement, specified in seconds.
     */
    var time_zone_displacement: Int32 = 0
}

@C
struct MYSQL_ROWS {
    /*
     * list of rows
     */
    var next: CPointer<MYSQL_ROWS> = CPointer<MYSQL_ROWS>()

    var data: CPointer<CString> = CPointer<CString>()

    var length: UInt64 = 0
}

@C
struct MYSQL_RES {
    var row_count: UInt64 = 0

    var fields: CPointer<MYSQL_FIELD> = CPointer<MYSQL_FIELD>()

    var data: CPointer<MYSQL_DATA> = CPointer<MYSQL_DATA>()

    var data_cursor: CPointer<MYSQL_ROWS> = CPointer<MYSQL_ROWS>()

    /*
     * column lengths of current row
     */
    var lengths: CPointer<UInt64> = CPointer<UInt64>()

    /*
     * for unbuffered reads
     */
    var handle: CPointer<Unit> = CPointer<Unit>()

    var methods: CPointer<Unit> = CPointer<Unit>()

    /*
     * If unbuffered read
     */
    var row: CPointer<CString> = CPointer<CString>()

    /*
     * buffer to current row
     */
    var current_row: CPointer<CString> = CPointer<CString>()

    var field_alloc: CPointer<Unit> = CPointer<Unit>()

    var field_count: UInt32 = 0

    var current_field: UInt32 = 0

    /*
     * Used by mysql_fetch_row
     */
    var eof: Bool = false

    /*
     * mysql_stmt_close() had to cancel this result
     */
    var unbuffered_fetch_cancelled: Bool = false

    var metadata: Int32 = 0

    var extension: CPointer<Unit> = CPointer<Unit>()
}

@C
struct MYSQL_FIELD {
    /*
     * Name of column
     */
    var name: CString = CString(CPointer<UInt8>())

    /*
     * Original column name, if an alias
     */
    var org_name: CString = CString(CPointer<UInt8>())

    /*
     * Table of column if column was a field
     */
    var table: CString = CString(CPointer<UInt8>())

    /*
     * Org table name, if table was an alias
     */
    var org_table: CString = CString(CPointer<UInt8>())

    /*
     * Database for table
     */
    var db: CString = CString(CPointer<UInt8>())

    /*
     * Catalog for table
     */
    var catalog: CString = CString(CPointer<UInt8>())

    /*
     * Default value (set by mysql_list_fields)
     */
    var def: CString = CString(CPointer<UInt8>())

    /*
     * Width of column (create length)
     */
    var length: UInt64 = 0

    /*
     * Max width for selected set
     */
    var max_length: UInt64 = 0

    var name_length: UInt32 = 0

    var org_name_length: UInt32 = 0

    var table_length: UInt32 = 0

    var org_table_length: UInt32 = 0

    var db_length: UInt32 = 0

    var catalog_length: UInt32 = 0

    var def_length: UInt32 = 0

    /*
     * Div flags
     */
    var flags: UInt32 = 0

    /*
     * Number of decimals in field
     */
    var decimals: UInt32 = 0

    /*
     * Character set
     */
    var charsetnr: UInt32 = 0

    /*
     * Type of field. See mysql_com.h for types
     */
    var types: Int32 = 0

    var extension: CPointer<Unit> = CPointer<Unit>()
}

@C
struct MYSQL_DATA {
    var data: CPointer<MYSQL_ROWS> = CPointer<MYSQL_ROWS>()

    var alloc: CPointer<Unit> = CPointer<Unit>()

    var rows: UInt64 = 0

    var fields: UInt32 = 0
}

@C
struct MYSQL_BIND {
    /*
     * output length pointer
     */
    var length: CPointer<UInt64> = CPointer<UInt64>()

    /*
     * Pointer to null indicator
     */
    var is_null: CPointer<UInt8> = CPointer<UInt8>()

    /*
     * buffer to get/put data
     */
    var buffer: CPointer<Unit> = CPointer<Unit>()

    /*
     * set this if you want to track data truncations happened during fetch
     */
    var error: CPointer<UInt8> = CPointer<UInt8>()

    /*
     * for the current data position
     */
    var row_ptr: CPointer<UInt64> = CPointer<UInt64>()

    var store_param_func: CFunc<(CPointer<Unit>, CPointer<MYSQL_BIND>) -> Unit> = CFunc<(CPointer<Unit>, CPointer<MYSQL_BIND>) -> Unit>(CPointer<Unit>(
            ))

    var fetch_result: CFunc<(CPointer<MYSQL_BIND>, CPointer<MYSQL_FIELD>, CPointer<CPointer<UInt64>>) -> Unit> = CFunc<(CPointer<MYSQL_BIND>,
        CPointer<MYSQL_FIELD>, CPointer<CPointer<UInt64>>) -> Unit>(CPointer<Unit>())

    var skip_result: CFunc<(CPointer<MYSQL_BIND>, CPointer<MYSQL_FIELD>, CPointer<CPointer<UInt64>>) -> Unit> = CFunc<(CPointer<MYSQL_BIND>,
        CPointer<MYSQL_FIELD>, CPointer<CPointer<UInt64>>) -> Unit>(CPointer<Unit>())

    /*
     * output buffer length, must be set when fetching str/binary
     */
    var buffer_length: UInt64 = 0

    /*
     * offset position for char/binary fetch
     */
    var offset: UInt64 = 0

    /*
     * Used if length is 0
     */
    var length_value: UInt64 = 0

    /*
     * For null count and error messages
     */
    var param_number: UInt32 = 0

    /*
     * Internal length for packed data
     */
    var pack_length: UInt32 = 0

    /*
     * buffer type
     */
    var buffer_type: Int32 = 0

    /*
     * used if error is 0
     */
    var error_value: Bool = false

    /*
     * set if integer type is unsigned
     */
    var is_unsigned: Bool = false

    /*
     * If used with mysql_send_long_data
     */
    var long_data_used: Bool = false

    /*
     * Used if is_null is 0
     */
    var is_null_value: Bool = false

    var extension: CPointer<Unit> = CPointer<Unit>()
}
