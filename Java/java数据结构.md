![java集合树状结构及源码_WolfArya的博客-CSDN博客](http://42.192.130.83:9000/picgo/imgs/OIP-C.8Njndz_T_ouyYaCIQ9VMngHaFk)

![Java 集合框架概览](http://42.192.130.83:9000/picgo/imgs/java-collection-hierarchy.png)

![Java 集合框架概览](http://42.192.130.83:9000/picgo/imgs/java-collection-hierarchy.png)
## 集合核心接口

- List：ArrayList、LinkedList
- Set：HashSet、TreeSet
- Queue：LinkedList、PriorityQueue
- Deque：Queue的子类
- Map：HashMap、TreeMap

Iterator：迭代器，可以通过迭代器遍历集合中的数据

## fail-fast机制是什么？

- Iterator迭代过程中进行了修改（增加、删除），则会抛出**Concurrent Modification Exception**（并发修改异常）

例如，**在使用 `Iterator` 迭代器遍历集合时，如果在遍历的过程中直接调用了集合的 `add()`、`remove()` 等方法来修改集合的结构，而不是通过迭代器提供的 `remove()` 方法**，就有可能抛出 `ConcurrentModificationException` 异常。

单线程环境下也可能触发Fail-fast机制。例如，当使用foreach遍历集合时，如果同时对该集合进行结构性修改（如添加或删除元素），就会抛出ConcurrentModificationException异常。这是因为foreach遍历实际上是通过迭代器实现的，而迭代器在遍历过程中会检查集合的结构是否发生了变化。如果检测到变化，就会抛出异常。

```java
当不允许对对象进行并发修改时，检测到对象并发修改的方法可能会引发此异常。
例如，通常不允许一个线程修改一个集合，而另一个线程正在循环访问它。通常，在这些情况下，迭代的结果是未定义的。如果检测到此行为，某些迭代器实现（包括 JRE 提供的所有通用集合实现的实现）可能会选择引发此异常。这样做的迭代器被称为 快速失败 迭代器，因为它们会快速而干净地失败，而不是冒着在未来不确定时间出现任意、非确定性行为的风险。
请注意，此异常并不总是指示对象已被 其他 线程并发修改。如果单个线程发出一系列违反对象约定的方法调用，则该对象可能会引发此异常。例如，如果线程在使用快速失败迭代器循环访问集合时直接修改集合，则迭代器将引发此异常。
请注意，不能保证快速故障行为，因为一般来说，在存在不同步并发修改的情况下，不可能做出任何硬性保证。快速失败的操作是在尽最大努力的基础上进行的 ConcurrentModificationException 。因此，编写一个依赖于此异常的程序的正确性是错误的： ConcurrentModificationException 应该仅用于检测错误。
public class ConcurrentModificationException extends RuntimeException {
    private static final long serialVersionUID = -3666751008965953603L;
```

解决 `ConcurrentModificationException` 异常的常见方法包括：

1. **使用迭代器自身的方法进行操作：** 在使用迭代器遍历集合时，应该只使用迭代器提供的方法来进行操作，如 `remove()` 方法，而不是直接操作集合本身。
2. **使用并发集合类：** Java 中提供了一些线程安全的并发集合类，如 `ConcurrentHashMap`、`CopyOnWriteArrayList` 等，它们可以在迭代时允许并发修改，不会抛出 `ConcurrentModificationException` 异常。
3. **使用同步机制：** 在多线程环境下，可以使用同步机制来保护集合的访问，例如使用 `synchronized` 关键字或者 `ReentrantLock` 锁来确保在修改集合时的线程安全性。

## 红黑树的结构与性质？作用是什么？

![OwRV5xB6l5](http://42.192.130.83:9000/picgo/imgs/OwRV5xB6l5.png)![img](http://42.192.130.83:9000/picgo/imgs/v2-39965fba3e7e0ceea2deba09a0446348_720w.webp)

1. 节点是红色或黑色。
2. 根是黑色。
3. 所有叶子都是黑色（叶子是NIL节点）。
4. 每个红色节点必须有两个黑色的子节点。（从每个叶子到根的所有路径上不能有两个连续的红色节点。）
5. 从任一节点到其每个叶子的所有**简单路径**都包含**相同数目的黑色节点**（简称黑高）。

作用：

- 可避免二叉查找树退化成单链表的情况。

- **最长路径不超过最短路径的两倍（高度近似logn）：** 由于性质 5，红黑树中任意一个节点到其叶子节点的最长路径不会超过最短路径的两倍，这确保了**树的高度**近似为 log(n)，其中 n 是树中节点的数量。

  *当某条路径最短时，这条路径必然都是由**黑色节点**构成。当某条**路径长度最长**时，这条路径必然是由红色和黑色节点相间构成（性质4限定了不能出现两个连续的红色节点）。而性质5又限定了从任一节点到其每个叶子节点的所有路径必须包含相同数量的黑色节点。*

- **插入和删除操作的复杂度为 O(log n)：** 由于红黑树的平衡性，插入和删除操作的最坏情况复杂度为 O(log n)，这使得红黑树非常适合于动态数据结构中的插入和删除操作。

- **查找操作的复杂度为 O(log n)：** 由于红黑树是一种二叉查找树，查找操作的时间复杂度为 O(log n)，其中 n 是树中节点的数量。

## ArrayList

[ArrayList javaGuide  源码解读](https://javaguide.cn/java/collection/arraylist-source-code.html#arraylist-%E6%A0%B8%E5%BF%83%E6%BA%90%E7%A0%81%E8%A7%A3%E8%AF%BB)

### ArrayList底层结构？优缺点？

- 底层为：可扩容数组即**动态数组**

```java
  public class ArrayList<E> extends AbstractList<E>
          implements List<E>, RandomAccess, Cloneable, java.io.Serializable
      // RandomAccess 是一个标记接口，用来表明实现该接口的类支持随机访问
```

 ```java
      /**
  存储数组列表元素的数组缓冲区。数组列表的容量是此数组缓冲区的长度。添加第一个元素时，任何带有 elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA 的空 ArrayList 都将扩展到 DEFAULT_CAPACITY=10
       */
      transient Object[] elementData; 
 ```

- 新建为空，第一个插入容量变为10
- 优点：遍历查找快
- 缺点：插入删除慢，需要移动元素

### ArrayList扩容机制

- `new ArrayList `容量为0，插入一个才会变成10

当数组大小不满足时需要增加存储能力，就要将已经有数组的数据**复制到新的存储空间**中。

==**ArrayList扩容后的数组长度会增加50% `number >> 1 `**== 

```java
/**
 * 默认初始容量大小
 */
private static final int DEFAULT_CAPACITY = 10;

private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

/**
 * 默认构造函数，使用初始容量10构造一个空列表(无参数构造)
 */
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}


private void grow(int minCapacity) {
 // overflow-conscious code ArrayList
 int oldCapacity = elementData.length;
// 1010(10)----右移1位---> 0101(5)
// 将oldCapacity 右移一位，其效果相当于oldCapacity /2，
// 我们知道位运算的速度远远快于整除运算，整句运算式的结果就是将新容量更新为旧容量的1.5倍，
 int newCapacity = oldCapacity + (oldCapacity >> 1);
 if (newCapacity - minCapacity < 0)
     newCapacity = minCapacity;
 if (newCapacity - MAX_ARRAY_SIZE > 0)
     newCapacity = hugeCapacity(minCapacity);
 // minCapacity is usually close to size, so this is a win:
 elementData = Arrays.copyOf(elementData, newCapacity);
}
```

### ArrayList修改为线程安全的？

- 变为SynchronizedList

```java
List list = Collections.synchronizedList(List<T> list)
```

### ArrayList可以加null吗？

- 数组是可以add null的，那ArrayList是可以add null的

```java
Object[] ints = new Object[]{null, null, null};
```

###  ArrayList 和 Array（数组）的区别？

- `ArrayList` 内部基于动态数组实现，比 `Array`（静态数组） 使用起来更加灵活：
- 动态扩容
- `ArrayList` 只能存储对象，不能存储基本数据类型
- `ArrayList` 不用指定大小

### ArrayList插入删除时间复杂度

- 头插On 尾插 O1
- 头删 On 尾删 O

## LinkedList

### LinkedList底层结构？优缺点？特点？

- 链表结构存储数据的

  ```java
  private static class Node<E> {
      E item;
      Node<E> next;
      Node<E> prev;
      Node(Node<E> prev, E element, Node<E> next) {
          this.item = element;
          this.next = next;
          this.prev = prev;
      }
  }
  ```

- 优点：专门用于操作**表头和表尾**元素，可以用做队列、堆栈使用。
- 缺点：随机遍历慢
- 特点：线程不安全 `Collections.synchronizedList` 

### LinkedList可以加null吗？

- 可以，没有对null做特殊处理

```java
/**
 * Links e as last element.
 */
void linkLast(E e) {
    final Node<E> l = last;
    final Node<E> newNode = new Node<>(l, e, null);
    last = newNode;
    if (l == null)
        first = newNode;
    else
        l.next = newNode;
    size++;
    modCount++;
}
```

### ArrayList和LinkedList的区别

- 底层数据结构不同，一个使用Object数组，一个使用链表（JDK1.6 之前为**循环链表**，JDK1.7 后为**双向链表**）
- ArrayList扩容机制为扩容1.5
- 性能：ArrayList支持随机访问，删除、插入都效率不高；LinkedList删除、插入效率高（插入到尾巴），访问遍历慢。
- 存储占用：ArrayList列表尾会预留一定空间，LinkedList每个元素都会消耗更多空间。

`ArrayList` ，性能通常会更好。

## LinkedList插入删除查找时间复杂度

- 指定位置插入/删除 On 主要查找
- 指定位置插入/删除 On 主要查找

## Vector

### Vector的底层实现？特点。

- 底层同ArrayList为数组，新建就容量10
- **线程安全**，简单粗暴加了锁
- 优点：线程安全，随机访问的形式，尾插尾删除效率高，空间利用率高。
- 缺点：头部位置的插入、删除效率低，扩容 double有消耗。

### Vector的扩容机制

==复制到新的存储空间中   扩容长度后数组会 double==

```java
private void grow(int minCapacity) {
// overflow-conscious code Vector加一倍
int oldCapacity = elementData.length;
int newCapacity = oldCapacity + ((capacityIncrement > 0) ?
                               capacityIncrement : oldCapacity);
if (newCapacity - minCapacity < 0)
  newCapacity = minCapacity;
if (newCapacity - MAX_ARRAY_SIZE > 0)
  newCapacity = hugeCapacity(minCapacity);
elementData = Arrays.copyOf(elementData, newCapacity);
}
```

### Vector和ArrayList的区别

1. **线程安全性**
2. **性能**
3. **初始容量**：Vector在创建对象时，会直接初始化容量为10，而ArrayList在第一次调用add方法时，才会初始化容量为10。
4. **扩容倍数**：Vector扩容每次增加1倍，而ArrayList每次扩充0.5倍。

## Stack 

### Stack底层结构

```java
public class Stack<E> extends Vector<E> 
```

### Stack对比Vector

- **存储方式**：Stack是**后进先出（LIFO）**的数据结构，只能从栈顶存取数据；Vector是连续存储结构，每个元素在内存上是连续的，支持高效的随机访问和在尾端插入/删除操作。
- **效率**：Vector支持随机访问。
- **扩展**：Stack来自于Vector

## HashSet

### HashSet底层结构

- HashMap key的唯一性，value为空Object，大部分方法都来自于HashMap

  ```java
  /**
   * Constructs a new, empty set; the backing <tt>HashMap</tt> instance has
   初始容量16 加载因子0.75
   * default initial capacity (16) and load factor (0.75).
   */
  public HashSet() {
      map = new HashMap<>();
  }
  
  ```

  ![给面试官讲解hashmap底层原理后，他表示很看好我 | w3c笔记](http://42.192.130.83:9000/picgo/imgs/1597914836534882.png)

## TreeSet

### TreeSet底层结构？特点？

- 基于TreeMap-->基于二叉红黑树

```java
public class TreeSet<E> extends AbstractSet<E>
    implements NavigableSet<E>, Cloneable, java.io.Serializable
```

- 支持自然排序，定制排序。

## LinkHashSet

### LinkedHashSet底层结构

- 继承自HashSet+LinkedHashMap，保存了记录的插入顺序

```java
/**
 * Constructs a new, empty linked hash set with the default initial
 * capacity (16) and load factor (0.75).
 */
public LinkedHashSet() {
    super(16, .75f, true);
}
// HashSet父类
HashSet(int initialCapacity, float loadFactor, boolean dummy) {
        map = new LinkedHashMap<>(initialCapacity, loadFactor);
}
```

### 比较 HashSet、LinkedHashSet 和 TreeSet 三者的异同

同：线程不安全

异：

- TreeSet带排序
- **底层结构：** HashSet基于HasMap；TreeSet基于TreeMap红黑树；LinkedHashSet基于HashSet+LinkedHashMap （链表和哈希表）
- 适用场景：HashSet不指定顺序，TreeMap指定顺序，LinkedHashSet满足FIFO

![（68）TreeSet练习：两种排序方式：自然排序（实现comparable接口）、比较器_FixedStarHaHa的博客-CSDN博客](https://tse3-mm.cn.bing.net/th/id/OIP-C.riLlcRbjuU5LG3Q82XRKewHaEK?pid=ImgDet&rs=1)

![面试官：如何用LinkedHashMap实现LRU_zy353003874的博客-CSDN博客](http://42.192.130.83:9000/picgo/imgs/aHR0cHM6Ly91cGxvYWQtaW1hZ2VzLmppYW5zaHUuaW8vdXBsb2FkX2ltYWdlcy8xMjQ2MzUxLTU1MjZmNmZhNzI5ZTk4N2M)



## HashMap

### HashMap为什么线程不安全？

- HashMap的内部实现不提供同步机制，即没有对多线程访问进行并发控制。**多个线程同时对HashMap进行修改操作（插入、删除、更新等），可能会导致数据结构的破坏和不一致性。**
- fail-fast：在迭代过程中有其他线程对HashMap进行修改，可能会导致ConcurrentModificationException异常或遗漏元素
- 当**多个线程put到同一个桶**可能会被覆盖

### HashMap结构

![给面试官讲解hashmap底层原理后，他表示很看好我 | w3c笔记](http://42.192.130.83:9000/picgo/imgs/1597914836534882.png)

- Java7 没有使用红黑树

![Java7](http://42.192.130.83:9000/picgo/imgs/r7ZADaG3Ke.png)

> 关键参数：
>
> 1. capacity：初始为16，当前数组容量，始终保持 2^n，可以扩容，扩容后数组大小为当前的 2 倍。
> 2. loadFactor：负载因子，默认为 0.75。
> 3. threshold阈值：扩容的阈值，等于 capacity * loadFactor
>
> 特点：
>
> - 数组+链表
> - 元素个数超过threshold对数组扩容

### Java8 的HashMap实现特点？优点？

> 数组+链表+红黑树
>
> ![OwRV5xB6l5](http://42.192.130.83:9000/picgo/imgs/OwRV5xB6l5.png)
>
> - 当前**数组的长度小于 64，那么会选择先进行数组扩容**，而不是转换为红黑树
> - 当**链表长度大于阈值（默认为 8）**时，将链表转化为红黑树，以减少搜索时间。

###  HashMap 的长度为什么是 2 的幂次方

为了能让 HashMap 存取高效，尽量较少碰撞，也就是要尽量把数据分配均匀。

- **数组下标计算**：`(n - 1) & hash`（n 代表数组长度）

  ```java
  if ((p = tab[i = (n - 1) & hash]) == null)
              tab[i] = newNode(hash, key, value, null);
  ```

- 更快计算hash，哈希值是一个整数，当我们将一个整数除以一个素数时，计算哈希值的效率会更高。

- 设计数组位置的算法

  > 取余 `(n - 1)%hash` 就能获取到位置
  >
  > - 与(&)操作有着更高的效率。
  >
  > - **hash%length==hash&(length-1)的前提是 length 是 2 的 n 次方**
  >
  >   ```java
  >   System.out.println(7%4); // hash%length
  >   System.out.println(7&3); // hash&(length-1) 111&011 011 &：相同为1
  >   ```

### HashMap 多线程操作导致死循环问题，怎么解决？

- JDK1.7 及之前，由于当一个桶元素过多，需要进行扩容时。多个线程同时对链表进行操作，**头插法可能会导致链表中的节点指向错误的位置**，从而**形成一个环形链表**，进而使得查询元素的操作陷入死循环无法结束。

- **解决方法**：JDK1.8 版本的 HashMap **采用了尾插法**而不是头插法来避免链表倒置，使得插入的节点永远都是放在链表的末尾，避免了链表中的环形结构。

但是还是不建议在多线程下使用 `HashMap`，因为多线程下使用 `HashMap` 还是会存在数据覆盖的问题。并发环境下，**推荐使用 `ConcurrentHashMap` 。**

[Java HashMap 的死循环open in new window](https://coolshell.cn/articles/9606.html)。

### HashMap 常见的遍历方式?

[HashMap 的 7 种遍历方式与性能分析！](https://mp.weixin.qq.com/s/zQBN3UvJDhRTKP6SzcZFKw)

- iterator **entry**、keyset

- foreach  **entry**、keyset

- lambda

- 单线程 多线程遍历 `map.entrySet().stream().forEach`

  ![效率最高的是entryset](https://mmbiz.qpic.cn/mmbiz_png/HrWw6ZuXCsgeYXAj2Uedoee2ibmnwMYLeaIRiatjtU387kxT68GwIsktTRnlgIvQdQIrH9WZtenTCMl1sVF1JNOA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

## ConcurrentHashMap

> 插入操作时
>
> 1. 乐观锁循环进入
> 2. 是否初始化
>    - 判断Hash位置**是否为空**，为空使用CAS插入Node（初始化）
>    - 判断**是否扩容**，helpTransfer
>    - 都不是，加syncronized锁，找到hash，循环判断
>
> 获取
>
> - volatile保证最新

- volatile

```java
//ConcurrentHashMap使用volatile修饰节点数组，保证其可见性，禁止指令重排。
transient volatile Node<K,V>[] table;
```

```java
final V putVal(K key, V value, boolean onlyIfAbsent) {
    if (key == null || value == null) throw new NullPointerException();
    int hash = spread(key.hashCode());
    int binCount = 0;
    // 情商高的就会说，这是一个乐观锁
    for (Node<K,V>[] tab = table;;) {
        Node<K,V> f; int n, i, fh;
        if (tab == null || (n = tab.length) == 0)
            tab = initTable(); // 初始化
        else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
            // CAS比较
            if (casTabAt(tab, i, null,
                         new Node<K,V>(hash, key, value, null)))
                break;                   // no lock when adding to empty bin
        }
        else if ((fh = f.hash) == MOVED) // 正在扩容中
            tab = helpTransfer(tab, f);
        else {
            V oldVal = null;
            synchronized (f) {
                if (tabAt(tab, i) == f) {
                    if (fh >= 0) {
                        binCount = 1;
                        // 找到了链表
                        for (Node<K,V> e = f;; ++binCount) {
                            K ek;
                            // 找到了hash和key相同的节点，更新
                            if (e.hash == hash &&
                                ((ek = e.key) == key ||
                                 (ek != null && key.equals(ek)))) {
                                oldVal = e.val;
                                if (!onlyIfAbsent)
                                    e.val = value;
                                break;
                            }
                            Node<K,V> pred = e;
                            if ((e = e.next) == null) {
                                pred.next = new Node<K,V>(hash, key,
                                                          value, null);
                                break;
                            }
                        }
                    }
                    else if (f instanceof TreeBin) {
                        Node<K,V> p;
                        binCount = 2;
                        if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                       value)) != null) {
                            oldVal = p.val;
                            if (!onlyIfAbsent)
                                p.val = value;
                        }
                    }
                }
            }
            if (binCount != 0) {
                if (binCount >= TREEIFY_THRESHOLD)
                    treeifyBin(tab, i);
                if (oldVal != null)
                    return oldVal;
                break;
            }
        }
    }
    addCount(1L, binCount);
    return null;
}
```

### concurrenthashmap，为什么1.7用reentrantlock，1.8用CAS+synchronized?

使用了CAS（Compare and Swap）操作和`synchronized`关键字的组合来实现并发控制。

**使用CAS和`synchronized`的组合在一些场景下可以提供更高的性能，因为CAS操作不需要线程进入阻塞状态。**

### 1.8之前的ConcurrentHashMap结构

- 分为多个段Segment存储（默认Segment数组大小为16，即支持最高16个并发读写），给每个Segment分锁；

  `static class Segment<K,V> extends ReentrantLock implements Serializable`

  Segment为一个HashEntry[]，HashEntry为一个链表

- 使用了`HashEntry`存储键值对


![Java7 ConcurrentHashMap 存储结构](http://42.192.130.83:9000/picgo/imgs/java7_concurrenthashmap.png)

![HashMap与ConcurrentHashMap 详解_majiawenzzz的博客-CSDN博客](http://42.192.130.83:9000/picgo/imgs/R-C.a563133d1a574eb72848fe278e5d2af0)

### 1.8之后的ConcurrentHashMap结构

- 基本结构为HashMap的**Node数组+红黑树+链表**实现，链表长度超过一定阈值（8）时将链表转为红黑树。
- ConcurrentHashMap 使用了轻量级锁（Lightweight Locking）技术来提高并发性能
- 采用 `Node + CAS + synchronized` 来保证并发安全。
  - 使用 synchronized 锁住链表头结点，因为单向链表的操作都是从头结点开始，所以也就锁住了整条链表。


![Java8 ConcurrentHashMap 存储结构](http://42.192.130.83:9000/picgo/imgs/java8_concurrenthashmap.png)

### JDK 1.7 和 JDK 1.8 的 ConcurrentHashMap 实现有什么不同？

- **线程安全的实现方式：**JDK1.7 采用 基于ReentranLock的Segment 分段锁保证安全。JDK1.8采用**CAS** Node synchronized保证线程安全，粒度更细。

  在CAS操作中，线程首先比较节点的**前驱节点和期望的前驱节点**是否相同，如果相同则更新后继节点，否则重新尝试。

- **Hash碰撞解决**，拉链法、红黑树。

- **最大并发数：**Segment数组默认16，1.8最大是Node数组大小。

> 从 JDK1.7 版本的 ReentrantLock+Segment+HashEntry，到 JDK1.8 版本中 synchronized+CAS+HashEntry + 红黑树。
>
> 1. 数据结构：取消了 Segment 分段锁的数据结构，取而代之的是数组 + 链表 + 红黑树的结构。
> 2. 保证线程安全机制：JDK1.7 采用 segment 的分段锁机制实现线程安全，其中 segment 继承自 ReentrantLock。JDK1.8 采用 CAS+Synchronized 保证线程安全。
> 3. 锁的粒度：原来是对需要进行数据操作的 Segment 加锁，现调整为对每个数组元素加锁（Node）。
> 4. 链表转化为红黑树：定位结点的 hash 算法简化会带来弊端，Hash 冲突加剧，因此在链表节点数量大于 8 时，会将链表转化为红黑树进行存储。
> 5. 查询时间复杂度：从原来的遍历链表 O (n)，变成遍历红黑树 O (logN)。

### ConcurrentHashMap 为什么 key 和 value 不能为 null？

- **key**：避免二义性，是没有这个key还是key为null
- **value**：get(key)为null 是没有这个kv存在：value为null

```java
   final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
```



### 为什么HashTable ConcurrentHashMap线程安全集合不可以有null的值，HashMap可以有？

**并发场景的歧义问题**

- 一个线程边操作，一个线程修改，contains(key)失效，无法判断是没有这个值还是还是值就是null
  - **多线程下无法正确判定键值对是否存在`contains(key)`（另一个线程在`put(key,null)`时，返回true，期望是false）**，单线程是可以的（不存在其他线程修改的情况）
  - **HashMap是设计给单线程的**，null值可以正常执行Hash和冲突，不能同时null null
  - 如果要使用null 可以用`public static final Object NULL = new Object();`



###  ConcurrentHashMap 能保证复合操作的原子性吗？那如何保证 `ConcurrentHashMap` 复合操作的原子性呢？

- 单个操作原子性!=复合操作原子性
- `putIfAbsent`、`compute`、`computeIfAbsent` 、`computeIfPresent`、`merge`

## LinkedHashMap

### LinkedHashMap有什么特点？

![面试官：如何用LinkedHashMap实现LRU_zy353003874的博客-CSDN博客](http://42.192.130.83:9000/picgo/imgs/aHR0cHM6Ly91cGxvYWQtaW1hZ2VzLmppYW5zaHUuaW8vdXBsb2FkX2ltYWdlcy8xMjQ2MzUxLTU1MjZmNmZhNzI5ZTk4N2M)

- 保存了记录的插入顺序
- 使用父类HashMap的方法操作数据
- 使用LinkedList维护插入元素的先后顺序

```java
public class LinkedHashMap<K,V>
    extends HashMap<K,V>
```

### LinkedHashMap如何实现有序？

- **在Node基础上，增加Entry，通过维护一个运行于所有条目的双向链表，LinkedHashMap保证了元素迭代的顺序，该迭代顺序可以是插入顺序或者是访问顺序。**

  输出的时候根据链表顺序输出

  ```java
  // H
  static class Node<K,V> implements Map.Entry<K,V> {
          final int hash;
          final K key;
          V value;
          Node<K,V> next;
  }
  
  /**
   * HashMap.Node subclass for normal LinkedHashMap entries.
   */
  static class Entry<K,V> extends HashMap.Node<K,V> {
      Entry<K,V> before, after;
      Entry(int hash, K key, V value, Node<K,V> next) {
          super(hash, key, value, next);
      }
  }
      
  /**
   * The head (eldest) of the doubly linked list.
   */
  transient LinkedHashMap.Entry<K,V> head;
  
  /**
   * The tail (youngest) of the doubly linked list.
   */
  transient LinkedHashMap.Entry<K,V> tail;
  ```
  
  

## HashTable

- 特点：线程安全

```java
public class Hashtable<K,V>
    extends Dictionary<K,V>
    implements Map<K,V>, Cloneable, java.io.Serializable 
```

## Queue

###  Queue 与 Deque 的区别

- Queue单端队列；Deque双端队列。

###  ArrayDeque 与 LinkedList 的区别

同：

- `ArrayDeque` 和 `LinkedList` 都实现了 `Deque` 接口

**异：**

- `ArrayDeque` 基于数组（初始化16），LinkedList基于链表.
- `ArrayDeque` 不支持存储 `NULL` 数据，但 `LinkedList` 支持
- `ArrayDeque` 有扩容的过程。
- `ArrayDeque` 可以用于实现栈（单端队列）

### PriorityQueue的结构

- `PriorityQueue` 利用了**二叉堆的数据结构**来实现的，底层使用可变长的数组来存储数据

  > 数组为[0,1,3,4,2,8,7,6,5,9]
  >
  > ![优先队列（PriorityQueue）常用方法及简单案例_little_fat_sheep的博客-CSDN博客_priorityqueue的方法](http://42.192.130.83:9000/picgo/imgs/20190831154010523.png)

- 出队顺序是与**优先级**相关的

### 什么是 BlockingQueue

- BlockingQueue（阻塞队列）是一个接口，继承自 Queue

## CopyOnWriteArrayList

### CopyOnWriteArrayList 到底有什么厉害之处？有什么优缺点？

- `CopyOnWriteArrayList` 线程安全的核心在于其采用了 **写时复制（Copy-On-Write）** 的策略

> 优点：读操作不加锁，性能很好。读读不冲突
>
> 缺点：
>
> 1. 内存占用，每次copy
> 2. 写开销，同上
> 3. 数据一致性：写操作不会立刻生效

## modCount的作用？

ArrayList,LinkedList,HashMap等等的内部实现增，删，改中我们总能看到modCount的身影，modCount字面意思就是修改次数，但为什么要记录modCount的修改次数呢？

只有在**本数据结构对应迭代器**中才使用。**检查哈希表是否在遍历过程中被修改，被修改就抛出ConcurrentModificationException**

- 以HashMap为例

```java
/**
此 HashMap 在结构上被修改的次数 结构修改是那些更改 HashMap 中的映射数量或以其他方式修改其内部结构（例如，重新散列）的修改。此字段用于使 HashMap 的 Collection-views 上的迭代器快速失败。（请参阅 ConcurrentModificationException）。
*/
transient int modCount;
```

```java
abstract class HashIterator {
    Node<K,V> next;        // next entry to return
    Node<K,V> current;     // current entry
    int expectedModCount;  // for fast-fail
    int index;             // current slot


    final Node<K,V> nextNode() {
        Node<K,V>[] t;
        Node<K,V> e = next;
        // 检查哈希表是否在遍历过程中被修改。
        // 判断 modCount 跟 expectedModCount 是否相等，如果不相等就表示已经有其他线程修改了 
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
        if (e == null)
            throw new NoSuchElementException();
        if ((next = (current = e).next) == null && (t = table) != null) {
            do {} while (index < t.length && (next = t[index++]) == null);
        }
        return e;
    }

    public final void remove() {
        Node<K,V> p = current;
        if (p == null)
            throw new IllegalStateException();
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
        current = null;
        removeNode(p.hash, p.key, null, false, false);
        expectedModCount = modCount;
    }
}
```

## other

### 为什么HashMap使用红黑树不使平衡树？

红黑树作为一种自平衡二叉搜索树，具有较好的平衡性能，保证了在最坏情况下的查找、插入和删除操作的时间复杂度为 O(log N)。相比之下，**平衡树（如 AVL 树）虽然也具有良好的平衡性能，但在插入和删除操作时可能需要更多的旋转操作，导致性能的略微下降**。

### 说说有哪些常见的集合框架？

Java 集合框架可以分为两条大的支线：

①、Collection，主要由 List、Set、Queue 组成：

- List 代表有序、可重复的集合，典型代表就是封装了动态数组的 [ArrayList](https://javabetter.cn/collection/arraylist.html) 和封装了链表的 [LinkedList](https://javabetter.cn/collection/linkedlist.html)；
- Set 代表无序、不可重复的集合，典型代表就是 HashSet 和 TreeSet；
- Queue 代表队列，典型代表就是双端队列 [ArrayDeque](https://javabetter.cn/collection/arraydeque.html)，以及优先级队列 [PriorityQueue](https://javabetter.cn/collection/PriorityQueue.html)。

②、Map，代表键值对的集合，典型代表就是 [HashMap](https://javabetter.cn/collection/hashmap.html)。

![二哥的 Java 进阶之路：Java集合主要关系](http://42.192.130.83:9000/picgo/imgs/gailan-01.png)

### ArrayList 怎么序列化的知道吗？  ArrayList 怎么序列化呢？

```java
/**
存储数组列表元素的数组缓冲区。数组列表的容量是此数组缓冲区的长度。添加第一个元素时，任何带有 elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA 的空 ArrayList 都将扩展到 DEFAULT_CAPACITY。
 */
transient Object[] elementData; // non-private to simplify nested class access
```

#### 为什么最 ArrayList 不直接序列化元素数组呢？

出于效率的考虑，数组可能长度 100，但实际只用了 50，剩下的 50 不用其实不用序列化，这样可以提高序列化和反序列化的效率，还可以节省内存空间。

#### **那 ArrayList 怎么序列化呢？**

ArrayList 通过两个方法**readObject、writeObject**自定义序列化和反序列化策略，实际直接使用两个流`ObjectOutputStream`和`ObjectInputStream`来进行序列化和反序列化。

![ArrayList自定义序列化](http://42.192.130.83:9000/picgo/imgs/collection-6.png)

### 快速失败(fail-fast)和安全失败(fail-safe)了解吗？

**快速失败（fail—fast）**：快速失败是 Java 集合的一种错误检测机制

- 在用迭代器遍历一个集合对象时，如果线程 A 遍历过程中，线程 B 对集合对象的内容进行了修改（增加、删除、修改），则会抛出 Concurrent Modification Exception。
- **原理：** iterator遍历过程中使用一个 `modCount` 变量，在遍历时 `hasNext/next `检查`modCount `变量是否为` expectedmodCount` 值
- 场景：java.util 包下的集合类都是快速失败的，不能在多线程下发生并发修改（迭代过程中被修改），比如 ArrayList 类。

**==安全==失败（fail—safe）**

- 采用安全失败机制的集合容器，在遍历时不是直接在集合内容上访问的，而是先复制原有集合内容，**在拷贝的集合上进行遍历**。
- 不会触发 Concurrent Modification Exception。
- 缺点：Iterator只能获取修改前的集合拷贝
- 场景：java.util.concurrent 包下的容器都是安全失败，可以在多线程下并发使用，并发修改，比如 CopyOnWriteArrayList 类。

### CopyOnWriteArrayList 了解多少？

`CopyOnWrite`——写时复制

允许并发读，读操作是无锁的，性能较高。

写操作，**加syncronized写**， 比如向容器中添加一个元素，则首先将当前容器复制一份，然后在新副本上执行写操作，结束之后再将原容器的引用指向新容器。

```java
public boolean add(E e) {
    synchronized (lock) {
        Object[] es = getArray();
        int len = es.length;
        es = Arrays.copyOf(es, len + 1);
        es[len] = e;
        setArray(es);
        return true;
    }
}
```

![CopyOnWriteArrayList原理](http://42.192.130.83:9000/picgo/imgs/collection-7.png)

### 红黑树了解多少？为什么不用二叉树/平衡树呢？

1. 红或黑
2. 根叶都是黑（叶子为null）
3. 红节点的子节点一定为黑
4. 所有路径红黑数量相同

![红黑树](http://42.192.130.83:9000/picgo/imgs/collection-9.png)

之所以不用二叉树：不平衡，极端场景

之所以不用平衡二叉树：旋转消耗大

### HashMap 的 hash 函数是怎么设计的?

HashMap 的哈希函数是先拿到 key 的 hashcode，是一个 32 位的 int 类型的数值，然后让 hashcode 的高 16 位和低 16 位进行异或操作。

```java
static final int hash(Object key) {
    int h;
    // key的hashCode和key的hashCode右移16位做异或运算
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

这么设计是为了降低哈希碰撞的概率。

```java
int c = this.hashCode();
System.out.println(c);
System.out.println((c >>> 16));
System.out.println((c & (c >>> 16)));
// 1879492184
// 28678
// 16384
// c		  		1110000000001101100011001011000
// (c >>> 16) 						111000000000110
// (c & (c >>> 16)) 				100000000000000
```

###  hashCode 对数组长度取模定位数组下标，这块有没有优化策略？

> - **当数组的长度是 2 的 n 次方**，或者 n 次幂，或者 n 的整数倍时，**取模运算/取余运算可以用位运算来代替，效率更高**，毕竟计算机本身只认二进制嘛。
>
> - (length-1)为全1
>
>   ```
>   011010 key=26
>   001111 len-1=15
>   001010 10 映射到10位置上 26/16=10
>   ```

### HashMap扩容机制了解吗？

扩容时，HashMap 会创建一个新的数组，其容量是原数组容量的两倍。

1. 长度为2的倍数

2. 新的HashMap.hash算法

   ```java
   static final int hash(Object key) {
       int h;
       return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
   }
   ```

在 JDK 8 的新 hash 算法下，数组扩容后的索引位置，要么就是原来的索引位置，要么就是**“原索引+原来的容量”**，遵循一定的规律。

![三分恶面渣逆袭：扩容节点迁移示意图](http://42.192.130.83:9000/picgo/imgs/collection-27.png)

### jdk1.8 对 HashMap 主要做了哪些优化呢？为什么？

1. **数据结构**：数组 + 链表改成了数组 + 链表或红黑树

2. **链表插入方式**：链表的插入方式从头插法改成了尾插法

3. **扩容 rehash**：扩容的时候 1.7 需要对原数组中的元素进行重新 hash 定位在新数组的位置，1.8 采用更简单的判断逻辑，不需要重新通过哈希函数计算位置，**新的位置不变或索引 + 新增容量大小**。

   **resize的时候判断每个节点与oldCap的&，就能确定新的位置存在哪**

   ```java
   /**
    * 该代码段分割一个链表，根据链表元素的哈希值与旧容量（oldCap）的按位与运算结果，
    * 将链表元素分为两个新的链表。这是一个内部循环，用于处理链表的分割逻辑。
    * 
    * @param e 链表的当前元素
    * @param oldCap 旧容量，用于与元素的哈希值进行按位与运算来决定元素归属的新链表
    * @param loHead 低哈希值链表的头元素
    * @param loTail 低哈希值链表的尾元素
    * @param hiHead 高哈希值链表的头元素
    * @param hiTail 高哈希值链表的尾元素
    * @return 无返回值，但会更新loHead、loTail、hiHead和hiTail引用，以指向分割后的链表头和尾
    */
   do {
       // 获取下一个元素
       next = e.next;
       // 判断元素的哈希值是否与旧容量的按位与结果为0
       if ((e.hash & oldCap) == 0) {
           // 如果低哈希值链表头为空，设置头为当前元素
           if (loTail == null)
               loHead = e;
           else
               // 否则，将当前元素添加到低哈希值链表的尾部
               loTail.next = e;
           // 更新低哈希值链表的尾部为当前元素
           loTail = e;
       }
       else {
           // 如果高哈希值链表头为空，设置头为当前元素
           if (hiTail == null)
               hiHead = e;
           else
               // 否则，将当前元素添加到高哈希值链表的尾部
               hiTail.next = e;
           // 更新高哈希值链表的尾部为当前元素
           hiTail = e;
       }
   } while ((e = next) != null); // 继续处理下一个元素，直到链表结束
   ```

4. **散列函数**：1.7 做了四次移位和四次异或，jdk1.8 只做一次。

   ```java
   static final int hash(Object key) {
       int h;
       return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
   }
   ```

   ```java
   final int hash(Object k) {
       int h = hashSeed;
       if (0 != h && k instanceof String) {
           return sun.misc.Hashing.stringHash32((String) k);
       }
   
       h ^= k.hashCode();
   
       // This function ensures that hashCodes that differ only by
       // constant multiples at each bit position have a bounded
       // number of collisions (approximately 8 at default load factor).
       h ^= (h >>> 20) ^ (h >>> 12);
       return h ^ (h >>> 7) ^ (h >>> 4);
   }
   ```

   

### 你能自己设计实现一个 HashMap 吗？

- Node
- DEFAULT_CAPATITY
- LOAD_FACTORY
- size
- 构造函数
- put()
- get()
- resize()
- rehash() 重新散列
- size()

![完整代码](http://42.192.130.83:9000/picgo/imgs/collection-30.png)
