# This tries to identify the L3P that are problematic:

# List all the new L3P that do NOT exits in UNTE yet

	SELECT
		`d`.`condo`
		, `c`.`flat_id`
		, `c`.`tower`
		, `a`.`room_designation`
		, `b`.`room_designation` AS `ext_L3P`
	FROM
		`205_rooms` AS `a`
		LEFT JOIN `external_property_level_3_rooms` AS `b`
			ON (`a`.`id_room` = `b`.`external_id`)
		LEFT JOIN `db_all_dt_2_flats` AS `c`
			ON (`a`.`system_id_flat` = `c`.`system_id_flat`)
		LEFT JOIN `db_sourcing_ls_0_condo` AS `d`
			ON (`c`.`condo_id` = `d`.`id_condo`)
	WHERE (`b`.`room_designation` IS NULL)
	ORDER BY 
		`d`.`condo` ASC
		, `c`.`flat_id` ASC
		, `c`.`tower` ASC
		, `a`.`room_designation` ASC
	;