#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <mysql.h>
#include <mysql_client_info_cj.h>

MYSQL_BIND *init_bind(int64_t size)
{
    MYSQL_BIND *bind = (MYSQL_BIND *)calloc(size, sizeof(MYSQL_BIND));
    return bind;
}

/*---------------------- 插入数据进入数据库 ----------------------*/
void set_string(MYSQL_BIND *bind, int64_t index, char *value)
{
    bind[index].buffer_type = MYSQL_TYPE_STRING;
    bind[index].buffer = malloc(strlen(value) + 1);
    strcpy(bind[index].buffer, value);
    bind[index].buffer_length = strlen(value) + 1;
}

void set_bytes(MYSQL_BIND *bind, int64_t index, char *value, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_BLOB;
    bind[index].buffer = malloc(length);
    memcpy(bind[index].buffer, value, length);
    bind[index].buffer_length = length;
}

void set_clob(MYSQL_BIND *bind, int64_t index, char *value, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_LONG_BLOB;
    bind[index].buffer = malloc(length);
    memcpy(bind[index].buffer, value, length);
    bind[index].buffer_length = length;
}

void set_blob(MYSQL_BIND *bind, int64_t index, char *value, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_BLOB;
    bind[index].buffer = malloc(length);
    memcpy(bind[index].buffer, value, length);
    bind[index].buffer_length = length;
}

void set_bool(MYSQL_BIND *bind, int64_t index, int8_t value)
{
    bind[index].buffer_type = MYSQL_TYPE_TINY;
    bind[index].buffer = malloc(1);
    *(int8_t *)bind[index].buffer = value;
}

void set_int8(MYSQL_BIND *bind, int64_t index, int8_t value)
{
    bind[index].buffer_type = MYSQL_TYPE_TINY;
    bind[index].buffer = malloc(1);
    *(int8_t *)bind[index].buffer = value;
}

void set_int16(MYSQL_BIND *bind, int64_t index, short value)
{
    bind[index].buffer_type = MYSQL_TYPE_SHORT;
    bind[index].buffer = malloc(2);
    *(short *)bind[index].buffer = value;
}

void set_int32(MYSQL_BIND *bind, int64_t index, int32_t value)
{
    bind[index].buffer_type = MYSQL_TYPE_LONG;
    bind[index].buffer = malloc(4);
    *(int32_t *)bind[index].buffer = value;
}

void set_int64(MYSQL_BIND *bind, int64_t index, int64_t value)
{
    bind[index].buffer_type = MYSQL_TYPE_LONGLONG;
    bind[index].buffer = malloc(8);
    *(int64_t *)bind[index].buffer = value;
}

void set_float32(MYSQL_BIND *bind, int64_t index, float value)
{
    bind[index].buffer_type = MYSQL_TYPE_FLOAT;
    bind[index].buffer = malloc(4);
    *(float *)bind[index].buffer = value;
}

void set_float64(MYSQL_BIND *bind, int64_t index, double value)
{
    bind[index].buffer_type = MYSQL_TYPE_DOUBLE;
    bind[index].buffer = malloc(8);
    *(double *)bind[index].buffer = value;
}

void set_date(MYSQL_BIND *bind, int64_t index, uint32_t year, uint32_t month_value, uint32_t day_of_month)
{
    bind[index].buffer_type = MYSQL_TYPE_DATE;
    MYSQL_TIME *time = (MYSQL_TIME *)malloc(sizeof(MYSQL_TIME));
    time->year = year;
    time->month = month_value;
    time->day = day_of_month;
    time->time_type = MYSQL_TIMESTAMP_DATE;
    bind[index].buffer = time;
}

void set_time(MYSQL_BIND *bind, int64_t index, uint32_t hour, uint32_t minute, uint32_t second)
{
    bind[index].buffer_type = MYSQL_TYPE_TIME;
    MYSQL_TIME *time = (MYSQL_TIME *)malloc(sizeof(MYSQL_TIME));
    time->year = 0;
    time->month = 0;
    time->day = 0;
    time->hour = hour;
    time->minute = minute;
    time->second = second;
    time->second_part = 0;
    time->neg = false;
    time->time_type = MYSQL_TIMESTAMP_TIME;
    bind[index].buffer = time;
}

void set_timestamp(MYSQL_BIND *bind, int64_t index, uint32_t year, uint32_t month_value, uint32_t day_of_month, uint32_t hour, uint32_t minute, uint32_t second)
{
    bind[index].buffer_type = MYSQL_TYPE_TIMESTAMP;
    MYSQL_TIME *time = (MYSQL_TIME *)malloc(sizeof(MYSQL_TIME));
    time->year = year;
    time->month = month_value;
    time->day = day_of_month;
    time->hour = hour;
    time->minute = minute;
    time->second = second;
    time->second_part = 0;
    time->neg = false;
    time->time_type = MYSQL_TIMESTAMP_DATETIME;
    bind[index].buffer = time;
}

void set_date_time(MYSQL_BIND *bind, int64_t index, uint32_t year, uint32_t monthValue, uint32_t dayOfMonth, uint32_t hour, uint32_t minute, uint32_t second)
{
    bind[index].buffer_type = MYSQL_TYPE_DATETIME;
    MYSQL_TIME *time = (MYSQL_TIME *)malloc(sizeof(MYSQL_TIME));
    time->year = year;
    time->month = monthValue;
    time->day = dayOfMonth;
    time->hour = hour;
    time->minute = minute;
    time->second = second;
    time->second_part = 0;
    time->neg = false;
    time->time_type = MYSQL_TIMESTAMP_DATETIME;
    bind[index].buffer = time;
}

void set_null(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_NULL;
    bind[index].is_null = malloc(1);
    *(bool *)bind[index].is_null = true;
    bind[index].is_null_value = true;
    bind[index].buffer = NULL;
}

void free_mysql_cj(MYSQL_BIND *bind, int64_t size)
{
    for (size_t i = 0; i < size; i++)
    {
        if (bind[i].buffer != NULL)
        {
            free(bind[i].buffer);
        }
        if (bind[i].is_null != NULL)
        {
            free(bind[i].is_null);
        }
        if (bind[i].error != NULL)
        {
            free(bind[i].error);
        }
        if (bind[i].length != NULL)
        {
            free(bind[i].length);
        }
    }
    if (bind != NULL)
    {
        free(bind);
    }
}

/*---------------------- 从数据库获取数据 ----------------------*/
void get_string(MYSQL_BIND *bind, int64_t index, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_STRING;
    char *value = (char *)calloc(length + 1, sizeof(char));
    bind[index].buffer = value;
    bind[index].buffer_length = length + 1;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_bytes(MYSQL_BIND *bind, int64_t index, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_BLOB;
    char *value = (char *)calloc(length, sizeof(char));
    bind[index].buffer = value;
    bind[index].buffer_length = length;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_clob(MYSQL_BIND *bind, int64_t index, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_LONG_BLOB;
    char *value = (char *)calloc(length, sizeof(char));
    bind[index].buffer = value;
    bind[index].buffer_length = length;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_blob(MYSQL_BIND *bind, int64_t index, int64_t length)
{
    bind[index].buffer_type = MYSQL_TYPE_BLOB;
    char *value = (char *)calloc(length, sizeof(char));
    bind[index].buffer = value;
    bind[index].buffer_length = length;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_bool(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_TINY;
    bool *value = (bool *)calloc(1, sizeof(bool));
    bind[index].buffer = value;
    bind[index].buffer_length = 1;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_int8(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_TINY;
    int8_t *value = (int8_t *)calloc(1, sizeof(int8_t));
    bind[index].buffer = value;
    bind[index].buffer_length = 1;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_int16(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_SHORT;
    short *value = (short *)calloc(1, sizeof(short));
    bind[index].buffer = value;
    bind[index].buffer_length = 2;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_int32(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_LONG;
    int32_t *value = (int32_t *)calloc(1, sizeof(int32_t));
    bind[index].buffer = value;
    bind[index].buffer_length = 4;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_int64(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_LONGLONG;
    int64_t *value = (int64_t *)calloc(1, sizeof(int64_t));
    bind[index].buffer = value;
    bind[index].buffer_length = 8;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_float32(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_FLOAT;
    float *value = (float *)calloc(1, sizeof(float));
    bind[index].buffer = value;
    bind[index].buffer_length = 4;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_float64(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_DOUBLE;
    double *value = (double *)calloc(1, sizeof(double));
    bind[index].buffer = value;
    bind[index].buffer_length = 8;
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_date(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_DATE;
    MYSQL_TIME *value = (MYSQL_TIME *)calloc(1, sizeof(MYSQL_TIME));
    bind[index].buffer = value;
    bind[index].buffer_length = sizeof(MYSQL_TIME);
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_time(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_TIME;
    MYSQL_TIME *value = (MYSQL_TIME *)calloc(1, sizeof(MYSQL_TIME));
    bind[index].buffer = value;
    bind[index].buffer_length = sizeof(MYSQL_TIME);
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_timestamp(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_TIMESTAMP;
    MYSQL_TIME *value = (MYSQL_TIME *)calloc(1, sizeof(MYSQL_TIME));
    bind[index].buffer = value;
    bind[index].buffer_length = sizeof(MYSQL_TIME);
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

void get_date_time(MYSQL_BIND *bind, int64_t index)
{
    bind[index].buffer_type = MYSQL_TYPE_DATETIME;
    MYSQL_TIME *value = (MYSQL_TIME *)calloc(1, sizeof(MYSQL_TIME));
    bind[index].buffer = value;
    bind[index].buffer_length = sizeof(MYSQL_TIME);
    bind[index].length = malloc(sizeof(unsigned long));
    bool *is_null = (bool *)calloc(1, sizeof(bool));
    bind[index].is_null = is_null;
    bool *error = (bool *)calloc(1, sizeof(bool));
    bind[index].error = error;
}

/*---------------------- 对获取的数据进行处理 ----------------------*/
/**
 * 获取MYSQL_BIND中的buffer,buffer_type,is_null,length,用作仓颉端处理，转换成SqlDbType
 */
void *get_sql_buffer(MYSQL_BIND *bind, int64_t index, enum enum_field_types *buffer_type, bool *is_null, int64_t *length)
{
    enum enum_field_types buffer_type_value = bind[index].buffer_type;
    *buffer_type = buffer_type_value;
    *is_null = *bind[index].is_null;
    *length = *bind[index].length;
    return bind[index].buffer;
}

/**
 * 处理time
 */
void get_sql_time(MYSQL_TIME *time, unsigned int *year, unsigned int *month, unsigned int *day, unsigned int *hour, unsigned int *minute, unsigned int *second)
{
    *year = time[0].year;
    *month = time[0].month;
    *day = time[0].day;
    *hour = time[0].hour;
    *minute = time[0].minute;
    *second = time[0].second;
}

/*---------------------- 获取列信息 ----------------------*/
/**
 * 获取数据库表单表头信息
 */
bool get_res_data(MYSQL_RES *mysql_res_list, int64_t length, MYSQL_COLUMN_INFO *info)
{
    MYSQL_RES mysql_res = mysql_res_list[0];
    MYSQL_FIELD *mysql_field_list = mysql_res.fields;
    if (mysql_field_list == NULL)
    {
        return false;
    }
    for (int i = 0; i < length; i++)
    {
        MYSQL_FIELD mysql_field = mysql_field_list[i];
        MYSQL_COLUMN_INFO mysql_column_info;
        mysql_column_info.name_string = mysql_field.name;
        mysql_column_info.type = mysql_field.type;
        mysql_column_info.flags = mysql_field.flags;
        mysql_column_info.display_size_int64 = mysql_field.max_length;
        mysql_column_info.length_int64 = mysql_field.length;
        mysql_column_info.scale_int64 = mysql_field.decimals;
        info[i] = mysql_column_info;
    }
    return true;
}
