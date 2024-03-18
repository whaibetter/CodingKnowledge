## SQL优化

### SQL优化一般步骤是什么？

1. 查询定位**慢SQL**，
2. 查看执行过程EXPLAIN
   - 或着使用**日志分析工具`mysqldumpslow`**
3. 确定并采取措施

```sql
show variables like '%slow_query_log%';
set global slow_query_log='ON';
show variables like '%long_query_time%'; # 默认是10s
set global long_query_time = 1; # 设置为1s，需要重连后查询才能生效
```

```
Time                 Id Command    Argument
# Time: 2024-03-15T08:12:41.686567Z  执行时间
# User@Host: root[root] @ localhost [::1]  Id:     8   连接
# Query_time: 18.036081  Lock_time: 0.000111 Rows_sent: 6  Rows_examined: 6
use blog; 
SET timestamp=1710490361; # 时间戳
SELECT *, sleep(3) FROM blog_main; # 具体慢sql

#  Query_time: duration 语句执行时间，以秒为单位。Lock_time: duration 获取锁的时间(以秒为单位)。Rows_sent: 发送给 Client 端的行数。Rows_examined: 服务器层检查的行数(不计算存储引擎内部的任何处理)

# Time: 2024-03-15T08:13:23.478413Z
# User@Host: root[root] @ localhost [::1]  Id:     8
# Query_time: 6.043930  Lock_time: 0.000065 Rows_sent: 6  Rows_examined: 6
SET timestamp=1710490403;
SELECT *, sleep(1) FROM blog_main;
```

### EXPLAIN的作用？

用于查询优化的工具。它可以**分析和解释查询语句的执行计划**，帮助开发人员和数据库管理员了解**查询是如何被执行的**，以及如何改进查询性能。

> 主要关注的字段：
>
> 1. **type**：**表的访问方法**，扫描方式；
> 2. **rows**：**预计要读取的行数**
> 3. **Extra：**附加信息，如使用Where、覆盖索引、临时表、排序、全表扫描等。

可以看到，执行计划结果中共有 12 列，各列代表的含义总结如下表：

| **列名**      | **含义**                                                     |
| ------------- | ------------------------------------------------------------ |
| id            | SELECT 查询的序列标识符                                      |
| select_type   | SELECT 关键字对应的查询类型<br />-  SIMPLE：简单查询，不包含子查询或者UNION操作。 <br />-  PRIMARY：最外层的查询。 <br />-  SUBQUERY：子查询。 <br />-  DERIVED：派生表，即从查询结果中构建的临时表。 <br />- UNION：UNION操作的查询。<br />-  UNION RESULT：UNION结果的查询。 |
| table         | 用到的表名                                                   |
| partitions    | 匹配的分区，对于未分区的表，值为 NULL                        |
| **type**      | **表的访问方法**，扫描方式<br />-  const：使用常量值进行查询，通常是主键或唯一索引等。<br />-  eq_ref：唯一索引查找。<br />-  ref：非唯一索引查找。 <br />- range：范围查找。<br />-  index：全索引扫描。<br />- all：全表扫描。 |
| possible_keys | 可能用到的索引                                               |
| key           | 实际用到的索引                                               |
| key_len       | 所选索引的长度                                               |
| ref           | 当使用索引等值查询时，与索引作比较的列或常量                 |
| **rows**      | **预计要读取的行数**                                         |
| **filtered**  | **按表条件过滤后，留存的记录数的百分比**                     |
| **Extra**     | **附加信息**                                                 |

```sql
mysql> explain SELECT * FROM dept_emp WHERE emp_no IN (SELECT emp_no FROM dept_emp GROUP BY emp_no HAVING COUNT(emp_no)>1);
+----+-------------+----------+------------+-------+-----------------+---------+---------+------+--------+----------+-------------+
| id | select_type | table    | partitions | type  | possible_keys   | key     | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+----------+------------+-------+-----------------+---------+---------+------+--------+----------+-------------+
|  1 | PRIMARY     | dept_emp | NULL       | ALL   | NULL            | NULL    | NULL    | NULL | 331143 |   100.00 | Using where |
|  2 | SUBQUERY    | dept_emp | NULL       | index | PRIMARY,dept_no | PRIMARY | 16      | NULL | 331143 |   100.00 | Using index |
+----+-------------+----------+------------+-------+-----------------+---------+---------+------+--------+----------+-------------+
```

#### Extra

- Using index：使用了**覆盖索引**。
- Using where：在表中使用了WHERE条件。
- Using temporary：在执行查询时需要创建**临时表**。**性能特别差，需要重点优化**
- Using filesort：需要对结果进行文件**排序**。
- Using join buffer：在连接查询时使用了连接缓冲区。
- Range checked for each record：对每条记录进行了范围检查。
- ALL 全表扫描
- index 索引全扫描
- range 索引范围扫描，常用语<,<=,>=,between,in等操作

### 优化SQL采用相应的措施有哪些？

- 优化**索引**
- 优化**SQL语句**：修改SQL、IN 查询分段、时间查询分段、基于上一次数据过滤
- 改用其他实现方式：**ES、数仓**等
- **数据碎片**处理

## SQL优化场景（走索引）

1. 最左匹配
2. 