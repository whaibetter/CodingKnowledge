## MVCC

### 为什么需要MVCC呢？

- 提高并发性能
- 降低锁冲突

读读不互斥，但读写互斥，MVCC解决读写互斥的问题。

### 一致性非锁定读是什么？如何实现？优点？

- 在不阻塞其他事务的情况下读取数据，**快照**
- 做法：**版本号；时间戳。**

快照读：读取时，修改，直接找对应行的快照来读。

**优点：**

1. **不阻塞**其他事务
2. 读取一致性快照，这个**快照在事务期间有一致性**
3. 可以读取旧版本

### 锁定读是什么？有什么问题？

- 每次读取的都是最新数据，可能**会阻塞**。**锁定当前条目的数据**

> 当前读（Current Read）的情况（**锁定了当前的数据，该数据不会被修改，不会不可重复读**），每次读取的都是最新的数据，如果**两次查询之间有其他事务插入了新数据**，就有可能产生**幻读**（两次条数不一样）。
>
> **`InnoDB` 在实现`Repeatable Read` 时，如果执行的是当前读，则会对读取的记录使用 `Next-key Lock` ，来防止其它事务在间隙间插入数据**

如果执行的是下列语句，就是 [**锁定读（Locking Reads）**open in new window](https://dev.mysql.com/doc/refman/5.7/en/innodb-locking-reads.html)

- `select ... lock in share mode`
- `select ... for update`
- `insert`、`update`、`delete` 操作

### InnoDB 对 MVCC 的实现？

- 使用Undo log实现回滚
- 使用Read View，类似于快照进行读操作。
- **版本链** 每当对数据进行修改时，InnoDB 不会直接修改原始数据，而是**创建一个新的数据版本**，并将该版本添加到**版本链**中。因此，对同一数据的不同版本都可以在数据库中存在。

### MVCC有哪些隔离机制？对应是怎么实现的？

- **Read Commited**：每次读取时创建Read View，**解决读脏问题（读未提交）**
- **Repeated Read**：每次事务时创建Read View，**解决不可重复读问题（读取的数据被改了）**
  - **Consistent Read（一致性读取）可重复读** InnoDB默认使用，**事务开始时确定Read View**。

### 为什么Reapeted Read会有幻读问题？

- **当前读**。**其他事务有插入数据（==因为只对当前表中的数据进行锁定，还没有对新插入的数据进行锁定==），就可能幻读**。

  活着说，一次Read View为5条数据；另一个线程插入了一条数据，就变成了6条数据；新数据对于本事务是不可见的。

### undo的作用？分类？

`undo log` 主要有两个作用：**保证事务的原子性；版本不对、事务回滚。**

- 属于InnoDB
- 当**事务回滚时**用于将数据恢复到修改前的样子
- 另一个作用是 `MVCC` ，当读取记录时，若**该记录被其他事务占用**或**当前版本对该事务不可见**，则可以通过 `undo log` 读取之前的版本数据，以此实现**非锁定读**

分类：

1. `insert undo log` 

   insert只对本事务可见，所以可以直接删除

2. `update undo log`

   update对其他事务有影响，所以**需要提供 `MVCC` 机制**，提交时放入 ==**`undo log` 链表**==，**等待 `purge线程` 进行最后的删除**。

![不同事务或者相同事务的对同一记录行的修改，会使该记录行的 `undo log` 成为一条链表，链首就是最新的记录，链尾就是最早的旧记录](https://javaguide.cn/assets/6a276e7a-b0da-4c7b-bdf7-c0c7b7b3b31c-J-draIaP.png)

不同事务或者相同事务的对同一记录行的修改，会使该记录行的 `undo log` 成为一条链表，链首就是最新的记录，链尾就是最早的旧记录

### [Read Committed（读提交）和Repeatable Read（可重复读）隔离级别下 MVCC 的差异](https://javaguide.cn/database/mysql/innodb-implementation-of-mvcc.html#rc-和-rr-隔离级别下-mvcc-的差异)

- 不可重复读问题：两次读取不一样；使用**快照读**可以解决。
- 幻读问题：串行化

在 **Read Committed** 隔离级别下的 **每次`select` 查询**前都生成一个`Read View` (m_ids 列表)：每次读取都用一个快照（Read View 读视图）（解决读脏问题）

在 **Repeatable Read** 隔离级别下只在**事务开始**后 **`第一次select`** 数据前生成一个`Read View`（m_ids 列表）：每次事务都用一个快照（解决不可重复读问题）

**Consistent Read（一致性读取）**：

- 在InnoDB中，当事务执行读取操作时，默认使用**一致性读取（Consistent Read）机制**，即**事务开始时的Read View决定了事务所能看到的数据版本**。
- 通过一致性读取，事务可以读取到事务开始时的一致性数据，即使其他事务在执行过程中对数据进行了修改，事务也不会看到这些修改，从而实现了事务的隔离性。

### MVCC解决不可重复读问题

 在 RC 隔离级别下，**每次查询生成一个Read View**，导致不可重复读。

- 解决：每次**事务开始时**生成一个Read View；确保事务内的查询读取到的都是一个Read View。

详情：[InnoDB存储引擎对MVCC的实现 | JavaGuide](https://javaguide.cn/database/mysql/innodb-implementation-of-mvcc.html#mvcc-解决不可重复读问题)
