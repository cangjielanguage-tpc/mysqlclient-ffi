#! /bin/bash
lib_path=$(cd `dirname $0`; pwd)

# 将.c文件生成.o文件
gcc -c ${lib_path}/libmysqlclient_c/mysql_client_cj.c
echo "Successfully generated .o file."

#将.o文件生成.a文件
ar rcs ${lib_path}/lib/libmysqlclient_cj.a ${lib_path}/libmysqlclient_c/*.o
echo "Successfully generated .a file."

# 将module.json的22行修改成静态编译
sed -i -e '22 s/	"output_type": "dynamic",/	"output_type": "static",/' ${lib_path}/module.json

cd  ${lib_path}/
echo start build mysqlclient

# 清理缓存
echo start cjpm clean
cjpm clean
echo end cjpm clean

# 开始编译
echo start cjpm build -V
cjpm build -V
echo end cjpm build -V

# 将lib下依赖包copy到运行环境下
cp ${lib_path}/lib/*.a ${lib_path}/build/release/mysqlclient/
cp ${lib_path}/lib/*.dll ${lib_path}/build/release/mysqlclient/
echo end build mysqlclient