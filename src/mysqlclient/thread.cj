package mysqlclient

foreign func mysql_thread_id(mysql: CPointer<Unit>): UInt32

public func cj_mysql_thread_id(mysql: CPointer<Unit>): UInt32{
  unsafe {
     mysql_thread_id(mysql)
  }
}

