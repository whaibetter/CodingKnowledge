// TODO

[Servlet 总结 | JavaGuide](https://javaguide.cn/system-design/J2EE基础知识.html#转发-forward-和重定向-redirect-的区别)

## Servlet

主要负责接收用户请求 `HttpServletRequest`,在`doGet()`,`doPost()`中做相应的处理，并将回应`HttpServletResponse`反馈给用户。

## [Servlet 接口中有哪些方法?有哪些子类？](https://javaguide.cn/system-design/J2EE基础知识.html#servlet-接口中有哪些方法及-servlet-生命周期探秘)

- **void init(ServletConfig config) throws ServletException**
- **void service(ServletRequest req, ServletResponse resp) throws ServletException, java.io.IOException**
- **void destroy()**
- java.lang.String getServletInfo()
- ServletConfig getServletConfig()

---

```java
public abstract class HttpServlet extends GenericServlet(from Servlet)
    doget
    dopost
    doput
    
```

## [转发(Forward)和重定向(Redirect)的区别](https://javaguide.cn/system-design/J2EE基础知识.html#转发-forward-和重定向-redirect-的区别)

**转发是服务器行为，重定向是客户端行为。**

**转发（Forward）**

- forward 是服务器请求资源，结果再给到客户端（**递归调用**）

```java
   request.getRequestDispatcher("login_success.jsp").forward(request, response);
```

**重定向（Redirect）**

- 服务器返回给客户端，客户端重新定向到新地址

利用**服务器返回的状态码**来实现的

服务器通过 `HttpServletResponse` 的 `setStatus(int status)` 方法设置状态码。如果服务器返回 **301 或者 302**，则浏览器会到新的网址重新请求该资源。