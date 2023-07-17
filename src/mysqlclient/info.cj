/*
    Copyright (c) [2023] [squallzhao]
    fountain is licensed under APACHE LICENSE, VERSION 2.0.
    You can use this software according to the terms and conditions of the APACHE LICENSE, VERSION 2.0.
    You may obtain a copy of APACHE LICENSE, VERSION 2.0 at: https://www.apache.org/licenses/LICENSE-2.0
*/

package mysqlclient

foreign func mysql_get_client_info(): CString

foreign func mysql_stat(mysql: CPointer<Unit>): CString

foreign func mysql_errno(mysql: CPointer<Unit>): UInt32

foreign func mysql_error(mysql: CPointer<Unit>): CString

foreign func mysql_sqlstate(mysql: CPointer<Unit>): CString

foreign func mysql_warning_count(mysql: CPointer<Unit>): UInt32

foreign func mysql_info(mysql: CPointer<Unit>): CString

foreign func mysql_dump_debug_info(mysql: CPointer<Unit>): Unit

public func cj_mysql_get_client_info(): CString{
   let s : CString
   unsafe {
     s =  mysql_get_client_info()
   }
   return s
   
}

public func cj_mysql_stat(mysql: CPointer<Unit>): CString{
  let ret :  CString
  unsafe{
     ret = mysql_stat(mysql)
  }
  return ret;
}

public func cj_mysql_errno(mysql:  CPointer<Unit>): UInt32{
  let ret : UInt32
  unsafe {
    ret = mysql_errno(mysql)
  } 
  return ret;
}

public func cj_mysql_error(mysql: CPointer<Unit>): CString{
  let ret : CString
  unsafe {
    ret = mysql_error(mysql)
  }
  return ret;
}

public func cj_mysql_sqlstate(mysql: CPointer<Unit>): CString{
  let ret : CString
  unsafe {
    ret = mysql_sqlstate(mysql)
  }
  return ret;
}

public func cj_mysql_warning_count(mysql: CPointer<Unit>): UInt32{
  unsafe {
     mysql_warning_count(mysql)
  }
}

public func cj_mysql_info(mysql: CPointer<Unit>): CString{
  let ret : CString
  unsafe {
    ret = mysql_info(mysql)
  }
  return ret;
}

public func cj_mysql_dump_debug_info(mysql: CPointer<Unit>): Unit{
  unsafe {
     mysql_dump_debug_info(mysql)
  }
}

