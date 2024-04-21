## SPI 的优缺点？

通过 SPI 机制能够大大地提高接口设计的灵活性，但是 SPI 机制也存在一些缺点，比如：

- **需要遍历加载所有的实现类，不能做到按需加载**，这样效率还是相对较低的。
- 当**多个 `ServiceLoader` 同时 `load` 时，会有并发问题**。

## 

## Java 反射可以怎样使用？

### 动态代理

```java
public class DebugInvocationHandler implements InvocationHandler {
    /**
     * 代理类中的真实对象
     */
    private final Object target;

    public DebugInvocationHandler(Object target) {
        this.target = target;
    }

    public Object invoke(Object proxy, Method method, Object[] args) throws InvocationTargetException, IllegalAccessException {
        System.out.println("before method " + method.getName());
        Object result = method.invoke(target, args);
        System.out.println("after method " + method.getName());
        return result;
    }
}
```

### Spring注解使用

- 扫描@Compoent
- `org.springframework.beans.factory.support.AbstractBeanFactory#registerCustomEditors` 抽象工厂调用下面的实例化Class
- `org.springframework.beans.BeanUtils#instantiateClass(java.lang.Class<T>)` 

### 使用SPI（Service Provider Interface）

1. 定义接口
2. 接口实现
3. resources/META-INF/services/{接口全限定名称} 这里配置具体实现类
4. 使用`java.utils.ServiceLoader`加载

```java
public static void main(String[] args) {
    ServiceLoader<Cache> c = ServiceLoader.load(Cache.class);
    for (Cache cache : c) {
        cache.put("1", "2");
    }
}
```

## SPI的应用？

### JDBC中的应用

[深入理解SPI机制 - 简书 (jianshu.com)](https://www.jianshu.com/p/3a3edbcd8f24)

```java
public class DriverManager {


    // JDBC驱动列表
    private final static CopyOnWriteArrayList<DriverInfo> registeredDrivers = new CopyOnWriteArrayList<>();

    /**
     * Load the initial JDBC drivers by checking the System property
     * jdbc.properties and then use the {@code ServiceLoader} mechanism
     */
    static {
        loadInitialDrivers();
        println("JDBC DriverManager initialized");
    }

```

```java
public class DriverManager {
    private static void loadInitialDrivers() {
        AccessController.doPrivileged(new PrivilegedAction<Void>() {
            public Void run() {
                //很明显，它要加载Driver接口的服务类，Driver接口的包为:java.sql.Driver
                //所以它要找的就是META-INF/services/java.sql.Driver文件
                ServiceLoader<Driver> loadedDrivers = ServiceLoader.load(Driver.class);
                Iterator<Driver> driversIterator = loadedDrivers.iterator();
                try{
                    //查到之后创建对象
                    while(driversIterator.hasNext()) {
                        driversIterator.next();
                    }
                } catch(Throwable t) {
                    // Do nothing
                }
                return null;
            }
        });
    }
}
```

![image-20240416180855358](http://42.192.130.83:9000/picgo/imgs/image-20240416180855358.png)

## SPI源码大致执行过程

**配置文件、解析配置文件、加载Provider接口、实例化实现类、放入providers的iteratior Map**

> 1. 初始化：创建一个`ServiceLoader`对象，并指定要**加载的服务接口的类型。这通常通过调用`java.util.ServiceLoader#load`方法**来完成。
>
> 2. 加载配置文件：`ServiceLoader`会在**类路径下查找名为`META-INF/services/接口全限定名`的配置文件**，该文件列出了实现该接口的服务提供者的类名。
>
> 3. 解析配置文件：`ServiceLoader`读取配置文件的内容，解析出服务提供者的类名。
>
> 4. 加载服务提供者类：`ServiceLoader`使用**类加载器加载服务提供者**的类。**Cache接口**
>
> 5. 实例化服务提供者：`ServiceLoader`通过**反射机制（构造方法）实例化**加载到的服务提供者类。**前面加载配置文件进行反射解析**
>
> 6. 返回服务提供者实例：`ServiceLoader`将实例化的服务提供者对象**包装在一个`Iterator`中**，并返回给调用者。通过遍历该`Iterator`，可以依次获取所有的服务提供者实例。 
>
>    ```java
>    providers.put(cn, p); // 放入Map集合中，对应key 全限定类名，value为实例化后的对象
>    ```

