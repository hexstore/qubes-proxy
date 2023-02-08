# Qubes Proxy

这是一个在Qubes OS中安装代理网络工具([sing-box](https://sing-box.sagernet.org/))的方案，旨在帮助Qubes OS用户在严重网络审查环境下突破封锁，让Qubes OS拥有连接Tor网络的能力。

该项目主仓库在[sourcehut](https://git.sr.ht/~qubes/proxy)上，并镜像在[GitHub](https://github.com/hexstore/qubes-proxy)。

## 工作原理

它基于Qubes OS的隔离机制，提供一个网络服务盒子，巧妙的利用了Qubes OS的全局DNS IP(10.139.1.1和10.139.1.2)作为tun设备的IP，并让流量经过它，为其它应用或服务盒子提供代理网络。

## 使用场景

它可以工作在这些场景下，也许您有自己的方案！

- sys-net <- sys-firewall <- **sys-proxy** <- AppVM(s)
- sys-net <- **sys-proxy** <- sys-firewall <- AppVM(s)

## 前提条件

- Qubes OS
- 代理服务帐号

## 安装

这里创建一个代理盒子，它被命名为`sys-proxy`，然后从GitHub下载[sing-box](https://github.com/SagerNet/sing-box/releases)的二进制文件。

```bash
[user@dom0 ~]$ qvm-create sys-proxy --class AppVM --label blue
[user@dom0 ~]$ qvm-prefs sys-proxy provides_network true
[user@dom0 ~]$ qvm-prefs sys-proxy autostart true
[user@dom0 ~]$ qvm-prefs sys-proxy memory 500
[user@dom0 ~]$ qvm-prefs sys-proxy maxmem 500
```

接下来将安装sing-box到`/rw/usrlocal/bin`目录，配置文件`sing-box.json`被安装到`/rw/bind-dirs/etc/sing-box`目录，
守护运行配置文件`sing-box.service`被安装到`/rw/bind-dirs/etc/systemd/system`目录。

完成安装之后，您需要更改`/rw/bind-dirs/etc/sing-box.json`中的`outbounds`为自己的代理服务，
更多配置信息请参照[sing-box configuration](https://sing-box.sagernet.org/configuration/)。

```bash
[user@dom0 ~]$ qvm-start sys-proxy
[user@dom0 ~]$ qrexec-client -W -d sys-proxy user:'sh <(curl --proto "=https" -tlsv1.2 -SfL https://git.sr.ht/~qubes/proxy/blob/main/install.sh)'
```

来到这一步，将要重启`sys-proxy`盒子。

```bash
[user@dom0 ~]$ qvm-shutdown --wait sys-proxy
[user@dom0 ~]$ qvm-start sys-proxy
```

确认`sys-proxy`盒子确认代理服务的运行状态。

```bash
[user@dom0 ~]$ qrexec-client -W -d sys-proxy root:'journalctl -ft sing-box'
```

最后，将应用或服务盒子的`netvm`配置为`sys-proxy`，以下示例将`sys-whonix`的网络配置为`sys-proxy`，即`sys-proxy`作为`sys-whonix`前置代理。

```bash
[user@dom0 ~]$ qvm-prefs sys-whonix netvm sys-proxy
```

## 贡献

您在使用这个项目的过程中发现任何问题或疑问，可以随时[创建ticket](https://todo.sr.ht/~qubes/proxy)，我们将会尽快解答。另外，您有任何改进方案，欢迎提交一个[patch](https://git.sr.ht/~qubes/proxy/send-email)。

## 相关

- [Qubes OS](https://www.qubes-os.org/)
- [sing-box](https://sing-box.sagernet.org/)
- [sing-box GitHub](https://github.com/SagerNet/sing-box)
