# 完整 Fork（保持与上游完全一致）操作指南

> 目标仓库：`https://github.com/mgz0227/OpenWrt_x86`

如果你希望 **Fork 后内容和上游完全一致**，建议使用下面两种方式之一：

## 方式 1：GitHub 网页 Fork（最简单）

1. 打开上游仓库：`https://github.com/mgz0227/OpenWrt_x86`
2. 点击右上角 **Fork**，选择你的账号。
3. 进入你自己的 Fork 仓库。
4. 在仓库首页点击 **Sync fork**（或在设置中开启自动同步），保持与上游一致。

## 方式 2：命令行镜像 Fork（最严格一致）

> 该方式会把所有分支、标签和引用完整镜像过去。

```bash
# 1) 镜像克隆上游（包含全部 refs）
git clone --mirror https://github.com/mgz0227/OpenWrt_x86.git
cd OpenWrt_x86.git

# 2) 在 GitHub 上先创建一个空仓库（不要初始化 README）
# 假设你的仓库地址为：git@github.com:<your_user>/OpenWrt_x86.git

# 3) 推送镜像到你的仓库
git push --mirror git@github.com:<your_user>/OpenWrt_x86.git
```

## 后续与上游保持一致（推荐定期执行）

```bash
cd OpenWrt_x86.git

git remote set-url --push origin git@github.com:<your_user>/OpenWrt_x86.git
git fetch -p origin
git push --mirror
```

## 校验是否一致

```bash
# 比较本地镜像 refs 与目标仓库 refs（示意）
git ls-remote origin | sort > /tmp/upstream.refs
git ls-remote git@github.com:<your_user>/OpenWrt_x86.git | sort > /tmp/fork.refs
diff -u /tmp/upstream.refs /tmp/fork.refs
```

`diff` 无输出时，说明 refs 已完全一致。
