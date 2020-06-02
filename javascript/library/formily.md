# formily

## 源码阅读

- FormLifeCycle 传递一个回调 `(type, payload) => {dispatch(...);}`
  - ··
- FormHeart

useEva->

- useForm
  - `useDirty` 通过 dirty.num 判断 **initialValues**、**values**、**editable** 的值是否改变
  - `useForceUpdate`
    - `publish`
    - `batch`
    - `buildLifeCycles`
  - FormLifeCycle 生命周期函数，在 useForm 里面会传入两个生命周期函数，一个是为了触发 FormWillInit
    - listener `(payload, ctx) => void`
    - notify() `(type, payload, ctx) => void`
  - Subscribable
    - subscribers
    - subscription
    - subscribe()
    - unsubscribe()
    - notify()
  - FormGraph extends Subscribable
    - nodes 节点列表
    - refernces 引用列表
    - exists 判断某个节点 path 是否存在
  - FormHeart extends Subscribable
    - 属性
      - lifecycles 使用传入的 lifecycles 构造
      - context(=formApi)
        - submit()
        - reset()
        - setFormState()
        - setFieldValue()
        - ...
      - buffer
      - beforeNotify
      - afterNotify
    - batch
    - publish() `(type, payload, context) => void`
      - 调用 listcycle.notify()
      - 调用 Subscribable.notify()
  - createForm
    - env
      - validateTimer
      - syncFormStateTimer
      - onChangeTimer
      - graphChangeTimer
      - hostRendering
      - publishing
      - taskQueue
      - taskIndexes
      - removeNodes
      - lastShownStates
      - submittingTask

创建 form 的过程中，调用 `heart.publish(LifeCycleTypes.ON_FORM_WILL_INIT, state)`，触发了。

### core

### onFieldChange

```ts
// registerField 的时候
field.subscription = {
  notify: onFieldChange({ field, path: nodePath }),
};
```

### 生命周期 hooks 及事件触发

#### effect 注册流程

生命周期 hooks 必须在 effect 里面定义，所以如果如果有生命周期 hooks，则一定会初始化的时候传入 effects method，那么在 `createFormEffects(effects, actions)` 时，会创建 effectSelector。

```ts
env.effectSelector = <T = any>(
  type: string,
  matcher?: string | ((payload: T) => boolean)
) => {
  // selector 会返回对应 type 的 Subject
  const observable$: Obsezrvable<T> = selector(type);
  if (matcher) {
    // 会在 Observable 里面根据 path 或者 name 过滤
    // 返回一个指定类型(hooks type 相同，name/path 相同)的 Observable
    // 然后在 effects 里面订阅相关事件就可以了
    return observable$.pipe(
      filter<T>(
        isFn(matcher) && !matcher["path"]
          ? matcher
          : (payload: T): boolean => {
              return FormPath.parse(matcher as any).matchAliasGroup(
                payload && (payload as any).name,
                payload && (payload as any).path
              );
            }
      )
    );
  }
  return observable$;
};

const env = {
  effectStart: false,
  effectSelector: null,
  effectEnd: false,
  currentActions: null,
};
// hooks 将自定义事件注册到 effectSelector
onFieldWillInit$: createEffectHook<IFieldMergeState>(
  LifeCycleTypes.ON_FIELD_WILL_INIT // onFieldWillInit
);
// 下面和这个等价 ("path") => env.effectSelector("onFieldWillInit", ...args)
onFieldWillInit$("path");
```

#### effect 触发流程

```ts
// 1、useForm 初始化的时候，创建 FormLifeCycle，这个是通用的 LifeCycle
// 所有的 FormHeart publish 方法都会执行
new FormLifeCycle(({ type, payload }) => {
  dispatch.lazy(type, () => {
    return isStateModel(payload) ? payload.getState() : payload;
  });
  if (broadcast) {
    broadcast.notify({ type, payload });
  }
});
// 2、FormHeart 执行 publish 操作
heart.publish(LifeCycleTypes.ON_FIELD_WILL_INIT, field);
// 3、lifecycle 执行 notify，
this.lifecycles.forEach((lifecycle) => {
  // 执行 FormLifeCycle，内部是 Subject.next(...) 生产数据
  lifecycle.notify(type, payload, context || this.context);
});
// 4、执行自身的 notify
// 主要目的是触发 formApi 里面订阅的事件
this.notify({
  type,
  payload,
});
```

#### form init 触发流程

- 在创建 form 的时候(useForm)，初始化传入 FormLifeCycle，type 为 LifeCycleTypes.ON_FORM_WILL_INIT 生命周期
- 创建 FormHeart，初始化 lifecycles
- form 创建即将完成
  - 调用 `heart.publish(LifeCycleTypes.ON_FORM_WILL_INIT, state)`，在 lifecycle 方法里面，会根据 type 来匹配执行响应的 listener
  - 调用 Subscribable 的 notify()

```ts
new FormLifeCycle(
  LifeCycleTypes.ON_FORM_WILL_INIT,
  (payload: IModel, form: IForm) => {
    const actions = {
      ...form,
      dispatch: form.notify,
    };
    implementActions(actions);
    if (broadcast) {
      broadcast.setContext(actions);
    }
  }
);
```

### 注册及触发 Field

useField->registerField(core)

```ts
// 1、注册回调事件，用来执行 field 的校验
// useField
ref.current.subscriberId = ref.current.field.subscribe(
  (fieldState: IFieldState) => {
    if (ref.current.unmounted) return;
    /**
     * 同步Field状态只需要forceUpdate一下触发重新渲染，因为字段状态全部代理在formily core内部
     */
    if (initialized) {
      if (options.triggerType === "onChange") {
        if (ref.current.field.hasChanged("value")) {
          mutators.validate({ throwErrors: false });
        }
      }
      if (!form.isHostRendering()) {
        // 执行 field 的 render 操作
        forceUpdate();
      }
    }
  }
);
// 2、createMutators 执行 Field 的相关操作
// 如提供相关操作 Field 的方法
function setValue(...values: any[]) {
  field.setState((state: IFieldState<FormilyCore.FieldProps>) => {
    state.value = values[0];
    state.values = values;
  });
  heart.publish(LifeCycleTypes.ON_FIELD_INPUT_CHANGE, field);
  heart.publish(LifeCycleTypes.ON_FORM_INPUT_CHANGE, state);
}
removeValue();
getValue();
onGraphChange();
swapState();
const mutators = {
  change(...values: any[]) {
    setValue(...values);
    return values[0];
  },
};
// 3、createStateModel->setState
// state 有值变化，并且 silent 则执行 field 的 render 操作
if (this.dirtyNum > 0 && !silent) {
  // 触发第 1 步的 subscribe 操作
  this.notify(this.getState());
}
```

如果 Field 在 FormGraph 里面不存在，则执行 createField

- `field = new FieldState()`，实际是经过 `createStateModel` 包装过的
- `heart.publish(LifeCycleTypes.ON_FIELD_WILL_INIT, field)`
- `heart.batch(() => field.batch(() => {field.setState()}))` 设置 field 的初始值，如 visible/display/props/required/rules 等
- 注册 validator

### field 值变化

### cool-path

[10 分钟解读 UForm 路径系统](https://zhuanlan.zhihu.com/p/100780657)

通过路径来操作 path

- 简单匹配，`a.b.c.d`，`a.b[1]`
- 批量选择,`*`
- 分组选择，`*(aa,bb,cc)`
  - 排除选择 `*(!aa,bb,cc)`
  - 前缀匹配 `aa~`
  - 范围匹配 `*[1:100]`
- 排除选择

```ts
Path.setIn({},'a.b.c.{aaa,bbb}',{aaa:123,bbb:321})
==>
{a:{b:{c:{aaa:123,bbb:321}}}}
Path.getIn({a:{b:{c:{aaa:123,bbb:321}}}},'a.b.c.{aaa,bbb}')
==>
{aaa:123,bbb:321}

Path.setIn({a:{b:{c:{kkk:'ddd'}}}},'a.b.c.{aaa,bbb}',{aaa:123,bbb:321})
==>
{a:{b:{c:{aaa:123,bbb:321,kkk:'ddd'}}}}
Path.getIn({a:{b:{c:{aaa:123,bbb:321,kkk:'ddd'}}}},'a.b.c.{aaa,bbb}')
==>
{aaa:123,bbb:321}

Path.setIn({a:{b:{c:{kkk:'ddd'}}}},'a.b.c.{aaa:ooo,bbb}',{aaa:123,bbb:321})
==>
{a:{b:{c:{ooo:123,bbb:321,kkk:'ddd'}}}}
Path.getIn({a:{b:{c:{ooo:123,bbb:321,kkk:'ddd'}}}},'a.b.c.{aaa:ooo,bbb}')
==>
{aaa:123,bbb:321}
```

### [react-eva](https://github.com/janryWang/react-eva)

有两条主线：

1. 传入 effects，useEva 会调用 effects，并将注册 Subject 的回调函数传递给 effects，effects 里面的 effect 可以订阅相关事件。通过 dispatch 可以触发事件。
2. 传入 actions，是一组 action name，返回 implementActions，用于实现对应的 action，实现之后，给传入的 actions 添加方法用来操作 actions。

通过 dispatch 触发事件，然后在 effect 里面订阅事件，并且能够获取参数，然后调用 actions 的相应方法且将参数传入。

```js
// createEva
// 1、创建 effects 的目的根据 type 返回对应的 Subject
// 提供一个回调函数作为参数 $ 传递给调用函数，调用函数使用 $("typeName") 来注册 Subject 订阅事件
createEffects = (fn) => fn;
effects = createEffects(async ($) => {
  console.log(await actions.getText());
  $("onClick").subscribe(() => {
    actions.setText("hello world");
  });
});
if (isFn(effects)) {
  // 将函数参数传递给 $, type=onClick
  // 保存订阅关系
  // subscribes={"onClick":new Subject()}
  effects((type, $filter) => {
    if (!subscribes[type]) {
      subscribes[type] = new Subject();
    }
    if (isFn($filter)) {
      return subscribes[type].pipe(filter($filter));
    }
    return subscribes[type];
  });
}
// 2、dispatch 根据 type找到对应的 Subject，然后调用 next 方法生产数据
// 3、implementActions 保存 actionName 和对应的操作fn，并且添加 actions[implementSymbol](name, fn)
// 最终返回 subscription()、dispatch()、implementActions()

// ActionFactory isAsync=true 通过 factory 来创建 actions
resolves = {};
actions = {};
factory = {
  // 1.
  [implementSymbol]: (name, fn) => {
    if(resolves[name]) {
      setTimeout(resolve(fn(...args)))
    }
    actions[name] = fn;
  }
  // 2.
  [actionName]: (...args) => actions[name](...args),
  // isAsync=true
  [actionName]: (...args) =>
    new Promise((res, rej) => res(actions[name](...args))),
};

```

## 疑问
