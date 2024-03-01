## Zookeeper

### 什么是Zookeeper

- 是一个分布式的小文件存储系统，一般对开发者屏蔽分布式应用开发过过程种的底层细节，用来解决**分布式集群中应用系统的一致性问题**

1. 集群管理
2. 分布式锁
3. Master选举

类似于一个裁判员的角色，专门负责协调和解决分布式系统中的各类问题

### Data model 节点模型分类？组成？有什么作用？

- **ZooKeeper 给出的每个节点的数据大小上限是 1M** 

- 通常是将 znode 分为 4 大类：

  - **持久（PERSISTENT）节点**：一旦创建就一直存在即使 ZooKeeper 集群宕机，直到将其删除。==在dubbo架构中service服务的注册==

  - **临时（EPHEMERAL）节点**：临时节点的生命周期是与 **客户端会话（session）** 绑定的，**会话消失则节点消失**。并且，**临时节点只能做叶子节点** ，不能创建子节点。

    ==分布式锁==

  - **持久顺序（PERSISTENT_SEQUENTIAL）节点**：除了具有持久（PERSISTENT）节点的特性之外， 子节点的名称还具有顺序性。比如 `/node1/app0000000001`、`/node1/app0000000002` 。

  - **临时顺序（EPHEMERAL_SEQUENTIAL）节点**：除了具备临时（EPHEMERAL）节点的特性之外，子节点的名称还具有顺序性

- 每个 znode 由 2 部分组成:

  - **stat**：状态信息
  - **data**：节点存放的数据的具体内容

### 常见命令

- `ls /app` 
- `create -e -s -es`
- `get /app`
- `set /app data`
- `delete /app`
  - `deleteall`
- `help`

### Watcher的工作流程？及应用？

1. Client注册Watcher
2. 事件发生后通知Client
3. Client执行回调方法

> ### 分布式锁
>
> - 临时顺序节点**监视前一个节点**是否释放，释放则自己获取了锁
>
> ![](http://42.192.130.83:9000/picgo/imgs/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9_u2qzxMFC6L.png)

### ZooKeeper 集群角色与作用？

- **Leader 提供读、写**
- Follower （提供读）
- Observer（提供读、但不参与选Leader的投票）

![ZooKeeper 集群中角色](https://oss.javaguide.cn/github/javaguide/distributed-system/zookeeper/zookeeper-cluser-roles.png)

###  ZooKeeper 集群为啥最好奇数台？

- 超过半数可用，方便选择Leader

  3台允许1damn，4台也是允许1damn。

### 什么是脑裂？ZooKeeper 选举的过半机制防止脑裂？

// TODO

- 6(3+3)网络断开了变成了3+3（分别有两个Leader），如何避免这种情况？

### ZAB 协议和 Paxos 算法

