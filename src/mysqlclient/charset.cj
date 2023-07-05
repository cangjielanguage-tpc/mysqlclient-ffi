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

