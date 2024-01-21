## 面向对象特性 3

- 封装：将事物抽象成类，对某些信息隐藏
- 继承：类可以派生
- 多态：不同对象调用相同方法有不同结果。，重载；运行时，使用父类指向子类对象。
  - 编译时 重载：同名方法，顺序、类型、返回值。
  - 运行时 覆盖：`Parents child = new Child();`  `Collection co = new ArrayList<>();`

## 内部类有哪些?有哪些应用。

- 静态内部类

  ```java
  public class JavaTest02{
      public static class InnerStaticClass extends Object implements innerInterface{
      }
  }
  ```

  - 集合类**HashMap**内部就有一个静态内部类**Entry**

- 成员内部类

   不能定义静态方法静态变量

  ```java
  class Out {
      public class Inner {
      }
      public static void main(String[] args) {
          Out out = new Out();
          Inner inner = out.new Inner();
      }
  }
  ```

- 局部（方法）内部类

  - 只能在方法内使用的类

- 匿名内部类

  ```java
  new Thread(new Runnable() {
      @Override
      public void run() {
  
      }
  });
  ```

  

## JDK与JRE有什么区别？

- JDK java development kit 运行工具，包括jre，编写运行
- JRE Java runtime enviroment 运行的环境，只能运行

## 访问修饰符

- private 当前类
- default 当前包
- protected 当前类的子类，当前包
- public

## 接口和抽象类

- 同：实例化，必须实现或重写抽象类（抽象方法）、接口（接口内定义的方法）内的方法。
- 不同：
  - implement、extends；
  - 可以多实现，不能多继承；
  - **接口有方法定义、变量（默认就是final static)**，**抽象类可以方法、属性**。

## 多重继承？ 3

- 多层继承
- 内部类
- 接口

1. 使用接口实现多继承

```java
interface A {
    void m();
}

interface B {
    void m();
}

class C implements A, B {
    public void m() {
        A.super.m(); // 调用A的m方法
        // 或者
        B.super.m(); // 调用B的m方法
    }
}
```

- 避免二义性：A.method()和B.method()是哪个呢？
- 影响性能

## 重写（覆盖）和重载？

- 重写为子类重写父类方法，**参数返回值都要一样**。
- 重载为同一个类里的，可以选择**参数顺序、类型、数量、返回值（只有返回值不行）**进行重载

## final、finally和finalize的区别是什么？

- final 

  - 变量 表示常量
  - 类 表示不能被继承
  - 方法 不能被覆盖

- finally 为异常处理的一部分，无论如何都会执行finally 比如流的close一般会在这。

  - **当try/catch语句块中有return时，==finally语句块中的代码会在return之前执行==**

- finalize 为Object的一个方法，用于回收对象占用的内存。

  > ```java
  > protected void finalize() throws Throwable { }
  > ```
  >
  > ```java
  > @Override
  > protected void finalize() throws Throwable {
  >  super.finalize();
  > } // 可以重写
  > ```

## finally是否一定会执行？在 finally 语句块中使用 return

- trycatch之前就异常

- try中强制退出 `System.exit(0)`

  > **注意：不要在 finally 语句块中使用 return!** 当 try 语句和 finally 语句中都有 return 语句时，try 语句块中的 return 语句会被忽略。这是因为 try 语句中的 return 返回值会先被暂存在一个本地变量中，当执行到 finally 语句中的 return 之后，**存储的本地变量的值就变为了 finally 语句中的 return 返回值。**
  >
  > [jvm 官方文档open in new window](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html#jvms-4.10.2.5)中有明确提到：
  >
  > > If the `try` clause executes a *return*, the compiled code does the following:
  > >
  > > 1. Saves the return value (if any) in a local variable.
  > > 2. Executes a *jsr* to the code for the `finally` clause.
  > > 3. Upon return from the `finally` clause, returns the value saved in the local variable.

## 如何使用 `try-with-resources` 代替`try-catch-finally`？

-  `try-with-resources` **try(资源){}catch**

> 在Java 7及以后的版本中，`try-with-resources`语句被引入，它确保**在程序完成后，任何被标记为资源的对象都会被自动关闭**。这主要涉及实现了`AutoCloseable`接口的任何对象。使用`try-with-resources`语句，无需显式调用`close()`方法，因为这会在`try`语句结束后自动完成。
>
> ```java
> public class TryWithResourcesExample {
>     public static void main(String[] args) {
>         try (BufferedReader br = new BufferedReader(new FileReader("input.txt"))) {
>             String line;
>             while ((line = br.readLine()) != null) {
>                 System.out.println(line);
>             }
>         } catch (IOException e) {
>             e.printStackTrace();
>         }
>     }
> }
> ```
>
> `BufferedReader`和`FileReader`实例被创建时，它们被声明在`try`语句的括号内。无论`try`块中的代码是否正常完成，都会自动调用`BufferedReader`和`FileReader`的`close()`方法。如果发生异常，也会调用`close()`方法，以防止资源泄漏。

## 什么是泛型？有什么作用？3

### 什么是泛型？

> Java 泛型（generics）是 JDK 5 中引入的一个新特性, 泛型提供了编译时类型安全检测机制，该机制允许程序员在编译时检测到非法的类型。
>
> 泛型的本质是**参数化类型**，也就是说所操作的数据类型被指定为一个参数。
>
> ==对于JVM其实都是Object 但这样写就不用强转了==

### 泛型类型

- 泛型类

  ```java
  //此处T可以随便写为任意标识，常见的如T、E、K、V等形式的参数常用于表示泛型
  //在实例化泛型类时，必须指定T的具体类型
  public class Generic<T>{
      private T key;
  }
  ```

- 泛型接口

  ```java
  public interface Generator<T> {
      public T method();
  }
  class GeneratorImpl<T> implements Generator<String>
      @Override
      public String method() {
          return "hello";
      }
  }
  ```

- 泛型方法

  ```java
  public static < E > void printArray( E[] inputArray )
  ```

## 泛型类型擦除?为什么使用？可以获取泛型吗？

[面试官：说说什么是泛型的类型擦除？ - 掘金 (juejin.cn)](https://juejin.cn/post/6999797611146248222)

- **泛型类型参数会被编译器在编译的时候去掉**
  - T会变成Object
  - \<T extends Integer> 变为 Integer类型擦除的主要目的是**避免过多的创建类而造成的运行时的过度消耗**。试想一下，如果用`List<A>`表示一个类型，再用`List<B>`表示另一个类型，以此类推，无疑会引起类型的数量爆炸。

- 反射获取泛型 **只能获取到泛型的参数占位符**，而不能获得代码中真正的泛型类型

  ```java
  Map<String,Integer> map=new HashMap<>();
  System.out.println(Arrays.asList(map.getClass().getTypeParameters()));
  // [K, V]
  ```

> ```java
> public static void main(String[] args) {
>     List<String> list1=new ArrayList<String>();
>     List<Integer> list2=new ArrayList<Integer>();
>     System.out.println(list1.getClass()==list2.getClass());
> }
> ```
>
> `ArrayList<String>`和`ArrayList<Integer>`在编译时是不同的类型，但是在编译完成后都被编译器简化成了`ArrayList`，这一现象，被称为泛型的**类型擦除**(Type Erasure)。
>
> - 类型擦除使得类型**参数只存在于编译期**
>
> ```java
> public class Fx {
>     public static void main(String[] args) {
>         String hello = new Fx().get("Hello");
>         System.out.println(hello);
>     }
>     public <T> T get(T t) {
>         return t;
>     }
> }
> ```
>
> - 使用Jad反编译字节码
>
> ```java
> public class Fx
> {
>     public Fx()
>     {
>     }
>     public static void main(String args[])
>     {
>         String s = (String)(new Fx()).get("Hello");
>         System.out.println(s);
>     }
>     public Object get(Object obj)
>     {
>         return obj;
>     }
> }
> ```

- 编译的时候不能随便使用，但编译的时候可以随便使用对象。

## JAVA 序列化

### Java序列化反序列化是什么？

- **序列化**：将数据结构或对象转换成二进制字节流的过程
- **反序列化**：将在序列化过程中所生成的二进制字节流转换成数据结构或者对象的过程

### 序列化有什么用？有什么特点？

作用：持久化 Java 对象（存入Redis），对象存取内存，在网络中传输Java对象。

特点：

- **序列化不保存静态变量**

- 序列化Id必须一致才能序列化 `private static final long serialVersionUID = 1L`  **Java序列化库的默认serialVersionUID是1L**

  只是用来被 JVM 识别，实际并没有被序列化 (static 属于类不会被序列化)

### 序列化怎么实现？

实现：

- 使用**Serializable** **实现序列化**，要想将父类对象也序列化，就需要让父类也实现 Serializable 接口。

- **ObjectOutputStream** **和** **ObjectInputStream** **对对象进行序列化及反序列化**

  通过 ObjectOutputStream 和 ObjectInputStream 对对象进行序列化及反序列化

- **writeObject** **和** **readObject** **自定义序列化策略**

  在类中增加 writeObject 和 readObject 方法可以实现自定义序列化策略。

```java
import java.io.*;

// 实现 Serializable 接口
public class MyClass implements Serializable {
    private static final long serialVersionUID = 1L; // 序列化版本号，= 1L;： 这是对版本号的初始化。通常建议初始版本号设为1，表示初始版本

    private int id;
    private String name;

    // 构造函数等其他代码

    // 序列化方法
    public void serialize(String filename) throws IOException {
        try (ObjectOutputStream outputStream = new ObjectOutputStream(new FileOutputStream(filename))) {
            outputStream.writeObject(this);
        }
    }

    // 反序列化方法
    public static MyClass deserialize(String filename) throws IOException, ClassNotFoundException {
        try (ObjectInputStream inputStream = new ObjectInputStream(new FileInputStream(filename))) {
            return (MyClass) inputStream.readObject();
        }
    }
}

```



## **Transient** 关键字有什么用

- **字段不进行序列化**

- 只能用在变量

  在被反序列化后，transient 变量的值被设为初始值，如 int 型的是 0，对象型的是 null。

  

## static的作用

- 方法：使方法与类关联而不是对象

- 创建**单一存储空间**、

修饰

- 变量，静态变量只有一个副本。
- 方法，无需创建对象就可以调用，但不能调用非static方法和this、super。**只能访问静态方法和变量。**
- 代码块，加载类的时候执行，用于**初始化静态变量**。
- 类，**静态类只能访问静态变量、静态方法**。

## 注解是什么

- 为 Java 代码提供元数据，不影响代码执行。

## Java异常

Throwable (java.lang)

- Error (java.lang) Java虚拟机（JVM）在遇到严重问题时抛出的异常，比如系统崩溃、虚拟机错误、内存空间不足、方法调用栈溢出等，对于这类异常，Java编译器不去检查它们

  - Java.lang.StackOverFlowError
  - Java.lang.OutOfMemoryError。

- Exception (java.lang) Exception是程序可以处理的异常，可以被捕获且可以恢复。

  - Checked Exception (受检查异常，**必须处理try catch**) 

    > IO 相关的异常、`ClassNotFoundException`、`SQLException`

  - Unchecked Exception (不受检查异常，可以不处理)。

    > `RuntimeException` **（程序的错误）**及其子类都统称为非受检查异常，常见的有（建议记下来，日常开发中会经常用到）：
    >
    > - `NullPointerException`(空指针错误)
    > - `IllegalArgumentException`(参数错误比如方法入参类型错误)
    > - `NumberFormatException`（字符串转换为数字格式错误，`IllegalArgumentException`的子类）
    > - `ArrayIndexOutOfBoundsException`（数组越界错误）
    > - `ClassCastException`（类型转换错误）
    > - `ArithmeticException`（算术错误）
    > - `SecurityException` （安全错误比如权限不够）
    > - `UnsupportedOperationException`(不支持的操作错误比如重复创建同一用户)



- 检查性异常和非检查性异常的区分主要在于**处理异常的方式和异常发生的原因。**
- **检查性异常**：指编译器会检查并强制要求开发者处理的异常。这类异常的发生难以避免，如果开发者没有处理这些异常，集成开发环境中的编译器就会给出错误提示，例如输入输出异常(IOException)、文件不存在异常(FileNotFoundException)等。
- **非检查性异常**：指编译器不会检查的异常。这类异常一般可以避免，因此无需处理（try …catch）。非检查性异常通常是由程序代码写的不够严谨而导致的问题，可以通过修改代码来规避，例如空指针异常(NullPointerException)、除零异常(ArithmeticException)等。

### Throw 和 throws 的区别？

- 位置不同，Throws在函数上，throw是方法内。
- 功能不同，throws声明异常告诉调用者，throw抛出具体问题对象。

## String、StringBuilder、StringBuffer  5

- **可变**： String不可变，StringBuilder、StringBuffer继承自AbstractStringBuilder类，使用数组保存字符串，是可变的。

  ```java
  private final char value[]; //String
  
  /*** The value is used for character storage. 
  AbstractStringBuilder 中继承下来的，在StringBuilder、StringBuffer中存在
  */
  char[] value;
  ```

  - **修改方式**，StringBuffer和StringBuilder在**修改字符串**方面比String的**性能要高，不用增加对象**
  - **性能**：String不可变最低，需要频繁地分配内存；StringBuilder无阻塞最高。

- **初始化方式**

- **equal hashcode** ： String重写了这两个方法

- **线程安全**：**String是不可变类，所以它是线程安全的，StringBuffer线程安全，每个方法都加了synchronized**，StringBuilder线程不安全。

- **存储方面**：String存储在字符串常量池里面 StringBuffer和StringBuilder存储在堆内存空间。

## 为什么设计String为final 3

- 省空间，都**存在了常量池**中，相同值会指向同一个。
- 效率，常量无需同步。
- 安全，不能修改。

## equals 与==区别 2

- == 比较的是引用。**基础类型比较值；引用类型比较地址。**
- equals 是可以重写的，一般重写都要重写hashcode方法，默认Object直接调用`==`

>- String类
>
>```java
>public boolean equals(Object anObject) {
>    if (this == anObject) {
>        // 如果地址已经相同
>        return true;
>    }
>    // 挨个比较字符
>    if (anObject instanceof String) {
>        String anotherString = (String)anObject;
>        int n = value.length;
>        if (n == anotherString.value.length) {
>            char v1[] = value;
>            char v2[] = anotherString.value;
>            int i = 0;
>            while (n-- != 0) {
>                if (v1[i] != v2[i])
>                    return false;
>                i++;
>            }
>            return true;
>        }
>    }
>    return false;
>}
>```
>
>- Integer
>
>```java
>public boolean equals(Object obj) {
>    if (obj instanceof Integer) {
>        return value == ((Integer)obj).intValue();
>    }
>    return false;
>}
>```

## 类初始化顺序

1. ==静态==属性（父类先，再子类）
2. ==静态==方法块 static{}代码块 ==静态顺序执行==
3. **普通属性**
4. **普通方法块**
5. 构造函数
6. 方法

> 父类静态变量、父类静态代码块、子类静态变量、子类静态代码块、父类非静态变量、父类非静态代码块、父类构造函数、子类非静态变量、子类非静态代码块、子类构造函数。

## 反射是什么

在运行时分析类以及执行类中方法的能力，通过反射你可以获取任意一个类的所有属性和方法，你还可以调用这些方法和属性。

- `Person p=new Student();`

其中编译时类型为 Person，运行时类型为 Student。

## 反射优缺点

- 优点：灵活，框架提供开箱即用的功能提供了便利
- 缺点：安全性，无视泛型参数的安全检查。性能稍差

## 反射 Class是什么？获取方式？创建对象?Method调用方法？

Class类包含该类的信息。

- Class.forName("包名")
- 类.class 
- 对象.getClass()

创建对象的方式

- `c2.newInstance `
- `c2.getConstructor(String.class).newInstance("bbb")`;

method调用方法：`c2.getClass().getMethod("method").invoke(null)`

## 反射的应用场景？





## 动态代理



### JDK动态代理 代理实现了接口的类

**什么是动态代理？为什么使用动态代理？**

不修改原始对象的情况下，**通过代理对象来间接访问原始对象，并在访问前后执行额外的操作**。常用于实现横切关注点（cross-cutting concerns），如日志记录、性能监控、事务管理等。它能够在不改变原始对象的代码的情况下，通过代理对象在方法调用前后插入额外的逻辑

> **动态代理是在运行时动态生成类字节码，并加载到 JVM 中的。**
>
> 优点：相比静态代理**不用实现接口的方法**。不需要针对每个目标类都**单独创建一个代理类**。

- 租户
- 生成代理对象，代理执行**多余的方法**，再实行原来租户的方法。

```java
public class Proxy  {

    public static void main(String[] args) {
        PhoneServiceImpl obj = new PhoneServiceImpl();
        PhoneService proxy = (PhoneService) ProxyUtils.getProxy(obj);
        proxy.call();
    }

}
// 接口
interface PhoneService {
    void call();
}

// 普通类
class PhoneServiceImpl implements PhoneService {
    public void call() {
        System.out.println("call");
    }
}

// 代理类
class ProxyUtils {
    // 获取代理
    //proxy :动态生成的代理类
	// method : 与代理类对象调用的方法相对应
	//args : 当前 method 方法的参数
    public static Object getProxy(final Object obj) {
        PhoneService service = (PhoneService) java.lang.reflect.Proxy.newProxyInstance(
                PhoneService.class.getClassLoader(),
                new Class[]{PhoneService.class},
                new InvocationHandler() {
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println("before");
                        // 激活原来的普通函数
                        Object result = method.invoke(obj, args);
                        System.out.println("after");
                        return result;
                    }
                }
        );
        return service;
    }
}
```

### CGLIB动态代理 MethodInterceptor+Enhancer 

#### 为什么使用？

> CGLIB是一个第三方库，可以在**运行时为Java类和接口生成子类或代理**。这个库主要用于像Spring这样的框架，为Bean生成代理，这样在调用Bean的方法时，可以执行一些额外的逻辑，例如事务管理、缓存等等。
>
> ### 优缺点
>
> 1. **可以代理接口和类，而java.lang.reflect.Proxy只能代理接口。**
>
> 2. java.lang.reflect.Proxy是基于接口的代理，而CGLIB是基于类的代理。这意味着，当你为一个类创建代理时，该类的方法都会被拦截。
>
> 3. CGLIB的**性能更好**。因为它是基于类的代理，所以不需要创建接口和类之间的连接，因此比java.lang.reflect.Proxy更快。
>
> 4. CGLIB可以**自动处理继承和实现的情况**，JDK动态代理可以自动处理实现的情况，但无法自动处理继承的情况。
>
>    这意味着当**为一个类生成代理时，该类的所有子类和实现的所有接口的代理也会被自动生成**
>
> 然而，CGLIB也有一些缺点。例如，它**不能正确处理final方法，因为它会生成子类**。此外，它也**不能正确处理方法返回null**的情况。
>
> - `final`修饰是在该类的基础上创建了一个新的类，并覆盖了其中的方法。但是，由于CGLIB创建的类并非原始类的子类，因此，如果原始类的方法被标记为`final`，CGLIB就不能覆盖这个方法。

- JDK动态代理只能对实现了接口的类生成代理，而不能针对类
- [CGLIB](https://so.csdn.net/so/search?q=CGLIB&spm=1001.2101.3001.7020)是针对类实现代理，主要是对指定的类生成一个子类，覆盖其中的方法

JDK 动态代理有一个最致命的问题是其只能代理实现了接口的类。**而 CGLIB 动态代理避免了使用接口**

- **使用MethodInterceptor+Enhancer 实现代理**

```java
public interface MethodInterceptor extends Callback{
    // 拦截被代理类中的方法
    public Object intercept(Object obj, java.lang.reflect.Method method, Object[] args,MethodProxy proxy) throws Throwable;
}
```

```java

class MyService {

    public static void main(String[] args) {
        MyService proxy = (MyService) ProxyUtils.getProxy(MyService.class);
        proxy.sayHello();
    }

    public void sayHello() {
        System.out.println("Hello");
    }
}

class DebugMethodInterceptor implements MethodInterceptor {

    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        //调用方法之前，我们可以添加自己的操作
        System.out.println("before method " + method.getName());
        Object object = methodProxy.invokeSuper(o, objects);
        //调用方法之后，我们同样可以添加自己的操作
        System.out.println("after method " + method.getName());

        return object;
    }
}

class ProxyUtils {

    public static Object getProxy(Class clazz) {
        // 创建动态代理增强类
        Enhancer enhancer = new Enhancer();
        // 设置类加载器
        enhancer.setClassLoader(clazz.getClassLoader());
        // 设置被代理类
        enhancer.setSuperclass(clazz);
        // 设置方法拦截器
        enhancer.setCallback(new DebugMethodInterceptor());
        // 创建代理类
        return enhancer.create();
    }
}
```



## comparator和compatable的区别，哪些类实现了

- java.lang.Compatable比较内部 compareTo(T o)
- java.util.Comparator 比较两个类 compare(T o1, T o2)

Integer、Double等都实现了`Comparable`接口，可以进行自然排序，同时也支持使用`Comparator`接口进行自定义排序

比如ArrayList、LinkedList等，可以使用`Collections.sort()`方法进行排序，这个方法内部使用了`Comparator`接口。



## 说说 Java 中多态的实现原理



## int 和 Integer 有什么区别，还有 Integer 缓存实现 4

- 基本类型 引用类型，Integer需要判空
- **默认值** 0 null
- **存储空间** int类型是直接存储在栈空间，Integer存储在堆内存
- **Integer 缓存机制**：为了节省内存和提高性能，Integer 类在内部通过**使用相同的对象引用实现缓存和重用**，Integer 类默认在**-128 ~ 127** 之间，可以通过 JVM设置- XX:AutoBoxCacheMax 进行修改，且这种机制仅在**自动装箱**时候有用，在使用构造器创建Integer 对象时无用。

### 装箱拆箱

```java
Integer i = 1；
int in = i; # 装箱
Integer in2 = in; # 拆箱
```

## 为什么重写equal，要重写HashCode？

**确保相等的对象具有相同的哈希码**

- 对象和对象equal，可以比较两个对象
- 但如果存储在散列表中，获取时会调用HashCode计算在哪个桶，如果两个对象的hashcode不同会存储在不同的地方。

**同理，重写HashCode也应该重写equal**

## 两个对象 hashCode()相同，则 equals()是否也一定为 true？

- HashCode 是通过地址计算出一个数值。

  equals为true，默认比较的是地址，地址相同，Hashcode一定相同。

  equals为false，地址不相同，hashcode生成的结果未必不相同。

- **如果hashcode相同，两个对象的地址未必相同，equals未必为true**

- demo

```java
public static void main(String[] args) {
    String aStr = "Aa";
    String bStr = "BB";
    System.out.println("aStr hash: " + aStr.hashCode());
    System.out.println("bstr hash: " + bStr.hashCode());
    System.out.println("bStr.hashCode()==aStr.hashCode() ： " + (bStr.hashCode() == aStr.hashCode()));
    System.out.println(aStr.equals(bStr));
}
//aStr hash: 2112
//bstr hash: 2112
//bStr.hashCode()==aStr.hashCode() ： true
//false
```

## 注解有什么用？

- 元程序中元素关联信息和元数据（metadata）
- 程序可以通过反射来获取指定程序中元素的 Annotation对象，获取注解中的元数据信息。

**元注解（标记注解的注解）**@Retentaion @Documented

- @Retentaion：标识这个注解怎么保存，是只在代码中，还是编入class文件中，或者是在运行时可以通过反射访问。
  - 在源文件中有效（即源文件保留）
  - CLASS:在 class 文件中有效（即 class 保留）
  - RUNTIME:在运行时有效（即运行时保留）
- @Documented
- @Target
- @Inherited：标记这个注解是继承与哪个注解类。

```java
@Target({ElementType.TYPE}) //修饰的对象范围 types（类、接口、枚举、Annotation 类型）
@Retention(RetentionPolicy.RUNTIME) //注解怎么保存
@Documented
@Component
public @interface Controller {
    @AliasFor(
        annotation = Component.class
    )
    String value() default "";
}

```

## JAVA 中几种基本数据类型什么，各自占用多少字节呢

#### 整数型 ： byte、short、int、long 1 2 4 8 byte

| 类型  | 比特           | 默认值                                               |
| ----- | -------------- | ---------------------------------------------------- |
| byte  | 8bit           | 0                                                    |
| short | 16bit (2 byte) | 0                                                    |
| int   | 32bit (4 byte) | 0<br />`System.out.println(Integer.toString(11,2));` |
| long  | 64bit (8 byte) | 0L                                                   |

#### 浮点数：float、double 4 8byte

| 类型   | 比特          | 默认值 |
| ------ | ------------- | ------ |
| float  | 32bit 4个字节 | 0.0f   |
| double | 64bit 8字节   | 0.0    |

#### 字符char 2 byte

16位(2byte) Unicode字符，最小值是\u0000(也就是0 )最大值是\uffff(即为65535) 

#### 布尔boolean 1bit

1位 默认false

## 为什么String不能被继承

- 效率：内部不会被变化，高性能。
- 安全：不会被恶意修改。
- 规范，Java核心类都被final，保证规范一致性。

## 说说 Java 中多态的实现原理，分类，实现方式 2

### 分类

- 动态 运行时多态（运行时才确定使用哪个方法）
- 静态 编译时多态（重载）

### 实现方式

- extends 重写父类方法实现不同结果
- implements 

Java 里对象方法的调用依靠类信息里的方法区实现，对象方法引用调用和接口方法引用调用的大致思想是一样的。

当调用对象的某个方法时，

- JVM **查找该对象类的方法区**以确定该方法的**直接引用地址**，有了地址后才真正调用该方法。

### demo

- **根据父类找到元数据** JVM会根据`Fruit`类的类型在内存中查找方法表，找到`taste()`这个方法的**元数据**（包括方法名、参数类型和返回类型等）。
- **根据元数据找到重写的方法的具体实现** 然后，基于这个元数据，JVM会动态地查找和确定具体的实现。在这个例子中，`Apple`类重写了`Fruit`类的`taste()`方法。所以，JVM会在运行时找到`Apple`类的`taste()`方法的具体实现。

```java
abstract class Fruit {
    abstract String taste();
}

class Apple extends Fruit {
    @Override
    String taste() {
        return "酸酸apple";
    }
}
class Pear extends Fruit {
    @Override
    String taste() {
        return "酸酸pear";
    }
}

class test {
    public static void main(String[] args) {
        Fruit apple = new Apple();
        apple.taste();
    }
}
```

## &和&&的区别

- **&按位与** 转为2进制进行按位与运算
- **逻辑运算**：&&短路，A&&B如果A为false，右边不会进行运算。



##  Java 中IO 流分为几种?

- 字符流（Writer Reader） 字节流（InputOutputStream）
- 输入流输出流
- 缓冲流（buffer） 数据流（serializable） 对象流（序列化反序列化的java对象）
- 文件流 网络流 内存流

## Java 创建对象有几种方式 5

- new Object()

- Class.newInstance()

- Class.**constructor**().newInstance()

- 实现**Cloneable**接口的对象object.clone()

- **流** 运用反序列化手段，调用 java.io.ObjectInputStream 对象readObject()方法

  ```java
  class Apple extends Fruit implements Serializable{
      String name;
      public Apple(String name) {
          this.name = name;
      }
      @Override
      String taste() {
          System.out.println(name);
          return name;
      }
  }
  
  class test {
      public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException, IOException, ClassNotFoundException {
          Fruit apple = new Apple("123342");
         
          FileOutputStream fileOutputStream = new FileOutputStream("1.txt");
          ObjectOutputStream objectOutputStream = new ObjectOutputStream(fileOutputStream);
          objectOutputStream.writeObject(apple);
          objectOutputStream.close();
          fileOutputStream.close();
  
          FileInputStream fileInputStream = new FileInputStream("1.txt");
          Apple o = (Apple) new ObjectInputStream(fileInputStream).readObject();
          o.taste();
      }
  }
  ```
  

## 如何将 GB2312 编码字符串转换为 ISO-8859-1 编码字 符串呢？

```java
new String("23".getBytes("GB2312"), "ISO-8859-1");
```

## ???守护线程是什么？用什么方法实现守护线程





## 浮点数精度丢失原因

> 0.2 转换为二进制数的过程为，不断乘以 2，直到不存在小数为止
>
> - 无限循环的小数存储在计算机时，只能被截断
>
> ```java
> float a = 2.0f - 1.9f;
> float b = 1.8f - 1.7f;
> System.out.println(a);// 0.100000024
> System.out.println(b);// 0.099999905
> ```
>
> ```
> 0.2 * 2 = 0.4 -> 0
> 0.4 * 2 = 0.8 -> 0
> 0.8 * 2 = 1.6 -> 1
> 0.6 * 2 = 1.2 -> 1
> 0.2 * 2 = 0.4 -> 0（发生循环）
> ```

## BigDecimal？原因？使用？

- 浮点数精度丢失
- 需要浮点数精确运算结果的业务场景，使用BigDecimal

想要解决浮点数运算精度丢失这个问题，可以直接使用 `BigDecimal` 来定义浮点数的值，然后再进行浮点数的运算操作即可。

```java
BigDecimal a = new BigDecimal("1.0");
BigDecimal b = new BigDecimal("0.9");
BigDecimal c = new BigDecimal("0.8");
// 使用String构造方法避免精度丢失，Doubled

BigDecimal x = a.subtract(b);
BigDecimal y = b.subtract(c);

System.out.println(x.compareTo(y));// 0
```

