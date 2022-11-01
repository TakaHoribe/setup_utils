#!/usr/bin/env python$

import os
import subprocess
import time
import numpy as np
import matplotlib.pyplot as plt

t_arr = []
v_arr = []

t = 0.0
dt = 1.0

plt.ion()
figure, ax = plt.subplots(figsize=(8,6))
line1, = ax.plot(t_arr, v_arr)

plt.xlabel("time [s]",fontsize=10)
plt.ylabel("cpu freq average",fontsize=10)
try:
    while True:
        res = subprocess.check_output('cat /proc/cpuinfo | grep MHz | cut -d " " -f 3', shell=True, text=True)
        res2 = res.split('\n')[0:12]
        val = [float(item) for item in res2]
        ave = sum(val) / len(val)

        time.sleep(dt)

        t_arr.append(t)
        v_arr.append(ave)

        t = t + dt

        line1.set_data(t_arr, v_arr)
        ax.set_xlim((0, t_arr[-1]))
        ax.set_ylim((1000, 5500))

        plt.pause(.01)
except KeyboardInterrupt:
    print('stop!')
