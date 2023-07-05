package mysqlclient;

foreign func mysql_binlog_open(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Int32
foreign func mysql_binlog_fetch(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Int32
foreign func mysql_binlog_close(mysql: CPointer<Unit>, rpl: CPointer<Unit>):Unit
