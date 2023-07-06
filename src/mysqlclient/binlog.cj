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



