package mysqlclient

foreign func mysql_thread_id(mysql: CPointer<Unit>): UInt32

public func cj_mysql_thread_id(mysql: CPointer<Unit>): UInt32{
  unsafe {
     mysql_thread_id(mysql)
  }
}

/*
bool STDCALL mysql_thread_init(void);
void STDCALL mysql_thread_end(void);
*/