## Redis

### 什么是 Redis？

- [Redisopen in new window](https://redis.io/) （**RE**mote **DI**ctionary **S**erver）是一个基于 C 语言开发的开源 NoSQL 数据库（BSD 许可）
- Redis 的数据是保存在内存中的（内存数据库，支持持久化），因此读写速度非常快，被广泛应用于分布式缓存方向

[在线 Redis 环境](https://try.redis.io/)

###  Redis 为什么这么快？

1. 基于**内存**，合理的线性模型
2. 基于 **Reactor 模式**设计开发了一套高效的事件处理模型，主要是单线程事件循环和 IO 多路复用
3. 内置了多种优化过后的**SDS数据类型/结构实现**
4. Hash O(1)就能获取到值
5. **合理的编码**



### 说一下 Redis 和 Memcached 的区别和共同点

同：

1. 性能
2. 内存

异：

1. Memcached只支持KV
2. Redis数据**持久化**
3. Redis**使用完内存，可以将旧数据放在磁盘**
4. Redis原生**集群**
5. **Memcached 是多线程，非阻塞 IO 复用的网络模型；Redis 使用单线程的多路 IO 复用模型。** （Redis 6.0 针对网络数据的读写引入了多线程）
6. **Redis 支持发布订阅模型、Lua 脚本、事务等功能**

###  Redis 除了做缓存，还能做什么？

IO效率高

- ==**分布式锁**==：通过 Redis 来做分布式锁是一种比较常见的方式。通常情况下，我们都是基于 Redisson 来实现分布式锁。关于 Redis 实现分布式锁的详细介绍，可以看我写的这篇文章：[分布式锁详解open in new window](https://javaguide.cn/distributed-system/distributed-lock.html) 。

- ==**限流**==：一般是通过 Redis + Lua 脚本的方式来实现限流。相关阅读：[《我司用了 6 年的 Redis 分布式限流器，可以说是非常厉害了！》open in new window](https://mp.weixin.qq.com/s/kyFAWH3mVNJvurQDt4vchA)。

- **消息队列**：Redis 自带的 List 数据结构可以作为一个简单的队列使用。Redis 5.0 中增加的 Stream 类型的数据结构更加适合用来做消息队列。它比较类似于 Kafka，有主题和消费组的概念，支持消息持久化以及 ACK 机制。

- **延时队列**：Redisson 内置了延时队列（基于 Sorted Set 实现的）。

- ==**分布式 Session**== ：利用 String 或者 Hash 数据类型保存 Session 数据，所有的服务器都可以访问。提供了主从复制+哨兵。

- **复杂业务场景**：通过 Redis 以及 Redis 扩展（比如 Redisson）提供的数据结构，我们可以很方便地完成很多复杂的业务场景比如通过 Bitmap 统计活跃用户、通过 Sorted Set 维护排行榜。

### Redis 过期策略和内存淘汰策略

**过期策略：**

1. 定时过期：每个创建计时器，计时器消耗CPU
2. 惰性过期：访问时检查计时器，如果长时间不访问占用内存
3. **定期过期：** 每一段时间检查expires字典

**Redis 内存淘汰策略**：

内存不足时，写入数据：

1. LRU（**最近**最少使用）
2. LFU（不经常使用）
3. 随机淘汰
4. 默认：新写入报错。

###  Redis 数有哪些据类型？对应的应用场景？

5种基本类型

| 类型    | 特性                                                         | 应用场景                                                     |
| ------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| string  | 存储的是序列化后的对象，数据二进制安全的，可以存储图片，值最大存储为 512M | **计数、缓存、分布式锁`setnx k v`**                          |
| set     | 不能重复                                                     | **不能重复的场景**（文章点赞、网站 UV `Unique Visitor` 统计）<br />`SInter`需要**交集**的场景（共同好友、粉丝）<br />`SDiff`需要**差集**的场景（可能的好友、推荐博主、音乐推荐）<br /><br />`SPop`**随机**场景（随机点名、随机抽奖） |
| zset    | **有序，还提供另一属性score**，这一属性在添加修改元素时候可以指定，每次指定后，ZSet会自动重新按新的值调整顺序。，`zadd @key [score member]` `zrange`  `zincrby` | **有序且不重复**：排行榜`zadd user:ranking:2024-01-06 3 Jay ` |
| hashmap | 可以存储对象单个字段，做到对象部分字段的修改。               | **存储需要经常变化的对象。（用户信息）**                     |
| list    | 有序字符串，最多可以存储2^32-1 个元素                        | 消息队列，文章列表                                           |

3 种特殊类型

| 类型        | 特性                                                         | 应用场景                           |
| ----------- | ------------------------------------------------------------ | ---------------------------------- |
| bitmap      | key [0101010101] 映射某个元素的状态                          | 签到、用户状态                     |
| geospatial  | 存储地理位置信息                                             |                                    |
| hyperloglog | **无论集合包含的元素有多少个，HyperLogLog 进行计算所需的内存总是固定的，并且是非常少的**。每个 `HyperLogLog` 最多只需要花费 12KB 内存，就可以计算 2 的 64 次方个元素的基数。 | **基数统计**（单个页面的访问数量） |

###  String 还是 Hash 存储对象数据更好呢？

- Map存储的是整个对象，可以做单独的修改。**Map节省流量**。
- **String更加节省内存**，String 消耗的内存约是 Hash 的一半。

在绝大部分情况，我们建议使用 String 来存储对象数据即可！



### String 的底层实现是什么？

Redis 是基于 C 语言编写的，但 Redis 的 String 类型的底层实现并不是 C 语言中的字符串（即以空字符 `\0` 结尾的字符数组），而是自己编写了 [SDSopen in new window](https://github.com/antirez/sds)（Simple Dynamic String，简单动态字符串） 来作为底层实现。



### 购物车信息用 String 还是 Hash 存储更好呢?

由于购物车中的商品**频繁修改和变动**，购物车信息建议使用 Hash 存储：

- `userId-->Hash(商品id,商品数量)`

> 添加、修改商品 `hset @userId @commodityId @number`
>
> 查询商品 `hget @userId`
>
> 清空商品  `del @userId`



##  Redis 持久化机制（重要）

- RDB 持久化、AOF 持久化、RDB 和 AOF 的混合持久化

[Redis持久化机制详解 | JavaGuide(Java面试 + 学习指南)](https://javaguide.cn/database/redis/redis-persistence.html)



### 什么是 RDB 持久化？RDB的优缺点？

- RDB优点：恢复大量数据比AOF快，全量备份，数据紧凑。
- RDB存在的问题：
  1. 耗时耗性能（每次fork一个线程）
  2. 阻塞、宕机丢失数据。

Redis Data Backup File

- Redis创建快照获得副本，备份。

- 快照持久化是 Redis 默认采用的持久化方式，在 `redis.conf` 配置文件中默认有此下配置：

  - save 时间 变化key的数量

  ```clojure
  save 900 1           #在900秒(15分钟)之后，如果至少有1个key发生变化，Redis就会自动触发bgsave命令创建快照。
  
  save 300 10          #在300秒(5分钟)之后，如果至少有10个key发生变化，Redis就会自动触发bgsave命令创建快照。
  
  save 60 10000        #在60秒(1分钟)之后，如果至少有10000个key发生变化，Redis就会自动触发bgsave命令创建快照。
  ```

持久化步骤

1. **fork子进程**进行持久化
2. 子进程**写入rdb临时文件**
3. **替换原来的快照**文件
4.  子进程退出

![Redis持久化RDB和AOF的区别有什么](http://42.192.130.83:9000/picgo/imgs/1017.png)

### RDB 创建快照时会阻塞主线程吗？

- 同步模式会阻塞 save 
- **fork子线程**（default）





### 什么是 AOF 持久化？AOF 工作基本流程是怎样的？优缺点？

![Redis 执行完写操作命令后，AOF 工作基本流程](http://42.192.130.83:9000/picgo/imgs/aof-work-process.png)

![AOF 持久化是怎么实现的？ | 小林coding](http://42.192.130.83:9000/picgo/imgs/6f0ab40396b7fc2c15e6f4487d3a0ad7.png)

- **每条**修改命令--->AOF缓冲区--->**appendonly.aof**

 ```bash
  appendonly yes
 ```

1. **命令追加（append）**：**所有的==写==命令**会追加到 AOF 缓冲区中。

2. **文件写入（write）**：将 AOF 缓冲区的数据写入到 AOF 文件中。这一步需要调用`write`函数（系统调用），`write`将数据写入到了系统内核缓冲区之后直接返回了（延迟写）。注意！！！**此时并没有同步到磁盘，只有同步到磁盘中才算持久化保存。**

-----

3. ==**文件同步（fsync）**==：AOF 缓冲区根据对应的持久化方式（ `fsync` 策略）向硬盘做同步操作。这一步需要调用 `fsync` 函数（系统调用）， `fsync` 针对单个文件操作，对其进行强制硬盘同步，`fsync` 将阻塞直到写入磁盘完成后返回，保证了数据持久化。

---

4. **文件重写（rewrite）**：随着 AOF 文件越来越大，需要定期对 AOF 文件进行重写，达到压缩的目的。

5. **重启加载（load）**：当 Redis 重启时，可以加载 AOF 文件进行数据恢复。

------

#### 优缺点：

优点：更好保证数据不丢失（每条命令\每秒备份）

缺点：数据庞大，恢复慢。

### AOF 持久化方式有哪些？

- `appendfsync always`：  
  -  `main--->write `  立刻调用 `main.fsync` 函数同步 AOF 文件
- `appendfsync everysec`：
  - 每秒钟调用 `main.fsync` 函数（系统调用）同步一次(`main.write`+`main.fsync`，`fsync`间隔为 1 秒)
- `appendfsync no`：
  - 操作系统决定，不可控

> 从 Redis 7.0.0 开始，Redis 使用了 **Multi Part AOF** 机制。顾名思义，Multi Part AOF 就是将原来的单个 AOF 文件拆分成多个 AOF 文件。在 Multi Part AOF 中，AOF 文件被分为三种类型，分别为：
>
> - BASE：表示基础 AOF 文件，它一般由子进程通过重写产生，该文件最多只有一个。
> - INCR：表示增量 AOF 文件，它一般会在 AOFRW 开始执行时被创建，该文件可能存在多个。
> - HISTORY：表示历史 AOF 文件，它由 BASE 和 INCR AOF 变化而来，每次 AOFRW 成功完成时，本次 AOFRW 之前对应的 BASE 和 INCR AOF 都将变为 HISTORY，HISTORY 类型的 AOF 会被 Redis 自动删除。
>
> Multi Part AOF 不是重点，了解即可，详细介绍可以看看阿里开发者的[Redis 7.0 Multi Part AOF 的设计和实现open in new window](https://zhuanlan.zhihu.com/p/467217082) 这篇文章。
>
> **相关 issue**：[Redis 的 AOF 方式 #783open in new window](https://github.com/Snailclimb/JavaGuide/issues/783)
>
> ------
>
> 著作权归JavaGuide(javaguide.cn)所有 基于MIT协议 原文链接：https://javaguide.cn/database/redis/redis-persistence.html

### AOF 为什么是在执行完命令之后记录日志？

![AOF 记录日志过程](http://42.192.130.83:9000/picgo/imgs/redis-aof-write-log-disc.png)

1. 不阻塞当前命令
2. 避免额外的语法检查开销

缺点：如果write结束后丢失，

### AOF和RDB的区别

- RDB 是达到某个条件就进行快照备份，默认情况下需要fork一个子线程
- AOF   Redis **执行完写操作命令后**
  - `append` 缓冲区，`write`内核缓冲区
  - 根据不同模式进行控制调用`fsync`的时机 

![Redis 执行完写操作命令后，AOF 工作基本流程](http://42.192.130.83:9000/picgo/imgs/aof-work-process.png)

### 如何选择AOF和RDB

- 需要**完整性**高、安全性高的选择AOF。优先使用everysec
- 需要**体积小**、恢复快的选择RDB。灾难恢复快。
- 安全性：混合使用

如果保存的数据要求安全性比较高的话，建议**同时开启 RDB 和 AOF 持久化**或者开启 RDB 和 AOF **混合持久化**。





###  AOF 重写了解吗？重写期间有新的write怎么办？

- AOF太大的时候，在后台子进程自动**重写AOF产生新的AOF文件**，体积会更小。

  > - 重写期间有新的write怎么办？缓冲区，子进程
  >
  > ```
  > <--------AOF重写————————————————————————>
  > 1. 子进程rewirte新AOF
  > <-----在此期间的新Write都进入AOF缓冲区----->
  > 2. 将AOF缓冲区的数据追加到新AOF
  > ```
  >
  > AOF 文件重写期间，Redis 还会维护一个 **AOF 重写缓冲区**，该缓冲区会在子进程创建新 AOF 文件期间，记录服务器执行的所有写命令。当子进程完成创建新 AOF 文件的工作之后，服务器会将重写缓冲区中的所有内容追加到新 AOF 文件的末尾，使得新的 AOF 文件保存的数据库状态与现有的数据库状态一致。最后，服务器用新的 AOF 文件替换旧的 AOF 文件，以此来完成 AOF 文件重写操作。
  >
  > ![img](http://42.192.130.83:9000/picgo/imgs/0o0n1wk8fe.png)



### AOF 校验机制了解吗？

-  Redis 在启动时对 AOF 文件进行检查，以判断文件是否完整
- **校验和（checksum）** 的数字来验证 AOF 文件，CRC64 算法计算得出的数字











## Redis应用

### Redis应用场景

1. 缓存 `String`
2. 排行榜 `ZSet`
3. 计数器应用 `String Hash Incr HIncrBy`
4. 共享Session `Hash或String`
5. 分布式锁 `String setnx`
6. 社交网络 `Set SInter、SDiff、SPop随机 `
7. 消息队列 `List`
8. 位操作，标记打卡 `Bitmap`

- 不能重复的场景（文章点赞、网站 UV `Unique Visitor` 统计）
- `SInter`需要交集的场景（共同好友、粉丝）
- `SDiff`需要差集的场景（可能的好友、推荐博主、音乐推荐）
- `SPop`随机场景（随机点名、随机抽奖）

### 计数器怎么做

- String `Incr`

```java
127.0.0.1:6379> set blog:123:visitCount 0
OK
127.0.0.1:6379> incr blog:123:visitCount
(integer) 1
127.0.0.1:6379> incr blog:123:visitCount
(integer) 2
127.0.0.1:6379> incr blog:123:visitCount
(integer) 3
127.0.0.1:6379> get blog:123:visitCount
"3"
```

- Hash `HIncrBy`

```java
127.0.0.1:6379> hset blog:visitcount blog124 0
(integer) 1
127.0.0.1:6379> hincrby blog:visitcount blog124 2
(integer) 2
127.0.0.1:6379> hget blog:visitcount blog124
"2"
```

### 使用 Redis 实现一个排行榜怎么做？点赞排行榜?

- zadd key [score member]

`zadd key [NX|XX] [GT|LT] [CH] [INCR] 【score member】`

```java
127.0.0.1:6379> zadd user:ranking:2024-01-06 3 Jay:blog1
(integer) 1
127.0.0.1:6379> zadd user:ranking:2024-01-06 3 May:blog2
(integer) 1
127.0.0.1:6379> zincrby user:ranking:2024-01-06 1 Jay:blog1
"4"
127.0.0.1:6379> zincrby user:ranking:2024-01-06 10 May:blog2
"13"
    
// 无排序 
127.0.0.1:6379> zrange user:ranking:2024-01-06 0 2
1) "Jay:blog1"
2) "May:blog2"

// ZRANGEBYSCORE 从小到大排序 需要制定score范围
127.0.0.1:6379> zrangebyscore user:ranking:2024-01-06 0 10000 withscores
1) "Jay:blog1"
2) "4"
3) "May:blog2"
4) "13"

//  ZREVRANGE 从大到小排序 不用需要制定score范围
127.0.0.1:6379> ZREVRANGE user:ranking:2024-01-06 0 -1 withscores
1) "May:blog2"
2) "13"
3) "Jay:blog1"
4) "4"
  
127.0.0.1:6379> ZSCORE user:ranking:2024-01-06 May:blog2
"13"
```

```java
127.0.0.1:6379> zadd rank 0 number1
(integer) 1
127.0.0.1:6379> zadd rank 1 number2
(integer) 1
127.0.0.1:6379> zadd rank 2 number3
(integer) 1
127.0.0.1:6379> zrange rank 0 1
1) "number1"
2) "number2"
127.0.0.1:6379>
```

### Redis实现共享Session

- set并设置过期时间，删除del

```java
127.0.0.1:6379> set sessions_id:user1 session_ahdhafkh ex 300
OK
127.0.0.1:6379> get sessions_id:user1
"session_ahdhafkh"
127.0.0.1:6379> del sessions_id:user1
(integer) 1
```

### 设计set抽奖、好友推荐、博主推荐、共同好友

- 抽奖 `pop`
- 好友推荐、博主推荐 `Sdiff`
- 共同好友  `Sinner`

```java
127.0.0.1:6379> sadd lottery user1 user2 user3
(integer) 3
127.0.0.1:6379> spop lottery 2
1) "user1"
2) "user2"
127.0.0.1:6379> del lottery
(integer) 1
```

###  使用 Bitmap 统计活跃用户怎么做？

1. key为什么
2. 每一位代表什么

```java
// 设置2021年3月8日 id 为 22 的用户 活跃
127.0.0.1:6379> SETBIT 20210308 22 1
(integer) 0
// 获取id为前22的用户哪些是活跃的，只有00000000001，即id=22的用户；获取这个key对应的value的前23个无符号整数
// u无符号整数 i有符号整数
127.0.0.1:6379> bitfield 20210308 get u23 0
1) (integer) 1
// 获取id为22的用户是否在当天活跃；第22位是否为1
127.0.0.1:6379> getbit 20210308 22
(integer) 1
// 当天在线用户的数量；这个key下有多少个1
127.0.0.1:6379> bitcount 20210308
(integer) 2
```

### 使用 HyperLogLog 统计页面 UV 用户访客 怎么做？相比使用Set有什么优势？

- 内存效率高：固定大小12kb，**超级高效**
- 运行效率：只进行简单的位运算

```java
127.0.0.1:6379> pfadd blog_page_id:1 user1 user2 user3
(integer) 1
127.0.0.1:6379> pfcount blog_page_id:1
(integer) 3
// pfmerge 合并
```

### ==使用过 Redis 分布式锁嘛？有哪些注意点呢？==



> 1. 命令 setnx + expire 分开写
>
> ```java
> if（jedis.setnx(key,lock_value) == 1）{ //加锁
>     // 这时进程崩了，那么这个锁就不会过期了
>     expire（key，100）; //设置过期时间
>     try {
>     	do something / / 业务请求
>     }catch(){
>    	}
>     finally {
>     	jedis.del(key); //释放锁
>     }
> }
> 
> ```
>
> 2.  setnx + value **过期时间自己生成**
>
> ```java
> long expires = System.currentTimeMillis() + expireTime; //系统时间+设置过期时间String
> expiresStr = String.valueOf(expires);
> // 如果当前锁不存在，返回加锁成功
> if (jedis.setnx(key, expiresStr) == 1) {
> 	return true;
> }
> // 如果锁已经存在，获取锁过期时间
> String currentValueStr = jedis.get(key);
> // 如果获取到过期时间，小于系统当前时间，表示已经过期
> if (currentValueStr != null && Long.parseLong(currentValueStr) < System.currentTimeMillis()) {
>     // 锁已过期，获取上一个锁过期时间，并设置现在锁新的过期时间
>     String oldValueStr = jedis.getSet(key_resource_id, expiresStr);
>     if (oldValueStr != null && oldValueStr.equals(currentValueStr)) {
>         // 考虑多线程并发情况，只有一个线程设置值和当前值相同，它才可以加锁
>         return true;
>     }
> }
> //其他情况，均返回加锁失败
> return false;
> ```
>
> - **时间不统一**：过期**时间**由客户端时间需要**校准**
> - **被释放锁**：没有标志所属持有者id，可能被别人释放锁
> - **多个getset会被覆盖**：锁过期时候，并发多个同时都执行了 jedis.getSet()，最终只能有一个客户端加锁成功，但该客户端锁的过期时间，可能被别的客户端覆盖。
>
> 3. set 扩展命令（set ex px nx）
>
> ```java
> if（jedis.set(key, lock_value, "NX", "EX", 100s) == 1）{ 
>     //加锁 NX 不存在才加锁 EX过期时间
> try {
> 		do something  // 业务处理
>     }catch(){
> 
>     }
> 	finally {
> 		jedis.del(key); //释放锁
> 	}
> ```
>
> - 锁释放了，业务还没执行完
> - 锁被别人删了
>
> 4. set ex px nx + 校验唯一随机值,再删除
>
> ```java
> if（jedis.set(key, uni_request_id, "NX", "EX", 100s) == 1）{ //加锁
>     try {
>         do something // 业务处理
>     }catch(){
>     }
>     finally {
>   		// 这里非原子性
>         if (uni_request_id.equals(jedis.get(key))) {
>             jedis.del(key); //释放锁
>         }
>     }
> }
> // 一般也用 lua 脚本代替。
> // 但还是有锁释放了，业务还没执行完的问题
> if redis.call('get',KEYS[1]) == ARGV[1] then
> 	return redis.call('del',KEYS[1])
> else
> 	return 0
> end;
> ```
>
> - 判断锁是否加锁和释放锁不是一个原子操作，`del`的时候，锁不一定属于当前线程。

> 问题汇总：
>
> 1. **原子性：**加锁的原子性（set、expire）、 释放锁的原子原子性（get、del）
> 2. **锁被释放、锁是否属于当前线程** 锁会不会被别人释放
> 3. 释放锁，业务还没执行完（超时时间太短）
> 4. 时间不统一（不同机器用自己的时间设置为过期时间）



## Redis安全

### 怎么实现 Redis 的高可用？有哪些模式？优缺点？

保证高可用：

1. 数据少丢失：AOF、RDB
2. 服务不中断：集群

#### 主从：

- 主从复制，保证一致。**读写分离**：对主库读写，对从库读，保证主从数据一致。

> ![wps_EcX4iYXUu6](http://42.192.130.83:9000/picgo/imgs/wps_EcX4iYXUu6.png)
>
> 1. 建立连接 `psync` ,`FULLRESYNC全量复制`
> 2. 主sync发至从，从清空后加载RDB
> 3. 增量 buffer中写入从库
>
> ### 问题：主从不一致？
>
> 1. 网络
> 2. 从阻塞：监控复制进度、读取过期数据
>
> ### 问题：主从网络断开？
>
> - 中断的写放入buffer，再增量复制
>
> ### 主-从-从模式
>
> ![wps_rIxxWM7iKm](http://42.192.130.83:9000/picgo/imgs/wps_rIxxWM7iKm.png)

#### 哨兵：



#### 集群：













### 如何保证主从数据一致性

1. 全量同步：建立主从关系时，长时间断开时
2. 增量同步：slave定时发起，只增加新增的数据。会携带offset
3. 指令同步：master输入的指令异步给slave



### 哨兵相关问题

#### 哨兵作用？哨兵模式简介？

1. 监控：监控主从，周期性Ping节点
2. 主节点选择
3. 通知：告知各个从谁是主节点，建立主从关系

通过监视多个主从节点，当主节点下线后，选择主节点，建立新的主从关系。多个哨兵间相互监控，并监控Redis节点。**发布订阅模式**

![qrQmcE99M8](http://42.192.130.83:9000/picgo/imgs/qrQmcE99M8.png)

#### 哨兵如何判定主库下线

- 主观下线：Ping没有响应，就判定为主观下线。
- 客观下线，**多数（比如超过一半）**哨兵确认为主观下线，则为客观下线。

#### 哨兵模式如何工作

1. 哨兵每秒ping主库、从库、其他哨兵。
2. 如果超过`down-after- milliseconds`没有响应，则**主观下线**
3. 其他监视此库的哨兵ping主库
4. **超过半数**没有响应，客观下线
5. 进入选主模式

#### 哨兵是如何选主？由哪个哨兵执行主从切换呢？

- 过滤不符合条件的从库
- 按照规则（如网络延迟）给其他库打分
- 最高分的

---

- 标记主库客观下线的哨兵，向其他哨兵发送 **投票**
  - 拿到票数>= quorum的票数的才能成为Leader

#### 哨兵下故障转移

主节点故障时：

1. 哨兵进行Leader选举
2. 选择新节点S2为主节点
3. 其他从节点配置为该S2的从节点

### Redis Cluster 集群是什么？

主从模式，每个节点存储的数据是一样的，浪费内存。

- **分布式存储**

  **对数据进行分片**，每台节点存储不同的内容。

  Redis Cluster 切片集群方案。

#### 如何确地数据存储在哪个实例？

- **Hash Slot** ： 一个切片分为16384个slot

对key进行Hash(CRC16计算出一个16bit，再对16384取模)，分配到这些slot。

```
如：
节点A 负责 0~5460 号哈希槽
节点B 负责 5461~10922 号哈希槽
节点C 负责 10923~16383 号哈希槽
```



## 使用过 Redisson 嘛？说说它的原理

- **定期检查、延长锁：**解决锁释放的问题（锁过期了，业务还没执行完），开启一个守护线程，**定期检查、延长锁。**

### 原理

守护线程的监控

1. 加锁成功后，**启动开启watch dog监控这个线程**，如果这个线程还有这个锁，会不断**延长时间**。

![9bsjaHRgYn](http://42.192.130.83:9000/picgo/imgs/9bsjaHRgYn.png)

### RedLock算法

[分布式锁#Redis 如何解决集群情况下分布式锁的可靠性？](./分布式/分布式锁.md#Redis 如何解决集群情况下分布式锁的可靠性？)

- 向集群中多个Redis实例请求加锁，超过半数加锁成功就为成功。



## Redis底层原理相关

### Redis ZSet的底层实现？

- 跳跃表，跳跃表支持平均 **O（logN）**,最坏 O（N）复杂度✁节点查找，还可以通过顺序性操作批量处理的节点。

> 设计
>
> - 不宜使用Array，插入删除不方便。
> - 需要排序
>
> 下图结构，查找很快（沿着最高路径查找，比他大就回退走往下的一条）
>
> ![v2-f5ee3e457b1db81cd8bc5491f35d68df_720w](http://42.192.130.83:9000/picgo/imgs/v2-f5ee3e457b1db81cd8bc5491f35d68df_720w.webp)











