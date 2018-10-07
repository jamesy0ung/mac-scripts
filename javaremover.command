#!/bin/bash

echo "This script MUST be run under an account with administrator privileges."

while true
do
 read -r -p "Do you wish to have java removed or left alone? [R or L]" input

 case $input in
     [R])
 echo "Please enter your Administrator password."
 sudo rm -fr /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin
 sudo rm -fr /Library/PreferencePanes/JavaControlPanel.prefPane
 rm -fr ~/Library/Application\ Support/Oracle/Java
 echo "Java has sucessfully been removed from your Mac."
 exit
 ;;

     [L])
 echo "Please enter your Administrator password."
 echo "Quitting"
 exit
        ;;

     *)
 echo "Invalid input"
 ;;
 esac
done
