/*
    Copyright (c) [2023] [squallzhao]
    fountain is licensed under APACHE LICENSE, VERSION 2.0.
    You can use this software according to the terms and conditions of the APACHE LICENSE, VERSION 2.0.
    You may obtain a copy of APACHE LICENSE, VERSION 2.0 at: https://www.apache.org/licenses/LICENSE-2.0
*/

package mysqlclient

foreign func mysql_character_set_name(mysql: CPointer<Unit>): CString

foreign func mysql_set_character_set(mysql: CPointer<Unit>, charset:CString): Int32

public  func cj_mysql_character_set_name(mysql: CPointer<Unit>): CString {
  unsafe {
     mysql_character_set_name(mysql)
  }
}

public  func cj_mysql_set_character_set(mysql: CPointer<Unit>, charset: CString):Int32{
  unsafe {
    mysql_set_character_set(mysql,charset)
  }
}

