# CodeResignTool

CodeResignTool provides a easy way to resign your IPA or XCARCHIVE file with different Provisioning Profile and Certificate. You can also change the bundle identifier of the application.

## How To Use

1. Dowload the zip file of this repository.
2. Unzip it at your prefered location.
3. Put .IPA or .XCARCHIVE file, you want to resign, into <b>CodeResignTool</b> directory.
4. Put new provisioning profile into <b>CodeResignTool</b> directory.
5. Open <b>Configration.plist</b> file, set proper values for all keys. (Please refer Configration.plist section below).
6. Run CodeResign.sh file.

### Configration.plist
<PRE>
<b>FileName (Required):</b> 
Name of ipa or xcarchive you want to resign. Do not forget to put this file into <b>CodeResignTool</b> directory.
</PRE>

<PRE>
<b>FileType (Required):</b> 
Type of file you want to resign. It must be either <b>IPA</b> or <b>ARCHIVE</b>.
</PRE>

<PRE>
<b>NewBundleIdentifier (Optional):</b>
Provide bundle identifier, if you want to change bundle identifier of your app.
</PRE>

<PRE>
<b>Certificate (Required):</b>
Name of certificate using which you want to resign your app. 
Please refer section <b>How to get certificate name</b>
</PRE>

### How to get certificate name
