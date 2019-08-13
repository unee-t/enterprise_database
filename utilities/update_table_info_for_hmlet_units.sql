SET @disable_lambda := 1 ;

# We add the information `external table` to the table `ut_map_external_source_units`

	# Level 1 units

		UPDATE `ut_map_external_source_units`
		SET `table_in_external_system` := 'db_sourcing_ls_0_condo'
		WHERE `external_property_type_id` = 1
			AND `organization_id` = 2	
		;

	# Level 2 units

		UPDATE `ut_map_external_source_units`
		SET `table_in_external_system` := 'db_all_dt_2_flats'
		WHERE `external_property_type_id` = 2
			AND `organization_id` = 2
		;

	# Level 3 units

		UPDATE `ut_map_external_source_units`
		SET `table_in_external_system` := '205_rooms'
		WHERE `external_property_type_id` = 3
			AND `organization_id` = 2	
		;

SET @disable_lambda := 0 ;