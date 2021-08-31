#!/usr/bin/python
# -*- coding: utf-8 -*-
import RPi.GPIO as GPIO
import time

TACH = 16
PULSE = 2
WAIT_TIME = 1

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(TACH, GPIO.IN, pull_up_down=GPIO.PUD_UP)

t = time.time()
rpm = 0

def fell(n):
    global t
    global rpm

    dt = time.time() - t
    if dt < 0.005: return

    freq = 1 / dt
    rpm = (freq / PULSE) * 60
    t = time.time()

GPIO.add_event_detect(TACH, GPIO.FALLING, fell)

try:
    while True:
        fanrpm = open('/home/pi/bin/conky/fanrpm.txt', "w")
        fanrpm.write("%.f RPM" % rpm)
        fanrpm.close()
#        print "%.f RPM" % rpm
        rpm = 0
        time.sleep(2)

#except KeyboardInterrupt:
#    GPIO.cleanup()

