/*
    Copyright (c) [2023] [squallzhao]
    fountain is licensed under APACHE LICENSE, VERSION 2.0.
    You can use this software according to the terms and conditions of the APACHE LICENSE, VERSION 2.0.
    You may obtain a copy of APACHE LICENSE, VERSION 2.0 at: https://www.apache.org/licenses/LICENSE-2.0
*/

package mysqlclient;

foreign func mysql_binlog_open(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Int32
foreign func mysql_binlog_fetch(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Int32
foreign func mysql_binlog_close(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Unit

/*
public  func cj_mysql_binlog_open(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Int32{
  unsafe {
    mysql_binlog_open(mysql,rpl)
  }
}

public  func cj_mysql_binlog_fetch(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Int32{
  unsafe {
    mysql_binlog_fetch(mysql,rpl)
  }
}

public  func cj_mysql_binlog_close(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Unit{
  unsafe {
    mysql_binlog_close(mysql,rpl)
  }
}
*/



