package mysqlclient

foreign func mysql_ssl_set(mysql: CPointer<Unit>, key: CString, ert: CString,ca: CString, capath: CString,cipher: CString): Bool

foreign func mysql_get_ssl_cipher(mysql: CPointer<Unit>): CString

foreign func mysql_get_ssl_session_reused(mysql: CPointer<Unit>): Bool

foreign func mysql_get_ssl_session_data(mysql: CPointer<Unit>, n_ticket: UInt32,out_len: CPointer<UInt32>): CPointer<Unit>

foreign func mysql_free_ssl_session_data(mysql: CPointer<Unit>, data: CPointer<Unit>): Bool



