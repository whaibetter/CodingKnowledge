[TOC]

## GC

### Java 垃圾回收机制?GC的地方？有什么方法？

- GC 主要关注于 方法区 和堆中的垃圾收集

1. 哪些垃圾要回收？**标记**
   - <mark>引用计数算法</mark>：引用计数器
   - <mark>可达性分析算法</mark>
2. 怎么回收清除？**清除**
   - ==标记-清除==
   - ==复制算法==
   - ==标记-清除-压缩（标记-压缩算法）==

### 有什么垃圾回收算法？优缺点？

#### 方式一：引用计数算法

==每个对象保存一个整型的**引用计数器（记录对象被引用的情况）**==

优点：实现简单、效率高、无延迟，随时可以进行GC

缺点：需要存储空间、**赋值操作**需要时间开销、==无法解决**循环引用**==

p不使用这三个对象，会让这3个对象一直保留，**内存泄露（无法被回收）**

![image-20200712102205795](http://42.192.130.83:9000/picgo/imgs/1367a58058e6653d53afdea83b937af3.png)

#### 方式二：可达性分析算法

- **根对象集合（GCRoots）**为起始点，按照从上至下的方式<mark>搜索被根对象集合所连接的目标对象是否可达</mark>

- 没有任何引用链相连，则是不可达的

![image-20210511195540451](http://42.192.130.83:9000/picgo/imgs/071039dcf30672f55dfe8e5dab5e8081.png)

### 在 Java 语言中，GC Roots 包括哪几类元素？

> - **虚拟机栈**中引用的对象
>   - 比如：各个线程被调用的方法中使用到的参数、局部变量等。
> - **本地方法栈**内 JNI（通常说的本地方法）引用的对象
> - **方法区中类静态属性**引用的对象
>   - 比如：Java 类的引用类型静态变量
> - **方法区中常量引用**的对象
>   - 比如：**字符串常量池（String Table）**里的引用
> - 被同步锁 **synchronized** 持有的对象
> - **Java 虚拟机内部的引用**
>   - **基本数据类型对应的 Class 对象**，一些常驻的异常对象（如：**NullPointerException、OutOfMemoryError**），**系统类加载器**。
> - 反映 java 虚拟机内部情况的 **JMXBean、JVMTI 中注册的回调、本地代码缓存**等。
>
> 除了这些固定的 GC Roots 集合以外，根据用户所选用的垃圾收集器以及当前回收的内存区域不同，还可以有**其他对象“临时性”**地加入，共同构成完整 GC Roots 集合。比如：**分代收集和局部回收（PartialGC）**。==老年代==
>
> 小技巧：由于 Root 采用栈方式存放变量和指针，所以如果一个指针，它保存了堆内存里面的对象，但是自己又不存放在堆内存里面，那它就是一个 Root。

### 虚拟机中的对象可能的三种状态？

1. ==可触及的（*活的*）==：从根节点开始，**可以到达这个对象**。
2. <mark>可复活的（*还未finalize*）</mark>：对象的所有引用都被释放，但是对象有可能在 finalize()中复活。*（刀下留人）*
3. <mark>不可触及的（*已经finalize*）</mark>：对象的 finalize()被调用，并且没有复活，那么就会进入不可触及状态（**这时才能回收**）。不可触及的对象不可能被复活，因为<mark>finalize()只会被调用一次</mark>。

**只有在对象不可触及时才可以被回收。**

#### 具体过程

判定一个对象 objA 是否可回收，至少要经历两次标记过程：

1. 如果对象 objA 到 GC Roots 没有引用链，则进行**第一次标记**。
2. 进行筛选，判断此对象是否有必要执行 finalize()方法
   - 如果对象 objA **没有重写 finalize()**方法，或者 finalize()方法已经被虚拟机调用过，则虚拟机视为“没有必要执行”，objA 被判定为不可触及的（*已经死了*）。
   - 如果对象 objA **重写了 finalize()**方法，且**还未执行过**，那么 objA 会被插入到 **F-Queue 队列**中，由一个虚拟机自动创建的、==**低优先级的 Finalizer 线程**==触发其 finalize()方法执行。
   - <mark>finalize()方法是对象逃脱死亡的最后机会</mark>，稍后 GC 会对 F-Queue 队列中的**对象进行第二次标记**。如果 objA 在 finalize()方法中与引用链上的任何一个对象建立了联系，那么在第二次标记时，objA 会被移出“即将回收”集合。之后，对象会再次出现没有引用存在的情况。在这个情况下，finalize 方法不会被再次调用，对象会直接变成不可触及的状态，也就是说，一个对象的 finalize 方法只会被调用一次。

#### **举例**

```java
public class CanReliveObj {
    // 类变量，属于GC Roots的一部分
    public static CanReliveObj canReliveObj;

    // 此方法只能被调用一次
    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        System.out.println("调用当前类重写的finalize()方法");
        // 复活
        canReliveObj = this;
    }

    public static void main(String[] args) throws InterruptedException {
        canReliveObj = new CanReliveObj();
        canReliveObj = null;
        System.gc();
        System.out.println("-----------------第一次gc操作------------");
        // 因为Finalizer线程的优先级比较低，暂停2秒，以等待它
        Thread.sleep(2000);
        if (canReliveObj == null) {
            System.out.println("obj is dead");
        } else {
            System.out.println("obj is still alive");
        }

        System.out.println("-----------------第二次gc操作------------");
        canReliveObj = null;
        System.gc();
        // 下面代码和上面代码是一样的，但是 canReliveObj却自救失败了
        Thread.sleep(2000);
        if (canReliveObj == null) {
            System.out.println("obj is dead");
        } else {
            System.out.println("obj is still alive");
        }

    }
}
```

运行结果

```
-----------------第一次gc操作------------
调用当前类重写的finalize()方法
obj is still alive
-----------------第二次gc操作------------
obj is dead
```

在第一次 GC 时，执行了 finalize 方法，但 finalize()方法只会被调用一次（在这里复活了），所以第二次该对象被 GC 标记并清除了。

### 清除的算法有哪些？优缺点？适合什么时候使用？

#### 标记清除

1. 根据可达性，**标记有被引用**的对象。
2. Collector 对堆遍历，如果**没有被标记**的清除

缺点：空间不连续，STW，效率

![image-20200712150935078](http://42.192.130.83:9000/picgo/imgs/8ea506a5c45c10410418ff0403e2b3a8.png)

#### 复制算法

- 如栈新生代 S0 S1 区，**将存活对象复制到另一块**

**适合新生代，经常被GC，量不大**

缺点：

1. 两倍空间
2. 改变地址（对于G1意味着**变量指针**也要不断移动｛句柄池｝）
3. 如果存活很多对象，效率不高

#### 标记-压缩-清除算法

1. 根据可达性，**标记有被引用**的对象。
2. 对**活的对象**压缩到一端，顺序排放。
3. 清理边界空间

缺点：碎片整理时间、STW、引用地址变换

![image-20200712153236508](http://42.192.130.83:9000/picgo/imgs/aac06de20fada1a602f1955010bd969d.png)

###  分代收集算法是什么？有什么样的对象适合这样存？

<mark>不同生命周期的对象可以采取不同的收集方式</mark>，以便提高回收效率。

- 生命周期长：<mark>Http 请求中的 Session 对象、线程、Socket 连接</mark>
- 生命周期短：<mark>String 对象</mark>

年轻代（Young Gen）：S0 S1 适合**复制算法**

老年代（Tenured Gen）：由**标记-清除**或者是**标记-清除与标记-整理**的混合实现

### 增量收集算法是什么？

基本思想：==交替执行GC和Application线程==，**逐步收集（慢慢增加的收集）**

==垃圾收集线程只收集一小片区域的内存空间，接着切换到应用程序线程。依次反复，直到垃圾收集完成==

优点：不至于一直STW

缺点：需要进行线程切换



### 指针碰撞（Bump the Pointer）是什么

- 用一个**指针**标记内存应该存放的地方，**一边为占用的，一边为空闲的**

如果内存空间以**规整和有序的方式分布**，即已用和未用的内存都各自一边，彼此之间维系着一个**记录下一次分配起始点的标记指针**，当为**新对象分配内存时，只需要通过修改指针的偏移量将新对象分配在第一个空闲内存位置上**，这种分配方式就叫做指针碰撞（Bump tHe Pointer）。

## GC相关概念

### System.gc()的作用？

- ==提醒GC==，不强制
- `System.runFinalization();` 强制执行使用引用的对象的finalize()方法

在默认情况下，通过 system.gc()或者 Runtime.getRuntime().gc() 的调用，<mark>会显式触发 **Full GC**</mark>，同时**对老年代和新生代进行回收**，尝试释放被丢弃对象占用的内存。

 System.gc() 不能确保立即生效。

```java
public class SystemGCTest {
    public static void main(String[] args) {
        new SystemGCTest();
        System.gc();// 提醒JVM的垃圾回收器执行gc，但是不确定是否马上执行gc
        // 与Runtime.getRuntime().gc();的作用一样

        System.runFinalization();//强制执行使用引用的对象的finalize()方法
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        System.out.println("SystemGCTest 重写了finalize()");
    }
}
```

```java
/**
 * -XX:+PrintGCDetail
 */
public void localvarGc1() {
    byte[] buffer = new byte[10 * 1024 * 1024];
    //10MB
    System.gc(); // 成功回收PSYoungGen，移动到ParOldGen老年代
    /**
     * 新生代 PSYoungGen: 15482K->11192K(152576K 10mb
     * full gc后，移动到老年代 [Full GC (System.gc()) [PSYoungGen: 11192K->0K(152576K)] 0mb  [ParOldGen: 8K->10885K(348160K)]
     * [GC (System.gc()) [PSYoungGen: 15482K->11192K(152576K)] 15482K->11200K(500736K), 0.0059640 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
     * [Full GC (System.gc()) [PSYoungGen: 11192K->0K(152576K)] [ParOldGen: 8K->10885K(348160K)] 11200K->10885K(500736K), [Metaspace: 3210K->3210K(1056768K)], 0.0060621 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
     * Heap
     */
}

public void localvarGc2() {
    byte[] buffer = new byte[10 * 1024 * 1024];
    buffer = null;// 对象已经没被引用，byte[]被回收

    System.gc();
    /**
     * 回收 空余的堆new byte[10 * 1024 * 1024];
     * [GC (System.gc()) [PSYoungGen: 15482K->840K(152576K)] 15482K->848K(500736K), 0.0009380 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
     * [Full GC (System.gc()) [PSYoungGen: 840K->0K(152576K)] [ParOldGen: 8K->645K(348160K)] 848K->645K(500736K), [Metaspace: 3215K->3215K(1056768K)], 0.0043640 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
     */
}

public void localvarGc3() {
    {
        byte[] buffer = new byte[10 * 1024 * 1024];
    }
    System.gc();
    /**
     * - 新生代 10mb
     * [GC (System.gc()) [PSYoungGen: 15482K->11112K(152576K)] 15482K->11120K(500736K), 0.0064283 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]
     * - 进入老年代
     * [Full GC (System.gc()) [PSYoungGen: 11112K->0K(152576K)] [ParOldGen: 8K->10882K(348160K)] 11120K->10882K(500736K), [Metaspace: 3169K->3169K(1056768K)], 0.0041698 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]*/
}

public void localvarGc4() {
    {
        byte[] buffer = new byte[10 * 1024 * 1024];
    }
    int value = 10;
    System.gc();
    /**
     * // 局部变量表长度是2，第一个为this，第二个为value，替换了buffer，所以被回收了
     * [GC (System.gc()) [PSYoungGen: 15482K->904K(152576K)] 15482K->912K(500736K), 0.0006836 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
     * [Full GC (System.gc()) [PSYoungGen: 904K->0K(152576K)] [ParOldGen: 8K->669K(348160K)] 912K->669K(500736K), [Metaspace: 3216K->3216K(1056768K)], 0.0043170 secs] [Times: user=0.00 sys=0.00, real=0.00 secs]
     */
}

public void localvarGc5() {
    localvarGc1();
    System.gc();
}
```

### 内存溢出与内存泄露的区别？什么原因？举例？

> - 内存溢出：无法提供内存；抛出 **OutOfMemoryError** 之前，**==通常==垃圾收集器会被触发**
>
>   - 原因：内存太小，大量大对象(如果对象超过堆最大值，会直接OOM)
>
> - 内存泄露，不用的对象无法被回收
>
>   - **举例**
>
>     1. **单例模式，引用外部对象，外部对象不能被回收。**
>
>        单例的生命周期和应用程序是一样长的，所以单例程序中，如果**持有对外部对象的引用**的话，那么这个外部对象是不能被回收的，则会导致内存泄漏的产生。
>
>        ```java
>        public class MemoryLeak {
>            static List list = new ArrayList();
>            public void oomTests(){
>                Object obj＝new Object();//局部变量，因为list是单例，所以obj不能回收
>                list.add(obj);
>            }
>            public static void clearList() {
>                list.clear(); // 清理后
>            }
>        }
>        
>        // 由于 list 是一个静态成员变量，其生命周期与应用程序的生命周期相同，因此 list 中的对象也会持续存在，直到 list 被显式地清空或程序结束。
>        ```
>     
>     2. 一些提供 **close 的资源未关闭**导致内存泄漏
>     
>        数据库连接（dataSourse.getConnection() ），网络连接（socket）和 io 连接必须**手动 close**，否则是不能被回收的。
>     
>     3. 引用计数算法也会内存泄露，但jvm没有采用
>
> ![右边这里有个指针无法断开，比如忘记close资源](http://42.192.130.83:9000/picgo/imgs/68967cdd14772a749efdb7485950aaa6.png)

### Stop The World 什么时候发生

1. **垃圾回收（Garbage Collection）**：当 JVM 检测到内存不足时，会启动垃圾回收机制来释放不再使用的内存。在进行全局垃圾回收时，会暂停所有的应用线程，以确保垃圾回收器可以安全地执行。
2. **内存压缩（Memory Compaction）**：有些垃圾回收器在执行垃圾回收时可能会进行内存压缩操作，即将存活的对象移动到一起，以便释放出更多的连续内存空间。这也会导致 Stop The World 事件。
3. **类加载、卸载**：当加载或卸载类时，可能会发生 Stop The World 事件。这确保了在加载或卸载期间，应用程序的所有线程都处于一个一致的状态。

### 垃圾回收的串行、并行与并发，优缺点？

- 串行，STW，GC结束后再运行应用
- 并行，多个GC线程**同时执行**
  - 但此时**用户线程仍处于等待状态**。如 ParNew、Parallel Scavenge、Parallel Old；
- 并发，应用线程和GC线程**交替执行**

![image-20210512112822896](http://42.192.130.83:9000/picgo/imgs/fd2b4f4ece3976fbd73c1039666cf7d7.png)

![image-20200712203815517](http://42.192.130.83:9000/picgo/imgs/48a4190f4d2ff4b7c8963a75ba2e6182.png)

**并发（Concurrent）**

（一个厨师同时做多个菜）

在操作系统中，是指一个时间段中有几个程序都处于已启动运行到运行完毕之间，且这几个程序都是在同一个处理器上运行。

![image-20200712202522051](https://img-blog.csdnimg.cn/img_convert/5e4a10263a26cb7aa87f1a6615b5b833.png)

**并行（Parallel）**，多线程并行同时执行。

（多个厨师）

当系统有一个以上 CPU 时，当一个 CPU 执行一个进程时，另一个 CPU 可以执行另一个进程，两个进程互不抢占 CPU 资源，可以同时进行，我们称之为并行（Parallel）。

![image-20200712202822129](https://img-blog.csdnimg.cn/img_convert/7ea1ebdd0fd0bc3a27c0d745c9bcdff7.png)

**并发 vs 并行**

- 并发，指的是多个事情，在<mark>同一时间段内</mark>同时发生了。
- 并行，指的是多个事情，在<mark>同一时间点上</mark>同时发生了。

- 并发的多个任务之间是互相抢占资源的。
- 并行的多个任务之间是不互相抢占资源的。

- 只有在多 CPU 或者一个 CPU 多核的情况中，才会发生并行。
- 否则，看似同时发生的事情，其实都是并发执行的。

### 安全点与安全区域是什么？

==理解为在此刻、或时间段，对象不会有变化，GC很安全==

- 安全点：==特定的时间点（安全点）才能停下来GC==
- 安全区域：安全区域是指在一段代码片段中，**对象的引用关系不会发生变化**，在**这个区域中的任何位置开始 Gc 都是安全的**。==在区域内对象引用关系不会变化==

### 什么是强软弱虚？具体使用场景是什么？

> - 强：**引用，不回收**，`Object obj = new Object()`
>   - 不会被回收。==强引用是造成 Java 内存泄漏的主要原因之一==
> - 软：**内存不足时**，将会把这些对象**列入回收范围之中**进行第二次回收。
>   - 大对象，释放内存。<mark>高速缓存</mark>就有用到软引用，Mybatis缓存。
> - 弱：**下次GC就被清除**，只能生存到下一次垃圾收集之前。
> - 虚：**对象回收跟踪**。虚引用不能单独使用，必须和引用队列（ReferenceQueue）一起使用。