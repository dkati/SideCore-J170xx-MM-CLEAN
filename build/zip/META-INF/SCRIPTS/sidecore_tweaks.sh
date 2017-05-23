#!/sbin/sh

timeshort="1"
timelong="2"

if [ -e /system/bin/busybox ]; then
	busybox chmod 111 /system/bin/busybox
	BB=/system/bin/busybox
elif [ -e /system/xbin/busybox ]; then
	busybox chmod 111 /system/xbin/busybox
	BB=/system/xbin/busybox
fi;

#Cache drop
$BB free | busybox awk '/Mem/{print ">>>...Memory Before Boosting: "$4/1024" MB";}'
$BB sleep $timeshort
$BB echo ""
$BB echo "Dropping cache"
sync
$BB sleep $timeshort
$BB sysctl -w vm.drop_caches=3
$BB sleep $timeshort
dc=/proc/sys/vm/drop_caches
dc_v=$($BB cat $dc)
if [ "$dc_v" -gt 1 ]; then
$BB sysctl -w vm.drop_caches=1
fi;

#FStrim
if [ -e /system/bin/fstrim ]; then
	$BB echo "Triming cache, please wait..."
       /system/bin/fstrim -v /cache;
	$BB echo ""
	$BB echo "Triming data, please wait..."
       /system/bin/fstrim -v /data;
	$BB echo ""
	$BB echo "Triming system, please wait"
       /system/bin/fstrim -v /system;
elif [ -e /system/xbin/fstrim ]; then
	$BB echo "Triming cache, please wait..."
       /system/xbin/fstrim -v /cache;
	$BB echo ""
	$BB echo "Triming data, please wait..."
       /system/xbin/fstrim -v /data;
	$BB echo ""
	$BB echo "Triming system, please wait"
       /system/xbin/fstrim -v /system;
else
	$BB echo "Your device doesn't support fstrim"
fi;

$BB sleep $timeshort
$BB echo ""
$BB sleep $timelong

#Database optimization

$BB echo "";

for i in `$BB find /data -iname "*.db"`; do
	/system/xbin/sqlite3 $i 'VACUUM;';
	/system/xbin/sqlite3 $i 'REINDEX;';
done;

for i in `$BB find /sdcard -iname "*.db"`; do
	/system/xbin/sqlite3 $i 'VACUUM;';
	/system/xbin/sqlite3 $i 'REINDEX;';
done;


