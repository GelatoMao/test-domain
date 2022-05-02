- tess 中 cluster 之间的关系，一个 cluster 应该是由多个 node 组成，不同 cluster 分给公司不同部门? (k8s 集群中有 Master Node 和 Worker Node，33 集群就是一个 k8s 集群，33 上应该有 Master Node，还有 Worker Node，然后 bdp 容器应该就部署在 Worker Node 上的)
- workload 概念：提交到 k8s 中的任务为 workload，workload 分为 2 种，一种是 pod(k8s 中的最小单位)，一种是 controller (部署一个 workload 到 tess 上，deployment 就算是一个 workload，deployment 是一个配置文件，当有这个配置文件，k8s 就会帮忙起一个 pod，pod 里面跑的是 container，k8s 中，container 外面有一个 pod。如果要跑一个 docker image，有几种方式：1 直接建一个 pod，不推荐，因为直接建一个 pod，是一次性的。2 建一个 deployment，deployment 会帮忙建一个 Pod，去管理这个 pod，pod 中再去跑 container。3 建一个 StatefulSet，一般的 pod 或者 deployment 建出来的 pod 是无状态的，如果想有状态，就使用 StatefulSet。有状态和无状态的区别：如果一个 application 启动起来了，怎么跑都是一样的，这个 application 就是无状态的。比如 BDP，部署在 35 和 116 集群，35 集群上部署了 2 个 pod，116 上也部署了 2 个 pod)
- "在 33 集群上跑一个 pod": （node 镜像，在 node 镜像生成的 container 中可以使用 node 命令运行 js 脚本，但是这个脚本放在什么地方，是不是 node 镜像加上 OS 镜像才行，还是所有的镜像都是 linux 环境），pod 具备什么条件才能说跑起来（比如，一个 pod 中有 2 个 container，其中一个 container 是前端环境，另一个 container 是后端环境，这个 pod 应该可以跑起来），一个集群上有多个 node，那么这个 pod 跑在 33 集群中哪个 node，随机分配的吗？(用 nginx 镜像生成一个 pod，这个 pod 会放在有 nginx 镜像的这个节点下)
- containers 里面的 image 应该是我的 Dockerfile 文件生成的镜像，是不是需要将生成的镜像 push 到 hub.tess.io 上
- 登录账号是 lumao 还是 delosrobot
- 一个 group 可以有多个 account，一个 account 也可以对应多个 group，是多对多的关系，namespace 是用来管理 docker 镜像的资源。一个 namespce 下面会部署 application，这个 application 的资源就是在 namespace 里面管理的。https://cloud.ebay.com/quota/home?account=delosrobot&cluster=tess140&scope=NotBestEffort。目前，我们team是一个application属于一个namespce，这个namespace的资源就被这个application是用。要跑一个新的application，就需要新建一个namespace，一个application instance。

- `k -nbdpns exec -it {pod名称} -c nginx -oyaml`

- 所有命令都是在 k8s 集群的主节点下操作的，登录 33 集群后，我的 yaml 文件写在如何与 33 集群关联，是执行`k apply -f pod.yaml` 自动关联的？

- 修改 Dockerfile 文件后，是不是只能重新 build 才能生成新的镜像，可以在原先 build 好的镜像基础上进行更新吗？

- clear.sh 脚本应该放在什么地方 写在 yaml 配置文件中？

- non-root: https://tess.io/userdocs/security/runasnonroot/

- 需不需要：chmod 777 /entrypoint.sh
- ecex -t /bin/
