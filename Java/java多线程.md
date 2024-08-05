## 线程的生命周期

![img](http://42.192.130.83:9000/picgo/imgs/java-thread.jpg)

- 新建 new Tread
  - start
- 就绪
  - run 获取CPU
- 运行
  - run结束
- 阻塞 wait()  synchronized{} sleep()
  - stop，destroy，Exception，Error
- 死亡

## 创建线程的方法

Java 提供了三种创建线程的方法：

- new Thread(==Runnable().run()=={}).start()

- ==extends Thread==.start

- implement Callable + FutureTask（==implement RunnableFuture ==> extends Runnable==）

  ```java
  FutureTask<Integer> integerFutureTask = new FutureTask<>(new CallableDemo());
          new Thread(integerFutureTask).start();

  class CallableDemo implements Callable<Integer> {
      @Override
      public Integer call()
      }
  ```

- 使用线程池

实现 Runnable、Callable 接口的方式创建多线程时，线程类只是实现了 Runnable 接口或 Callable 接口，还**可以继承其他类**

继承 Thread 类的方式创建多线程时，使用 this 即可获得当前线程。

## 终止线程的方法

- 正常结束

- 退出标记 while(boolean)

- **Interrupt** 阻塞 使用 `isInterrupted()` 判断线程的中断标志来退出循环。

- **stop方法终止线程（线程不安全）**

  thread.stop()调用之后，创建子线程的线程就会抛出 ThreadDeatherror 的错误，并且会释放子线程所持有的所有锁。

## Runnable和Callable区别

- 返回值，这也是要Callable的原因
  - void Runnable
  - V Callable
- 抛出异常 Callable.call()可以throw

## synchronized是什么，有什么性质？

同步方法块，只能被一个线程访问。

- 修饰代码
- 修饰方法

### 性质

- 原子性，要么不执行，要么执行到底。

- 可见性，**当多个线程访问同一个变量时，==一个线程修改了这个变量的值，其他线程能够立即看得到修改的值==**

- 有序性：代码块中的**所有操作都是作为一个单一的不可分割的操作**来执行的。同时，`synchronized`关键字也可以防止指令重排，从而保证了代码执行的有序性。

  通过**阻塞和同步****（获得锁后，进入同步块，其他线程都会被阻塞）**来实现指令的有序执行，避免了指令重排的问题

## volatile是什么，有什么性质？

共享变量在多线程模型中的不可见性问题，**加锁太繁重**

volatile修饰的变量有可见性，一旦某个线程修改了这样的变量，就**立刻更新到主存**

### 性质：

- 可见性，修改立刻更新主存，**每次读取到的都是最新的**。
- 不能保证原子性和有序性

- 禁止进行**指令重排**。**指令重排：不保证语句顺序，但保证语句结果**

  告诉CPU和编译器先于volatile的必须先执行，后于volatile的必须后执行

> 变量声明`volatile`关键字，
>
> 1. 所有线程对该变量的**写入都会被立即同步到主内存中**
> 2. 读取时，就**从MainMemory获取**
>
> ```java
> public class MyClass {
>     private int years;
>     private int months
>     private volatile int days;
> 
>     public void update(int years, int months, int days){
>         this.years  = years;
>         this.months = months;
>         this.days   = days;
>     }
> }
> ```
>
> - 当days修改的时候，会将years，months也写入
>
> #### 问题：指令重排序问题
>
> instance = new Singleton();的执行过程可能被重排序。
>
> ```java
> public class Singleton {
>     private volatile static Singleton singleton;
> 
>     private Singleton() {}
> 
>     public static Singleton getInstance() {
>         if (singleton == null) { // 1
>             synchronized(Singleton.class) {
>                 if (singleton == null) {
>                     singleton = new Singleton(); // 2
>                 }
>             }
>         }
>         return singleton;
>     }
> } 
> ```
>
> 正常过程如下：
>
> 1. 分配内存空间
> 2. 初始化Singleton实例
> 3. instance 实例变量引用
>
> 但是被重排序以后可能会出现：
>
> 1. 分配内存空间
> 2. instance 实例变量引用
>    - 这时instance就不为空了
> 3. 初始化Singleton实例
>
> 如果先赋值了instance变量，那么b线程`if (singleton == null)`为false，但==线程B使用了一个**没有被初始化的对象引用**==
>
> - **使用volatile就能避免重排序**
>
> 线程 T1 执行了 **1 分配空间**和 **3引用**，此时 T2 调用 `getInstance`() 后发现 `uniqueInstance` 不为空，因此返回 `uniqueInstance`，但此时 `uniqueInstance` 还未被初始化（**T2获取到未被初始化的对象**）。

```java
/**
 * 懒汉式 双检锁/双重校验锁（DCL，即 double-checked locking）
 * 【推荐使用】
 * > JDK1.5
 *
 * 线程安全性：是
 * lazy初始化：是
 */
class LazySingletonDCL{

    /**
     * instance变量时使用了volatile关键字。
     * 没有volatile修饰符，可能出现Java中的另一个线程看到个初始化了一半的_instance的情况，
     * 但使用了volatile变量后，就能保证先行发生关系（happens-before relationship）。
     * 对于volatile变量_instance，所有的写（write）都将先行发生于读（read）
     */
    private volatile static Singleton singleton = null;

    public static Singleton getInstance() {

        if (singleton == null) { //线程1，2同时到达，如果均通过（instance == null）判断。，防止重复创建对象，所以下面还使用了if (singleton == null)
            synchronized (Singleton.class){ // 防止其他线程也创建Singleton
                if (singleton == null){
                    return new Singleton();
                }
            }
        }

        return singleton;
    }
}
```

> 1. 为什么使用两个if(=null)
>
>    **A线程释放锁后，没有第二个if会被重复new**
>
>    防止两个线程同时进入第一个if，**线程A创建对象，释放锁**，如果没有第二个if，会重复创建对象。
>
> 2. 为什么使用volatile？
>
>    **如果先赋值再初始化，B线程会使用到没有初始化的对象**
>
>    指令重排序，如果先赋值了instance变量，那么b线程`if (singleton == null)`为false，但==线程B使用了一个**没有被初始化的对象引用**==

## 问题：synchronized和volatile的区别

- 同：

  - 解决共享数据

  - 指令重排
    - `synchronized`关键字通过**阻塞和同步**来实现指令的有序执行，避免了指令重排的问题
    - `volatile`关键字则通过**内存屏障（Memory Barrier）**来实现指令的有序执行，强制将某些指令的执行顺序保留下来，`volatile`关键字声明的变量会在其后面插入一个内存屏障，以确保该变量的读/写操作的顺序性。
  - 可见性，顺序性

- 异：

  - **原子性**：volatile不能保证原子性（线程AB都能读取到最新数据，但AB都读取后，AB修改写入只有一个生效的情况）
  - **性能** synchronized会阻塞，慢
  - volatile 是 synchronized 弱同步的方式
  - **使用级别**：volatile在变量，synchronized在变量、方法、类级别

## start run 区别

- start()才有多线程的特性。**只使用run其实是普通方法，还是同步执行，按顺序执行的**

## FutureTask是什么

- 对任务操作，对Callable这个异步**运算的任务的结果进行等待获取、判断是否已经完成、取消任务等操作**

```java
public class FutureTask<V> implements RunnableFuture<V>
```

```java
FutureTask<String> futureTask = new FutureTask<>(new Callable<String>() {
    @Override
    public String call() throws Exception {
        // 在这里执行你的长时间运行任务，例如：
        Thread.sleep(3000);
        return "任务执行完毕！";
    }
});

new Thread(futureTask).start();

try {
    // 在这里可以执行其他操作，而不会被阻塞
    System.out.println("正在等待任务执行...");
    System.out.println(futureTask.get()); // 会阻塞直到任务执行完毕，并返回结果
} catch (Exception e) {
    e.printStackTrace();
}
```

## 什么是线程安全？绝对、相对线程安全

- 多线程和单线程有一样的运行结果

> - 不可变 final `String、Integer、Long`
>
> - **绝对线程安全** 不管运行时环境如何，调用者都不需要额外的同步措施。**ConcurrentLinkedQueue、CopyOnWriteArrayList、CopyOnWriteArraySet**。（在修改列表时创建底层数组的新副本）
>
> - **相对线程安全** Vector会有ConcurrentModificationException(读取的时候被他人修改了)，也就是fail-fast机制
>
>   (add()、get()和size()等方法虽然被synchronized修饰，但在某些情况下，调用它的时候还是需要同步手段)
>
>   - **如何保证** **`ConcurrentHashMap`** **复合操作的原子性呢？**
>
>   `ConcurrentHashMap` 提供了一些原子性的复合操作，如 `putIfAbsent`、`compute`、`computeIfAbsent` 、`computeIfPresent`、`merge`等
>
> - **线程非安全** ArrayList、LinkedList、HashMap

## 两个线程如何共享数据，使用什么方法进行？

- 在Java中，可以使用共享内存(共享对象)

  ```java
  javapublic static void main(String[] args) {
      Data data = new Data();
      Thread thread = new Thread(new Runnable() {
          @Override
          public void run() {
              data.inc();
          }
      });
      thread.start();
      Thread thread1 = new Thread(new Runnable() {
          @Override
          public void run() {
              data.dec();
          }
      });
      thread1.start();
  }
  ```

- 可见性和有序原子性

- 使用锁ReentrantLock，synchronized
- **共享内存区域**volatile
- `wait/notify/notifyAll、await/signal/signalAll`唤起和等待

> - Object的内置方法，所有的对象都有这些方法。
>
>   拿锁等待，拿锁通知
>
>   - `wait()`: 使得当前线程等待，直到其他线程调用该对象的`notify()`或`notifyAll()`方法。注意，调用`wait()`方法前，必须先获得对象的锁。否则会抛出IllegalMonitorStateException。
>   -  `notify()`: 唤醒一个在该对象上等待的线程（如果存在）。注意，调用`notify()`方法时，并**不保证哪个线程会被唤醒**，只保证唤醒一个等待的线程。
>   -  `notifyAll()`: 唤醒所有在该对象上等待的线程。
>
> - `java.util.concurrent.locks.Condition`
>
>   -  `await()`: 使得当前线程在该对象的等待队列中等待，直到另一个线程调用该对象的`signal()`或`signalAll()`方法。与`wait()`类似，使用前必须先获取到对象的锁。
>   - `signal()`: 唤醒等待在该对象上的一个线程（如果存在）。与`notify()`类似，并不保证哪个线程会被唤醒。
>   - `signalAll()`: 唤醒等待在该对象上的所有线程。与`notifyAll()`类似。
>
> - demo
>
>   获取了同一个锁对象`lock`，使用`wait`等待，`notify`进行通知。
>
> ```java
> public class Demo {
>     private static Object lock = new Object();
>
>     public static void main(String[] args) {
>         Thread thread1 = new Thread(new Runnable() {
>             @Override
>             public void run() {
>                 synchronized (lock) {
>                     try {
>                         System.out.println("线程1等待资源就绪");
>                         lock.wait();
>                         System.out.println("线程1接收到通知，继续执行");
>                     } catch (InterruptedException e) {
>                         e.printStackTrace();
>                     }
>                 }
>             }
>         });
>
>         Thread thread2 = new Thread(new Runnable() {
>             @Override
>             public void run() {
>                 synchronized (lock) {
>                     try {
>                         System.out.println("线程2等待资源就绪");
>                         Thread.sleep(2000);
>                         lock.notifyAll();
>                         System.out.println("线程2通知所有等待的线程，资源已就绪");
>                     } catch (InterruptedException e) {
>                         e.printStackTrace();
>                     }
>                 }
>             }
>         });
>
>         thread1.start();
>         thread2.start();
>     }
> }
> ```

## 为什么wait()方法和notify()/notifyAll()方法要在synchronized块中被调用

- **线程安全**  ：确保在调用这些方法时，使用synchronized来确保当前线程已经获取了对象的监视器锁
- wait会释放锁，让其他线程获取

## sleep和wait的区别

- **所属类：** sleep是Thread的，wait是Objec的
- **监控状态：**sleep让出CPU，保持监控状态
- **释放锁：** sleep()方法是**抱着锁睡觉**，不释放锁；**wait会释放obj锁，等待有obj锁的线程notify**
  - sleep会让其他人等待，wait会让其他人去忙别的事情。
- ==**使用范围：**wait必须要再synchronized里面==
- 它们都可以被interrupted方法中断

## 线程池的线程复用

- Thread.start() 当调用 start **启动线程时 Java 虚拟机会调用该类的 run 方法**。 那么该类的 run() 方法中就是调用了 Runnable 对象的 run() 方法
- 在其 start 方法中**添加不断循环调用传递过来的 Runnable 对象**

```java
class CircleTask {
    public static void main(String[] args) {
        MyThread myThread = new MyThread();
        myThread.setRunnable(new MyTask());
        myThread.start();
    }
}
class MyThread extends Thread{
    private Runnable runnable;
    public void setRunnable(Runnable runnable) {
        this.runnable = runnable;
    }
    @Override
    public synchronized void start() {
        while (true) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            runnable.run();
        }
    }
}
class MyTask implements Runnable {
    @Override
    public void run() {
        System.out.println("执行run");
    }
}
```



## 为什么要使用线程池？

线程对象的重用，避免创建销毁。

> corePoolSize ：线程池的核心大小，也可以理解为最小的线程池大小
>
> - 运行线程<corePoolSize，创建新核心线程
> - 运行线程>corePoolSize，存储到**workQueue**
>   - workQueue满了
>     - 运行线程<maximumPoolSize，创建**非核心新线程**
>     - 运行线程>maximumPoolSize，拒绝策略
>
> **corePoolSize->workQueue->maximumPoolSize**

## ThreadLocal有什么用

ThreadLocal的作用是提供**线程内的==局部变量==**，这种变量在线程的生命周期内起作用

- 为每个线程提供了一个独立的变量副本，这样每个线程都可以独立地改变自己的副本

- 应用：数据库连接、Session 管理（保留用户的状态，每个用户一个独立的session）

  ```java
  class MySession {
      String name;
      public MySession(String name) {
          this.name = name;
      }
      @Override
      public String toString() {
          return "MySession{" +
                  "name='" + name + '\'' +
                  '}';
      }
  }


```java
public class ThreadLocalExample {
    
    public static void main(String[] args) throws InterruptedException {
        for(int i=0 ; i<3; i++){
            new Thread(new MyThread()).start();
        }
    }
}

class MyThread  implements Runnable{

    private static ThreadLocal<Integer> localVariable = new ThreadLocal<Integer>() {
        @Override
        protected Integer initialValue() {
            return 100;
        }
    };

    @Override
    public void run() {
        System.out.println("Thread Name= " + Thread.currentThread().getName() + " default value = " + localVariable.get());
        //formatter pattern is changed here by thread, but it won't reflect to other threads
        localVariable.set(localVariable.get() + 1);

        System.out.println("Thread Name= " + Thread.currentThread().getName() + " localVariable = " + localVariable.get());

    }
}
Thread Name= Thread-0 default value = 100
Thread Name= Thread-1 default value = 100
Thread Name= Thread-0 localVariable = 101
Thread Name= Thread-1 localVariable = 101
Thread Name= Thread-2 default value = 100
Thread Name= Thread-2 localVariable = 101
```
## [ThreadLocal 原理了解吗？](https://javaguide.cn/java/concurrent/java-concurrent-questions-03.html#threadlocal-原理了解吗)

`Thread` 类中有一个 `threadLocals` 和 一个 `inheritableThreadLocals` 变量。

`InheritableThreadLocal`**允许父线程和子线程之间相互访问彼此的变量副本**。

```java
public class Thread implements Runnable {
    //......
    //与此线程有关的ThreadLocal值。由ThreadLocal类维护 存储线程本地变量的值
    ThreadLocal.ThreadLocalMap threadLocals = null;

    //与此线程有关的InheritableThreadLocal值。由InheritableThreadLocal类维护  存储可继承的线程本地变量的值。
    ThreadLocal.ThreadLocalMap inheritableThreadLocals = null;
    //......
}

```

- ThreadLocal.**set和get** 一旦没有threadLocals就创建

```java
public void set(T value) {
    //获取当前请求的线程
    Thread t = Thread.currentThread();
    //取出 Thread 类内部的 threadLocals 变量(哈希表结构)
    ThreadLocalMap map = getMap(t);
    if (map != null)
        // 将需要存储的值放入到这个哈希表中
        map.set(this, value);
    else
        createMap(t, value);
}
ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}
```

![ThreadLocal内部类](http://42.192.130.83:9000/picgo/imgs/thread-local-inner-class.png)

![ThreadLocal 数据结构](http://42.192.130.83:9000/picgo/imgs/threadlocal-data-structure.png)!

```java
static class ThreadLocalMap {
    private Entry[] table;
    static class Entry extends WeakReference<ThreadLocal<?>> {
        /** 弱引用  */
        Object value;

        // ThreadLocal 为key
        Entry(ThreadLocal<?> k, Object v) {
            super(k);
            value = v;
        }
    }
```

## [ThreadLocal 内存泄露问题是怎么导致的？](https://javaguide.cn/java/concurrent/java-concurrent-questions-03.html#threadlocal-内存泄露问题是怎么导致的)

`ThreadLocalMap` 

-  key 为 `ThreadLocal` 的弱引用。**下一次GC就会回收**
-  value 是强引用。**相对难被回收**

这样一来，`ThreadLocalMap` 中就**会出现 key 为 null 的 Entry（内存泄露，不会被回收）**。

`ThreadLocalMap` 实现中已经考虑了这种情况，在调用 `set()`、`get()`、`remove()` 方法的时候，会清理掉 key 为 null 的记录。使用完 `ThreadLocal`方法后最好手动调用`remove()`方法



![ThreadLocal 数据结构](http://42.192.130.83:9000/picgo/imgs/threadlocal-data-structure.png)



##  wait()方法和notify()/notifyAll()方法在放弃对象监视器时有什么区别

-  wait会**放弃对象锁**。并等待唤醒
-  notify()/notifyAll()**不会放弃对象锁，只通知wait线程获取锁**，**必须等到synchronized方法或者语法块执行完才真正释放锁**

- `wait()` 是唯一一个能够主动放弃对象监视器的方法。当一个线程调用 `wait()` 时，它会释放对象的监视器锁，使其他线程可以获取并修改对象的状态。
- `notify()` 和 `notifyAll()` 不会释放对象的监视器锁。它们只是唤醒在对象监视器上等待的线程。被唤醒的线程需要重新获取对象的监视器锁才能继续执行。

```java
    new Thread(() -> {
        try {
            synchronized (basicBean) {
                System.out.println("wait");
                basicBean.wait(); // 放弃锁
                System.out.println(basicBean);
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }).start();

    new Thread(() -> {
        synchronized (basicBean) {
            System.out.println("notify");
            basicBean.notify(); // wait放弃锁后 这里就能拿到锁
            try {
                Thread.sleep(10000); // notify并没有放弃锁，需要执行sleep结束后才能执行到上面的print
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }

        }
    }).start();
}
```



## 怎么检测一个线程是否持有对象监视器，是否有锁

`Thread.holdsLock(object)`

```java
public static void main(String[] args) {
    Object o = new Object();
    boolean b = Thread.holdsLock(o);
    System.out.println(b);

    new Thread(() -> {
        synchronized (o) {
            boolean b1 = Thread.holdsLock(o);
            System.out.println("th1  "+b1);
        }
    }).start();

    new Thread(
            () -> {
                boolean b1 = Thread.holdsLock(o);
                System.out.println("th2  "+b1);
            }
    ).start();
}
```

## Synchronized与ReentrantLock区别总结，为什么使用ReentrantLock

- 同

  都是加锁方式同步，而且都是阻塞式的同步

  线程安全

  可见性和互斥性

- 区别

  > - **用法不同** synchronized 可用来修饰普通方法、静态方法和代码块；ReentrantLock 只能用在代码块上。
  >
  > - ReentrantLock 需要手动加锁和释放锁
  >
  > - **锁类型不同** ReentrantLock支持公平锁
  >
  >   ```java
  >   public ReentrantLock() {
  >       sync = new NonfairSync();
  >   }
  >   public ReentrantLock(boolean fair) {
  >       sync = fair ? new FairSync() : new NonfairSync();
  >   }
  >   ```
  >
  > - **ReentranLock响应中断**
  >
  >   synchronized 不能响应中断，也就是如果发生了死锁，使用 synchronized 会一直等待下去
  >
  >   ```java
  >   //除非当前线程 中断，否则获取锁。
  >   //lockInterruptibly是Object类中的一个方法，用于线程安全地获取一个锁。 当前线程尝试获取锁时，如果锁已被其他线程获取，当前线程将进入等待状态，直到获取到锁或者被其他线程中断。如果当前线程被中断，它将抛出InterruptedException异常。
  >   public void lockInterruptibly() throws InterruptedException {
  >           sync.acquireInterruptibly(1);
  >   }
  >   ```
  >
  > - **底层实现不同**
  >
  >   synchronized 是 JVM;ReentrantLock 是通过 AQS（AbstractQueuedSynchronizer）程序级别的 API

  - synchronized 是同步阻塞，使用的是悲观并发策略，lock 是同步非阻塞，采用的是乐观并发策略

  - synchronized 在发生异常时，会**自动释放线程占有的锁**，因此不会导致死锁现象发生；

    而 Lock 在发生异常时，如果没有主动通过 **unLock()去释放锁**，则很可能造成死锁现象，

    因此使用 Lock 时需要在 finally 块中释放锁。

  - **基础**：Synchronized来说，它是java语言的关键字，是**原生语法层面**的互斥，需要jvm实现。

    ReentrantLock它是JDK 1.5之后提供的**API层面**的互斥锁，需要lock()和unlock()方法配合try/finally语句块来完成

    ```java
    class MyThread implements Runnable {
    	private Lock lock=new ReentrantLock();
    	public void run() {
    			lock.lock();
    			try{
    				for(int i=0;i<5;i++)
    					System.out.println(Thread.currentThread().getName()+":"+i);
    			}finally{
    				lock.unlock();
    			}
    	}
    }
    ```

  - ReentrantLock可以实现**公平锁**

    > **公平锁**: **线程直接进入队列中排队，第一个线程获取锁。（按顺序来）**
    >
    > **非公平锁:  加锁的时候直接要锁，要不到再排队，就是有可能抢占锁**

  - **性能**：ReentrantLock，减少了线程挂起和唤醒次数

  - **等待可中断性**：ReentrantLock可以响应中断，而synchronized是不支持的。

    > ReentrantLock 是显式锁，通过 lock() 和 unlock() 方法控制线程的进入和释放，它支持公平锁和非公平锁，且可以响应中断。当持有锁的线程被中断时，它会在 unlock() 之前抛出 InterruptedException。
    >
    > 而 synchronized 是 Java 语言内置的锁，是一种隐式锁，直接通过对象引用来锁定。synchronized 在遇到中断时，如果被中断的线程正在等待获取锁，那么它将不会释放锁，而是抛出 InterruptedException。如果被中断的线程已经获取了锁，那么它将会忽略中断，继续执行，并在执行完毕后释放锁。
    >
    > - 下面是一个使用 `ReentrantLock` 中断等待的简单示例：
    >
    >   ```
    >   javaCopy codeimport java.util.concurrent.locks.Lock;
    >   import java.util.concurrent.locks.ReentrantLock;
    >                                
    >   public class InterruptibleLockExample {
    >       private final Lock lock = new ReentrantLock();
    >                                
    >       public void performTask() throws InterruptedException {
    >           lock.lockInterruptibly(); // 线程可以被中断
    >           try {
    >               // 执行需要同步的代码
    >           } finally {
    >               lock.unlock();
    >           }
    >       }
    >   }
    >   ```

### 为什么使用ReentrantLock？

- 实现**公平锁**
- ReentrantLock的lockInterruptibly()方法可以**响应中断**
- ReentrantLock可以支持多个Condition实例（对象监视器），Synchronized只能一个
- 设置锁的获取超时时间

## 写一个Java的死锁

- **拿着碗里的看着别人碗里的**

```java
public static void main(String[] args) {
    Object o1 = new Object();
    Object o2 = new Object();
    new Thread(() -> {
        synchronized (o1){
            try {

                System.out.println("1-o1");
                Thread.sleep(50);
                synchronized (o2){
                    System.out.println("1-o2");
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }).start();

    new Thread(()->{
        synchronized (o2){
            System.out.println("2-o2");
            synchronized (o1){
                System.out.println("2-o1");
            }
        }
    }).start();
}
```

## 怎么唤醒一个阻塞的线程

- signal notify
- `Thread  thread.interrupt()` 并且通过抛出InterruptedException来唤醒它
- **IO阻塞**：如果线程遇到了IO阻塞，无能为力，因为IO是操作系统实现的，Java代码并没有办法直接接触到

## 不可变对象对多线程有什么帮助

- 不可变对象==>想到String，每次都读取到最新的，**可见性，线程安全性**。无需做同步操作。
- 缓存效率高

## 什么是多线程的上下文切换

- CPU控制权从一个**正在运行的线程**切换到另一个**就绪等待CPU执行权线程**

  线程是操作系统分配资源的最小单位，每个线程都有自己的栈空间和寄存器，缺少资源无法执行时，先保存到内存，加载另一个就绪的线程。
  
  
  
  当线程使用完时间片后，就会处于就绪状态并让出 CPU 让其他线程占用，这就是上下文切换。
  
  ![上下文切换时机](http://42.192.130.83:9000/picgo/imgs/javathread-9.png)
  
  ![线程切换-2020-12-16-2107](http://42.192.130.83:9000/picgo/imgs/javathread-8.png)

## 引起线程上下文切换的原因

- 时间片用完，执行下一个任务
- 挂起
  - IO阻塞
  - 没抢到任务
  - 用户代码挂起任务，让出CPU ` Thread.sleep()`

## 如果你提交任务时，线程池队列已满，这时会发生

- \< corePoolSize 创建核心线程
- coreMaxPoll< 运行线程   进入队列
  - 队列满了
    - 运行线程<maximumPoolSize，创建非核心新线程
    - 运行线程>maximumPoolSize，(**拒绝策略==RejectedExecutionHandler==**处理满了的任务，默认是AbortPolicy)

> - 如果使用**LinkedBlockingQueue**是无界队列，会继续添加任务到队列中。
> - 使用**ArrayBlockingQueue**有界队列如上

## 线程池阻塞队列原理，有哪些方法？

- 队列没有数据，线程挂起
- 生产者产生数据给阻塞队列，会通知消费者消费
- 队列满了，生产者阻塞
- 消费者消费了满的队列，通知生产者

方法：

- `put` 加入数据
- `take` 取出数据
- `offer` 非阻塞的入队
- `poll` 非阻塞的出队

## Java常见阻塞队列

- `ArrayBlockingQueue` ：数组 组成的有界阻塞队列。公平（**按照线程阻塞的先后顺序进行访问的队列**）、非公平
- `LinkedBlockingQueue `：链表 组成的有界阻塞队列。对于生产者端和消费者端分别采用了独立的锁来控制数据同步
- `PriorityBlockingQueue`
- `DelayQueue`支持延时获取元素的无界阻塞队列（缓存失效、定时任务 ）

## Java中用到的线程调度算法是

线程调度算法有：

- **抢占式**（JVM使用的），OS根据线程优先级、饥饿情况计算优先级分配，**都由系统控制**
- 协同式调度，**接力赛**，执行完通知另一个线程。

JVM的抢占式：优先级高得到越多的执行时间片，不单独占用

## Thread.sleep(0)有什么用

**平衡CPU控制权** ，为了让某些优先级比较低的线程也能获取到CPU控制权，可以使用Thread.sleep(0)**手动触发一次操作系统分配时间片**的操作

## 乐观锁和悲观锁

> - 悲观锁：**synchronized**是悲观锁，这种线程一旦得到锁，其他需要锁的线程就挂起的情况就是悲观锁。**对资源操作会有一个独占的锁**
>
>   ![](http://42.192.130.83:9000/picgo/imgs/89d34d8196e74fafb3843292b0aa481e.png)
>
> - 乐观锁（Compare And Swap）：**CAS操作**的就是乐观锁，每次不加锁而是假设没有冲突而去完成某项操作，如果**因为冲突失败就重试（回滚），直到成功为止。**
>
>   ==**比较-替换CAS**这两个动作作为一个原子操作尝试去修改内存中的变量==
>
>   ![在这里插入图片描述](http://42.192.130.83:9000/picgo/imgs/89d34d8196e74fafb3843292b0aa481e.png)

## CAS是什么？有什么性质？有什么用？

- 乐观锁 （**比较跟上一次的版本号，如果一样则更新**）

- 比较和替换

  先检查内存中的值与期望值是否相等

  - 如果相等，则执行交换操作。
  - 不相等，不执行（表明被修改了）。

特点：在执行过程中**不需要使用传统的互斥锁**，因此它可以在并发环境下实现**高效的线程同步**。

作用：保证原子操作。

```java
class AtomicInteger{
    ...
}
class Unsafe{

	public final int getAndAddInt(Object var1, long var2, int var4) {
        int var5;
        do {
            var5 = this.getIntVolatile(var1, var2);
            // while cas
        } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));
        return var5;
	}
}

// native 就是根据不同平台调用底层d
public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);

```



## CAS自旋是什么？优缺点？

当锁被其他线程占用的情况下，该线程会**循环等待（自旋）**，直到获取到锁为止。

等待竞争锁的线程就不需要做内核态和用户态之间的切换。

- 优点：竞争不激烈的情况，性能好。

- 缺点：竞争激烈的情况下，会有大量线程竞争一个锁。

  **线程自旋消耗和阻塞挂起消耗。**

## AQS是什么？// TODO

[AQS 详解 | JavaGuide](https://javaguide.cn/java/concurrent/aqs.html)

**AbstractQueuedSynchronizer** 先尝试**cas乐观锁**去获取锁，获取不到，才会转换为**悲观锁**，如 RetreenLock。

如果CAS操作失败，说明有其他线程已经获取到了锁，当前线程会进入等待状态。当一个线程释放锁时，它会调用AQS的release方法来释放锁资源。

**核心思想：**

- 如果资源空闲：当前请求资源的线程设置为有效的工作线程，并锁定。

- 如果资源被占用：

  需要一套线程阻塞等待以及被唤醒时锁分配的机制，这个机制 AQS 是基于 **CLH 锁** （Craig, Landin, and Hagersten locks） 实现的
  
  当持有锁的线程释放锁时，**AQS 会唤醒等待队列中的一个或多个线程，使它们重新竞争锁的获取**。

**CLH 锁**

CLH 锁是对自旋锁的一种改进，是一个虚拟的双向队列。**检查前驱结点状态**

```java
/** CLH Nodes */
    abstract static class Node {
        // 初始情况下，节点通过casTail操作被附加
        volatile Node prev;
        // 当节点是signallable时，这个变量是可见的
        volatile Node next;
        // 表示等待该节点的线程
        Thread waiter;
        // 表示节点的状态 表示同步状态
        volatile int status;
    }
//返回同步状态的当前值
protected final int getState() {
     return state;
}
 // 设置同步状态的值
protected final void setState(int newState) {
     state = newState;
}
//原子地（CAS操作）将同步状态值设置为给定值update如果当前同步状态的值等于expect（期望值）
protected final boolean compareAndSetState(int expect, int update) {
      return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
}
```

![CLH 队列结构](https://oss.javaguide.cn/github/javaguide/java/concurrent/clh-queue-structure.png)

![CLH 队列](http://42.192.130.83:9000/picgo/imgs/clh-queue-state.png)

`ReentrantLock` 为例

- 在公平锁中，AQS会选择等待时间最长的节点唤醒

[从ReentrantLock的实现看AQS的原理及应用 | JavaGuide](https://javaguide.cn/java/concurrent/reentrantlock.html)

```java
// java.util.concurrent.locks.ReentrantLock#NonfairSync

// 非公平锁
static final class NonfairSync extends Sync {
  ...
  final void lock() {
    if (compareAndSetState(0, 1))
     // CAS 设置变量 State（同步状态）成功，也就是获取锁成功，则将当前线程设置为独占线程。
  setExclusiveOwnerThread(Thread.currentThread());
    else
        // 若通过 CAS 设置变量 State（同步状态）失败，也就是获取锁失败，则进入 Acquire 方法进行后续处理。
      acquire(1);
    }
  ...
}

```

- 获取不到锁的后续处理





## Semaphore是什么？有什么用？

Semaphore的作用是**用来控制同时访问特定资源的线程数量**，常用于限流场景。

- `Semaphore(1) `相当于`synchronized`

```java
Semaphore semaphore = new Semaphore(1);
new Thread(() -> {
    try {
        semaphore.acquire();  // 获取许可
        System.out.println(Thread.currentThread().getName() + "开始执行");
        Thread.sleep(1000);  // 模拟耗时操作
        System.out.println(Thread.currentThread().getName() + "执行完毕");
        semaphore.release();  //  释放许可
    } catch (InterruptedException e) {
        throw new RuntimeException(e);
    }
}).start();
```

## 程类的构造方法、静态块是被哪个线程调用的

> **构造方法、静态方法是创建这个线程的线程调用的**，run方法才是本线程调用的
>
> ```java
> public static void main(String[] args) {
>     new Thread(
>             new Runnable() {
>                 /* Run方法才是这个线程的方法 */
>                 @Override
>                 public void run() {
>                     System.out.println("1" + Thread.currentThread().getName());
>
>                     new Thread(
>                             new Runnable() {
>                                 @Override
>                                 public void run() {
>                                     System.out.println("2" + Thread.currentThread().getName());
>                                 }
>                             }
>                             , "thread-22").start();
>
>
>                 }
>             }
>             , "thread-11").start();
>
> }
> ```
>
> 这里main创建了thread11, thread11创建了thread22。那么thread11的构造方法、静态块就是main调用的。

## 同步方法和同步块，哪个是更好的

- 范围越小效率越高，所以**同步块效率更高**，锁住整个对象和锁住一部分。

## 使用两个线程交替打印ab100次？3个线程交替打印abc？

> #### 使用syncronized锁定+count奇偶性计数
>
> - 线程1在0（偶数）时进行wait，此时0（偶数）不会让线程2进入wait，让线程2执行完后++再notify，此时线程1的wait继续执行
>
> **奇数偶数分别由不同线程进行等待**
>
> **如果是三个线程，需要保证count属于本线程的时候才wait**
>
> ```java
> // 判断是否轮到自己执行
> while (count % 3 != 0) {
>     // 不是则等待
>     lock.wait();
> }
> ```
>
> #### 使用2个Semaphore信号量，进行锁定释放
>
> - 使用2个Semaphore，执行前加锁，执行完解锁

```java
private static Object lock = new Object();
private static Integer count = 0;
/**
 * 主函数示例，演示了通过两个线程交替打印字符并控制其执行顺序的简单并发程序。
 * 使用一个共享计数器和一个对象锁来协调两个线程的执行。
 * 线程1打印字符'a'，线程2打印字符'b'，交替进行，直到计数器达到100。
 *
 * @param args 命令行参数（未使用）
 * @throws InterruptedException 如果线程在等待时被中断则抛出此异常
 */
public static void main1(String[] args) throws InterruptedException{

// 创建三个线程
        Thread threadA = new Thread(() -> {
            try {
                // 循环100次
                for (int i = 0; i < 100; i++) {
                    // 获取锁
                    synchronized (lock) {
                        // 判断是否轮到自己执行
                        while (count % 3 != 0) {
                            // 不是则等待
                            lock.wait();
                        }
                        // 打印字母
                        System.out.println("A");
                        // 修改状态
                        count++;
                        // 唤醒下一个线程
                        lock.notifyAll();
                    }
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        Thread threadB = new Thread(() -> {
            try {
                for (int i = 0; i < 100; i++) {
                    synchronized (lock) {
                        while (count % 3 != 1) {
                            lock.wait();
                        }
                        System.out.println("B");
                        count++;
                        lock.notifyAll();
                    }
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        Thread threadC = new Thread(() -> {
            try {
                for (int i = 0; i < 100; i++) {
                    synchronized (lock) {
                        // 确保严格到本线程打的时候再等候
                        while (count % 3 != 2) {
                            lock.wait();
                        }
                        System.out.println("C");
                        count++;
                        lock.notifyAll();
                    }
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        // 启动三个线程
        threadA.start();
        threadB.start();
        threadC.start();

}
```

```java
private static final Semaphore semaphoreA = new Semaphore(1); // 初始化为1，表示开始时允许线程1（打印'a'）执行
private static final Semaphore semaphoreB = new Semaphore(0); // 初始化为0，表示开始时阻止线程2（打印'b'）执行
public static void main(String[] args) throws InterruptedException {

    new Thread(
            () -> {
                for (int i = 0; i < 50; i++) {
                    try {
                        semaphoreA.acquire();
                        System.out.println("a");
                        semaphoreB.release();
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
    ).start();


    new Thread(
            () -> {
                for (int i = 0; i < 50; i++) {
                    try {
                        semaphoreB.acquire();
                        System.out.println("b");
                        semaphoreA.release();
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
    ).start();
}
```

## [美团面试：如何检测和避免线程死锁? (qq.com)](https://mp.weixin.qq.com/s/RTSPH23dTvLA3hOBT7CwtQ)

1. **互斥条件**：该资源任意一个时刻只由一个线程占用。
2. **请求与保持条件**：一个线程因请求资源而阻塞时，对已获得的资源保持不放。
3. **不剥夺条件**:线程已获得的资源在未使用完之前不能被其他线程强行剥夺，只有自己使用完毕后才释放资源。
4. **循环等待条件**:若干线程之间形成一种头尾相接的循环等待资源关系。

### 如何预防和避免线程死锁?

#### **如何预防死锁？** 破坏死锁的产生的必要条件即可：

1. **破坏请求与保持条件**：一次性申请所有的资源。**申请所有资源**
2. **破坏不剥夺条件**：占用部分资源的线程进一步申请其他资源时，如果申请不到，可以主动释放它占有的资源。**主动释放**
3. **破坏循环等待条件**：靠按序申请资源来预防。按某一顺序申请资源，释放资源则反序释放。破坏循环等待条件。**按顺序获取**

#### **如何避免死锁？**

- 线程2变成先获取A；只有1释放A后2才能获取B

```java
new Thread(
        ()->{
            synchronized (a) {
                System.out.println(Thread.currentThread().getName() + "a");
                synchronized (b) {

                }
            }
        }
).start();
```

### 检测

Jconsole

**启动参数**

```
-Dcom.sun.management.jmxremote=true
-Dcom.sun.management.jmxremote.port=8011
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
```

![jconsole_xyA3XxdpEx](http://42.192.130.83:9000/picgo/imgs/jconsole_xyA3XxdpEx.png)

## 什么是进程和线程？如何理解协程？

[进程与线程的区别是什么？ | 二哥的Java进阶之路 (javabetter.cn)](https://javabetter.cn/thread/why-need-thread.html)

- 进程Java
- 线程 进程中的一个或多个线程，充分发挥多CPU的优势

![三分恶面渣逆袭：进程与线程关系](http://42.192.130.83:9000/picgo/imgs/javathread-3.png)

#### 如何理解协程？

协程通常被视为**比线程更轻量级的并发单元**，它们主要在一些支持异步编程模型的语言中得到了原生支持，如 Kotlin、Go 等。

> ### 模拟协程式的异步执行任务
>
> - 两个异步任务，结果合并
>
> ```java
> public static void main(String[] args) throws ExecutionException, InterruptedException {
>     // 创建一个异步任务，该任务返回一个整数
>     CompletableFuture<Integer> future = CompletableFuture.supplyAsync(
>             new Supplier<Integer>() {
>                 @Override
>                 public Integer get() {
>                     System.out.println("A complete");
>                     return 10;
>                 }
>             }
>     );
> 
>     // 创建另一个异步任务，该任务同样返回一个整数
>     CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(
>             () -> {
>                 System.out.println("B start");
>                 try {
>                     Thread.sleep(10000);
>                 } catch (InterruptedException e) {
>                     throw new RuntimeException(e);
>                 }
>                 System.out.println("B complete");
>                 return 20;
>             }
>     );
> 
>     // 两个异步任务完成计算后，将它们的结果相加
>     CompletableFuture<Object> ans = future.thenCombine(future2, new BiFunction<Integer, Integer, Object>() {
>                 @Override
>                 public Object apply(Integer integer, Integer integer2) {
>                     return integer + integer2;
>                 }
>             }
>     );
> 
>     // 打印结果
>     System.out.println(ans.get());
> 
> }
> ```

## 为什么调用 start()方法时会执行 run()方法，那怎么不直接调用 run()方法？

- **start方法才会创建一个线程**
- 直接调用run方法其实还是单线程

## 说说线程中断[interrupt 方法](https://www.cnblogs.com/myseries/p/10918819.html)

Java 中的线程中断是一种线程间的协作模式，通过**设置线程的中断标志**并**不能直接终止该线程的执行**。

<b style='color:red'>stop 方法</b>用来强制线程立刻停止（可能会在不一致的状态下释放锁，破坏对象的一致性，导致难以发现的错误和资源泄漏），<b style='color:red'> 很危险</b>

- `void interrupt()` 方法：**中断线程标志**，例如，当线程 A 运行时，线程 B 可以调用线程 `interrupt()` 方法来设置线程的中断标志为 true 并立即返回。设置标志仅仅是设置标志, 线程 B 实际并没有被中断，会继续往下执行。
- `boolean isInterrupted()` 方法： 检测当前线程是否**被中断**。
- `boolean interrupted()` 方法： 检测当前线程**是否被中断**，与 isInterrupted 不同的是，该方法如果发现当前线程被中断，则会清除中断标志。

```java
public void run() {
    try {
        while (!Thread.currentThread().isInterrupted()) {
            // 执行任务
        }
    } catch (InterruptedException e) {
        // 线程被中断时的清理代码
    } finally {
        // 线程结束前的清理代码
    }
}
```

## 线程有几种状态？

![Java线程状态变化](http://42.192.130.83:9000/picgo/imgs/javathread-7.png)

| 状态         | 说明                                                         |
| ------------ | ------------------------------------------------------------ |
| NEW          | 初始状态：线程被创建，但还没有调用 start()方法               |
| RUNNABLE     | 运行状态：Java 线程将操作系统中的就绪和运行两种状态笼统的称作“运行” |
| BLOCKED      | 阻塞状态：表示线程阻塞于锁                                   |
| WAITING      | 等待状态：表示线程进入等待状态，进入该状态表示当前线程需要等待其他线程做出一些特定动作（通知或中断） |
| TIME_WAITING | 超时等待状态：该状态不同于 WAITIND，它是可以在指定的时间自行返回的 |
| TERMINATED   | 终止状态：表示当前线程已经执行完毕                           |

## 守护线程了解吗？

Java 中的线程分为两类，分别为 **daemon 线程（守护线程）**和 **user 线程（用户线程）**。

- 用户线程：main 方法，main 方法所在的线程就是一个用户线程。
- 守护线程
  1. 垃圾回收器（Garbage Collector）线程：用于自动回收不再使用的内存资源。
  2. Finalizer线程：用于执行对象的finalize()方法，进行垃圾回收前的清理工作。
  3. 系统信号分发线程（Signal Dispatcher）：用于接收操作系统发送的信号并进行处理。
  4. 队列清理线程（Reference Handler）：负责处理引用对象的清理工作，例如处理引用队列中的对象。

## 线程间有哪些通信方式？

- volatile

- syncronized 

- wait notify

- **管道输入/输出流**

  > 管道输入/输出流和普通的文件输入/输出流或者网络输入/输出流不同，它主要用于线程之间的数据传输，而传输的媒介为内存。
  >
  > [管道输入/输出流open in new window](https://javabetter.cn/io/piped.html)主要包括了如下 4 种具体实现：PipedOutputStream、PipedInputStream、 PipedReader 和 PipedWriter，前两种面向字节，而后两种面向字符。

- **使用 ThreadLocal**

- Semaphore

- **Thread.join()** 等待这个线程终止后

  ```java
  public static void main(String[] args) {
  
      Thread thread = new Thread(() -> {
          try {
              System.out.println("A Start");
              Thread.sleep(10000);
              System.out.println("A DONE");
          } catch (InterruptedException e) {
              throw new RuntimeException(e);
          }
  
      });
      thread.start();
  
      new Thread(() -> {
          try {
              thread.join(); // 等待A线程执行完成
              System.out.println("B DONE");
          } catch (InterruptedException e) {
              throw new RuntimeException(e);
          }
      }).start();
  }
  ```

## ThreadLocal 怎么实现的呢？

ThreadLocal 本身并不存储任何值，它只是作为一个映射，来映射线程的局部变量。当一个线程**调用 ThreadLocal 的 set 或 get 方法时，实际上是访问线程自己的 ThreadLocal.ThreadLocalMap**。

- key ThreadLocal
- value 值

**每个线程有直接的ThreadLocal.ThreadLocalMap**

ThreadLocal 的实现原理就是

- **每个线程维护一个 Map**

  - key 为 ThreadLocal 对象
  - value 为想要实现线程隔离的对象。

- set(ThreadLocal,Object) 获得**ThreadLocal的hash**，放入对应的Map（**其实是个数组**）

  使用线性探测法，即在发生冲突时，会顺序地检查下一个位置

- get() 获取本ThreadLocal的Object，获取ThreadLocal的hash，获取对应的Entry

```java
// 创建一个线程局部变量threadLocal1，并设置其初始值为10
    private static ThreadLocal<Integer> threadLocal1 = ThreadLocal.withInitial(() -> 10);
    // 创建一个线程局部变量threadLocal2，并设置其初始值为"Hello"
    private static ThreadLocal<String> threadLocal2 = ThreadLocal.withInitial(() -> "Hello");

    public static void main(String[] args) {
        // 创建一个新线程thread，并为其指定一个Runnable实现
        Thread thread = new Thread(() -> {
            // 获取threadLocal1的值
            int value1 = threadLocal1.get();  // 放入Thread的Map key 为ThreadLocal<integer> value为10
            // 获取threadLocal2的值
            String value2 = threadLocal2.get(); // 放入Thread的Map key 为ThreadLocal<String> value为Hello
            // 打印threadLocal1的值
            System.out.println("ThreadLocal1: " + value1);
            // 打印threadLocal2的值
            System.out.println("ThreadLocal2: " + value2);
        });
    
        // 启动线程thread
        thread.start();
    }
}
```

![三分恶面渣逆袭：ThreadLoca结构图](http://42.192.130.83:9000/picgo/imgs/javathread-13.png)

> **Entry 继承了 WeakReference**，它限定了 key 是一个弱引用，弱引用的好处是**当内存不足时，JVM 会回收 ThreadLocal 对象**，并且将其对应的 Entry 的 value 设置为 null，这样在很大程度上可以避免内存泄漏。
>
> ```java
> static class Entry extends WeakReference<ThreadLocal<?>> {
>     /** The value associated with this ThreadLocal. */
>     Object value;
> 
>     Entry(ThreadLocal<?> k, Object v) {
>         super(k);
>         value = v;
>     }
> }
> ```

![img](http://42.192.130.83:9000/picgo/imgs/javathread-20240407205747.png)

### 说说你对 JUC 下并发工具类的了解?

Java 并发工具类（JUC，Java Util Concurrency）是 Java 标准库中用于支持多线程编程的一组工具类。这些工具类位于 java.util.concurrent 包下，提供了高级别的并发抽象，使得开发人员能够更容易地编写线程安全的程序。
JUC 下常用的并发工具类
以下是一些常用的并发工具类及其用途：
- AtomicInteger
  定义：AtomicInteger 是一个原子整数类，它提供了一组原子操作，如加减法、比较和交换等。
- CountDownLatch
  定义：CountDownLatch 是一种协调工具类，用于让一组线程等待其他线程完成工作。
  用途：通常用于等待一组操作完成，例如在启动服务时等待所有环境初始化完毕。
- CyclicBarrier
  定义：CyclicBarrier 类似于 CountDownLatch，但它允许线程在某个屏障点等待其他线程。
  用途：用于多线程协作场景，例如多线程并行计算后需要同步结果。
  - 和CountDownLatch 类似，CyclicBarrier 允许一组线程等待其他线程完成工作(所有线程都await时，才会被释放，而CountDownLatch是设置num，当num减到0的时候才唤醒await)。
  - CyclicBarrier 允许重用，而 CountDownLatch 不能。
```java
import java.util.concurrent.CountDownLatch;
public class CountDownLatchExample {
    public static void main(String[] args) throws InterruptedException {
        int threadCount = 5;
        CountDownLatch latch = new CountDownLatch(threadCount);

        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                System.out.println(Thread.currentThread().getName() + " 开始工作");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread().getName() + " 工作完成");
                latch.countDown();
            }).start();
        }

        // 等待所有子线程完成
        latch.await();
        System.out.println("所有子线程已完成！");
    }
}
import java.util.concurrent.CyclicBarrier;

public class CyclicBarrierExample {
    public static void main(String[] args) {
        int threadCount = 5;
        CyclicBarrier barrier = new CyclicBarrier(threadCount, () -> {
            System.out.println("所有线程已完成！");
        });

        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                System.out.println(Thread.currentThread().getName() + " 开始工作");
                try {
                    Thread.sleep(1000); // 模拟耗时操作
                    barrier.await(); // 等待所有线程到达屏障点
                } catch (Exception e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread().getName() + " 工作完成");
            }).start();
        }
    }
}



```
- Semaphore
  定义：Semaphore 是一种信号量，用于控制对有限资源的访问。
  用途：通常用于限制同时访问某个资源的线程数量，例如限制并发的网络请求。
- Exchanger
  定义：Exchanger 是一种协调工具类，用于在线程间交换数据。
  用途：两个线程可以在 Exchanger 上交换数据，常用于数据交换场景。
  - 当调用exchange时，会阻塞，等待另一个线程调用exchange，所以必须两边都发送才是exchange
  - 如果只要当方面发送，可以考虑 BlockingQueue 或者 SynchronousQueue。
    - BlockingQueue：适用于生产者-消费者模型，可以实现数据的单向传输。
    - SynchronousQueue：类似于 Exchanger，但是它不需要两个线程都提供数据就可以进行交换。一个线程可以只提供数据（放入队列），另一个线程可以只从队列中取数据。
      示例
- SynchronousQueue

```java
    /**
     * 创建一个线程池，该线程池会根据需要创建新线程，
     * 但在以前构造的线程可用时将重用这些线程。这
     * 些池通常会提高执行许多短期异步任务的程序的性能。
     * 对 的 execute 调用将重用以前构造的线程（如果可用）。
     * 如果没有可用的现有线程，将创建一个新线程并将其添加到池中。
     * 60 秒内未使用的线程将被终止并从缓存中删除。
     * 因此，保持空闲足够长时间的池不会消耗任何资源。
     * 请注意，可以使用构造函数创建 ThreadPoolExecutor 具有相似属性但详细信息不同
     * （例如，超时参数）的池。
     * 返回：新创建的线程池
     * Creates a thread pool that creates new threads as needed, but
     * will reuse previously constructed threads when they are
     * available.  These pools will typically improve the performance
     * of programs that execute many short-lived asynchronous tasks.
     * Calls to {@code execute} will reuse previously constructed
     * threads if available. If no existing thread is available, a new
     * thread will be created and added to the pool. Threads that have
     * not been used for sixty seconds are terminated and removed from
     * the cache. Thus, a pool that remains idle for long enough will
     * not consume any resources. Note that pools with similar
     * properties but different details (for example, timeout parameters)
     * may be created using {@link ThreadPoolExecutor} constructors.
     *
     * @return the newly created thread pool
     */
    public static ExecutorService newCachedThreadPool() {
        return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                      60L, TimeUnit.SECONDS,
                                      new SynchronousQueue<Runnable>());
    }
    /**
     * 核心线程数 0
     * 最大线程数 Integer.MAX_VALUE
     * 线程存活时间 60秒
     * 队列 SynchronousQueue 
     *          一个 阻塞队列 ，其中每个插入操作都必须等待另一个线程执行相应的删除操作，反之亦然。同步队列没有任何内部容量，甚至没有 1 的容量。
     *          被设计为一种轻量级的线程间通信机制，而不是一个真正的队列。
     *          它的主要目的是为了实现线程之间的直接传递，而不是作为一个持久的存储区域。
     *          无缓冲特性:
     *              SynchronousQueue 的容量为0，意味着它没有任何内部缓冲区来存储元素。
     *          当一个线程尝试通过 put 方法将一个元素放入 SynchronousQueue 时，它实际上是在等待另一个线程通过 take 方法来消费这个元素。
     * 
     * /
```



