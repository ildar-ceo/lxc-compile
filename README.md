# Установка LXC

Установите базовые пакеты:
```
apt install rsync python3 debootstrap libapparmor1 libmpdec2 libc6 libcap2 libseccomp2 multiarch-support
```


Скачайте и установите скомпилированные версии lxc версии 2.0.6
```
wget https://github.com/
dpkg -i ./lxc_2.0.6-1_amd64.deb
```

Включаем LXC в автозагрузку:
```
systemctl enable lxc
systemctl enable lxc-net
```

## Настройка UID/GID


Перед тем как запускать lxc убедитесь в правильной настройке файлов `/etc/subuid` и `/etc/subgid`. Для пользователей lxc и root должны быть выставлены следующие значения:

**less /etc/subuid**
```
lxc:1000000:65536
root:1000000:65536
```

**less /etc/subgid**
```
lxc:1000000:65536
root:1000000:65536
```

Если вдруг вы хотите поставить другие ID, то вы должны их поменять также в `/etc/lxc/lxc/default.conf`.


Также желательно создать пользователей:
```
groupadd lxc-root -g 1000000
useradd lxc-root -g 1000000 -u 1000000 -M -r -d /dev/null
```
Это упростит работу с LXC и будет показывать человеческие значения для root контейнера.


## Перезагружаемся

Перед тем как создавать первый контейнер, нужно перезагрузится, чтобы UID и сеть корректно заработала.

```
init 6
```


## Скачиваем контейнер по умолчанию

```
lxc-create -t download -n test-centos -- -d centos -r 7 -a amd64
```

Скачается чистая версия контейнера centos 7.


**для Debian:**
```
lxc-create -t download -n test-debian -- -d debian -r jessie -a amd64
```

**для Ubuntu:**
```
lxc-create -t download -n test-ubuntu -- -d ubuntu -r xenial -a amd64
```


## Запуск тестового контейнера


Откройте файл `nano /var/lib/lxc/test-centos/config` и добавьте строчку:
```
lxc.network.ipv4 = 10.0.1.5/16
```
Это позволит привязать IP к контейнеру.

Теперь можно запустить контейнер командой `lxc start --name test-centos`

Контейнер сразу должен быть отображен в `lxc top`:
```
Container                   CPU          CPU          CPU          BlkIO        Mem
Name                       Used          Sys         User          Total       Used
test                       0.34         0.10         0.10        6.59 MB    0.00
TOTAL 1 of 1               0.34         0.10         0.10        6.59 MB    0.00
```

Делаем `lxc attach --name test-centos`, чтобы зайти в контейнер

проверяем IP:
```
[root@test /]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
4: em0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:16:3e:c6:69:24 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/16 brd 10.0.255.255 scope global em0
       valid_lft forever preferred_lft forever
    inet6 fe80::216:3eff:fec6:6924/64 scope link
       valid_lft forever preferred_lft forever
```

Делаем ping:
```
[root@test /]# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=45 time=111 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=45 time=109 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 109.131/110.549/111.968/1.456 ms
```

Выходим из контейнера командой `exit`.

Для того чтобы остановить контейнер, нужно выполнить `lxc stop --name test-centos`


Я советую вам скачать шаблон через `lxc-create -t download`, и настроить его. Установить туда mc, nano, wget, полезные утилиты, настроить локаль, ssh, resolv.conf, сертификаты letsencrypt.
И использовать эту сборку как чистую, потому что шаблонная версия очень урезанная.


## Настройка тестового контейнера

Еще можно контейнеру прописать некоторые параметры:


Запускать контейнер только на первых трех cpu:
```
lxc.cgroup.cpuset.cpus = 0,1,2
```

Назначить имя сетевого адаптера для этого контейнера на хостовой машине:
```
lxc.network.veth.pair = veth-containername
```

Имя хоста виртуальной машины:
```
lxc.utsname = containername
```


## Настройка сети

Почему я использую маску 16, а не 24. Это такой лайхак, чтобы путаницы с IP было меньше в облачных системах.

Контейнеров может быть много. Они могут быть установлены на разных хостах. А еще есть всякие virtualbox и qemu. И конфиг контейнера тоже перемещается с машины на машину. А еще есть VPN.

Так вот удобно юзать одинаковые уникальные ip адреса для контейнеров в облачной системе или если у вас несколько серваков.

По крайне мере есть некая гарантия что свежий контейнер не будет конфликтовать с другим контейнером по IP.

Можно также зеркалить IP с VPN IP. Например, 10.0.30.60 - это локальный IP, а 10.50.30.60 - это VPN IP. И всегда можно отняв 50 получить локальный IP и наоборот.

А в системе VPN IP должны быть уникальными.

**Сети:**
```
10.0.0.0/16 - Сеть LXC
10.50.0.0/16 - Сеть Open VPN
10.200.0.0/16 - Сеть LXD
```

**P.S.** В LXC настроен DHCP в диапазоне 10.0.200.1 - 10.0.255.254


# Материалы
1. https://github.com/lxc/lxc
2. https://wiki.ubuntu.com/LinuxContainers
3. https://www.claudiokuenzler.com/blog/517/install-lxc-from-source-ubuntu-14.04-trusty
4. http://vasilisc.com/lxc-1-0-unprivileged-containers
