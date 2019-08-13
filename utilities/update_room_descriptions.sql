# This script updates the room descriptions based on 
#	- the Unit number and 
#	- the last 3 characters of the room designation
# 
# This works for the hmlet units.
# We will limit this script to the units created by hmlet.

# We do the update:

UPDATE `external_property_level_3_rooms` AS `a`
	INNER JOIN `external_property_level_2_units` AS `b`
		ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
	SET `room_description` = (CONCAT (CONCAT ('Unit '
					, `b`.`unit_id`
					)
				, ' - Room ',
				SUBSTRING(`room_designation`, -3)
				)								
			)
		, `a`.`syst_updated_datetime` = NOW()
		, `a`.`update_system_id` = 'Unee-T Enterprise portal'
		, `a`.`update_method` = 'Manage_Rooms_Edit_Page'
		, `a`.`updated_by_id` = 2
	WHERE `a`.`created_by_id` = 2
	;