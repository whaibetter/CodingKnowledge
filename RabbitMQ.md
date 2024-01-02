## RabbitMQ工作原理的理解

### 1. 关键组件

- Producer
- Consumer
- ==Broker== 主机RabbitMq客户端 **是一栋用来存储和转发消息的房子**

----

- Exchange 只根据规则分发消息。
- Queue
- Binding Exchange和Queue是多对多

----

- Channel 

  在AMQP协议里面引入了Channel的概念，它相当于是一个**虚拟的连接**。这样我们就可以在已经连接好的**TCP长连接里面去创建和释放Channel，大大了减少了资源消耗**

  **虚拟的连接**（线程池里的线程）

- Connection

![wps_TqCtLmdiih](http://img.whaifree.top//wps_TqCtLmdiih.png)

### 2. Exchange 的类型

- **fanout** 广播
- **direct** RoutingKey 完全匹配
- **topic** com.rabbitmq.client  \# 代表匹配0个或者多个单词 \* 代表匹配不多不少一个单词
- **headers(不推荐)** 根据发送的消息内容中的 headers （键值对）属性进行匹配

## 说说 Broker 服务节点、Queue 队列、Exchange 交换器？

- **Broker**：可以看做 RabbitMQ 的服务节点
- **Queue** :RabbitMQ 的内部对象，用于存储消息
- **Exchange** : 生产者将消息发送到交换器，由交换器将消息路由到一个或者多个队列中。当路由不到时，或返回给生产者或直接丢弃。

## 什么是死信队列？如何导致的？

变成死信 (`dead message`) 之后，它能被重新被发送到另一个交换器中

- TTL
- 消息被拒（`Basic.Reject /Basic.Nack`) 且 `requeue = false`
- 队列满了

## 什么是延迟队列？RabbitMQ 怎么实现延迟队列？

等待特定时间后，消费者才能拿到这个消息进行消费。

要实现延迟消息，一般有两种方式：

1. ==使用 RabbitMQ 的死信交换机（Exchange）和消息的存活时间 TTL（Time To Live）。==

![msedge_z5vvSuSS4i](http://img.whaifree.top//msedge_z5vvSuSS4i.png)

设置队列TTL，让消息在这个队列停留，等到超时给到死信队列，消费者只监听死信队列。

2. ==rabbitmq-delayed-message-exchange插件== 来实现延迟队列功能。

## 什么是优先级队列？

优先级高的队列会先被消费。可以通过`x-max-priority`参数来实现优先级队列。

##  AMQP 是什么?

AMQP，全称Advanced Message Queuing Protocol（高级消息队列协议），**异步**

**AMQP 模型的三大组件**：

- **交换器 (Exchange)**：消息代理服务器中用于把消息路由到队列的组件。
- **队列 (Queue)**：用来存储消息的数据结构，位于硬盘或内存中。
- **绑定 (Binding)**：一套规则，告知交换器消息应该将消息投递给哪个队列。

生产者把消息发送到**RabbitMQ Broker**上的Exchange交换机上。Exchange交换机把收到的消息根据路由规则发给绑定的队列（Queue）

最后再把消息投递给订阅了这个队列的消费者，从而完成消息的异步通讯。

![i3OWPSd0gG](http://img.whaifree.top//i3OWPSd0gG.png)

##  RabbitMQ 有哪些工作模式？

- 简单模式 

- work 工作模式 轮询 不公平分发

- pub/sub 发布订阅模式  **fanout**类型的交换机

- Routing 路由模式 **direct**

- Topic 主题模式 **topic**

- RPC (RPC协议的主要目的是做到不同服务间调用方法像同一服务间调用本地方法一样)

  ![Summary illustration, which is described in the following bullet points.](http://img.whaifree.top//python-six.png)

## RabbitMQ 消息怎么传输？

RabbitMQ 在一条 TCP 链接上建立成百上千个信道来达到多个线程处理。

RabbitMQ 消息传输过程如下：

1. **生产者**：发布消息到 RabbitMQ 中的交换机（Exchange）上。
2. **交换机**：和生产者建立连接并接收生产者的消息。
3. **消费者**：监听 RabbitMQ 中的 Queue 中的消息。
4. **队列**：Exchange 将消息分发到指定的 Queue，Queue 和消费者进行交互。
5. **路由**：交换机转发消息到队列的规则。

### **如何保证消息的可靠性？不丢失？**

- 生产者到 RabbitMQ：

  - **事务机制**

  - **Confirm 机制**  客户端可以根据消息的处理结果来决定是否要做消息的重新发送

    ```java
    channel.addConfirmListener(new ConfirmListener() {
             //消息失败处理
             @Override
             public void handleNack(long deliveryTag, boolean multiple) throws IOException {
    
             }
             //消息成功处理
             @Override
             public void handleAck(long deliveryTag, boolean multiple) throws IOException {
                   log.info("sendQueue-ack-confirm-successs==>exchange:{}--routingkey:{}--deliveryTag:{}--multiple:{}", topicExchange, routingKey, deliveryTag, multiple);
             }
    });
    ```
    
    ```java
    //手动确认 ConfirmCallback、returnCallback
    
    public class RabbitMqProducerAck implements RabbitTemplate.ConfirmCallback , RabbitTemplate.ReturnCallback{
    	@Override
        public void confirm(CorrelationData correlationData, boolean ack, String cause) {
            log.info("rabbitMqProducerAck-confirm-successs==>消息回调confirm函数:{},ack:{},cause:{}", JSONObject.toJSONString(correlationData), ack, cause);
        }
        @Override
        public void returnedMessage(Message message, int replyCode, String replyText, String exchange, String routingKey) {
            log.info("rabbitMqProducerAck-confirm-fail==>消息使用的交换器 exchange : {}--消息使用的路由键 routing :{}--消息主体 message : {}-replyCode : {}-replyText： {}", exchange, routingKey, message.getBody(),replyCode,replyText);
            try {
                Thread.sleep(3000l);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            //从新发送
            this.send(exchange, routingKey, new String(message.getBody()));
        }
    }
    ```java
    
    

  > - 注意：事务机制和 Confirm 机制是互斥的，两者不能共存，会导致 RabbitMQ 报错。
  >
  > confirm机制是为了确保消息能够正确的发送至RabbitMQ的交换器，如果此交换器没有匹配的队列，那么消息也会丢失。事务机制是对消息进行确认，如果开启事务，消息就不会丢失。由于两者的目的不同，所以不能同时开启，因此confirm机制和事务机制是互斥的。

- RabbitMQ 自身宕机：**持久化**、**集群**、普通模式、备用交换机、镜像模式。

- RabbitMQ 到消费者（消费者宕机）：**手动确认basicAck 机制 （这种方式可能会造成重复消费问题，所以这里需要考虑到幂等性的设计）、死信队列**、消息补偿机制。

------

### 如何保证 RabbitMQ 消息的顺序性？ 4

1. **单一消费者**：一个队列只被一个消费者消费，**多个消息按顺序到达消费者按顺序处理**
2. **多个消费者：**消费者分组，同一组消费者受到相同消息。
3. **公平调度：**`x-max-concurrent-consumers` （最大并发消息数）参数设置为1，只允许一个消费者同时从该队列获取消息。
4. **优先级**：有序交换器（Priority Exchange）

##  如何保证 RabbitMQ 高可用的？

- 普通集群模式

  启动多个 RabbitMQ 实例ABC，每个机器启动一个。**BC实例都同步 A的queue 的元数据**。

  消费的时候，连接BC会从A的 queue 所在实例上拉取数据过来

  - 优点：分担了流量，提高吞吐量。
  - 缺点：一旦Queue所在的节点挂了，那么这个Queue的消息就没办法访问了

- 镜像集群模式

  queue 元数据和数据都会**存在于多个实例**上，就是说，每个 RabbitMQ 节点都**有这个 queue 的一个完整镜像**，包含 queue 的全部数据的意思。

  写消息到 queue 的时候，完整同步所有Queue。

  - 优点：高可用，有备份

  - 缺点：性能开销

  > HAProxy是一个能支持四层和七层的负载均衡器，可以实现对RabbitMQ集群的负载均衡同时为了
  >
  > 避免HAProxy的单点故障，可以再增加Keepalived实现HAProxy的主备，如果HAProxy主节点出现
  >
  > 故障那么备份节点就会接管主节点提供服务。
  >
  > Keepalived提供了一个虚拟IP，业务只需要连接到虚拟IP即可。

## 如何解决消息队列的延时以及过期失效问题？

消息在 queue 中TTL就会被 RabbitMQ 给清理掉。大量的数据会直接搞丢。

> #### 积压大量消息
>
> 原因：Consumer故障了
>
> 解决：让消费者把消息，重新写入MQ中，然后在用 10倍的消费者来进行消费。
>
> 1. 修复Consumer
> 2. 新Consumer--->超大的Queue
> 3. 加大物理机部署Consumer
>
> #### 大量消息积压，并且设置了过期时间
>
> - 过了高峰期后重新添加到MQ
>
> 丢弃了数据，然后等高峰期过了之后，例如在晚上12点以后，就开始写程序，将丢失的那批数据，写个临时程序，一点点查询出来，然后重新 添加MQ里面，把白天丢的数据，全部补回来。

1. 提高消费并行度
2. 批量重导，丢失数据查出重新导入。
3. 避免过期
   - 合理超时时间

> RabbtiMQ 是可以设置过期时间的，也就是 TTL。如果消息在 queue 中积压超过一定的时间就会被 RabbitMQ 给清理掉，这个数据就没了。那这就是第二个坑了。这就不是说数据会大量积压在 mq 里，而是大量的数据会直接搞丢。我们可以采取一个方案，就是批量重导，这个我们之前线上也有类似的场景干过。就是大量积压的时候，我们当时就直接丢弃数据了，然后等过了高峰期以后，比如大家一起喝咖啡熬夜到晚上 12 点以后，用户都睡觉了。这个时候我们就开始写程序，将丢失的那批数据，写个临时程序，一点一点的查出来，然后重新灌入 mq 里面去，把白天丢的数据给他补回来。也只能是这样了。假设 1 万个订单积压在 mq 里面，没有处理，其中 1000 个订单都丢了，你只能手动写程序把那 1000 个订单给查出来，手动发到 mq 里去再补一次。
>
> ------
>
> 著作权归JavaGuide(javaguide.cn)所有 基于MIT协议 原文链接：https://javaguide.cn/high-performance/message-queue/rabbitmq-questions.html
>
> 1. **提高消费并行度**：通过增加消费并行度，可以提高总的消费吞吐量，但并行度增加到一定程度，反而会下降，因此需要设置合理的并行度。
> 2. **批量重导**：写程序将丢失的数据查出来，然后重新放到mq里面去，把白天丢的数据补回来。
> 3. **设置合理的超时时间**：根据业务场景，设置合理的超时时间，**防止消息过期**。
> 4. **选择合适的消息队列**：针对业务特点，选择合适的消息队列。
> 5. **避免消息被重复消费**：在程序中增加幂等操作，避免消息被重复消费。

## 什么是幂等？如何解决幂等性问题？

一个逻辑即使被重复执行多次。重复去扣钱，消息被重复消费。

1. 用户的**重复提交**或者用户的恶意攻击；
2. 分布式系统中，为了避免数据丢失，采用的**超时重试机制**。

幂等性的核心思想，其实就是保证这个接口的执行结果**只影响一次**，后续即便再次调用，也不能对数据产生影响

### 解决方法

- **redis setNX**（如果存在是不会执行的）
- **数据库唯一性Id**（重复id无法执行）**写入时先查一下有没有**
- **状态机**（状态只能向前，指一条数据的完整运行状态的转换流程）

要么就是**接口只允许调用一次**，比如唯一约束、基于 Redis 的锁机制。

要么就是对**数据的影响只会触发一次**，比如乐观锁等。

