package mysqlclient

foreign func mysql_server_init(argc: Int32, argv: CPointer<CString>, groups: CPointer<CString>): Int32
foreign func mysql_server_end() : Unit
foreign func mysql_shutdown(mysql: CPointer<Unit>, shutdown_level: Int32) : Int32
foreign func mysql_refresh(mysql: CPointer<Unit>, refresh_options: UInt32):Int32
foreign func mysql_kill(mysql: CPointer<Unit>, pid:UInt32):Int32
foreign func mysql_ping(mysql: CPointer<Unit>): Int32
foreign func mysql_set_server_option(mysql: CPointer<Unit>, option:Int32):Int32

public func cj_mysql_server_init(argc: Int32, argv: CPointer<CString>, groups: CPointer<CString>): Int32{
  var ret: Int32 = 0
  unsafe{
    ret = mysql_server_init(argc,argv,groups)
  }
  return ret
}

public func cj_mysql_server_end() : Unit{
   unsafe{
       mysql_server_end()
   }
}

public func cj_mysql_shutdown(mysql: CPointer<Unit>, shutdown_level: Int32) : Int32{
   unsafe{
       mysql_shutdown(mysql,shutdown_level)
   }
}

public func cj_mysql_refresh(mysql: CPointer<Unit>, refresh_options: UInt32):Int32{
    unsafe{
        mysql_refresh(mysql,refresh_options)
    }
}

public func cj_mysql_kill(mysql: CPointer<Unit>, pid:UInt32):Int32{
    unsafe{
        mysql_kill(mysql,pid)
    }
}

public func cj_mysql_ping(mysql: CPointer<Unit>): Int32{
    unsafe{
        mysql_ping(mysql)
    }
}

public func cj_mysql_set_server_option(mysql: CPointer<Unit>, option:Int32):Int32{
    unsafe{
        mysql_set_server_option(mysql,option)
    }
}

