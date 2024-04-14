[TOC]

### 如何新建一个表，并把另一个表的数据插入新表

[创建一个actor_name表_牛客题霸_牛客网 (nowcoder.com)](https://www.nowcoder.com/practice/881385f388cf4fe98b2ed9f8897846df?tpId=82&tqId=29804&rp=1&ru=/exam/oj&qru=/exam/oj&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%E7%AF%87%26topicId%3D82&difficulty=3&judgeStatus=undefined&tags=&title=)

```sql
DROP TABLE
    IF EXISTS actor_name;

CREATE TABLE
    `actor_name` (
        first_name varchar(45) NOT NULL COMMENT '名字',
        last_name varchar(45) NOT NULL COMMENT '姓氏'
    );

insert into
    actor_name
SELECT
    first_name,
    last_name
FROM
    actor;
```

### SQL如何开启一个事务

