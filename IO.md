[toc]

# I/O相关

## 讲讲阻塞IO和非阻塞IO。讲讲有哪些常用实现。多路复用是什么？

- 阻塞IO BIO 

  程序发起IO操作时会**一直等待**，直到操作完成后执行后续代码。

  - 系统调用
  - `read()` ` write()`

  ![202211211631552](http://42.192.130.83:9000/picgo/imgs/202211211631552.png)

- 非阻塞IO NIO

  程序**不会等待IO完成**，继续执行后续代码。即使IO操作还没有完成，程序也可以继续执行其他任务。

  - 轮询检查IO是否完成
  - 事件机制（回调、事件处理器）返回IO结果

![202211211631553 (1)](http://42.192.130.83:9000/picgo/imgs/202211211631553 (1).png)

- IO多路复用

  允许一个程序**监控多个IO资源**，任何一个资源就绪就能处理

  ![image-20221121161111685](http://42.192.130.83:9000/picgo/imgs/202211211631554 (1).png)

## 有哪些IO模型？

> 1. 同步阻塞I/O
> 2. 同步非阻塞I/O **轮询**IO是否完成
> 3. I/O多路复用 **select、poll 和 epoll**查询是否完成
> 4. 信号驱动I/O 信号通知
> 5. 异步I/O 回调通知

## Java的IO模型有哪些？区别是什么？

- BIO 阻塞IO
- NIO 非阻塞IO
- AIO 异步IO

![BIO、NIO 和 AIO 对比](http://42.192.130.83:9000/picgo/imgs/bio-aio-nio.png)

## 同步非阻塞模型和I/O 多路复用模型？

#### 同步非阻塞

- 数据从内核空间拷贝到用户空间的这段时间里，是阻塞
- 存在问题：==轮询耗资源== **应用程序不断进行 I/O 系统调用轮询数据是否已经准备好的过程是十分消耗 CPU 资源的。**

<img src="http://42.192.130.83:9000/picgo/imgs/bb174e22dbe04bb79fe3fc126aed0c61~tplv-k3u1fbpfcp-watermark.png" alt="图源：《深入拆解Tomcat & Jetty》" style="zoom:50%;" />

![202211211631553](http://42.192.130.83:9000/picgo/imgs/202211211631553.png)

#### **I/O 多路复用模型**

1. select/poll/epoll 询问**数据是否准备就绪**
2. ready 内核准备就绪
3. read （数据从内核空间 -> 用户空间）**阻塞**

**IO 多路复用模型，通过减少无效的系统调用（只有当IO事件发生时才触发系统调用，==由内核去进行轮询==），减少了对 CPU 资源的消耗。**

<img src="http://42.192.130.83:9000/picgo/imgs/88ff862764024c3b8567367df11df6ab~tplv-k3u1fbpfcp-watermark.png" alt="img" style="zoom:50%;" />

![image-20221121161111685](http://42.192.130.83:9000/picgo/imgs/202211211631554 (1).png)

![](http://42.192.130.83:9000/picgo/imgs/image-20240422223715000.png)

#### **多路复用器**

Java 中的 NIO ，有一个非常重要的**选择器 ( Selector )** 的概念，也可以被称为 **多路复用器**。

只需要一个线程便可以管理多个客户端连接。当客户端数据到了之后，才会为其服务。

## Java NIO的模型结构？

在标准 Java 代码中提供了**非阻塞、面向缓冲、基于通道**的 I/O，可以使用少量的线程来处理多个连接，大大提高了 I/O 效率和并发。

> :warning: 需要注意：使用 NIO 并不一定意味着高性能，它的性能优势主要体现在高并发和高延迟的网络环境下。当连接数较少、并发程度较低或者网络传输速度较快时，NIO 的性能并不一定优于传统的 BIO 。

### NIO 核心组件？

![Buffer、Channel和Selector三者之间的关系](http://42.192.130.83:9000/picgo/imgs/channel-buffer-selector.png)

![image-20240422223715000](http://42.192.130.83:9000/picgo/imgs/image-20240422223715000.png)

Thread select，让Selector去轮询

- **Buffer（缓冲区** 一块内存区域，存储不同类型的数据
- **Channel（通道）** 连接到IO源或目标的开放连接
- **Selector（选择器）**用于实现IO多路复用。它可以**同时监控多个Channel的IO事件**（如可读、可写等），并在事件发生时通知应用程序进行相应的处理。

### [Buffer（缓冲区）](https://javaguide.cn/java/io/nio-basis.html#buffer-缓冲区)

使用 NIO 在**读写数据**时，都是通过**缓冲区**进行操作。

### [Channel（通道）](https://javaguide.cn/java/io/nio-basis.html#channel-通道)

建立了与数据源（如文件、网络套接字等）之间的连接。**自来水管**，让数据在 Channel 中自由流动。

- BIO 中的流是单向的
- NIO Channel（通道）是双向的，全双工的

### [Selector（选择器）](https://javaguide.cn/java/io/nio-basis.html#selector-选择器)

- Selector **轮询注册在其上的 Channel**，一旦有Channel就绪，就立刻处理

### NIO（非阻塞I/O）中主要使用到了反应器模式

反应器模式是一种为处理服务请求并发提交到一个或者多个服务处理程序的事件设计模式。当请求抵达后，服务处理程序使用解多路分配策略，然后同步地派发这些请求至相关的请求处理程序。

在NIO中，Selector（选择器）就是**反应器，它可以同时监听多个Channel（通道）的状态变化**，当某个Channel的状态发生变化时，Selector就会通知对应的处理程序进行处理