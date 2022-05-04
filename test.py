#!/usr/bin/env python3
import math

print("TEST CODE")

print("USING CONSTANTS")

a = 15.0
y = 939.0
v = 200.0

angularDistance = y/math.sin(math.radians(a))
dist = angularDistance * math.cos(math.radians(a))

fallTime = math.sqrt((2 * y)/9.8)
 
travelTime = dist/v

print("fallTime:", fallTime)
print("distance:", dist)
print("angularDistance:", angularDistance)
print("TimeToTarg:", travelTime)
print("Result:",travelTime - fallTime)
