Empty epsilon configuration
===========================

options.ini is used to configure autoconnecting of stations.
should be linked to ~/.emptyepsilon/options.ini

hardware.ini is used to configure DMX channels.
It should only be configured on the GM room Main Screen client,
NOT the server. This is because the server does not select a ship
explicitly and we want the DMX signals only from Odysseus

Link hardware.ini to ~/.emptyepsilon/hardware.ini

Ensure that the user running Empty Epsilon is part of 
dialout group allowed to control the ttyUSB devices. If nothing
works, run as sudo.


