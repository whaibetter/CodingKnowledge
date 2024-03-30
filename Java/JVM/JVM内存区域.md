[toc]

## JVM内存区域

### JVM1.6、1.7、1.8的内存区别

![image-20220410175413952](http://42.192.130.83:9000/picgo/imgs/21e99709b959126cf5f0863f0cc2b8ef.png)

- JDK1.6 程序计数器、虚拟机栈、本地方法栈、**方法区**（**永久代**｛逻辑上属于方法区，物理上属于堆｝【**字符串常量池，静态变量，运行时常量池，类常量池**】）、堆
- JDK1.7 **字符串常量池、静态变量**移动到堆。
  - *从《Java虚拟机规范》所定义的概念模型来看，所有Class相关的信息都应该存放在方法区之中，但方法区该如何实现，《Java虚拟机规范》并未做出规定，这就成了一件允许不同虚拟机自己灵活把握的事情。JDK 7及其以后版本的HotSpot虚拟机选择把静态变量与类型在Java语言一端的映射Class对象存放在一起，存储于Java堆之中；jdk6及以前放在方法区，jdk7开始放在堆中Class对象中*

- JDK1.8 **方法区（永久代）被删除**，用**元空间**取代，移动到**直接内存**。

### 字符串常量池在JVM1.6、1.7、1.8的存储位置？为什么？永久代的变化？

![image-20220410175413952](http://42.192.130.83:9000/picgo/imgs/21e99709b959126cf5f0863f0cc2b8ef.png)

- 1.6 存在方法区（永久代中） 
- 1.7 存在**堆**中，移动到堆（因为**永久代的回收效率很低，只有full Gc才会触发**）
- 1.8 存在**堆**中，取消永久代（永久代在jvm中，**合适的大小难以确定**（元空间分配在本地内存，无需考虑大小））

> 1.6 永久代｛类常量池、字符串常量池、运行时常量池、静态变量｝
>
> ------移动**静态变量、字符串常量池**到堆中
>
> 1.7 永久代 ｛类常量池，运行时常量池｝ **堆｛静态变量，字符串常量池｝**
>
> ------区别是**移动到本地内存**，并变为元空间
>
> 1.8 元空间｛类常量池，运行时常量池｝
>
> - *从《Java虚拟机规范》所定义的概念模型来看，所有Class相关的信息都应该存放在方法区之中，但方法区该如何实现，《Java虚拟机规范》并未做出规定，这就成了一件允许不同虚拟机自己灵活把握的事情。JDK 7及其以后版本的HotSpot虚拟机选择把静态变量与类型在Java语言一端的映射Class对象存放在一起，存储于Java堆之中；jdk6及以前放在方法区，jdk7开始放在堆中Class对象中*

### JVM线程私有、公有的部分？

公有：堆、方法区

私有：程序计数器、虚拟机栈、本地方法栈

### [程序计数器是什么？特点？](https://javaguide.cn/java/jvm/memory-area.html#程序计数器)

- **当前线程**所执行的字节码的**行号指示器**。
- 通过改变这个计数器的值来**选取下一条需要执行的字节码**指令，**分支、循环、跳转、异常处理、线程恢复**等功能

特点：程序计数器是**唯一一个不会出现 `OutOfMemoryError` 的内存区域**，它的生命周期随着线程的创建而创建，随着线程的结束而死亡。

## 类加载子系统

![image-20240224171708354](http://42.192.130.83:9000/picgo/imgs/image-20240224171708354.png)

### 类加载器是什么？有什么组成？有什么作用？

#### 是什么？有什么作用？

- ClassLoader 负责 class 文件的加载

![image-20200705081913538](https://img-blog.csdnimg.cn/img_convert/e8172076eaa7a152408633a353f06b2c.png)

- .class file 加载到 JVM 中，被称为 DNA 元数据模板，放在**方法区**。
- 在**.class 文件->JVM->最终成为元数据模板**，此过程就要一个运输工具（类装载器 Class Loader），扮演一个快递员的角色。

#### **有什么组成**？

- **引导类加载器（BootStrap）**核心库、ExtClassLoader和System ClassLoader的父类，加载java、javax、sun等开头的类。
- **扩展类加载器（ExtClassLoader）**从jre/1ib/ext加载，或指定java.ext.dirs的加载
- **系统类加载器（System ClassLoader）应用程序类加载器**，程序中默认的类加载器

![image-20200705094149223](https://img-blog.csdnimg.cn/img_convert/1e553c6d5254f827d2dfab537bea3ab9.png)

![image-20200705081813409](http://42.192.130.83:9000/picgo/imgs/3569bfb903e80b66ee7e972a6b4a5036.png)

### 类的加载过程是什么样？作用是什么？

![image-20200705082601441](https://img-blog.csdnimg.cn/img_convert/a9497a1eeb7fae3022846b509186fdcd.png)

#### 加载阶段：**静态存储结构**转化为方法区的**运行时数据结构**

类的全限定名获取类的字节流，**静态存储结构**转化为方法区的**运行时数据结构**

#### 连接阶段：验证、static设默认、引用转换

1. **验证（Verify）**：验证有效性。
   - 文件格式验证，元数据验证，字节码验证，符号引用验证
2. **准备（Prepare）**：**为static变量设置==默认值==**，不会对实例变量分配初始化。
   - 这里不包含用 final 修饰的 static， final 在**编译**的时候就会分配了，准备阶段会显式初始化；
   - 这里不会为实例变量（成员变量）分配初始化，实例变量在堆中
3. **解析（Resolve）**：将常量池内的<mark>符号引用转换为直接引用</mark>的过程。
   - 事实上，解析操作往往会伴随着 JVM 在执行完初始化之后再执行。
   - 解析动作主要针对类或接口、字段、类方法、接口方法、方法类型等。对应常量池中的 CONSTANT_Class_info，CONSTANT_Fieldref_info、CONSTANT_Methodref_info 等。

#### 初始化阶段：类构造器，收集类变量（staic）和static块合并，顺序执行。

- **&lt;clinit&gt;() **：==初始化阶段就是执行**类构造器方法**&lt;clinit&gt;()的过程。==
- **自动收集：** 是 javac 编译器**自动收集类中的所有类变量的赋值动作和静态代码块**中的语句==**合并**==而来。
- **顺序执行：**构造器方法中指令按语句在**源文件中出现的顺序执行**。
- **优先父类：**若该类具有父类，JVM 会保证子类的&lt;clinit&gt;()执行前，父类的&lt;clinit&gt;()已经执行完毕。
- **只执行一次：**类加载到内存中进入方法区，只调用一次\<clinit>



![image-20200705081813409](http://42.192.130.83:9000/picgo/imgs/3569bfb903e80b66ee7e972a6b4a5036.png)



### 获取 ClassLoader 的途径？

- 方式一：获取当前 ClassLoader  **类**

  ```java
  clazz.getClassLoader()
  ```

- 方式二：获取当前**线程上下文**的 ClassLoader 

  ```java
  Thread.currentThread().getContextClassLoader()
  ```

- 方式三：获取**系统**的 ClassLoader 

  ```java
  ClassLoader.getSystemClassLoader()
  ```

- 方式四：获取**调用者**的 ClassLoader

  ```java
  DriverManager.getCallerClassLoader()
  ```

### 双亲委派机制是什么？工作原理？解决了什么问题？

- **会优先委派上级类加载器进行类加载**。
- 避免类的重复加载，保护程序**安全**，防止核心 API 被随意篡改,**不能用java包名**

> ### 工作原理
>
> 1. 类加载请求，**优先委托给父类加载器**
>    1. 父类可以加载，由父类加载
>    2. 父类不能加载才看子类能不能加载
> 2. 都不行ClassNotFound
>
> ![image-20200705105151258](https://img-blog.csdnimg.cn/img_convert/05fa27fcc38eeaaa5babff55a00882a3.png)
>
> 如**java.lang.String**只会从Bootstrap ClassLoader中加载。
>
> - ==引导类加载器（Bootstrap ClassLoader）==   Java 的核心库（JAVA_HOME/jre/lib/rt.jar、resources.jar 或 sun.boot.class.path 路径下的内容），用于提供 JVM 自身需要的类。Bootstrap 启动类加载器只加载包名为 java、javax、sun 等开头的类
> - <mark>自定义类加载器（User-Defined ClassLoader）</mark>。所有派生于抽象类 ClassLoader 的类加载器都划分为自定义类加载器
>   - **扩展类加载器（Extension ClassLoader）** java.ext.dirs 系统属性所指定的目录中加载类库，或从 JDK 的安装目录的 jre/1ib/ext 子目录（扩展目录）下加载类库
>   - **应用程序类加载器（系统类加载器，System Class Loader; App ClassLoader）**默认的类加载器

### 沙箱安全机制是什么？

- **将Java代码==限定在虚拟机（JVM）特定的运行范围==中，并且严格限制代码对本地系统资源的访问**

如自定义的java.lang.String不能生效，引导类加载器（Bootstrap ClassLoader）会加载jdk自带的String

自定义 String 类，但是**在加载自定义 String 类的时候会率先使用引导类加载器加载**，而引导类加载器在加载的过程中会先加载 jdk 自带的文件（rt.jar 包中 java\lang\String.class），报错信息说没有 main 方法，就是因为加载的是 rt.jar 包中的 string 类。这样可以保证对 java 核心源代码的保护，这就是沙箱安全机制。



### 如何判断两个 class 对象是否相同？

- 类名相同
- 类加载器相同

### 什么地方会存储ClassLoader信息

- 方法区（元空间）[**常量池**、**运行时常量池**，*字符串常量池*、*静态变量*]

### 类的主动使用和被动使用？

区别：**类是否会初始化\<clint>**

#### **主动使用**

1. 创建类的实例

2. 访问某个类或接口的静态变量，或者对该静态变量赋值

3. 调用类的静态方法

4. 反射（比如：Class.forName（"com.atguigu.Test"））

5. 初始化一个类的子类

6. Java 虚拟机启动时被标明为启动类的类

7. JDK 7 开始提供的动态语言支持：

   java.lang.invoke.MethodHandle 实例的解析结果

   REF_getStatic、REF_putStatic、REF_invokeStatic 句柄对应的类没有初始化，则初始化

#### 被动使用

除了以上七种情况，其他使用 Java 类的方式都被看作是对<mark>类的被动使用</mark>，都<mark>不会导致类的初始化</mark>。

虽然是以Dson.count 形式调用的，但是因为count是Dfather的静态成员变量，所以只初始化Dfather类，而不初始化Dson类

```java
class Dfather{  
    static int count = 1;  
    static{  
        System.out.println("Initialize class Dfather");  
    }  
}  
  
class Dson extends Dfather{  
    static{  
        System.out.println("Initialize class Dson");  
    }  
}  
  
public class Test4 {  
    public static void main(String[] args) {  
        int x = Dson.count;  
    }  
}  
// Initialize class Dfather
```



## 栈

### [Java 虚拟机栈是什么？由什么组成？](https://javaguide.cn/java/jvm/memory-area.html#java-虚拟机栈)

除了一些 Native 方法调用是通过本地方法栈实现的(后面会提到)，其他**所有的 Java ==方法调用==都是通过栈来实现的**（也需要和其他运行时数据区域比如程序计数器配合）。只有入栈、出栈操作。

**组成：**

- 栈帧
  - 局部变量表：存放了==**编译期可知**的各种**基本数据类型**==（boolean、byte、char、short、int、float、long、double）（32位以内占用1slot，64位占用2slot）、以及**对象引用**（reference 类型，它不同于对象本身，可能是一个指向对象起始地址的**引用指针**，也可能是指向一个代表对象的句柄或其他与此对象相关的位置）
  - 操作数栈：方法执行过程中产生的**中间计算结果**
  - 动态链接：**一个方法需要调用其他方法**的场景，为了将**符号引用**转换为**调用方法的直接引用**，这个过程也被称为 **动态连接** 
  - 方法返回地址

> ![image-20200705204836977](http://42.192.130.83:9000/picgo/imgs/0ed2029b435d547547f32540077bb082.png)
>
> - 局部变量表
>
>   ![局部变量表](http://42.192.130.83:9000/picgo/imgs/local-variables-table.png)
>
> - 操作数栈
>
>   ![image-20200706090618332](http://42.192.130.83:9000/picgo/imgs/7f911f276f834d820fa09f31dd63a74b.png)
>
> - 动态链接
>
> ![img](http://42.192.130.83:9000/picgo/imgs/jvmimage-20220331175738692.png)

### 局部/本地变量表(Local Variables)是什么？有什么特点？

局部变量表也被称之为局部变量数组或本地变量表

- ==数字数组==，主要用于存储方法参数和定义在方法体内的局部变量。
- 私有数据，因此<mark>不存在数据安全问题</mark>
- ==局部变量表所需的容量大小是在编译期确定下来的==
- <mark>局部变量表中的变量只在当前方法调用中有效</mark>

> 1. 32 位以内的类型只占用一个 slot，64 位的类型（long 和 double）占用两个 slot。
>
> 2. 该对象引用 this 将会存放在 index 为 0 的 slot 处。
>
>    static内的this不存在于当前的局部变量表，不能使用this
>
> 3. 如果当前帧是由**构造方法**或者**实例方法**创建的，那么<mark>该对象引用 this 将会存放在 index 为 0 的 slot 处</mark>，其余的参数按照参数表顺序继续排列。

### 栈有几种返回方式？有几种错误？

Java 方法有两种返回方式，一种是 **return 语句正常返回**，一种是**抛出异常**。

- 都会栈弹出

错误：

1. **`StackOverFlowError`：** 若**栈的内存大小不允许**动态扩展，那么当线程请求栈的深度超过当前 Java 虚拟机栈的最大深度的时候，就抛出 `StackOverFlowError` 错误。
2. **`OutOfMemoryError`：** 如果栈的内存大小可以动态扩展， 如果虚拟机在动态**扩展栈时无法申请到足够的内存空间**，则抛出`OutOfMemoryError`异常。

### 静态变量与局部变量的对比 ？

**类变量（static变量）**表有两次初始化的机会：

1. ==linking prepare阶段== 对类变量（static变量）设置零值
2. ==初始化initial== 赋予程序员在代码中定义的初始值

局部变量：

1. 局部变量表不存在系统初始化的过程
2. 不存在初始化的过程，必须人为初始化

> - 类变量（static变量）会在==prepare==后设置默认值，不手动赋值也能用，==linking后赋设置的值==。
> - 实例变量：对象创建会在堆中分配空间。
> - ==**局部变量：必须手动赋值。**==

### [本地方法栈是什么？和虚拟机栈的区别？](https://javaguide.cn/java/jvm/memory-area.html#本地方法栈)

**虚拟机栈为虚拟机执行 Java 方法 （也就是字节码）服务，而本地方法栈则为虚拟机使用到的==Native 方法==服务。**

在 HotSpot 虚拟机中和 Java 虚拟机栈合二为一



### 操作数栈（Operand Stack）是什么？有什么作用？有什么特点？

- 计算中间结果，临时存储空间，返回值被压入栈。
- JVM 执行引擎的一个工作区。

特点：

1. 每一个操作数栈都会拥有一个明确的栈深度用于存储数值，其**所需的最大深度在编译期就定义好**了
2. 32bit 的类型占用一个栈单位深度
3. 不能使用索引，只能通过标准的入栈和出栈操作。

代码举例

```java
public void testAddOperation(){
    byte i = 15;
    int j = 8;
    int k = i + j;
}
```

字节码指令信息

```shell
public void testAddOperation();
    Code:
    0: bipush 15
    2: istore_1
    3: bipush 8
    5: istore_2
    6:iload_1
    7:iload_2
    8:iadd
    9:istore_3
    10:return
```

### 虚方法和非虚方法是什么？

> - 非虚方法：**编译期确定**，运行时**不可变**
>   - 静态方法、私有方法、final 方法、实例构造器、父类方法（`super()`）都是非虚方法
>   - 以上方法都不能被重写
> - **虚方法**：运行时可变，父类指针可以指向子类方法
>   - 多态

### 动态类型语言和静态类型语言的区别？

- 静态类型：**编译期进行类型检查**Java
- 动态类型：**运行期间检查变量值** Python、Js

动态类型语言和静态类型语言两者的区别就在于**==对类型的检查==是在编译期还是在运行期**

### 方法返回地址（return address）是什么？

存放调用该方法的 **pc 寄存器的值**。

返回地址是指函数被调用后，在执行完函数体内的代码后需要返回到调用点的地址。

一个方法的结束，有两种方式：

- 正常执行完成 <mark>调用者的 pc 计数器的值作为返回地址，即调用该方法的指令的下一条指令的地址</mark>
- 出现未处理的**异常**，非正常退出；返回地址是要通过==**异常表**==来确定，栈帧中一般不会保存这部分信息。

> 当一个方法开始执行后，只有两种方式可以退出这个方法：
>
> 1. 执行引擎遇到任意一个方法返回的字节码指令（return），会有返回值传递给上层的方法调用者，简称<mark>正常完成出口</mark>；
>    - 一个方法在正常调用完成之后，究竟需要使用哪一个返回指令，还需要根据方法返回值的实际数据类型而定。
>    - 在字节码指令中，返回指令包含 **ireturn**（当返回值是 boolean，byte，char，short 和 int 类型时使用），lreturn（Long 类型），freturn（Float 类型），dreturn（Double 类型），areturn。另外还有一个 return 指令声明为 void 的方法，实例初始化方法，类和接口的初始化方法使用。
> 2. 在方法执行过程中遇到异常（Exception），并且这个异常没有在方法内进行处理，也就是只要在**本方法的异常表（在方法区）**中没有搜索到匹配的异常处理器，就会导致方法退出，简称<mark>异常完成出口</mark>。

### 举例栈溢出的情况？

StackOverFlowError

- 帧过大，过多。

1. **==递归==调用层次过深**：当递归调用层次过多时，每次函数调用都在栈上分配内存，缺乏终止条件或不合适的终止条件会迅速耗尽栈空间，导致溢出。
2. **存在==大量局部变量==**：函数内部定义过多局部变量或者单个变量占用大量空间会增加栈空间的压力，可能导致栈溢出。
3. **存在==无限循环==**：没有停止条件的循环会不断向栈中添加数据，最终耗尽栈空间导致溢出。
4. **存在过大的数据结构**：尝试在栈上分配过大的数据结构，特别是递归创建大型结构时，可能迅速耗尽栈空间。

### 如何调整栈的大小？

- 通过 -Xss 设置栈的大小 Stack Size
- 默认1M

### 调整栈大小，就能保证不出现溢出么？

- 不能保证不溢出

  - 如递归、循环无终止条件，无法避免栈溢出。

  - 内存泄露（无法正常分配空间）

### 分配的栈内存越大越好么？

- 不一定，整个空间是有限的。

### 方法中定义的局部变量是否线程安全？

- 线程安全



## [堆](https://javaguide.cn/java/jvm/memory-area.html#堆)

### 什么是堆，里面包含了什么？不同版本对比？

- 存放对象实例

- 不同版本对比：

  - 1.6 只存对象
  - 1.7 字符串常量池、静态变量存储在堆
  - 1.8 同1.7

- 组成：

  - 新生代（Eden , s0, s1）
  - 老年代  (Tenured)
  - 永久代（1.7之前交永久代，1.8开始叫元空间，并且存放在本地内存）

  ![image-20200707075847954](http://42.192.130.83:9000/picgo/imgs/f3ee86daaf5076fe22265ffcaa831175.png)

### 新生代老年代的工作模式？

- 对象先在Eden分配
- **Minor GC**后，存活对象进入S0或者S1，并标记年龄+1
- S0，S1复制算法
- 当年龄超过15时还没被GC，就进入老年代。
- 老年代不足时，使用**Major GC**清理

==**大对象**==直接分配到老年代（尽量**避免过多的大对象**）

<mark>可以设置参数：`-Xx:MaxTenuringThreshold= N`设置进入老年代的代数</mark>

![第08章_新生代对象分配与回收过程 红色为被回收的，绿色里面的数字为经历的GC代数](http://42.192.130.83:9000/picgo/imgs/第08章_新生代对象分配与回收过程.jpg)

### 堆空间常见的错误？

1. **`java.lang.OutOfMemoryError: GC Overhead Limit Exceeded`**：**垃圾回收只能获得很小的内存。（内存泄露）**当 JVM 花太多时间执行垃圾回收并且只能回收很少的堆空间时，就会发生此错误。
2. **`java.lang.OutOfMemoryError: Java heap space`** :**堆空间不够存放新对象了。**假如在创建新的对象时, 堆内存中的空间不足以存放新创建的对象, 就会引发此错误。(和配置的最大堆内存有关，且受制于物理内存大小。最大堆内存可通过`-Xmx`参数配置，若没有特别配置，将会使用默认值，详见：[Default Java 8 max heap sizeopen in new window](https://stackoverflow.com/questions/28272923/default-xmxsize-in-java-8-max-heap-size))

### 为什么这样设计堆？

- 主要是根据**不同生命周期**的对象进行不同的处理，有助于**提高GC效率**（Minor GC、Major GC）
- <mark>关于垃圾回收：**频繁在新生区收集**，很少在老年代收集，**几乎不再永久代和元空间进行收集**</mark>

### Minor GC，MajorGC、Full GC的区别？触发条件？

- Minor GC：新生代，**Eden不足时**。
- Major GC：老年代，老年代不足时。
- Full GC：对整个堆
  - 老年代不足，且无法MinorGC解决
  - System.gc()
  - 方法区空间不足

> 由 Eden 区、survivor space0（From Space）区向 survivor space1（To Space）区复制时，**对象太大放不进To（Survivor），则把该对象转存到老年代**，且老年代的可用内存小于该对象大小

### 如何设置堆大小？默认几个代之间的比例？

- -Xms1m 启动时的初始堆大小
- -Xmx2m 设置JVM可以使用的最大堆大小

`-Xms1m -Xmx1m -XX:+PrintGCDetails`

> 官网地址：[https://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html)
>
> ```java
> // 详细的参数内容会在JVM下篇：性能监控与调优篇中进行详细介绍，这里先熟悉下
> -XX:+PrintFlagsInitial  //查看所有的参数的默认初始值
> -XX:+PrintFlagsFinal  //查看所有的参数的最终值（可能会存在修改，不再是初始值）
>     
>     
> -Xms  //初始堆空间内存（默认为物理内存的1/64） X memory initSize
> -Xmx  //最大堆空间内存（默认为物理内存的1/4） X memory maxSize
> -Xmn  //设置新生代的大小。（初始值及最大值） 
>     
>     
> -XX:NewRatio  //配置新生代与老年代在堆结构的占比
> -XX:SurvivorRatio  //设置新生代中Eden和S0/S1空间的比例
> -XX:MaxTenuringThreshold  //设置新生代垃圾的最大年龄
> -XX:+PrintGCDetails //输出详细的GC处理日志
> //打印gc简要信息：①-Xx：+PrintGC ② - verbose:gc
> -XX:HandlePromotionFalilure：//是否设置空间分配担保
> ```
>

### 为什么有Thread Local Allocation Buffer？如何实现？

==并发安全==

- **堆区是线程共享区域、线程不安全**，任何线程都可以访问到堆区中的共享数据
- 由于对象实例的创建在 JVM 中非常频繁，因此在并发环境下从堆区中划分内存空间是线程不安全的
- 为避免**多个线程操作同一地址**，需要使用加锁等机制，进而影响分配速度。

**实现：**

> 对Eden继续划分，为每个线程分配了私有缓存区域。

- 从内存模型而不是垃圾收集的角度，对 ==Eden 区域继续进行划分==，JVM 为<mark>每个线程分配了一个私有缓存区域</mark>，它包含在 Eden 空间内。

<img src="http://42.192.130.83:9000/picgo/imgs/90162691ef6b0f4dc96be1c1ab02dc8b.png" alt="image-20210510114110526"  />

### 堆是分配对象的唯一选择么？

- 不是。经过逃逸分析后，有可能直接分配到栈上。
- 如果没有逃逸，就可能分配到栈上。

如果经过**逃逸分析（Escape Analysis）**后发现，一个对象并**没有逃逸出方法**的话，那么就可能被**优化成栈上分配**。这样就无需在堆上分配内存，也无须进行垃圾回收了。这也是最常见的堆外存储技术。

在《深入理解 Java 虚拟机》中关于 Java 堆内存有这样一段描述：

> 随着 JIT 编译期的发展与<mark>逃逸分析技术</mark>逐渐成熟，<mark>栈上分配</mark>、<mark>标量替换优化技术</mark>将会导致一些微妙的变化，所有的对象都分配到堆上也渐渐变得不那么“绝对”了。
>
> **举例**
>
> ```java
> public void f() {
>     Object hellis = new Object();
>     synchronized(hellis) {
>         System.out.println(hellis);
>     }
> }
> ```
>
> 代码中对 hellis 这个对象加锁，但是 hellis 对象的生命周期只在 f()方法中，并不会被其他线程所访问到，所以在 JIT 编译阶段就会被优化掉，优化成：
>
> ```java
> public void f() {
>     Object hellis = new Object();
> 	System.out.println(hellis);
> }
> ```
>

### 逃逸分析是什么？

- Java Hotspot 编译器能够分析出一个**新的对象的引用的使用范围**从而决定**是否要将这个对象分配到堆**上。

#### 举例 1

- 其他方法去修改sb，就**发生逃逸**，分配到堆上，不会进行栈分配。

```java
public static StringBuffer createStringBuffer(String s1, String s2) {
    StringBuffer sb = new StringBuffer();
    sb.append(s1);
    sb.append(s2);
    return sb;
}
```

- 避免逃逸，会进行栈分配

```java
public static String createStringBuffer(String s1, String s2) {
    StringBuffer sb = new StringBuffer();
    sb.append(s1);
    sb.append(s2);
    return sb.toString();
}
```

#### **参数设置**

在 JDK 6u23 版本之后，HotSpot 中默认就已经开启了逃逸分析

如果使用的是较早的版本，开发人员则可以通过：

- 选项“`-XX:+DoEscapeAnalysis`"显式开启逃逸分析
- 通过选项“`-XX:+PrintEscapeAnalysis`"查看逃逸分析的筛选结果

**结论**：<mark>开发中能使用局部变量的，就不要使用在方法外定义。</mark>

## 方法区

### 方法区是什么？包含了什么？作用是什么？

- 1.6 方法区（也叫**永久代**）类常量池、运行时常量池、**静态变量、字符串常量池**
- 1.7 方法区（也叫永久代）类常量池、运行时常量池
- 1.8 方法区变为元空间，移动到直接内存

1. 常量池：每个加载的类型（类 class、接口 interface、枚举 enum、注解 annotation）的**全名、父类全名、修饰符**（public，private，protected，static，final，volatile，transient）、**接口列表**；**运行时常量池**；**方法信息**
2. **non-final 的类变量**，1.6的静态变量；**全局变量**。
3. 静态类

```java
public class StaticObjTest {
      // 静态类存储在元空间（方法区）中 
      static class Test{
          // 1.6及之前静态*变量*存方法区 ，1.7之后静态*变量*在堆中；对象实体一直在堆中
          static ObjectHolder staticObj = new ObjectHolder();
          // 成员*变量*存堆中
          ObjectHolder instanceObj = new ObjectHolder();
          
          void foo(){
              // *变量*存放在foo()方法中的栈帧中的局部变量表中，对象存储在堆中。
              ObjectHolder localObj = new ObjectHolder();
              System.out.println("done");
          }
      }
      
      
      private static class ObjectHolder{
          
      }
}
```

![image-20200708211541300](http://42.192.130.83:9000/picgo/imgs/1a3aa55257c3150d78327542e5ca230e.png)

![image-20200708211609911](http://42.192.130.83:9000/picgo/imgs/e0f65fc4228d9b6573ae1b23d9a1558b.png)

![image-20200708211637952](http://42.192.130.83:9000/picgo/imgs/c3ed969b0d2bad704c22481208e5dd10.png)

![image-20200708161856504](http://42.192.130.83:9000/picgo/imgs/fbe3915506e7979c7d591d17c216fbb1.png)

### 方法区的生命周期？

- ==方法区在 JVM 启动的时候被创建==，并且它的实际的物理内存空间中和 Java 堆区一样都==可以是不连续==的。

### 方法区的错误？

`java.lang.OutOfMemoryError: PermGen space` 或者`java.lang.OutOfMemoryError: Metaspace`

**举例 2**

```java
/**
 * 不断创建Class加载到方法区
 * jdk8中：
 * -XX:MetaspaceSize=10m-XX:MaxMetaspaceSize=10m
 * jdk6中：
 * -XX:PermSize=10m-XX:MaxPermSize=10m
 */
public class OOMTest extends ClassLoader{
    public static void main(String[] args){
        int j = 0;
        try{
            OOMTest test = new OOMTest();
            for (int i=0;i<10000;i++){
                //创建Classwriter对象，用于生成类的二进制字节码
                ClassWriter classWriter = new ClassWriter(0);
                //指明版本号，public，类名，包名，父类，接口
                classWriter.visit(Opcodes.V1_6, Opcodes.ACC_PUBLIC, "Class" + i, nu1l, "java/lang/Object", null);
                //返回byte[]
                byte[] code = classWriter.toByteArray();
                //类的加载
                test.defineClass("Class" + i, code, 0, code.length); //CLass对象
                j++;
            }
        } finally{
            System.out.println(j);
        }
    }
}
```

### 如何解决OOM？

> 1. 导出dump快照，使用Memory Analyzer Tool、JProfiler 分析**内存泄露**（栈指向堆，但没被使用，迟迟不能被GC）还是**溢出**。 `-XX:HeapDumpPath=<path> 指定heap转储文件的存储路径，默认当前目录`
> 2. 如果是内存泄漏，可进一步通过工具查看泄漏对象到 GC Roots 的引用链。
> 3. 检查虚拟机的堆参数（`-Xmx`与`-Xms`）

### 运行时常量池 VS 常量池

常量池主要在编译期确定并存储在class文件中，而运行时常量池则是在运行时动态地管理和添加常量。

- 常量池：存储**类相关的信息**（如常量、字段和方法信息）的区域。（类相关信息程**序启动时**就被加载进来。）==类信息等==

- 运行时常量池，**动态解析符号引用**，将符号引用转换为直接引用。`System.out.println`这个符号引用会被解析为`println`方法具体代码在内存中的地址，这个过程就是动态链接。

  **运行时常量池就是Class中数据在运行时的表示形式**，Class(常量池)---->运行时常量池（真实地址）**动态性**

  **运行时常量池存储真实地址 **==动态信息==；动态性这一重要特征，意味着它的字面量**可以动态地添加，符号引用也可以解析为直接引用。**
  
  运行时常量池和class文件的常量池是一一对应的，它就是class文件的常量池来构建的。

> 常量池是Java虚拟机（JVM）中用于存储类相关的信息（如常量、字段和方法信息）的区域。在Java程序的运行过程中，JVM会为每个已加载的类创建一个对应的Class对象，并把这个Class[对象存储](https://cloud.baidu.com/product/bos.html)在方法区（Method Area）中。类的元数据信息，例如字段信息、方法信息。
>
> 运行时常量池是Java HotSpot虚拟机中的一个特殊数据结构，它是方法区的一部分。运行时常量池主要负责动态解析符号引用，将符号引用转换为直接引用。这个过程称为符号解析（Symbolic Resolution）和动态链接（Dynamic Linking）。通过运行时常量池，JVM可以在运行时解析类的元数据信息，从而提高了程序的运行效率和动态性。

> #### demo  
>
> ```java
> public class SimpleClass {  
>     public static final String CONSTANT_STRING = "Hello, World!";   // CONSTANT_STRING 是一个字符串常量，它会在编译期间被放入常量池中 System.out、println等方法和类引用也会被作为符号引用放入常量池
>     public void sayHello() {  
>         System.out.println(CONSTANT_STRING);  
>     }  
> }
> // 运行时常量池：当SimpleClass被加载到JVM中时，其常量池中的内容会被加载到运行时常量池中。如果程序在运行时动态地创建了一个新的字符串，这个新创建的字符串常量也会被添加到运行时常量池中（Java字符串常量池是运行时常量池的一部分）
> // 动态链接：在sayHello方法被调用时，System.out.println这个符号引用会被解析为println方法具体代码在内存中的地址
> ```

### 为什么需要常量池？

- **JVM需要常量池的原因是为了==提高性能==和==减少内存==占用**。

  基本的元素存储在这，使用的时候调用即可

  常量池是JVM内存中的一块区域，用于**存储编译期生成的各种==字面量和符号引用==**。在程序运行时，JVM会将这些符号引用转换为直接引用，从而可以**快速地访问到对应的内存地址。**由于常量池中的数据是编译期就确定的，因此可以被共享和重用，从而减少了内存占用。

> 常量池、可以看做是==**一张表**==，虚拟机指令**根据这张常量表找到要执行的类名、方法名、参数类型、字面量等类型**

- ==运行时常量池（Runtime Constant Pool）是**方法区**的一部分。==
- <mark>常量池表（Constant Pool Table）是 **Class 文件**的一部分，用于存放编译期生成的各种字面量与符号引用，这部分内容将在类加载后存放到方法区的运行时常量池中。</mark>
- 运行时常量池，在加载类和接口到虚拟机后，就会创建对应的运行时常量池。
- JVM **为每个已加载的类型（类或接口）都维护一个常量池**。池中的数据项像数组项一样，是通过<mark>索引访问</mark>的。
- 运行时常量池中包含多种不同的常量，包括编译期就已经明确的数值字面量，也包括到运行期解析后才能够获得的方法或者字段引用。此时不再是常量池中的符号地址了，这里换为<mark>真实地址</mark>。
- 运行时常量池，相对于 Class 文件常量池的另一重要特征是：具备<mark>动态性</mark>。

### 为什么永久代要被元空间替代？

> **永久代（方法区、元空间）设置空间大小**是很难确定的，
>
> 1. **大了浪费**
> 2. **小了Full GC，Perm区OOM**，动态加载类过多，容易产生 Perm 区的 oom
>
> 元空间并不在虚拟机中，而是使用**本地内存**。

### StringTable 为什么要调整位置？

jd7之前在方法区（永久代）中，jdk7 中将 StringTable 放到了堆空间中，**==永久代（方法区）==的回收效率很低**，在 **full gc** 的时候才会触发。

大量的字符串被创建，回收效率低，导致永久代内存不足。**放到堆里，能及时回收内存**

### 方法区垃圾回收的条件？

1. 常量

   <mark>只要常量池中的常量没有被任何地方引用，就可以被回收</mark>

2. 类型（Class）是否回收

   - 该类**所有的实例**都已经被回收
   - 加载该类的**类加载器**已经被回收（几种类加载器很难被回收的）
   - 该类对应的 java.lang.**Class 对象没有在任何地方被引用**

在大量使用反射、动态代理、CGLib 等字节码框架，动态生成 JSP 以及 OSGi 这类频繁自定义类加载器的场景中，<u>通常都需要 Java 虚拟机具备类型卸载的能力，以保证不会对方法区造成过大的内存压力</u>。

## 对象实例化及直接内存

### 创建对象的方式？

1. new：Xxx 的静态方法，XxxBuilder/XxxFactory 的静态方法
2. Class.newInstance 只能调用空参public
3. Class.getConstuctor.invoke，可以调用**多参数的方式**，权限没有要求。
4. clone()。Cloneable接口
5. 序列化：网络、文件ObjectInputStream
6. 第三方库 Objenesis

### Object o = new Object()创建对象的步骤？

1.  判断对象对应的类是否**加载、链接（verify、prepare、resolve）、初始化**（类元信息）
   - 检查 new 是否在常量池中存在。
   - 没有初始化，在双亲委派模式下，使用当前**类加载器**以 ClassLoader + 包名 + 类名为 key 进行查找**对应的 .class 文件**；
2. 为对象分配内存
3. 处理并发问题，CAS、TLAB
4. 初始化分配到的内存（**堆中的对象**的参数初始化）
5. 设置对象的**对象头（元数据信息、HashCode、GC信息、锁信息）**
6. 执行 **init 方法（构造器）**进行初始化；初始化成员变量，执行实例化代码块，调用类的构造方法

### 对象头（Header）包含了什么？

对象头包含了两部分，分别是<mark>运行时元数据（Mark Word）</mark>和<mark>类型Class指针</mark>。如果是数组，还需要记录数组的长度

> #### 运行时元数据
>
> - **哈希**值（HashCode）
> - **GC 分代**年龄
> - **锁**状态标志
> - 线程**持有的锁**
> - 偏向线程 ID
> - 翩向时间戳
>
> #### 类型指针
>
> - ==指向（方法区、元空间）类元数据 InstanceClass==，确定该对象所属的类型。

### 绘制下图的内存结构

```java
public class Customer{
 int id = 1001;
 String name;
 Account acct;

 {
     name = "匿名客户";
 }

 public Customer() {
     acct = new Account();
 }
}

public class CustomerTest{
 public static void main(string[] args){
     Customer cust=new Customer();
 }
}
```

![第10章_图示对象的内存布局](http://42.192.130.83:9000/picgo/imgs/第10章_图示对象的内存布局.jpg)



### JVM 是如何通过**栈帧中的对象引用访问到其内部的对象**实例呢？

- 栈帧（局部变量表）---> 堆（对象实体）--->方法区（类型信息）

### 什么是句柄访问？优缺点？HotSpot采用了什么？

对象和类型分开存储。

优点：改变对象不用改变类型指针。

![image-20210510230241991](http://42.192.130.83:9000/picgo/imgs/59cc079fe02b7a5836ff7c2c7fffb635.png)

直接指针（HotSpot 采用）

- **对象**实体存储**类型指针**

  优点：访问方便

![image-20210510230337956](http://42.192.130.83:9000/picgo/imgs/694601dcb023c6d10168a00fe000becc.png)



## 执行引擎

### 执行引擎是什么？包含了什么？各自的作用是什么？

- **解释器**。读取**字节码.class**并将其解释（转换）为**机器码**（本机代码）并按顺序执行。
  - 使得Java程序可以在不同平台上运行，无需重新编译。这种特性使得Java具有很高的可移植性，它允许开发人员**编写一次代码，然后在多个平台上运行**，大大简化了跨平台开发的难度。

- **JIT编译器**。为了克服解释器每次都解释，甚至多次解释相同的方法，降低系统性能的问题而被引入。
- **垃圾回收器**。负责回收JVM中的不再使用的内存空间。



### 执行引擎的工作流程？

**输入的是字节码二进制流，输出的是执行过程**

1. 执行引擎根据PC寄存器，需要执行什么字节码
2. 执行完后更新PC寄存器
3. 执行的过程中，根据 **局部变量表、对象头元数据指针**定位实例信息

![image-20200710081627217](http://42.192.130.83:9000/picgo/imgs/a03c1910e508456b690ec9088300de5f.png)

### Java 代码编译和解释?

 Java 通常被归类为“编译型”语言，但实际上它的运行过程包含编译和解释两个阶段

编译阶段：转换为中间语言，再进行优化或执行。

1. **前端编译（javac）**：Java代码的编译，javac（.java）将源码编译为JVM字节码（.class）**静态**
2. **后端编译（即时编译JIT）：**运行时将JVM字节码经过JIT(即时)编译器转换为本地机器代码。**动态**

解释阶段：采用**逐行解释**的方式执行。

![image-20200710082141643](http://42.192.130.83:9000/picgo/imgs/e2a8ec10bc97a061e4b77abf63936ba1.png)

![image-20200710082433146](http://42.192.130.83:9000/picgo/imgs/93e5f0b67767b7d783ace2471447f449.png)

![image-20200710083036258](http://42.192.130.83:9000/picgo/imgs/bf1139f9652e2a1ac0cab00df869e23e.png)

### 为什么 Java 是半编译半解释型语言？

- ==同时结合了**编译**和**解释**==
- 编译器：**速度快**；但编译器要想发挥作用，把代码编译成本地代码，需要一定的执行时间。
- 解释器：当程序启动后，**解释器可以马上发挥作用（逐行）**，省去编译的时间，立即执行。

JDK1.0 时代，将 Java 语言定位为“解释执行”还是比较准确的。再后来，Java 也发展出可以直接生成本地代码的编译器。现在 JVM 在执行 Java 代码的时候，通常都会将**解释执行与编译执行**二者结合起来进行。

**图示**

![image-20200710083656277](http://42.192.130.83:9000/picgo/imgs/f10a353479e6d2bca99abd4781fd9940.png)

### JIT的工作原理？热点代码及探测技术？

- ==**缓存**函数体编译成机器码，执行时只执行机器码（编译码）==，不用重新编译

**JIT 的即时编译的技术**，目的是避免函数被解释执行，而是将整个函数体编译成机器码，每次**函数执行时，只执行编译后的编译码**即可，这种方式大大的提升了执行效率。

#### 什么时候使用JIT编译器？

- “热点代码”，计数器来统计 ==方法调用次数、循环体次数==
  - **方法调用计数器**用于统计**方法的调用次数**
  - **回边计数器**则用于统计**循环体执行的循环次数**

## [StringTable](./StringTable.md)

## 面试真题

### 说一下 JVM 内存模型吧，有哪些区？分别干什么的？

- 堆：几乎所有的对象实例、1.8后字符串常量池、静态变量
- 虚拟机栈：方法真正的执行的过程｛栈帧｛局部变量表、操作数栈、动态链接、方法返回地址｝}
- 本地方法栈：调用其他语言的native方法
- CPU计数器：当前线程所执行的字节码
- 方法区（元空间）：类信息，常量，静态变量，运行时常量池

### Java8 的内存分代改进 JVM 内存分哪几个区，每个区的作用是什么？

- 将永久代变为元空间，并存放在**本地内存**

> - 堆：几乎所有的对象实例、1.8后字符串常量池、静态变量
> - 虚拟机栈：方法真正的执行的过程｛栈帧｛局部变量表、操作数栈、动态链接、方法返回地址｝}
> - 本地方法栈：调用其他语言的native方法
> - CPU计数器：当前线程所执行的字节码
> - 方法区（元空间）：类信息，常量，静态变量，运行时常量池

### JVM 内存分布/内存结构？栈和堆的区别？堆的结构？为什么两个 survivor 区？

> - 堆：几乎所有的对象实例、1.8后字符串常量池、静态变量
> - 虚拟机栈：方法真正的执行的过程｛栈帧｛局部变量表、操作数栈、动态链接、方法返回地址｝}
> - 本地方法栈：调用其他语言的native方法
> - CPU计数器：当前线程所执行的字节码
> - 方法区（元空间）：类信息，常量，静态变量，运行时常量池

> - 堆是存储大部分对象的；栈是通过入栈出栈进行调用方法的。
> - 堆一般比较大
> - 栈生命周期一般比较短，需要频繁出入栈进行调用。

> - **复制算法**（GC的效率），对象会在 Survivor 区之间来回移动，直到它们变得足够老，然后被移动到老年代。
>
> 优点：快
>
> 缺点：需要两倍内存，回收后不连续。



### Eden 和 survior 的比例分配

默认情况811，解决内存碎片的问题。

### 为什么要有新生代和老年代？

**1. 实现高效回收**

- 新生代为新建的对象，随时可能被回收
- 老年代为不经常被回收的对象

**2. 提升程序性能**

- 因为Minor GC效率比Major GC要快很多，并且STW时间会比较短。主要为了提升GC的效率。



### 讲讲 jvm 运行时数据库区什么时候对象会进入老年代？

创建时先进入Eden，年龄为1；后面每次Minor GC就会进入S0或S1，在S0和S1之间进行复制算法GC，如果经过15此GC还没有被GC，就进入老年代。

### JVM 的内存模型，Java8 做了什么改动？

- 将永久代取消，变为元数据，并放在了直接内存

  **永久代（方法区、元空间）设置空间大小**是很难确定的，

  1. **设置大了浪费**
  2. **小了Full GC，Perm区（永久区）OOM**，动态加载类过多，容易产生 Perm 区的 oom

  元空间并不在虚拟机中，而是使用**本地内存**。

### java 内存分配 jvm 的永久代中会发生垃圾回收吗？

- 会的，1.6、1.7的永久代

  - 常量

    <mark>只要常量池中的常量没有被任何地方引用，就可以被回收</mark>

  - 类型（Class）是否回收

    - 该类**所有的实例**都已经被回收
    - 加载该类的**类加载器**已经被回收（几种类加载器很难被回收的）
    - 该类对应的 java.lang.**Class 对象没有在任何地方被引用**

  在大量使用反射、动态代理、CGLib 等字节码框架，动态生成 JSP 以及 OSGi 这类频繁自定义类加载器的场景中，<u>通常都需要 Java 虚拟机具备类型卸载的能力，以保证不会对方法区造成过大的内存压力</u>。
