package mysqlclient

foreign func mysql_stmt_init(mysql: CPointer<Unit>): CPointer<Unit>

foreign func mysql_stmt_prepare(stmt: CPointer<Unit>,query: CString,length: UInt32): Int32

foreign func mysql_stmt_execute(stmt: CPointer<Unit>): Int32

foreign func mysql_stmt_fetch(stmt: CPointer<Unit>): Int32

foreign func mysql_stmt_store_result(stmt: CPointer<Unit>): Int32

foreign func mysql_stmt_param_count(stmt: CPointer<Unit>): UInt32

foreign func mysql_stmt_close(stmt: CPointer<Unit>): Bool

foreign func mysql_stmt_reset(stmt: CPointer<Unit>): Bool

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

/*
bool STDCALL mysql_stmt_bind_param(MYSQL_STMT *stmt, MYSQL_BIND *bnd);
bool STDCALL mysql_stmt_bind_result(MYSQL_STMT *stmt, MYSQL_BIND *bnd);
bool STDCALL mysql_stmt_free_result(MYSQL_STMT *stmt);
unsigned int STDCALL mysql_stmt_errno(MYSQL_STMT *stmt);
const char *STDCALL mysql_stmt_error(MYSQL_STMT *stmt);
const char *STDCALL mysql_stmt_sqlstate(MYSQL_STMT *stmt);
uint64_t STDCALL mysql_stmt_num_rows(MYSQL_STMT *stmt);
uint64_t STDCALL mysql_stmt_affected_rows(MYSQL_STMT *stmt);
uint64_t STDCALL mysql_stmt_insert_id(MYSQL_STMT *stmt);
unsigned int STDCALL mysql_stmt_field_count(MYSQL_STMT *stmt);

*/

