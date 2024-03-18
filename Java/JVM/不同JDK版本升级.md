## JDK不同版本的特性

### JDK8的不同版本的特性

- **Lambda表达式**
- Stream API
- **接口默认方法和静态方法** 支持Interface **static default** 修饰
- 新的日期和时间API（java.time）
- 更好的注解支持
- CompletableFuture类（异步编程）
- Nashorn JavaScript引擎

#### Interface支持Default和static

- 新 interface 的方法可以用`default` 或 `static`修饰

  - implement interface不用实现

  - 但多实现且default方法名相同，需要重写

    ```java
    class Sun implements Inter,Outer {
    
    
        public static void main(String[] args) {
            new Sun().testDefault();
            Inter.testStatic();
    
        }
    
        /**
         * 必须重写
         */
        @Override
        public void testDefault() {
            Outer.super.testDefault();
            Inter.super.testDefault();
        }
    }
    
    
    interface Inter{
    
        default void testDefault(){
            System.out.println("testDefault");
        }
    
        static void testStatic(){
            System.out.println("testStatic");
        }
    }
    
    interface Outer{
    
        default void testDefault(){
            System.out.println("testDefault outer");
        }
    
        static void testStatic(){
            System.out.println("testStatic outer");
        }
    }
    ```

#### [lambda 表达式](https://javaguide.cn/java/new-features/java8-common-new-features.html#lambda-表达式)

```java
(parameters) -> expression 或
(parameters) ->{ statements; }
```

```java
@FunctionalInterface
public interface Runnable {
```

- **自定义函数式接口**，只要将接口作为参数就能使用

```java
@FunctionalInterface
public interface LambdaInterface {
 void f();
}
```

```java
//函数式接口参数
static void lambdaInterfaceDemo(LambdaInterface i){
    i.f();
}
```

- Java 8 允许使用 `::` 关键字来传递方法或者构造函数引用

### JDK9

#### [G1 成为默认垃圾回收器](https://javaguide.cn/java/new-features/java9.html#g1-成为默认垃圾回收器)

- G1 还是在 Java 7 中被引入的，经过两个版本优异的表现成为成为默认垃圾回收器。

#### String 存储结构优化

Java 8 及之前的版本，`String` 一直是用 `char[]` 存储。在 Java 9 之后，`String` 的实现改用 `byte[]` 数组存储字符串，节省了空间。

### JDK10

- 局部变量类型推断（支持var关键字）

### **JDK 11**

- [ZGC(可伸缩低延迟垃圾收集器)](https://javaguide.cn/java/new-features/java11.html#zgc-可伸缩低延迟垃圾收集器)

  **ZGC 即 Z Garbage Collector**，是一个可伸缩的、低延迟的垃圾收集器。

  

### [Java15](https://javaguide.cn/java/new-features/java14-15.html#java15)

- **ZGC(转正)**

Java11 的时候 ，ZGC 还在试验阶段。ZGC 在 Java 15 已经可以正式使用了！

不过，默认的垃圾回收器依然是 G1。你可以通过下面的参数启动 ZGC：

```bash
java -XX:+UseZGC className
```

### Java 21

- 字符串模板
- Sequenced Collections（序列化集合，也叫有序集合）

#### [JEP 430：字符串模板（预览）](https://javaguide.cn/java/new-features/java21.html#jep-430-字符串模板-预览)

String Templates(字符串模板) 目前仍然是 JDK 21 中的一个预览功能。

String Templates 提供了一种更简洁、更直观的方式来动态构建字符串。通过使用占位符`${}`，我们可以将变量的值直接嵌入到字符串中，而不需要手动处理。在运行时，Java 编译器会将这些占位符替换为实际的变量值。并且，表达式支持局部变量、静态/非静态字段甚至方法、计算结果等特性。

实际上，String Templates（字符串模板）再大多数编程语言中都存在:

```typescript
"Greetings {{ name }}!";  //Angular
`Greetings ${ name }!`;    //Typescript
$"Greetings { name }!"    //Visual basic
f"Greetings { name }!"    //Python
```

------

```java
String message = STR."Greetings \{name}!";
```

在上面的模板表达式中：

- STR 是模板处理器。
- `\{name}`为表达式，运行时，这些表达式将被相应的变量值替换。

Java 目前支持三种模板处理器：

- STR：自动执行字符串插值，即将模板中的每个嵌入式表达式替换为其值（转换为字符串）。
- FMT：和 STR 类似，但是它还可以接受格式说明符，这些格式说明符出现在嵌入式表达式的左边，用来控制输出的样式
- RAW：不会像 STR 和 FMT 模板处理器那样自动处理字符串模板，而是返回一个 `StringTemplate` 对象，这个对象包含了模板中的文本和表达式的信息

#### [JEP431：序列化集合](https://javaguide.cn/java/new-features/java21.html#jep431-序列化集合)

JDK 21 引入了一种新的集合类型：**Sequenced Collections（序列化集合，也叫有序集合）**

Sequenced Collections 包括以下三个接口：

- [`SequencedCollection`open in new window](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedCollection.html)
- [`SequencedSet`open in new window](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedSet.html)
- [`SequencedMap`open in new window](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/SequencedMap.html)

`SequencedCollection` 接口继承了 `Collection`接口， 提供了在集合两端访问、添加或删除元素以及获取集合的反向视图的方法。

