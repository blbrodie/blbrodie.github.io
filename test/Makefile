all: schedule_flight_to_los_angeles

schedule_flight_to_krakow:
	@if [ -z "$(krakow_date)" ]; then \
		echo "You must set krakow_date"; exit 1; fi
		echo $(krakow_date) > schedule_flight_to_krakow

schedule_drive_to_riga: schedule_flight_to_krakow
	@if [ -z "$(riga_date)" ]; then \
		echo "You must set riga_date"; exit 1; fi
		echo $(riga_date) > schedule_drive_to_riga

schedule_flight_to_tromso: schedule_drive_to_riga
	@if [ -z "$(tromso_date)" ]; then \
		echo "You must set tromso_date"; exit 1; fi
		echo $(tromso_date) > schedule_flight_to_tromso

schedule_flight_to_los_angeles: schedule_flight_to_tromso
	@if [ -z "$(los_angeles_date)" ]; then \
		echo "You must set los_angeles_date"; exit 1; fi
		echo $(los_angeles_date) > schedule_flight_to_los_angeles

reschedule_flight_to_los_angeles: schedule_flight_to_los_angeles
	@if [ -z "$(los_angeles_date)" ]; then \
		echo "You must set los_angeles_date"; exit 1; fi
		echo $(los_angeles_date) > schedule_flight_to_los_angeles
