package mysqlclient


foreign func mysql_autocommit(mysql: CPointer<Unit>, auto_mode: Bool): Bool

foreign func mysql_commit(mysql: CPointer<Unit>): Bool

foreign func mysql_rollback(mysql: CPointer<Unit>): Bool


public func cj_mysql_autocommit(mysql: CPointer<Unit>, auto_mode: Bool): Bool{
  let ret : Bool
  unsafe{
    ret = mysql_autocommit(mysql,auto_mode)
  }
  return ret;
}


public func cj_mysql_commit(mysql: CPointer<Unit>): Bool{
  unsafe {
    mysql_commit(mysql)
  }
}

public func cj_mysql_rollback(mysql: CPointer<Unit>): Bool{
  unsafe {
    mysql_rollback(mysql)
  }
}
