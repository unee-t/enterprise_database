UPDATE `ut_map_external_source_units` AS `a`
	INNER JOIN `property_level_2_units` AS `b`
		ON (`a`.`new_record_id` = `b`.`system_id_unit`)
		SET `a`.`tower` = `b`.`tower`
		WHERE `a`.`external_property_type_id` = 2
		;