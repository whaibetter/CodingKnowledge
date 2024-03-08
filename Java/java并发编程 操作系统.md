[Java并发常见面试题总结（上） | JavaGuide](https://javaguide.cn/java/concurrent/java-concurrent-questions-01.html)

## 并发

### 可重入锁是什么？有什么作用？

**可重入锁（ReentrantLock）是Java中提供的一种同步机制，用于实现对共享资源的线程安全访问**。

可重入锁以线程为单位，当一个线程获取对象锁之后，这个线程可以再次获取本对象上的锁，而其他的线程则不可以。可重入锁的意义在于**防止死锁**，**同一个线程可以多次获取锁，而不会造成死锁。**这使得在某些情况下，可以方便地在一个方法中嵌套调用另一个使用同一个ReentrantLock的方法，而不需要额外的同步操作。



### 进程和线程？

- 进程：程序的基本单位，创建、运行、消亡 **main函数所在线程为进程中主线程**
- 线程：比进程更小的单位
  - 线程**共享进程的堆、方法区**
  - 有各自的计数器、虚拟机栈、方法栈

```java
public static void main(String[] args) {
    // 获取 Java 线程管理 MXBean
    ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
    // 不需要获取同步的 monitor 和 synchronizer 信息，仅获取线程和线程堆栈信息
    ThreadInfo[] threadInfos = threadMXBean.dumpAllThreads(false, false);
    // 遍历线程信息，仅打印线程 ID 和线程名称信息
    for (ThreadInfo threadInfo : threadInfos) {
        System.out.println("[" + threadInfo.getThreadId() + "] " + threadInfo.getThreadName());
    }
}
```

- 输出的各个线程

```
[5] Attach Listener //添加事件
[4] Signal Dispatcher // 分发处理给 JVM 信号的线程
[3] Finalizer //调用对象 finalize 方法的线程
[2] Reference Handler //清除 reference 线程
[1] main //main 线程,程序入口
```

**一个Java程序运行、是main和多个其他线程同时运行**

### Java 线程和操作系统的线程有啥区别？

- **现在的 Java 线程的本质其实就是==操作系统的线程==**。

### 用户线程和内核线程？

- 用户线程：用户空间程序管理调度，**用户空间**、给应用程序使用。
- 内核线程：由操作系统调度，**内核空间、只有内核可以访问**。

### 请简要描述线程与进程的关系,区别及优缺点？

- 一个进程中有多个线程
- 线程私有：
  - **程序计数器**：线程执行位置
  - **虚拟机栈**：局部变量表、操作数栈、常量池引用
  - **本地方法栈**：本地方法栈为 Native 方法服务；其中 Native 方法可以看做用其它语言（C、C++ 或汇编语言等）编写的方法；
- 其他都是公有：
  - **堆**：存对象、栈的引用
  - **元空间（方法区）**：被加载的类信息、常量、静态变量、即编译器编译后的代码
    - **常量池**
  - **直接内存**

![Java 运行时数据区域（JDK1.8 之后）](http://42.192.130.83:9000/picgo/imgs/java-runtime-data-areas-jdk1.8.png)![0559ebc7398a4d688d559bda3876ae13.png](http://42.192.130.83:9000/picgo/imgs/0559ebc7398a4d688d559bda3876ae13.png)

### 程序计数器为什么是私有的?作用？

1. 多线程下记录线程执行位置
2. 改变计数器来进行流程控制，如：顺序执行、选择、循环、异常处理。

程序计数器私有主要是为了**线程切换后能恢复到正确的执行位置**。

### 虚拟机栈和本地方法栈为什么是私有的?作用？

- 虚拟机栈：存储方法的局部变量、操作数栈、动态链接、方法出口等信息。

- 执行流程：

  > 1. 创建时初始化
  > 2. 调用时入栈
  > 3. 在栈内执行完成
  > 4. 返回结果出栈
  > 5. 回收

- 本地方法栈：**Native 方法服务**

区别是：**虚拟机栈为虚拟机执行 Java 方法 （也就是字节码）服务，而本地方法栈则为虚拟机使用到的 Native 方法服务。** 在 HotSpot 虚拟机中和 Java 虚拟机栈合二为一。