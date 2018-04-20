###############
# vio server disk info script for vhost attached luns.
# ipg_vl 2014/05/21
###############
echo hostname,frameid,volid,disk,disksize,vhostadapter,presentedas
hostname=$(/usr/ios/cli/ioscli hostname)
mapall=$(/usr/ios/cli/ioscli lsmap -all -type disk -field backing vtd|cut -c 22-|sed 's/^$/:/'|tr '\n' ' ')
for disk in $(/usr/ios/cli/ioscli lsdev -type disk|grep -v "Virtual Target Device"|grep -v ^name|awk '{print $1}')
do
   presentedas=unpresented
   vhostadapter=novhost
   wwn=WWNNOTAPPLICABLE
   disksn=NONE
   #parent1=$(/usr/ios/cli/ioscli lsdev -dev $disk -parent|tail +3)
   #parent2=$(/usr/ios/cli/ioscli lsdev -dev $parent1 -parent|tail +3)
     echo $parent2|grep -q ^pci
     if [ $? == 1 ]; then
       #wwn=$(/usr/ios/cli/ioscli lsdev -dev $parent2 -vpd|grep "Network Address"|awk -F. '{print $NF}')
       volid=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|grep "FRU Label"|awk -F. '{print $NF}')
       if [ x$volid == x ]; then
         frameid=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|grep "EC Level"|awk -F. '{print $NF}')
         if [ x$frameid == x ]; then
           frameid=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|grep "Device Specific"|awk -F. '{print $NF}')
         fi
         volid=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|grep "LIC Node VPD"|awk -F. '{print $NF}')
         if [ x$volid == x ]; then
           volid=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|grep "Serial Number"|awk -F. '{print $NF}')
         fi
       else
         frameid=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|grep "Serial Number"|awk -F. '{print $NF}')
       fi
       #disksn=$(/usr/ios/cli/ioscli lsdev -dev $disk -vpd|awk '/Z1/ {print substr($2,length($2)-3,4)}')
       disksize=$(/usr/ios/cli/ioscli lspv -size $disk)
     fi
   presentedas=$(echo $mapall|tr ':' '\n'|grep "$disk "|awk '{print $2}')
     if [ ! -z $presentedas ];then
       vhostadapter=$(/usr/ios/cli/ioscli lsdev -dev $presentedas -parent|grep ^v)
     else
        presentedas=unpresented
        vhostadapter=novhost
     fi
   #echo $hostname,$wwn,$parent1:$parent2,$frameid,$volid,$disksn,$disk,$disksize,$vhostadapter,$presentedas
   echo $hostname,$frameid,$volid,$disk,$disksize,$vhostadapter,$presentedas
done