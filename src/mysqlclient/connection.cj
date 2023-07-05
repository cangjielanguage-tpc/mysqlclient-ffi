package mysqlclient



foreign func mysql_init(mysql: CPointer<Unit>) : CPointer<Unit>

foreign func mysql_real_connect(mysql:CPointer<Unit>, host: CString, user: CString, passwd : CString,
                                  db: CString, port: UInt32, unix_socket: CString, clientflag: UInt32):  CPointer<Unit>

foreign func mysql_close(mysql: CPointer<Unit>): Unit

foreign func mysql_change_user(mysql:CPointer<Unit>, user: CString, passwd : CString, db: CString): Bool

foreign func mysql_select_db(mysql:CPointer<Unit>, db: CString): Int32

public func cj_mysql_init(mysql: CPointer<Unit>): CPointer<Unit>{
  let ret :  CPointer<Unit>
  unsafe {
    ret = mysql_init(mysql)
  }
  return ret;
}

public func cj_mysql_real_connect(mysql:CPointer<Unit>, host: CString, user: CString, passwd : CString,
                                  db: CString, port: UInt32, unix_socket: CString, clientflag: UInt32): CPointer<Unit>{
  let ret :  CPointer<Unit>
  unsafe {
     ret = mysql_real_connect(mysql,host,user,passwd,db,port,unix_socket,clientflag);
  }
  return ret;
}

public func cj_mysql_change_user(mysql:CPointer<Unit>, user: CString, passwd : CString,db: CString): Bool{
  unsafe {
    mysql_change_user(mysql,user,passwd,db);
  }
}

public func cj_mysql_close(mysql: CPointer<Unit>): Unit{
  unsafe {
   mysql_close(mysql)
  }
}



public func cj_mysql_select_db(mysql:CPointer<Unit>, db: CString): Int32{
   unsafe{
       mysql_select_db(mysql,db)
   }
}
