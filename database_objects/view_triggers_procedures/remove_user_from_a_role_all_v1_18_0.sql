#################
#
# This is part 8
# Remove a user from a role
#
#################


# Remove a user from an area 
#	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_1`
#

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_an_area`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_an_area`
AFTER DELETE ON `external_map_user_unit_role_permissions_areas`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		# We delete the record in the tables that are visible in the Unee-T Enterprise interface

			SET @deleted_area_id := OLD.`unee_t_area_id` ;
			SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;

			DELETE `external_map_user_unit_role_permissions_level_1` 
			FROM `external_map_user_unit_role_permissions_level_1`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area`
				ON (`ut_list_mefe_unit_id_level_1_by_area`.`level_1_building_id` 
				= `external_map_user_unit_role_permissions_level_1`.`unee_t_level_1_id`)
			WHERE 
				`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
				AND `ut_list_mefe_unit_id_level_1_by_area`.`id_area` = @deleted_area_id
				;

	END IF;
END;
$$
DELIMITER ;

# Remove a user from a Level 1 property (building)
# 	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_2`
#		- `ut_map_user_permissions_unit_level_1`
#	- Update the table:
#		 - `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_1_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_1_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_1`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_1_id := OLD.`unee_t_level_1_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`created_by_id` ;

		DELETE `external_map_user_unit_role_permissions_level_2` 
		FROM `external_map_user_unit_role_permissions_level_2`
		INNER JOIN `ut_list_mefe_unit_id_level_2_by_area`
			ON (`ut_list_mefe_unit_id_level_2_by_area`.`level_2_unit_id` = `external_map_user_unit_role_permissions_level_2`.`unee_t_level_2_id`)
		WHERE 
			`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
			AND `ut_list_mefe_unit_id_level_2_by_area`.`level_1_building_id` = @deleted_level_1_id
			;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_1_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l1 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE `level_1_building_id` = @deleted_level_1_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l1 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_1` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_1`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_1` ;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_1` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l1

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_1`

			DELETE `ut_map_user_permissions_unit_level_1` 
			FROM `ut_map_user_permissions_unit_level_1`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l1
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l1
					;

END;
$$
DELIMITER ;

# Remove a user from a Level 2 property (unit)
# 	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_3`
#		- `ut_map_user_permissions_unit_level_2`
#	- Update the table:
#		- `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_2_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_2_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_2`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_2_id := OLD.`unee_t_level_2_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`creation_system_id` ;

		DELETE `external_map_user_unit_role_permissions_level_3` 
		FROM `external_map_user_unit_role_permissions_level_3`
		INNER JOIN `ut_list_mefe_unit_id_level_3_by_area`
			ON (`ut_list_mefe_unit_id_level_3_by_area`.`level_3_room_id` = `external_map_user_unit_role_permissions_level_3`.`unee_t_level_3_id`)
		WHERE 
			`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
			AND `ut_list_mefe_unit_id_level_3_by_area`.`level_2_unit_id` = @deleted_level_2_id
			;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_2_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l2 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_2_by_area`
				WHERE `level_2_unit_id` = @deleted_level_2_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l2 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_2` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_2`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_2`;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_2` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l2

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_2`

			DELETE `ut_map_user_permissions_unit_level_2` 
			FROM `ut_map_user_permissions_unit_level_2`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l2
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l2
					;

END;
$$
DELIMITER ;

# Remove a user from a Level 3 property (rooms)
# 	- Delete the records in the table
#		- `ut_map_user_permissions_unit_level_3`
#	- Update the table:
#		 - `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

			DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_3_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_3_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_3`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_3_id := OLD.`unee_t_level_3_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`creation_system_id` ;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_3_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l3 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_3_by_area`
				WHERE `level_3_room_id` = @deleted_level_3_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l3 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_3` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_3`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_3`;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_3` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l3

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_3`

			DELETE `ut_map_user_permissions_unit_level_3` 
			FROM `ut_map_user_permissions_unit_level_3`
				WHERE (`unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l3)
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l3
					;

END;
$$
DELIMITER ;