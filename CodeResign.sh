#!/bin/sh

#  CodeResign.sh
#  
#
#  Created by semal.gajera on 5/22/15.
#

set -e

PlistFile="Configration.plist"
FileName=`/usr/libexec/PlistBuddy -c "print :'FileName'" $PlistFile`
FileType=`/usr/libexec/PlistBuddy -c "print :'FileType'" $PlistFile`
NewBundleIdentifier=`/usr/libexec/PlistBuddy -c "print :'NewBundleIdentifier'" $PlistFile`
Certificate=`/usr/libexec/PlistBuddy -c "print :'Certificate'" $PlistFile`
ProvisioningProfile=`/usr/libexec/PlistBuddy -c "print :'ProvisioningProfile'" $PlistFile`
PayloadDir="Payload"
OutputDir="Output"
OutputDirIPA="$OutputDir/$FileName.ipa"


echo "FileNeme: $FileName"
echo "FileType: $FileType"
echo "NewBundleIdentifier: $NewBundleIdentifier"
echo "Certificate: $Certificate"
echo "ProvisioningProfile: $ProvisioningProfile"


###################################
# Functions
###################################

error_exit() {

    red=`tput setaf 1`
    reset=`tput sgr0`

    echo "$red *********$1 $reset" 1>&2
    exit 1
}

removePayloadDir() {

    if [ -d "$PayloadDir" ]; then
        rm -rf "$PayloadDir"
        echo "\nPayload directory removed\n"
    fi
}

resetOutputDir(){

    if [ -d "$OutputDir" ]; then
        rm -rf "$OutputDir"
        echo "\nOutput directory removed\n"
    fi

    mkdir $OutputDir
}

cleanup() {

    echo "\nClean Up\n"
    # Removing Directories if exist

    removePayloadDir

    resetOutputDir

}

inputValidation() {



    if [  ! "$FileName" ]; then

        error_exit "\nPlease provide FileName in $PlistFile!  Aborting.\n"
    fi

    if [  ! "$FileType" ]; then
        error_exit "\nPlease provide FileType in $PlistFile!  Aborting.\n"
    fi

    if [  ! "$Certificate" ]; then
        error_exit "\nPlease provide Certificate name in $PlistFile!  Aborting.\n"
    fi

    if [ ! "$ProvisioningProfile" ]; then
        error_exit "\nPlease provide ProvisioningProfile in $PlistFile!  Aborting.\n"
    fi

}

###################################
# Script Execution
###################################

#
# Clean up old resorces
#

cleanup

#
# Validate inputs from Configration.plist
#

inputValidation

#
# Check for type fo input file
#
shopt -s nocasematch
if [[ $FileType = "IPA" ]]; then
    echo "IPA file"

    unzip "$FileName.$FileType"
fi;

if [[ $FileType = "ARCHIVE" ]]; then
    echo "Archive file"

    mkdir $PayloadDir

    #
    # Copy app file into payload directory
    #

    for AppFile in $FileName.xcarchive/Products/Applications/*.app
    do
        cp -r $AppFile $PayloadDir
    done

fi;

#
# Remove exsting code sign resources
#

for AppFile in $PayloadDir/*.app
do

    CodeSignaturePath="$AppFile/_CodeSignature"
    CodeResourcesPath="$AppFile/CodeResources"

    if [ -d "$CodeSignaturePath" ]; then
        rm -rf "$CodeSignaturePath"
        echo "\n_CodeSignature directory removed\n"
    fi

    if [ -d "$CodeResourcesPath" ]; then
        rm -rf "$CodeResourcesPath"
        echo "\nCodeResources directory removed\n"
    fi

    # Remove provisioning profile
    rm -f $AppFile/embedded.mobileprovision

    #
    # Check if new bundle id is available in configration file, if avalable update info.plist file
    #

    InfoPlistPath="$AppFile/Info.plist"

    if [ ! -z "$NewBundleIdentifier" -a "$NewBundleIdentifier" != " " ]; then
        echo "\nNewBundleIdentifier: $NewBundleIdentifier\n"

        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $NewBundleIdentifier" $InfoPlistPath
        echo "\nUpdated  ($InfoPlistPath) with new bundle identifier ($NewBundleIdentifier)\n"
    fi

    #
    # Copy new provisioning profile
    #

    cp -f "$ProvisioningProfile" "$AppFile/embedded.mobileprovision"

    echo "\nCopied new provisioning profile: $ProvisioningProfile\n"

    #
    # Signing App file with new identity
    #

    codesign -f -v -s "$Certificate" "$AppFile"

    echo "\n Signing done \n"

    echo "\n********** Signing Details ************\n"

    codesign -dvvv "$AppFile"

    echo "\n***************************************\n"

done

#
# Generating IPA
#

zip -yr $OutputDirIPA $PayloadDir

echo "\nPlease find resigned IPA at: $(PWD)/$OutputDirIPA"

rm -rf $PayloadDir

echo "\n"
