package mysqlclient

foreign func mysql_query(mysql: CPointer<Unit>, q:CString): Int32

foreign func mysql_store_result(mysql: CPointer<Unit>): CPointer<Unit>

foreign func mysql_num_fields(result: CPointer<Unit>): Int32

foreign func mysql_eof(result: CPointer<Unit>): Bool

foreign func mysql_num_rows(result: CPointer<Unit>): Int32

foreign func mysql_fetch_row(result: CPointer<Unit>): CPointer<CString>

foreign func mysql_free_result(result: CPointer<Unit>): Unit

foreign func mysql_affected_rows(mysql: CPointer<Unit>): UInt64

foreign func mysql_insert_id(mysql: CPointer<Unit>): UInt64

public func cj_mysql_query(mysql: CPointer<Unit>, q:CString): Int32{
  let ret: Int32
  unsafe{
    ret = mysql_query(mysql,q)
  }
  return ret;
}

public func cj_mysql_store_result(mysql: CPointer<Unit>): CPointer<Unit>{
  let ret: CPointer<Unit>
  unsafe{
    ret = mysql_store_result(mysql)
  }
  return ret;
}

public func cj_mysql_num_fields(result: CPointer<Unit>): Int32{
  let ret: Int32
  unsafe{
    ret = mysql_num_fields(result)
  }
  return ret;
}

public func cj_mysql_eof(result: CPointer<Unit>): Bool{
  unsafe{
     mysql_eof(result)
  }
}

public func cj_mysql_num_rows(result: CPointer<Unit>): Int32{
  let ret: Int32
  unsafe{
    ret = mysql_num_rows(result)
  }
  return ret;
}

public  func cj_mysql_fetch_row(result: CPointer<Unit>): CPointer<CString>{
  let ret: CPointer<CString>
  unsafe {
    ret = mysql_fetch_row(result)
  }
  return ret;
}

public func cj_mysql_fetch_field(row: CPointer<CString>, i: Int32): CString{
   unsafe{ row.read(Int64(i))}
}

public func cj_mysql_free_result(result: CPointer<Unit>): Unit{
  unsafe {
    mysql_free_result(result)
  }
}


public func cj_mysql_affected_rows(mysql: CPointer<Unit>): UInt64 {
  let ret : UInt64
  unsafe {
    ret = mysql_affected_rows(mysql)
  }
  return ret;
}

public func cj_mysql_insert_id(mysql: CPointer<Unit>): UInt64 {
  unsafe {
    mysql_insert_id(mysql)
  }
}
