#!/bin/bash

# 10.11 or newer use Seeding.framework
# 10.10 or older use legacy enrollment

MAJOR_VERSION=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d '.' -f 2,2)
CONFIGURATION_URL="https://configuration.apple.com/configurations/macos/seeding/content"

if [ $MAJOR_VERSION -gt 10 ]; then
    echo "Beta Access Utility: major version greater than 10.10. Enrolling in DeveloperSeed"
    /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil enroll DeveloperSeed
else
    echo "Beta Access Utility: major version less than or equal to 10.10. Enrolling in DeveloperSeed"

    if [ $MAJOR_VERSION -eq 10 ]; then
        /usr/sbin/softwareupdate --set-catalog https://swscan.apple.com/content/catalogs/others/index-10.10seed-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz
    elif [ $MAJOR_VERSION -eq 9 ]; then
        /usr/sbin/softwareupdate --set-catalog https://swscan.apple.com/content/catalogs/others/index-10.9seed-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz

        #32062857
        echo "Beta Access Utility: major version is 10.9. Writing /Library/Application Support/App Store/.SeedEnrollment.plist"
        /usr/libexec/PlistBuddy -c "clear dict"  -c "add :SeedProgram string DeveloperSeed" "$3/Library/Application Support/App Store/.SeedEnrollment.plist"
    elif [ $MAJOR_VERSION -eq 8 ]; then
        /usr/sbin/softwareupdate --set-catalog https://swscan.apple.com/content/catalogs/others/index-mountainlionseed-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz
    fi
fi

/usr/libexec/PlistBuddy -c "clear dict"  -c "add :SeedProgram string DeveloperSeed" "$3/Users/Shared/.SeedEnrollment.plist"

if [[ -e "/System/Library/CoreServices/Applications/Feedback Assistant.app" ]]; then
    "/System/Library/CoreServices/Applications/Feedback Assistant.app/Contents/Library/LaunchServices/seedusaged"
fi

if [ ! -f "/tmp/staged-content-1.0.plist" ]; then
    CONFIGURATION_PLIST=$(/usr/bin/curl $CONFIGURATION_URL/content-1.0.plist -fL)
else
    CONFIGURATION_PLIST=$(/bin/cat /tmp/staged-content-1.0.plist)
fi

if [ $? -eq 0 ]; then
    # we got the plist
    echo "Beta Access Utility: Received plist from $CONFIGURATION_URL/content-1.0.plist"
    TMP_FILE=$(/usr/bin/mktemp 2> /dev/null || /usr/bin/mktemp -t tmp)
    if [ $? -ne 0 ]; then
        echo "Beta Access Utility: Could not open tmp file"
        if [ $MAJOR_VERSION -lt 14 ]; then
            /usr/bin/open macappstore://showUpdatesPage
            echo "Beta Access Utility: Pre-10.14. Opened MAS updates pane"
        else
            /usr/bin/open "x-apple.systempreferences:com.apple.preferences.softwareupdate?client=bau"
            echo "Beta Access Utility: 10.14 or later. Opened Software Updates System Preferences Pane"
        fi
    fi

    echo -n $CONFIGURATION_PLIST > "$3/$TMP_FILE"

    MAINLINE_SEEDING_ACTIVE=$(/usr/libexec/PlistBuddy -c "Print :MainlineSeedingActive" $TMP_FILE)

    if [ $? -eq 0 ] && [ "$MAINLINE_SEEDING_ACTIVE" == "true" ]; then
        if [ $MAJOR_VERSION -lt 14 ]; then
            ADAM_ID=$(/usr/libexec/PlistBuddy -c "Print :ProductPageAdamID" $TMP_FILE)
            /usr/bin/open macappstores://itunes.apple.com/app/id$ADAM_ID
            echo "Beta Access Utility: Pre-10.14: Opened MAS link: macappstores://itunes.apple.com/app/id$ADAM_ID"
        else
            BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :IASUBundleID" $TMP_FILE)
            /usr/bin/open "x-apple.systempreferences:com.apple.preferences.softwareupdate?client=bau&installMajorOSBundle=$BUNDLE_ID"
            echo "Beta Access Utility: 10.14 or later. Opened Software Updates System Preferences Pane: installMajorOSBundle=$BUNDLE_ID"
        fi
    else
        if [ $MAJOR_VERSION -lt 14 ]; then
            /usr/bin/open macappstore://showUpdatesPage
            echo "Beta Access Utility: Pre-10.14. Opened MAS updates pane"
        else
            /usr/bin/open "x-apple.systempreferences:com.apple.preferences.softwareupdate?client=bau"
            echo "Beta Access Utility: 10.14 or later. Opened Software Updates System Preferences Pane"
        fi
        echo "Beta Access Utility: Opened MAS updates pane"
    fi

    rm $TMP_FILE

else
    # fall back to updates pane
    /usr/bin/open macappstore://showUpdatesPage
    echo "Beta Access Utility: Received error attempting to reach $CONFIGURATION_URL/content-1.0.plist. Opened MAS updates pane"
fi
