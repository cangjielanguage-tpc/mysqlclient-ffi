package mysqlclient

foreign func mysql_list_dbs(mysql: CPointer<Unit>, wild: CString):CPointer<Unit>
foreign func mysql_list_tables(mysql: CPointer<Unit>, wild: CString):CPointer<Unit>
foreign func mysql_list_processes(mysql: CPointer<Unit>):CPointer<Unit>
foreign func mysql_list_fields(mysql: CPointer<Unit>, table: CString, wild: CString):CPointer<Unit>

