A systemd service that keeps the files netdata checks up to date. Does the same as running the "source ./stats.sh ...." command but may be more usable. Will start automatically on boot after 7 minutes, giving time for gridcoin to start, then updates the files every 5 seconds.

INSTALL
As long as the machine is setup per the main readme file. Run "./setup_service.sh" (may require sudo) to copy the files to the proper directories.

Enable the service using "systemctl enable gridcoin_netdata_stats.timer"

Start the service timer using "systemctl start gridcoin_netdata_stats.timer"

Find the status of the service "systemctl status gridcoin_netdata_stats.service"
