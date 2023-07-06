package mysqlclient

foreign func mysql_list_dbs(mysql: CPointer<Unit>, wild: CString):CPointer<Unit>
foreign func mysql_list_tables(mysql: CPointer<Unit>, wild: CString):CPointer<Unit>
foreign func mysql_list_processes(mysql: CPointer<Unit>):CPointer<Unit>
foreign func mysql_list_fields(mysql: CPointer<Unit>, table: CString, wild: CString):CPointer<Unit>

public  func cj_mysql_list_dbs(mysql: CPointer<Unit>, wild: CString):CPointer<Unit>{
  unsafe {
    mysql_list_dbs(mysql,wild)
  }
}

public func cj_mysql_list_tables(mysql: CPointer<Unit>, wild: CString):CPointer<Unit>{
  unsafe {
    mysql_list_tables(mysql,wild)
  }
}

public func cj_mysql_list_tables(mysql: CPointer<Unit>):CPointer<Unit>{
  unsafe {
    mysql_list_processes(mysql)
  }
}

public func cj_mysql_list_fields(mysql: CPointer<Unit>, table: CString, wild: CString):CPointer<Unit>{
  unsafe {
    mysql_list_fields(mysql,table,wild)
  }
}
