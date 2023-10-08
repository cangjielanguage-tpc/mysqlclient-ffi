#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <mysql.h>

typedef struct MYSQL_COLUMN_INFO
{
    char *name_string;
    enum enum_field_types type;
    unsigned int flags;
    int64_t display_size_int64;
    int64_t length_int64;
    int64_t scale_int64;
} MYSQL_COLUMN_INFO;