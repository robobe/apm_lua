```
./Tools/autotest/sim_vehicle.py --defaults /home/user/projects/apm_lua/params/lua.param -v ArduCopter
```

```
sudo ip link set can0 type can bitrate 125000
sudo ip link can0 up
```

# Rover

```
./Tools/autotest/sim_vehicle.py -v apmrover2
```

```
param show SCR_ENABLE
```

```
ftp put /home/user/projects/apm_lua/scripts/simple_loop.lua scripts/hello.lua

```

```
output add udp:10.100.102.67:14550
```