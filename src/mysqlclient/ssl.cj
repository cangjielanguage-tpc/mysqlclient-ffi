package mysqlclient

foreign func mysql_ssl_set(mysql: CPointer<Unit>, key: CString, ert: CString,ca: CString, capath: CString,cipher: CString): Bool

foreign func mysql_get_ssl_cipher(mysql: CPointer<Unit>): CString

foreign func mysql_get_ssl_session_reused(mysql: CPointer<Unit>): Bool

foreign func mysql_get_ssl_session_data(mysql: CPointer<Unit>, n_ticket: UInt32,out_len: CPointer<UInt32>): CPointer<Unit>

foreign func mysql_free_ssl_session_data(mysql: CPointer<Unit>, data: CPointer<Unit>): Bool

public func cj_mysql_ssl_set(mysql: CPointer<Unit>, key: CString, ert: CString,ca: CString, capath: CString,cipher: CString): Bool{
  unsafe {
    mysql_ssl_set(mysql,key,ert,ca,capath,cipher)
  }
}

public func cj_mysql_get_ssl_cipher(mysql: CPointer<Unit>): CString{
   unsafe {
    mysql_get_ssl_cipher(mysql)
  }
}

public func cj_mysql_get_ssl_session_reused(mysql: CPointer<Unit>): Bool{
  unsafe {
    mysql_get_ssl_session_reused(mysql)
  }
}

public func cj_mysql_get_ssl_session_data(mysql: CPointer<Unit>, n_ticket: UInt32,out_len: CPointer<UInt32>): CPointer<Unit>{
   unsafe {
    mysql_get_ssl_session_data(mysql,n_ticket,out_len)
   }
}

public func cj_mysql_free_ssl_session_data(mysql: CPointer<Unit>, data: CPointer<Unit>): Bool{
   unsafe {
      mysql_free_ssl_session_data(mysql,data)
   }
}
