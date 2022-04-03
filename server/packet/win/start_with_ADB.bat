@echo off
adb reverse tcp:8888 tcp:8888 && echo Running ADB reverse
start /min cmd "/c @echo off & echo Will launch the browser on the tablet in 5s. & ping -n 3 127.0.0.1 > null & adb shell am start -a android.intent.action.VIEW -d http://localhost:8888" && echo Will launch the browser on the tablet in 5s. 
vTablet.exe