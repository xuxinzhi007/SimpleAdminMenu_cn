# Simple Admin Menu v1.2 FORCE OPEN PATCH

This version fixes the issue where F6 and right-click do nothing even though the mod is enabled.

## What changed

- Added a small always-visible ADMIN button near the lower-left of the screen.
- Added multiple hotkey hooks for F6.
- Kept right-click world menu support.
- Added stronger console logging.
- Added delayed fallback loading so the ADMIN button appears after you enter a save.

## How to open

After loading into a save, look for a small button that says:

ADMIN

Click it to open or close the menu.

You can also try:

Right-click world > Admin Menu > Open Admin Menu

or press:

F6

## Install

Delete your old SimpleAdminMenu folder first.

Then place the new SimpleAdminMenu folder into:

Windows:
C:\Users\YOURNAME\Zomboid\mods\SimpleAdminMenu

Linux / Steam Deck:
~/Zomboid/mods/SimpleAdminMenu

Enable Simple Admin Menu from the Project Zomboid Mods menu.

## If it still does not show

Open console.txt and search for:

[SimpleAdminMenu v1.2]

If you do not see that line, the Lua file is not loading.
If you do see it, send the nearby lines and the patch can be adjusted.
