#! /bin/bash
lib_path=$(cd `dirname $0`; pwd)


# check libmysqlclient.so
if [ ! -d "${lib_path}/lib/" ];then
    mkdir ${lib_path}/lib
    echo "Please copy libmysqlclient.so to the folder ${lib_path}/lib."
    exit 1
fi

if [ ! -f "${lib_path}/lib/libmysqlclient.so" ];then
    echo "Please copy libmysqlclient.so to the folder ${lib_path}/lib."
    exit 1
fi

# libmysqlclient_cj.so
cd ${lib_path}/libmysqlclient_c
if [ -f "Makefile" ];then
    make clean
fi

# "/usr1/ohos/linux-x86_64/llvm/bin/clang"为ohos编译路径，
# "/usr1/ohos/usr/include/aarch64-linux-ohos"为ohos头文件路径，请自行修改
./configure --cc="/usr1/ohos/linux-x86_64/llvm/bin/clang" --cross-prefix="/usr1/ohos/linux-x86_64/llvm/bin/llvm-" \
--target=aarch64-linux-ohos --cflags="-I/usr1/ohos/usr/include/aarch64-linux-ohos"
make

# mysqlclient
cd  ${lib_path}/

echo start build mysqlclient

echo start cjpm clean
cjpm clean
echo end cjpm clean

echo start cjpm build -V
cjpm build -V
echo end cjpm build -V

cp ${lib_path}/lib/*.so ${lib_path}/build/mysqlclient/
cp ${lib_path}/lib/*.so.21 ${lib_path}/build/mysqlclient/
cp ${lib_path}/lib/*.so.21.2.33 ${lib_path}/build/mysqlclient/
echo end build mysqlclient
