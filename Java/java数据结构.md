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

- 遍历过程中进行了修改（增加、删除），则会抛出**Concurrent Modification Exception**（并发修改异常）

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

