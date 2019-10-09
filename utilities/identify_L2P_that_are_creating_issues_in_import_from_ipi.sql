# This tries to identify the L2P that are problematic:

# List all the new L2P that do NOT exits in UNTE yet

	SELECT
		`c`.`condo`
		, `a`.`flat_id`
		, `b`.`designation`
		, `a`.`tower`
		, `a`.`condo_id`
	FROM
		`db_all_dt_2_flats` AS `a`
		LEFT JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_flat` = `b`.`external_id`)
		LEFT JOIN `db_sourcing_ls_0_condo` AS `c`
			ON (`a`.`condo_id` = `c`.`id_condo`)
	WHERE (`b`.`designation` IS NULL)
	ORDER BY 
		`c`.`condo` ASC
		, `a`.`flat_id` ASC
		, `a`.`tower` ASC
		, `b`.`designation` ASC
	;

# List of L2P that are NOT imported in the table `hmlet_level_2_units`

	SELECT
		`c`.`condo` AS `ipi_condo_name`
		, `a`.`system_id_flat` AS `ipi_flat_system_id`
		, `a`.`tower` AS `ipi_flat_tower`
		, `a`.`flat_id` AS `ipi_flat_id`
		, `b`.`tower` AS `hmlet_L2_tower`
		, `b`.`designation` AS `hmlet_L2_designation`
	FROM
		`db_all_dt_2_flats` AS `a`
		LEFT JOIN `hmlet_level_2_units` AS `b`
			ON (`a`.`system_id_flat` = `b`.`external_id`)
		LEFT JOIN `db_sourcing_ls_0_condo` AS `c`
			ON (`a`.`condo_id` = `c`.`id_condo`)
	WHERE (`b`.`designation` IS NULL)
	ORDER BY 
		`c`.`condo` ASC
		, `a`.`flat_id` ASC
		, `a`.`tower` ASC
		, `b`.`designation` ASC
	;