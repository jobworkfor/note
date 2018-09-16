git ver 0.99 Makefile结构
========================

编译主流程
----------------------------------------------------------------------------------------------------

### 编译目标`all`
默认target是all
```
all: $(PROG)
```
> 该目标依赖`$(PROG)`

### 编译目标`$(PROG)`
其依赖`$(PROG)`的定义如下
```
PROG=   git-update-cache git-diff-files git-init-db git-write-tree \
	git-read-tree git-commit-tree git-cat-file git-fsck-cache \
	git-checkout-cache git-diff-tree git-rev-tree git-ls-files \
	git-check-files git-ls-tree git-merge-base git-merge-cache \
	git-unpack-file git-export git-diff-cache git-convert-cache \
	git-http-pull git-ssh-push git-ssh-pull git-rev-list git-mktag \
	git-diff-helper git-tar-tree git-local-pull git-hash-object \
	git-get-tar-commit-id git-apply git-stripspace \
	git-diff-stages git-rev-parse git-patch-id git-pack-objects \
	git-unpack-objects git-verify-pack git-receive-pack git-send-pack \
	git-prune-packed git-fetch-pack git-upload-pack git-clone-pack \
	git-show-index

# 定义了$(PROG)中各目标的依赖关系
git-update-cache: update-cache.c
# ...省略类似定义
git-fetch-pack: fetch-pack.c

git-http-pull: LIBS += -lcurl
git-rev-list: LIBS += -lssl

# 定义了$(PROG)各目标中的编译规则，该target依赖$(LIB_FILE)
git-%: %.c $(LIB_FILE)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LIBS)
```

> 该目标依赖`$(LIB_FILE)`

### 编译目标`$(LIB_FILE)`
$(LIB_FILE)目标的定义如下：
```
LIB_FILE=libgit.a

$(LIB_FILE): $(LIB_OBJS)
	$(AR) rcs $@ $(LIB_OBJS)
```

> 该目标依赖`$(LIB_OBJS)`

### 隐式编译目标`$(LIB_OBJS)`
如果依赖关系的内容是`*.o`的形式，那么make会将每个`.o`同名的`.c`文件编译成对应的`.o`文件。

```
LIB_OBJS=read-cache.o sha1_file.o usage.o object.o commit.o tree.o blob.o \
	 tag.o date.o index.o diff-delta.o patch-delta.o entry.o path.o \
	 epoch.o refs.o csum-file.o pack-check.o pkt-line.o connect.o

# 定义了$(LIB_OBJS)中各目标的依赖关系
blob.o: $(LIB_H)
tree.o: $(LIB_H)
commit.o: $(LIB_H)
tag.o: $(LIB_H)
object.o: $(LIB_H)
read-cache.o: $(LIB_H)
sha1_file.o: $(LIB_H)
usage.o: $(LIB_H)
strbuf.o: $(LIB_H)
gitenv.o: $(LIB_H)
entry.o: $(LIB_H)
diff.o: $(LIB_H) diffcore.h
diffcore-rename.o : $(LIB_H) diffcore.h
diffcore-pathspec.o : $(LIB_H) diffcore.h
diffcore-pickaxe.o : $(LIB_H) diffcore.h
diffcore-break.o : $(LIB_H) diffcore.h
diffcore-order.o : $(LIB_H) diffcore.h
epoch.o: $(LIB_H)
```

### 小结
综上，编译分成四个阶段：
1. 编译生成LIB_OBJS变量定义的`.o`文件
2. 将生成的`.o`文件打包成`libgit.a`
3. 编译生成`PROG`中定义的目标可执行文件，其共享库为`libgit.a`，每个目标对应的`c`文件名称为去掉`git-`前缀。
4. all: $(PROG)，完成默认target的动作


附加的各个target
----------------------------------------------------------------------------------------------------
暂未细究，供参考
```
install: $(PROG) $(SCRIPTS)
	$(INSTALL) -m755 -d $(dest)$(bin)
	$(INSTALL) $(PROG) $(SCRIPTS) $(dest)$(bin)

check:
	for i in *.c; do sparse $(CFLAGS) $(SPARSE_FLAGS) $$i; done

test-date: test-date.c date.o
	$(CC) $(CFLAGS) -o $@ test-date.c date.o

test-delta: test-delta.c diff-delta.o patch-delta.o
	$(CC) $(CFLAGS) -o $@ $^

git.spec: git.spec.in
	sed -e 's/@@VERSION@@/$(GIT_VERSION)/g' < $< > $@

dist: git.spec
	git-tar-tree HEAD $(GIT_TARNAME) > $(GIT_TARNAME).tar
	@mkdir -p $(GIT_TARNAME)
	@cp git.spec $(GIT_TARNAME)
	tar rf $(GIT_TARNAME).tar $(GIT_TARNAME)/git.spec
	@rm -rf $(GIT_TARNAME)
	gzip -9 $(GIT_TARNAME).tar

rpm: dist
	rpmbuild -ta git-$(GIT_VERSION).tar.gz

test: all
	$(MAKE) -C t/ all

clean:
	rm -f *.o mozilla-sha1/*.o ppc/*.o $(PROG) $(LIB_FILE)
	$(MAKE) -C Documentation/ clean

backup: clean
	cd .. ; tar czvf dircache.tar.gz dir-cache
```





