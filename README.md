# JOSM Development version file updater
JOSM file updater on local Windows machine
# Why?
I love OpenStreetMap. This is why I contribute my spear time to this project.

The main tool I contribute to OSM is JOSM application based on Java.

I prefer using the newest JOSM version. This is why I've created this tool to download the newest DEVELOPMENT (not TESTED) file version. 
To be honest, the tool was created not by me but the idea was mine and I asked my ex-colleague (unfortunately he does not have an account on GitHub) to help me.  
# How does it work?
Simply. 
1. Download all files and put them in one directory on your Windows machine. 
2. Find a file named RunMe.cmd.
3. Double click on it to initiate wget to download the josm-latest.jar file from https://josm.openstreetmap.de. The file is downloaded to the parent folder where files of downloader are placed. 

For example, I have a PortalbeApps folder with  JOSM_updater folder in it - PortalbeApps/JOSM_updater/. So, josm-latest.jar is downloaded to a PortalbeApps folder.

If you want another place josm-latest.jar to be uploaded, just change "..\josm-latest.jar" part in RunMe.cmd (can be opened with Notepad).
