/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package mysqlclient_ffi

public enum MysqlTypeEnum <: Equatable<MysqlTypeEnum> & ToString{
    | SqlString 
    | SqlArrayByte
    | SqlInputStream 
    | SqlBool 
    | SqlInt8 
    | SqlInt16 
    | SqlInt32 
    | SqlInt64 
    | SqlFloat32 
    | SqlFloat64 
    | SqlDateTime 
    | SqlMysqlTypeDate 
    | SqlMysqlTypeTime 
    | SqlMysqlTypeTimeTimestamp
    | SqlDecimal
    | SqlNull
    | SqlBigInt
    | SqlOther

    /*
     * 枚举是否相等
     *
     * 参数 that - 枚举
     * 返回值 Bool - 是否相等
     */
    public operator func ==(that: MysqlTypeEnum): Bool {
        match ((this, that)) {
            case (SqlString, SqlString) => true
            case (SqlArrayByte, SqlArrayByte) => true
            case (SqlInputStream, SqlInputStream) => true
            case (SqlBool, SqlBool) => true
            case (SqlInt8, SqlInt8) => true
            case (SqlInt16, SqlInt16) => true
            case (SqlInt32, SqlInt32) => true
            case (SqlInt64, SqlInt64) => true
            case (SqlFloat32, SqlFloat32) => true
            case (SqlFloat64, SqlFloat64) => true
            case (SqlDateTime, SqlDateTime) => true
            case (SqlMysqlTypeDate, SqlMysqlTypeDate) => true
            case (SqlMysqlTypeTime, SqlMysqlTypeTime) => true
            case (SqlMysqlTypeTimeTimestamp, SqlMysqlTypeTimeTimestamp) => true
            case (SqlDecimal, SqlDecimal) => true
            case (SqlNull, SqlNull) => true
            case (SqlBigInt, SqlBigInt) => true
            case (SqlOther, SqlOther) => true
            case _ => false
        }
    }

    /*
     * 枚举是否不相等
     *
     * 参数 that - 枚举
     * 返回值 Bool - 是否不相等
     */
    public operator func !=(that: MysqlTypeEnum): Bool {
        return !(this == that)
    }

    public override func toString():String{
        match (this) {
            case SqlString => return "SqlString"
            case SqlArrayByte => return "SqlArrayByte"
            case SqlInputStream => return "SqlInputStream"
            case SqlBool => return "SqlBool"
            case SqlInt8 => return "SqlInt8"
            case SqlInt16 => return "SqlInt16"
            case SqlInt32 => return "SqlInt32"
            case SqlInt64 => return "SqlInt64"
            case SqlFloat32 => return "SqlFloat32"
            case SqlFloat64 => return "SqlFloat64"
            case SqlDateTime => return "SqlDateTime"
            case SqlMysqlTypeDate => return "SqlMysqlTypeDate"
            case SqlMysqlTypeTime => return "SqlMysqlTypeTime"
            case SqlMysqlTypeTimeTimestamp => return "SqlMysqlTypeTimeTimestamp"
            case SqlDecimal => return "SqlDecimal"
            case SqlNull => return "SqlNull"
            case SqlBigInt => return "SqlBigInt"
            case SqlOther => return "SqlOther"
        }
    }

    public static func fromToString(str:String):MysqlTypeEnum{
        match (str) {
            case "SqlString" => return SqlString
            case "SqlArrayByte" => return SqlArrayByte
            case "SqlInputStream" => return SqlInputStream
            case "SqlBool" => return SqlBool
            case "SqlInt8" => return SqlInt8
            case "SqlInt16" => return SqlInt16
            case "SqlInt32" => return SqlInt32
            case "SqlInt64" => return SqlInt64
            case "SqlFloat32" => return SqlFloat32
            case "SqlFloat64" => return SqlFloat64
            case "SqlDateTime" => return SqlDateTime
            case "SqlMysqlTypeDate" => return SqlMysqlTypeDate
            case "SqlMysqlTypeTime" => return SqlMysqlTypeTime
            case "SqlMysqlTypeTimeTimestamp" => return SqlMysqlTypeTimeTimestamp
            case "SqlDecimal" => return SqlDecimal
            case "SqlNull" => return SqlNull
            case "SqlBigInt" => return SqlBigInt
            case "SqlOther" => return SqlOther
            case _ => throw SqlException("The Statement has been closed")
        }
    }
}
