#! /bin/bash
lib_path=$(cd `dirname $0`; pwd)


# check libmysql.dll
if [ ! -d "${lib_path}/lib/" ];then
    mkdir ${lib_path}/lib
    echo "Please copy libmysql.dll to the folder ${lib_path}/lib."
    exit 1
fi

if [ ! -f "${lib_path}/lib/libmysql.dll" ];then
    echo "Please copy libmysql.dll to the folder ${lib_path}/lib."
    exit 1
fi

# libmysqlclient_cj.dll
cd ${lib_path}/libmysqlclient_c
if [ -f "Makefile" ];then
    make clean
fi

# 将configure的126行和196行的mysqlclient依赖改成mysql
sed -i -e '126 s|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysqlclient"|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysql"|' ${lib_path}/libmysqlclient_c/configure
sed -i -e '196 s|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysqlclient"|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysql"|' ${lib_path}/libmysqlclient_c/configure

./configure
make

# 将configure的126行和196行修改还原
sed -i -e '126 s|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysql"|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysqlclient"|' ${lib_path}/libmysqlclient_c/configure
sed -i -e '196 s|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysql"|  LDFLAGS="${LDFLAGS} -L${SRCDIR}../lib -lmysqlclient"|' ${lib_path}/libmysqlclient_c/configure

# 将cjpm.toml的4行的cjpm的mysqlclient改成mysql
sed -i -e '4 s|  mysqlclient = { path = "./lib/"}|  mysql = { path = "./lib/"}|' ${lib_path}/cjpm.toml

# mysqlclient
cd  ${lib_path}/
echo start build mysqlclient

echo start cjpm clean
cjpm clean
echo end cjpm clean

echo start cjpm build -V
cjpm build -V
echo end cjpm build -V

cp ${lib_path}/lib/*.dll ${lib_path}/target/release/mysqlclient_ffi/
echo end build mysqlclient
