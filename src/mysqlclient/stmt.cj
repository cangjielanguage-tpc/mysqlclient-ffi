package mysqlclient

foreign func mysql_stmt_init(mysql: CPointer<Unit>): CPointer<Unit>

foreign func mysql_stmt_prepare(stmt: CPointer<Unit>,query: CString,length: UInt32): Int32

foreign func mysql_stmt_execute(stmt: CPointer<Unit>): Int32

foreign func mysql_stmt_fetch(stmt: CPointer<Unit>): Int32

foreign func mysql_stmt_store_result(stmt: CPointer<Unit>): Int32

foreign func mysql_stmt_param_count(stmt: CPointer<Unit>): UInt32

foreign func mysql_stmt_close(stmt: CPointer<Unit>): Bool

foreign func mysql_stmt_reset(stmt: CPointer<Unit>): Bool

foreign func mysql_stmt_bind_param(stmt: CPointer<Unit>, bnd: CPointer<Unit>): Bool

foreign func mysql_stmt_bind_result(stmt: CPointer<Unit>, bnd: CPointer<Unit>): Bool

foreign func mysql_stmt_free_result(stmt: CPointer<Unit>): Bool

foreign func mysql_stmt_errno(stmt: CPointer<Unit>): UInt32

foreign func mysql_stmt_error(stmt: CPointer<Unit>): CString

foreign func mysql_stmt_sqlstate(stmt: CPointer<Unit>): CString

foreign func mysql_stmt_num_rows(stmt: CPointer<Unit>): UInt64

foreign func mysql_stmt_affected_rows(stmt: CPointer<Unit>): UInt64

foreign func mysql_stmt_insert_id(stmt: CPointer<Unit>): UInt64

foreign func mysql_stmt_field_count(stmt: CPointer<Unit>): UInt32

public func cj_mysql_stmt_init(mysql: CPointer<Unit>): CPointer<Unit>{
   unsafe {
    mysql_stmt_init(mysql)
  }
}

public func cj_mysql_stmt_prepare(stmt: CPointer<Unit>,query: CString,length: UInt32): Int32{
   unsafe {
    mysql_stmt_prepare(stmt, query, length)
  }
}

public func cj_mysql_stmt_execute(stmt: CPointer<Unit>): Int32{
   unsafe {
    mysql_stmt_execute(stmt)
  }
}

public func cj_mysql_stmt_fetch(stmt: CPointer<Unit>): Int32{
   unsafe {
    mysql_stmt_fetch(stmt)
  }
}

public func cj_mysql_stmt_store_result(stmt: CPointer<Unit>): Int32{
   unsafe {
    mysql_stmt_store_result(stmt)
  }
}

public func cj_mysql_stmt_param_count(stmt: CPointer<Unit>): UInt32{
   unsafe {
    mysql_stmt_param_count(stmt)
  }
}

public func cj_mysql_mysql_stmt_close(stmt: CPointer<Unit>): Bool{
  unsafe {
    mysql_stmt_close(stmt)
  }
}

public func cj_mysql_mysql_stmt_reset(stmt: CPointer<Unit>): Bool{
  unsafe {
    mysql_stmt_reset(stmt)
  }
}



