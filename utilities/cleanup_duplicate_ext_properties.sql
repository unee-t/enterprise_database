# This scrip makes sure that we cleanup the duplicates in the tables:
#	- extL1P
#	- extL2P
#	- extL3P

# How many duplicates for L1P?
# The below query should return 0 records

	SELECT
		`created_by_id`
		, `tower`
		, `external_table`
		, `external_system_id`
		, `external_id`
		, COUNT(`id_building`)
	FROM
		`external_property_level_1_buildings`
	GROUP BY 
		`created_by_id`
		, `tower`
		, `external_table`
		, `external_system_id`
		, `external_id`
	HAVING (COUNT(`id_building`) > 1)
	;
	
# How many duplicates for L2P?
# The below query should return 0 records

	SELECT
		COUNT(`system_id_unit`)
		, `external_id`
		, `external_system_id`
		, `external_table`
		, `created_by_id`
	FROM
		`external_property_level_2_units`
	GROUP BY 
		`external_id`
		, `external_system_id`
		, `external_table`
		, `created_by_id`
	HAVING (COUNT(`system_id_unit`) > 1)
	;

# How many duplicates for L3P?
# The below query should return 0 records

	SELECT
		COUNT(`system_id_room`)
		, `external_id`
		, `external_system_id`
		, `external_table`
		, `created_by_id`
	FROM
		`external_property_level_3_rooms`
	GROUP BY 
		`external_id`
		, `external_system_id`
		, `external_table`
		, `created_by_id`
	HAVING (COUNT(`system_id_room`) > 1)
	;