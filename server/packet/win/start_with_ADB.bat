adb reverse tcp:8888 tcp:8888 
adb shell am start -a android.intent.action.VIEW -d http://localhost:8888
vTablet.exe