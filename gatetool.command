#!/bin/bash

while true
do
 read -r -p "Do you wish to have gatekeeper enabled or disabled? [E/D]" input

 case $input in
     [E])
 echo "Please enter your Administrator password."
 sudo spctl --master-enable
 echo "Enabled"
 exit
 ;;

     [D])
 echo "Please enter your Administrator password."
 sudo spctl --master-disable
 echo "Disabled"
 exit
        ;;

     *)
 echo "Invalid input..."
 ;;
 esac
done
