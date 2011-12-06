#!/bin/bash

#Pull config from file.
DATE=$(date +"%m-%d-%Y")
PACKAGE=$"jdkernel_inc_sense_$DATE.zip"
PACKAGE_SIGNED=$"jdkernel_inc_sense_signed_$DATE.zip"


 echo "
 === Welcome to JDBOT! Kernel build has initiated successfully! ===
"

cd ~/incrediblec_sense_2.6.35
rm -rf ~/Incrediblec_sense_2.6.35/AnyKernel
make clean
make jdkernel_inc_defconfig
export CCOMPILER=${HOME}/android/system/prebuilt/linux-x86/toolchain/arm-eabi-4.4.0/bin/arm-eabi-
make ARCH=arm CROSS_COMPILE=$CCOMPILER -j8
if [ -f ~/incrediblec_2.6.35/arch/arm/boot/zImage ];
     then
         echo "
 === zImage found. Onward to packaging. ===
"
     else
       echo "
 === zImage not found. Fix your code and re-compile. ===
"
         exit 0
 fi
git clone https://github.com/koush/AnyKernel.git
rm ~/incrediblec_sense_2.6.35/AnyKernel/kernel/zImage
rm  ~/incrediblec_sense_2.6.35/AnyKernel/system/lib/modules/tiwlan_drv.ko
cp ~/Incrediblec_sense_2.6.35/arch/arm/boot/zImage ~/Incrediblec_sense_2.6.35/AnyKernel/kernel/zImage
cp ~/incrediblec_sense_2.6.35/drivers/net/wireless/bcm4329_204/bcm4329.ko  ~/Incrediblec_sense_2.6.35/AnyKernel/system/lib/modules/bcm4329.ko
cd AnyKernel
echo " 
=== Packing files. ===
"
zip -r $PACKAGE system kernel META-INF 
echo " 
=== Signing Zip. ===
"
java -jar ~/kernelsign/signapk.jar ~/kernelsign/testkey.x509.pem ~/kernelsign/testkey.pk8 ~/incrediblec_sense_2.6.35/AnyKernel/$PACKAGE ~/incrediblec_sense_2.6.35/AnyKernel/$PACKAGE_SIGNED
rm ~/incrediblec_sense_2.6.35/AnyKernel/$PACKAGE
md5sum $PACKAGE_SIGNED > $PACKAGE_SIGNED.md5sum
echo " 
=== DONE! ===
"
exit
