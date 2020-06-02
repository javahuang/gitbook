# rxjs

## 文档笔记

- **Observable**: represents the idea of an invokable collection of future values or events.(可观察序列，只出不进)
- **Observer**: is a collection of callbacks that knows how to listen to values delivered by the Observable.(观察者，只进不出)
- **Subscription**: represents the execution of an Observable, is primarily useful for cancelling the execution.(订阅关系)
- **Operators**: are pure functions that enable a functional programming style of dealing with collections with operations like map, filter, concat, reduce, etc.

  - **Pipeable Operators**

    > A Pipeable Operator is a function that takes an Observable as its input and returns another Observable. It is a pure operation: the previous Observable stays unmodified.

  - **Creation Operators**

- **Subject**: is the equivalent to an EventEmitter, and the only way of multicasting a value or event to multiple Observers.(可出可进的可观察序列，可作为观察者)
- **Schedulers**: are centralized dispatchers to control concurrency, allowing us to coordinate when computation happens on e.g. setTimeout or requestAnimationFrame or others.

  > A scheduler controls when a subscription starts and when notifications are delivered

  - A Scheduler is a data structure. It knows how to store and queue tasks based on priority or other criteria.(是一个数据结构，可以按照条件或者优先级将任务保存或者放到队列里面)
  - A Scheduler is an execution context. It denotes where and when the task is executed (e.g. immediately, or in another callback mechanism such as setTimeout or process.nextTick, or the animation frame).(是一个执行上下文，可以指定任务执行的时机)
  - A Scheduler has a (virtual) clock. It provides a notion of "time" by a getter method now() on the scheduler. Tasks being scheduled on a particular scheduler will asdhere only to the time denoted by that clock.()

### push 和 pull 系统

|      | SINGLE   | MULTIPLE   |
| ---- | -------- | ---------- |
| Pull | Function | Iterator   |
| Push | Promise  | Observable |

pull <-> data consumer
push <-> data producer

**What is Pull?** In **Pull systems**, the Consumer determines when it receives data from the data Producer. The Producer itself is unaware of when the data will be delivered to the Consumer.

消费者主动去拉取数据，生产者不知道何时将数据发送给消费者。
如 Function 是一个 Pull system，function 本身是个生产数据的 producer，function call 是一个 consumer，主动去拉取数据。

**What is Push?** In **Push systems**, the Producer determines when to send data to the Consumer. The Consumer is unaware of when it will receive that data.

消费者被动接收数据，生产者决定何时将数据发送给消费者。
如 Promise（本身是一个 Producer）将 resolved 的值发送给注册的回调（Consumers），并且由 Promise 决定何时将值推送给回调。

RxJS 引入了 Observables，一个新的 Javascript Push system。
Observable 是一个可以产生多个数据的生产者，并且把他们 push 到 Observers(Consumers).

> Observables are like functions with zero arguments, but generalize those to allow multiple values.
> Subscribing to an Observable is analogous to calling a Function.
> Observables are able to deliver values either synchronously or asynchronously.

Observables 和 functions 都是惰性计算的，只有被订阅和被调用的时候才会开始执行。并且每次订阅和调用都产生 separate side effects。
Observable 可以同步或者异步返回数据，由 Observable 里面的 data Producer 来决定。

- observable 被观察者
  - producer 生产者，push value
- observer 观察者，消费数据

Observable 可以由 `new Observable` 或者创建操作符来创建，并且被 Observer 订阅，由 data Producer 发送 `next`/`error`/`complete` 通知。
可以分解为如下 4 步：

- **Creating** Observables
- **Subscribing** to Observables
- **Executing** the Observable
- **Disposing** Observables

## 博客阅读

> Observable is just a function that takes an observer and returns a function
> An “operator” in RxJS is little more than a function that takes a source observable, and returns a new observable that will subscribe to that source observable when you subscribe to it.<sup>[4]</sup>
>
> `Observables are functions that tie an observer to a producer`
> A producer is the source of values for your observable.It could be a web socket, it could be DOM events, it could be an iterator, or something looping over an array. Basically, it’s anything you’re using to get values and pass them to `observer.next(value)`

简单说，Observable 就是一个接受一个 observer 参数并且返回一个函数的的函数

- 是一个函数
- 接受一个包含 `next`、`error`、`complete` 方法的 object 参数
- 返回一个可以取消的函数

## 操作符

## 参考

[1. rxjs-samples-codesandbox](https://codesandbox.io/s/rxjs-samples-70yg7)

[2. RxJS 入门指引和初步应用](https://zhuanlan.zhihu.com/p/25383159)

[3. rxjs reference](https://rxjs-dev.firebaseapp.com/guide/overview)

[4. Learning Observable By Building Observable](https://medium.com/@benlesh/learning-observable-by-building-observable-d5da57405d87)

[5. codesandbox rxjs samples](https://codesandbox.io/s/rxjs-samples-70yg7)
