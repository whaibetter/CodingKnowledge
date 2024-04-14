### MySQL中和事务相关的语句

> ### MYSQL 事务处理主要有两种方法：
>
> #### 1. 用 BEGIN, ROLLBACK, COMMIT 来实现
>
> - **`BEGIN` 或 `START TRANSACTION （READ only）`**：开用于开始一个事务。
> - `ROLLBACK` 事务回滚，取消之前的更改。
> - `COMMIT`：事务确认，提交事务，使更改永久生效。
>
> #### 2. `SAVEPOINT sp1`
>
> - `ROLLBACK TO sp1；`
> - `RELEASE SAVEPOINT sp1`
>
> #### 3. 直接用 SET 来改变 MySQL 的自动提交模式:
>
> - `SET AUTOCOMMIT=0`禁止自动提交
> - `SET AUTOCOMMIT=1`** 开启自动提交
>
> ```sql
> -- 开始事务
> START TRANSACTION (READ only);
> 
> -- 执行一些SQL语句
> UPDATE accounts SET balance = balance - 100 WHERE user_id = 1;
> UPDATE accounts SET balance = balance + 100 WHERE user_id = 2;
> 
> -- 判断是否要提交还是回滚
> IF (条件) THEN
>     COMMIT; -- 提交事务
> ELSE
>     ROLLBACK; -- 回滚事务
> END IF;
> ```

