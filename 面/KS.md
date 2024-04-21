[toc]

# 1

1.string为什么要用final修饰？

- final保证线程安全，每次赋值都是一个全新的对象

> **不可变性，提供线程安全性，支持缓存优化**
>
> 一旦创建了一个`String`对象，它的值就不能被修改。
>
> - 不可变性：`final`关键字确保`String`类的实例在创建后不能被修改。
> - 线程安全
> - 缓存优化：由于`String`对象的不可变性，可以在内存中缓存字符串常量，以便在多个地方重复使用。

2.反射了解吗？你项目里面有用过吗？

- 运行在运行的过程中动态调用类的方法、属性、创建对象

> - 静态编译：在编译时确定类型，绑定对象
> - 动态编译：运行时确定类型，绑定对象

**应用**

> ### SPI（Service Provider Interface）
>
> 场景：**通过改配置文件，来实现不同功能的切换**。 比如我们有一个缓存接口，提供redis实现和memecache实现：
>
> ### JDBC

3.双亲委派机制，为什么要有这个？tomcat的双亲委派知道吗？

**JDK 中的本地方法类一般由[根加载器](https://www.zhihu.com/search?q=根加载器&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A2219153613})（Bootstrp loader）装载，JDK 中内部实现的扩展类一般由[扩展加载器](https://www.zhihu.com/search?q=扩展加载器&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A2219153613})（ExtClassLoader ）实现装载，而程序中的类文件则由[系统加载器](https://www.zhihu.com/search?q=系统加载器&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A2219153613})（AppClassLoader ）实现装载。**

- 在使用类加载器**将.class加载为Class对象**的时候，优先给到父类加载器，查看父类加载器能否加载，如果父类不能加载再由自己加载。
- 为了保证一个安全，沙箱安全机制，使得代码只能在限定范围内起作用。**比如我们自己建立一个java.lang.String包，如果不使用这种方式，会覆盖掉java原生的String，必然会出问题**

**tomcat双亲委派**

在初学时部署项目，我们是把war包放到tomcat的webapp下，这意味着一个tomcat可以运行多个Web应用程序

假设我现在有两个Web应用程序，它们都有一个类，叫做User，并且它们的类全限定名都一样，比如都是com.yyy.User。但是他们的具体实现是不一样的。那么Tomcat是如何保证它们是不会冲突的呢？

答案就是，Tomcat给每个 Web 应用创建一个类加载器实例（WebAppClassLoader），该加载器重写了loadClass方法，**优先加载当前应用目录下的类，如果当前找不到了，才一层一层往上找**。那这样就做到了Web[应用层级](https://www.zhihu.com/search?q=应用层级&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A2219153613})的隔离

如何自定义ClassLoader



4.mysql锁，死锁知道吗？mysql是怎么解决死锁的

- 多个事务占用各自需要的资源

**锁的分类**：

MySQL中的锁可以分为两类：共享锁（Shared Lock）和排他锁（Exclusive Lock）

**MySQL解决死锁：**

- 当检测到死锁时，MySQL会**选择一个事务作为牺牲者，将其回滚**，释放其持有的锁，让其他事务继续执行。





5.隔离级别，读已提交



6.mysql主从复制知道吗？聊聊在应用层面的问题（开哭😭）

- 主从复制binlog --->从---> relay log 重新执行一次

问题：

- **数据一致性**、主从延迟、

可能会有读写速率不一致导致阻塞、数据一致性的问题，比如从库读的压力太大了，无法及时写入，

- 数据分片和一致性哈希

  考虑如何进行数据分片和负载均衡，以确保数据在各个从服务器之间的分布均衡和一致性



6.1master节点是负责写，slave负责读对吧，应用层面是怎么做这个区分的？

- 针对不同操作指向不同的数据库

  对于写操作，应用程序使用连接到主节点的数据库连接，而对于读操作，应用程序使用连接到从节点的数据库连接。通过这种方式，可以明确地将读操作和写操作发送到不同的节点

- 使用读写分离中间件，例如MySQL Proxy、MaxScale、ProxySQL等，这些中间件可以拦截应用程序的数据库请求，并根据请求类型将其重定向到合适的节点。

- 数据库连接池配置：
  在应用程序中使用数据库连接池，可以通过配置连接池来实现读写分离。连接池可以根据配置规则选择合适的数据库连接，使写操作使用主节点连接，读操作使用从节点连接。某些数据库连接池还提供了负载均衡和故障转移的功能，以确保读操作的高可用性和性能。



6.2怎么把写请求发给master而其他发给slave

- 针对不同操作发送到不同的连接

6.3用aop可以吗？

- 可以，拦截下来，检验是写操作就把该SQL交给Master执行

  

6.4除了aop呢？还有呢？

7.concurrenthashmap，为什么1.7用reentrantlock，1.8用synchronized

在Java 1.7版本中，`ConcurrentHashMap`内部使用了`ReentrantLock`来实现并发控制。`ReentrantLock`是Java提供的一个可重入锁，它提供了更灵活的锁机制，可以支持更复杂的同步需求。使用`ReentrantLock`可以实现更细粒度的控制，比如可中断、公平锁等。

然而，在Java 1.8版本中，`ConcurrentHashMap`进行了重大的改进和优化。其中一个重要的改进是使用了CAS（Compare and Swap）操作和`synchronized`关键字的组合来实现并发控制，取代了之前版本中的`ReentrantLock`。CAS操作是一种无锁的线程安全机制，它允许多个线程同时访问数据，而不需要使用显式的锁。

使用CAS和`synchronized`的组合在一些场景下可以提供更高的性能，因为CAS操作不需要线程进入阻塞状态。在Java 1.8中，`ConcurrentHashMap`的实现经过精心优化，结合了CAS和`synchronized`，在保证线程安全的同时，提供了更好的性能和可伸缩性。

作者：适彼乐土
链接：https://www.nowcoder.com/feed/main/detail/10000654b6284231b8a576b3a6f53792?sourceSSR=search
来源：牛客网

# 2

## 一面（4月27号，1h20min）

**自我介绍**

**集合**

1. 了解哪些集合？

2. HashMap 和 TreeMap 的区别？

   - TreepMap底层为红黑树，能够（自定义排序规则），TreeMap的查找、插入和删除操作的时间复杂度是对数级别（O(log N)）
   - HashMap为链表+数组+红黑树

3. HashMap jdk8与jdk7区别？

4. HashMap为什么线程不安全？

   不提供同步机制，即没有对多线程访问进行并发控制。多个线程同时对HashMap进行修改操作（插入、删除、更新等），可能会导致数据结构的破坏和不一致性

5. JDK1.7中的 HashMap 使用头插法插入元素为什么会出现环形链表？

   

6. 哪种HashMap是线程安全的？

   - ConcurrentHashMap Segment CAS Syncronized
   - 

1. ConcurrentHashMap 的1.7版本和1.8版本的实现原理？
2. CAS机制在ConcurrentHashMap有哪些具体体现？
3. ConcurrentHashMap为什么在1.7使用分段锁，1.8使用CAS + synchronized？

 **JUC**

1. 线程有哪些状态？

   - 新建
   - 就绪
   - 运行
   - 阻塞
   - 销毁

   ![img](http://42.192.130.83:9000/picgo/imgs/java-thread.jpg)

2. sleep() 方法和 wait() 方法区别?

   sleep会抱着锁睡觉，不会放弃cpu的执行权，不会释放锁
    wait会放弃锁，会释放cpu的执行权，会释放锁

   - **sleep属于Thread**；wait属于Object

   - wait可以notify
   - wait必须在syncronized中使用

   

3. 偏向锁是什么？轻量级锁是什么？

   一般情况认为一个锁只有一个访问，标记对象所属线程，只要是这个线程进来就放行。

   1. 偏向锁

      **对象头记录线程id**

      **在对象Header头中标记拿锁线程id，之后再次进入同步块中不用加锁**

      如果有其他线程也需要访问这个锁，偏向锁就失效了，升级成轻量级锁

   Java里面，**轻量级锁用CAS**的方式实现所以，也可以叫自旋锁，这俩没差

   2. 轻量级锁

      若一个线程尝试获取锁，检测到被占用但没有达到自旋次数阀值，它会采用**CAS操作（Compare And Swap）**来不断尝试获取锁。这就是所谓的“轻量级”自旋锁。若过了自旋阀值还没有获取到锁，则升级为重量级锁。

1. 讲一讲synchronized锁升级过程？

   无锁 ==> 偏向锁 ==> 轻量级锁 ==> 重量级锁

   - 无锁 单线程很快乐的运行，没有其他的线程来和其竞争
   - 偏向锁  一般只被一个线程访问，如果对象标记属于某个线程，那个线程进来就不用加锁
   - 轻量级锁 如果偏向锁被其他线程访问就会失效，变成CAS
   - 重量级锁 如果CAS次数达到阈值，就会变成重量级锁

   > 线程A进入syncronized
   >
   > - 判断偏向锁是不是线程A（根据头部的所属线程id）
   > - 不是线程A，就CAS，获取成功改线程ID
   > - 如果达到CAS阈值，就升级为重量级锁

2. CAS了解多少？

3. CAS底层实现原理？

4. AQS了解多少？

5. ReentrantLock公平锁实现原理？

   - AQS 获取锁的时候包装为Node进入队列排队，而不是直接获取锁。先到先得的原则。
   - 当锁的持有者释放锁时，AQS会从等待队列中选择一个节点唤醒，使其继续尝试获取锁。**在公平锁中，AQS会选择等待时间最长的节点唤醒**，确保等待时间最长的线程优先获取锁。

6. ReentrantLock非公平锁实现原理？

7. 线程池有哪些核心参数？

   最大核心

   核心线程

   拒绝策略，直接拒绝Exception、交给父线程、丢弃

   队列类型

8. 讲讲线程池的工作方式？

9. 如果线程到达 maximumPoolSize 仍然有新任务来临，并且该任务的优先级比较高，不允许直接丢弃，希望该任务立即执行，如何处理？

   - 调整线程池大小
   - 使用优先队列，优先级高的先执行

**计算机网络**

1. TCP拥塞控制如何实现？

2. 什么是快重传和快恢复算法？

   - 快重创：发送方只要一连**收到三个重复确认**就应当立即**重传对方尚未收到的报文段**
   - 快恢复：三个重复的ACK，ssthresh减半+拥塞避免

3. 每一层对应的网络协议有哪些？

4. WebSocket 与 Socket 的区别？

   > // TODO
   >
   > WebSocket是一种基于HTTP协议的双向通信协议。长连接。可以在HTTP和TCP之上进行通信
   >
   > Socket是一种传统的网络套接字，通过建立客户端和服务器之间的连接，可以进行双向通信。每次都要连接。Socket TCP协议进行通信。

5. HTTP与HTTPS的区别?

6. HTTPS为什么是安全的？

**Redis**

1. Redis过期键的删除策略有哪些？

2. Redis删除策略的优点和缺点有哪些？

3. 什么是热点Key问题？什么样的key被称为热key？如何解决热点Key？//todo

   热点 Key 是指在分布式系统中，**某些特定的键（Key）被频繁地访问或操作**，导致集中的热点流量集中在少数几个键上，而其他键的访问压力相对较低的问题。

   - 策略：对于热门 Key，可以采用更长的缓存过期时间或使用永久缓存
   - 缓存预热
   - 数据分片：将热门 Key 分散到多个节点或服务器上，使访问负载均衡
   - 限流与熔断
   - 异步处理：将热门 Key 的请求转换为异步处理，减少同步请求的阻塞，提高系统的并发处理能力。

4. Redis是单线程的吗？

5. **Redis String类型的底层是如何实现？**

6. **为什么Redis要用简单动态字符串 SDS？**

7. **Redis Sorted set类型的底层是如何实现？**

   **跳跃表**

8. **为什么Sorted set底层不用二叉树，平衡树实现？**

   - 实现简单，插入和删除不用旋转（平衡）
   - 时间复杂度和树相当
   - 在做**范围查找**的时候，平衡树比skiplist操作要复杂

   [Redis为什么用跳表而不用平衡树？ - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/23370124)

   - 平衡树如 AVL 树或红黑树每个节点通常需要存储更多的信息来**维持树的平衡**
   - 跳跃表在进行**范围查询**（如 `ZRANGE` 或 `ZREVRANGE`）时，可以像链表一样遍历
   - **实现简单性**：跳跃表的结构和算法相对简单

   > > There are a few reasons:
   > >
   > > \1) They are not very memory intensive. It's up to you basically. Changing parameters about the probability of a node to have a given number of levels will make then less memory intensive than btrees.
   > >
   > > \2) A sorted set is often target of many ZRANGE or ZREVRANGE operations, that is, traversing the skip list as a linked list. With this operation the cache locality of skip lists is at least as good as with other kind of balanced trees.
   > >
   > > \3) They are simpler to implement, debug, and so forth. For instance thanks to the skip list simplicity I received a patch (already in Redis master) with augmented skip lists implementing ZRANK in O(log(N)). It required little changes to the code.
   > >
   > > 
   > >
   > > 这段话原文出处：[https://news.ycombinator.com/it](https://link.zhihu.com/?target=https%3A//news.ycombinator.com/item%3Fid%3D1171423)

9. 讲一讲Redis持久化机制？

10. 如果我采取AOF持久化方式，并且想要高可靠性保证，选择哪一种写回策略，为什么？

11. **如果我想要数据不能丢失，如何让RDB和AOF混合使用来满足我的诉求？**

**Spring**

1. 讲一下Spring中的bean生命周期？
   - 实例化
   - 属性注入
   - 初始化
     - 设置各种Aware `BeanNameAware ` `BeanFactoryAware` `ApplicationContextAware`
     - BeanPostProcessor **postProcessBeforeInitialization()** 
     - **InitializingBean 的 afterPropertiesSet()** 
     - init-method
     - BeanPostProcessor **afterProcessBeforeInitialization()** 
   - 使用
   - 销毁 DisposableBean 
     - 通过 `destroy-method` 属性或 `@PreDestroy` 注解
2. 讲一下Spring事务的传播机制？
   - 有就属于，没有就新建 **REQUIRED**
   - **有就属于，没有就不事务**
   - **嵌套子事务**
   - 强制新建
   - 没有事务就报错
   - 有事务就报错
   - **不事务**
3. 有时候在一个大的事务中，需要执行一些小的业务操作，这些小的业务操作可以单独成功或失败，不影响大的事务，这属于哪种事务传播机制？
   - new
4. 如果当前存在事务，则使用当前事务，如果当前不存在事务，则无事务执行，这属于哪种事务传播机制？

**MySQL**

1. 什么是MVCC？

2. 讲一讲MVCC的实现原理？

   InnoDB 的 MVCC的实现原理

   [InnoDB存储引擎对MVCC的实现](https://javaguide.cn/database/mysql/innodb-implementation-of-mvcc.html)

   > `MVCC` 的实现依赖于：**隐藏字段、Read View、undo log**。
   >
   > ### [隐藏字段](#隐藏字段)
   >
   > 在内部，`InnoDB` 存储引擎为每行数据添加了三个 [隐藏字段open in new window](https://dev.mysql.com/doc/refman/5.7/en/innodb-multi-versioning.html)：
   >
   > - **`DB_TRX_ID（6字节）`：更新操作事务id**
   > - **`DB_ROLL_PTR（7字节）`： 回滚指针**
   > - `DB_ROW_ID（6字节）`：如果没有设置主键且该表没有唯一非空索引时，`InnoDB` 会使用该 id 来生成聚簇索引
   >
   > ![image-20240418220417906](http://42.192.130.83:9000/picgo/imgs/image-20240418220417906.png)
   >
   > ### UndoLog
   >
   > 作用：事务回滚、通过undolog读取之前的版本（非锁定读）
   >
   > ![img](http://42.192.130.83:9000/picgo/imgs/6a276e7a-b0da-4c7b-bdf7-c0c7b7b3b31c-n52toho_.png)
   >
   > ### Read View
   >
   > - 记录（正在执行的事务，未提交的事务、未开始的事务）
   >
   > ![image-20240418221022981](http://42.192.130.83:9000/picgo/imgs/image-20240418221022981.png)

**实习经历（10min）**

**场景题**

1. 实现一个权限框架可以做到，对同一个对象，不同的角色可以访问到的对象字段不一样。比如对于员工对象，领导可以看到员工的手机号，而普通人看不到员工的手机号。

**算法题**

1. Leetcode  69. x 的平方根111

**反问**

1. 部门的业务（商业化技术-广告投放）
2. 部门的技术栈（Java）？
3. 后续的面试流程（一共4轮面试）



## 二面（4月28号，1h）

**自我介绍**

**实习经历（15min）**

**简历项目（15min）**

**Redis**

1. Redis过期键的删除策略有哪些？
2. Redis能实现ACID属性吗？
3. Redis的事务可以保证原子性吗？为什么？
4. Redis的事务可以保证一致性吗？为什么？
5. Redis的事务可以保证隔离性吗？为什么？
6. Redis的事务可以保证持久性吗？为什么？
7. Redis中的事务是否支持回滚？
8. Redis中AOF 和 RDB持久化方式的区别？
9. 渐进式rehash实现过程？

**计算机网络**

1. TCP/IP四层模型，五层模型？
2. HTTP与HTTPS的区别? 
3. TCP 和 UDP 的区别？
4. 有哪些应用使用的是TCP协议，哪些应用使用的是UDP协议？
5. 用户输入网址到显示对应页面的全过程？
6. TCP协议如何保证可靠性？

**算法**

1. LeetCode 146. LRU 缓存
2. Leetcode 215. 数组中的第K个最大元素

**反问**

1. 部门的业务？
2. 部门的技术栈？

## 三面（5月6号，40min）

**自我介绍**

**实习经历**

1. 介绍一下三段实习分别做了哪些工作？
2. 介绍一下在字节实习做的业务和方向？
3. 对广告投放系统了解多少？
4. 如果让你设计一个广告投放系统，你会怎么考虑？
5. 共享屏幕，画一下广告系统整体链路架构图？
6. 介绍一下字节实习部门在整个广告系统的位置，以及为什么需要这个部门？
7. 结合实习经历，讲一下对设计模式的理解？

**其他**

1. 对未来的规划有哪些？
2. 现在还在字节实习吗？在哪里租的房子？
3. 选择一家公司最看中的一个因素是什么？为什么？
4. 自己身上的优点和缺点有哪些？
5. 最近有关注哪些技术热点和阅读哪些技术书籍？
6. 为什么写博客？什么时候开始写博客的？
7. 有没有考研的想法，为什么？
8. 遇到的最大的一个困难是什么？如何解决的？

**反问**

1. 部门的业务？
2. 部门的技术栈？

## HR面（5月6日，10min）

1. 手里的offer有哪些？
2. 字节实习的经历？
3. 然后就是介绍快手福利，薪资待遇

## 投递记录



作者：肆意不羁少年鼠
链接：https://www.nowcoder.com/discuss/486354378278957056?sourceSSR=search
来源：牛客网
