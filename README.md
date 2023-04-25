# mysqlclient

#### 介绍
用cj封装 mysql的c 语言libmysqlclient库

#### 安装教程

1.  ubuntu 安装 sudo apt-get install libmysqlclient-dev 或 使用lib下面的libmysqlclient.so
2.  cpm build
3.  ./build/bin/main 测试数据库连接

#### 使用说明

1.  打印mysql版本 
    println(cj_mysql_get_client_info());
2.  初始化连接对象 
    let t: CPointer<Unit> = CPointer<Unit>();
    var mysql: CPointer<Unit> = cj_mysql_init(t)
3.  连接数据库
    mysql = cj_mysql_real_connect(mysql,host,user,pass,db,port,CString(""),0);
4.  查看mysql状态
    cj_mysql_stat(mysql)
5.  执行SQL语句
    let q = CString("select * from tb_conf");
    cj_mysql_query(mysql,q)
6.  获取查询结果
    let result = cj_mysql_store_result(mysql)
7.  获取查询结果列数和行数
    let columns = cj_mysql_num_fields(result)
    let rows = cj_mysql_num_rows(result);
8.  遍历查询结果
    var i: Int32
    for(i in 0..rows){
        let row:CPointer<CString> = cj_mysql_fetch_row(result)
        for(j in 0..columns){
           let p = cj_mysql_fetch_field(row,j)
           print(p); print("   ")
        }
        println()
    }
9. 释放结果集内存
    cj_mysql_free_result(result)
    
10. 断开数据库连接
     cj_mysql_close(mysql)

#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request


