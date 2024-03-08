## StringTable

### String在不同版本的变化

- 1.8 char[]

- 1.9 byte[] 增加编码coder，确定编码类型

  优点：缩短长度

### String 的特性是什么？以下代码有什么区别？

```java
String a = "d"; 
String b = "d"; 
System.out.println(a == b);
a = new String("d"); 
System.out.println("a=" + a);
System.out.println("b=" + b);
System.out.println(a == b);
```

- 不可变性

```java
String a = "d"; //字面量
String b = "d"; //字面量，存常量池
System.out.println(a == b); // true
a = new String("d"); //对象，存堆
System.out.println(a == b);//false
```

### StringTable 的内存分配在哪？

- JDK 1.6 永久代
- JDK 1.7 堆，因为永久代空间小

### 字符串拼接操作的原理？拼接后存储在哪？

```java
 public static void test1() {
      String s1 = "a" + "b" + "c";
      String s2 = "abc";
      System.out.println(s1 == s2);
  }
```

```java
public void test6(){
    String s0 = "beijing";
    String s1 = "bei";
    String s2 = "jing";
    String s3 = s1 + s2;
    // 连接操作的执行细节 s1+s2 
    // 1. StringBuilder s = new StringBuilder();
    // 2. s.append("a");
    // 3. s.append("b");
    // 4. return s.toString(); // 类似于new String() 在堆空间
    System.out.println(s0 == s3); // false s3指向对象实例，s0指向字符串常量池中的"beijing"
    
    
    String s7 = "shanxi";
    final String s4 = "shan"; // 常量
    final String s5 = "xi"; // 常量
    String s6 = s4 + s5; // 编译期 prepare 自动拼接，即s6也是"shanxi"
    System.out.println(s6 == s7); // true s4和s5是final修饰的，编译期就能确定s6的值了
}

Class StringBuilder
@Override
public String toString() {
    // Create a copy, don't share the array
    return new String(value, 0, count);
}

```

- **不使用 final 修饰，即为变量。**如 s3 行的 s1 和 s2，会**通过 new StringBuilder 进行拼接**
- **使用 final 修饰，即为常量。会在编译器进行代码优化。**<mark>在实际开发中，能够使用 final 的，尽量使用</mark>

> - 常量+常量（编译期优化） 在常量池
> - 存在 变量 ，就在堆中

```java
  public static void test1() {
      // 都是常量，前端编译期会进行代码优化
      // 通过idea直接看对应的反编译的class文件，会显示 String s1 = "abc"; 说明做了代码优化
      String s1 = "a" + "b" + "c";
      String s2 = "abc";

      // true，有上述可知，s1和s2实际上指向字符串常量池中的同一个值
      System.out.println(s1 == s2);
  }
```

### intern()是什么？有什么特性？分析下面代码。

```java
String a1 = "beijing" ;
String a2 = new String("beijing");
System.out.println(a1 == a2);
String a3 = a2.intern();
System.out.println(a3 == a1); 
```

- 查询StringTable是否有这个字符串
  1. 有 直接返回该String的引用（JDK8）
  2. 无 放入String后返回
- 特性 native，确保字符串在在**内存**里只有一份。

![image-20210511145542579](http://42.192.130.83:9000/picgo/imgs/b3657b493efaf41f83b72e2debffb14b.png)

### String a = new String("ab")会创建几个对象？如何证明？

看字节码操作。

1. “ab”
2. String对象

```java
 0 new #2 <java/lang/String> // 创建String 对象
 3 dup
 4 ldc #3 <abc> // 常量池
 6 invokespecial #4 <java/lang/String.<init> : (Ljava/lang/String;)V> // 虚方法
 9 astore_1
10 return
// 堆（new String(x)) ---->常量池（"ab"）
```

### new String("abc")+new String("cde")会创建几个对象？

1. 常量池 "abc"
2. 常量池"cde"
3. new String("abc")
4. new String("cde")
5. new StringBuilder
6. stringBuilder.toString() ，这里从没有出现过abccde

```java
 0 new #2 <java/lang/StringBuilder> // 1. StringBuilder
 3 dup
 4 invokespecial #3 <java/lang/StringBuilder.<init> : ()V>
 7 new #4 <java/lang/String> // 2.String abc
10 dup
11 ldc #5 <abc> // 3.常量池
13 invokespecial #6 <java/lang/String.<init> : (Ljava/lang/String;)V>
16 invokevirtual #7 <java/lang/StringBuilder.append : (Ljava/lang/String;)Ljava/lang/StringBuilder;>
19 new #4 <java/lang/String> // 4. String cde
22 dup
23 ldc #8 <cde> // 5. 常量池
25 invokespecial #6 <java/lang/String.<init> : (Ljava/lang/String;)V>
28 invokevirtual #7 <java/lang/StringBuilder.append : (Ljava/lang/String;)Ljava/lang/StringBuilder;>
31 invokevirtual #9 <java/lang/StringBuilder.toString : ()Ljava/lang/String;> //6.  StringBuilde return new String(char[] c)返回值
    // 此时字符串常量池还不存在"abccde"，常量池不会存储abccde
34 astore_1
35 return
```

```java
@Override
public String toString() {
    // 直接将value的char给到新的String，根本没动字符串常量池
    // Create a copy, don't share the array
    return new String(value, 0, count);
}
```

### 10.5.1. intern 的使用：JDK6 vs JDK7/8

总结 String 的 intern()的使用：

**JDK1.6 中**，将这个字符串对象尝试放入串池。

- 如果串池中有，则并不会放入。返回已有的串池中的对象的地址
- 如果没有，会**把此<mark>对象复制一份</mark>，放入串池**，并返回串池中的对象地址

**JDK1.7 起**，将这个字符串对象尝试放入串池。

- 如果串池中有，则并不会放入。返回已有的串池中的对象的地址
- 如果没有，则会**把<mark>对象的引用地址</mark>复制一份，放入串池**，并返回串池中的引用地址

```java
/** 
* ① String s = new String("1") 
* 创建了两个对象 
* 		堆空间中一个new对象 
* 		字符串常量池中一个字符串常量"1"（注意：此时字符串常量池中已有"1"） 
* ② s.intern()由于字符串常量池中已存在"1"   
* s指向的是堆空间中的对象地址 
* s2 指向的是堆空间中常量池中"1"的地址 
* 所以不相等 
*/
String s = new String("1"); 
s.intern(); // 这里 常量池已经存在1
String s2 = "1"; // 使用还是前面那个1
System.out.println(s==s2); // 一指向堆、一个指向常量池
// jdk1.6 false jdk7/8 false

/* 
* ① String s3 = new String("1") + new String("1") 
* 等价于new String（"11"），但是，常量池中并不生成字符串"11"； 
* 
* ② s3.intern() 
* 由于此时常量池中并无"11"，所以把s3中记录的对象的地址存入常量池 
* 所以s3 和 s4 指向的都是一个地址
*/
String s3 = new String("1") + new String("1");
// 执行完后 常量池中不存在11
s3.intern(); // 让常量池中存在11；
// 1. 在jdk6中，intern() 如果没有，会复制一份放入
// 2. 在jdk7之后，intern() 如果没有，会把对象引用地址复制一份放入串池，不会创建对象
String s4 = "11"; // 使用上一行代码生成的11
System.out.println(s3==s4);  
//jdk1.6 false jdk7/8 true

```

![image-20210511152240683](http://42.192.130.83:9000/picgo/imgs/4c11070481d7c3cdb566163802cf582b.png)

![image-20200711145925091](http://42.192.130.83:9000/picgo/imgs/3a3bab69ad3c6302ea00c301dffb5193.png)

