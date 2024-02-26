package mysqlclient

/*
 * 大数
 */
public class SqlDecimal <: SqlDbType {
    private var decimal: Decimal

    /*
     * 初始化SQL数据类型
     *
     * 参数 decimal - 大数
     */
    public init(decimal: Decimal) {
        this.decimal = decimal
    }

    /*
     * 数据
     */
    public mut prop value: Decimal {
        get() {
            decimal
        }
        set(value) {
            decimal = value
        }
    }

    /*
     * 类型名称
     */
    public prop name: String {
        get() {
            "SqlDecimal"
        }
    }
}

/*
 * 大数，数据可能为None
 */
public class SqlNullableDecimal <: SqlNullableDbType {
    private var decimal: ?Decimal

    /*
     * 初始化SQL数据类型
     *
     * 参数 dateTime - 大数
     */
    public init(decimal: ?Decimal) {
        this.decimal = decimal
    }

    /*
     * 数据
     */
    public mut prop value: ?Decimal {
        get() {
            decimal
        }
        set(value) {
            decimal = value
        }
    }

    /*
     * 类型名称
     */
    public prop name: String {
        get() {
            "SqlNullableDecimal"
        }
    }
}
