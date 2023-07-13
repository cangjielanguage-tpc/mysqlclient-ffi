package mysqlclient

foreign func mysql_thread_id(mysql: CPointer<Unit>): UInt32

foreign func mysql_thread_init(): Bool

foreign func mysql_thread_end(): Unit

public func cj_mysql_thread_id(mysql: CPointer<Unit>): UInt32{
  unsafe {
     mysql_thread_id(mysql)
  }
}

public func cj_mysql_thread_init(): Bool{
  unsafe {
     mysql_thread_init()
  }
}


public func cj_mysql_thread_end(): Unit{
  unsafe {
     mysql_thread_end()
  }
}
