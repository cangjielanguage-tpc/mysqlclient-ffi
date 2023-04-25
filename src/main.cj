import mysqlclient.*

main(){
  let host: CString = CString("127.0.0.1")
  let user: CString = CString("root")
  let pass: CString = CString("root")
  let db: CString = CString("chatgpt")
  let port: UInt32 = 3306;

  print("mysql version: "); println(cj_mysql_get_client_info());
  
  let t: CPointer<Unit> = CPointer<Unit>();
  var mysql: CPointer<Unit> = cj_mysql_init(t)
  if (mysql.isNull()){
    println("mysql init failed")
    return;
  }

  mysql = cj_mysql_real_connect(mysql,host,user,pass,db,port,CString(""),0);
  if (mysql.isNull()){
    println("mysql connect failed")
    return;
  }
  print("mysql stat:"); println(cj_mysql_stat(mysql))

  let q = CString("select * from tb_conf");
  cj_mysql_query(mysql,q)

  let result = cj_mysql_store_result(mysql)
  let columns = cj_mysql_num_fields(result)
  let rows = cj_mysql_num_rows(result);
  print("table columns="); println(columns)
  print("table rows="); println(rows)
  
  var i: Int32
  for(i in 0..rows){
    let row:CPointer<CString> = cj_mysql_fetch_row(result)
    for(j in 0..columns){
       //let p = unsafe{ row.read(Int64(j))}
       let p = cj_mysql_fetch_field(row,j)
       print(p); print("   ")   
    }
    println()
  }
  cj_mysql_free_result(result)
  cj_mysql_close(mysql)
}

