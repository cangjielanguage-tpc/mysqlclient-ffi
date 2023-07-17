/*
    Copyright (c) [2023] [squallzhao]
    fountain is licensed under APACHE LICENSE, VERSION 2.0.
    You can use this software according to the terms and conditions of the APACHE LICENSE, VERSION 2.0.
    You may obtain a copy of APACHE LICENSE, VERSION 2.0 at: https://www.apache.org/licenses/LICENSE-2.0
*/

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
