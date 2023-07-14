package mysqlclient

/*

MYSQL_STMT *STDCALL mysql_stmt_init(MYSQL *mysql);
int STDCALL mysql_stmt_prepare(MYSQL_STMT *stmt, const char *query,
                               unsigned long length);
int STDCALL mysql_stmt_execute(MYSQL_STMT *stmt);
int STDCALL mysql_stmt_fetch(MYSQL_STMT *stmt);
int STDCALL mysql_stmt_store_result(MYSQL_STMT *stmt);
unsigned long STDCALL mysql_stmt_param_count(MYSQL_STMT *stmt);
bool STDCALL mysql_stmt_bind_param(MYSQL_STMT *stmt, MYSQL_BIND *bnd);
bool STDCALL mysql_stmt_bind_result(MYSQL_STMT *stmt, MYSQL_BIND *bnd);
bool STDCALL mysql_stmt_close(MYSQL_STMT *stmt);
bool STDCALL mysql_stmt_reset(MYSQL_STMT *stmt);
bool STDCALL mysql_stmt_free_result(MYSQL_STMT *stmt);
unsigned int STDCALL mysql_stmt_errno(MYSQL_STMT *stmt);
const char *STDCALL mysql_stmt_error(MYSQL_STMT *stmt);
const char *STDCALL mysql_stmt_sqlstate(MYSQL_STMT *stmt);
uint64_t STDCALL mysql_stmt_num_rows(MYSQL_STMT *stmt);
uint64_t STDCALL mysql_stmt_affected_rows(MYSQL_STMT *stmt);
uint64_t STDCALL mysql_stmt_insert_id(MYSQL_STMT *stmt);
unsigned int STDCALL mysql_stmt_field_count(MYSQL_STMT *stmt);

*/