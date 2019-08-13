# This script 
# For any given organization:
#	- Step 1: record the current type for all the existing users
#	- Step 2: update all users type to the "neutral" type
#	- Step 3: update all users type back to the type they had in Step 1
#
# The consequence of this is that the trigger which auto assign units to these users based on the user type in are fired again in Step 3
#
# WARNING!
# This might create A LOT of lambda calls!!!!
#

# How to use this script:

#	1- Make sure the variabl
#	2- Run Part 1 of the script
#	   Make sure there was no errors
#	3- Run Part 2 of the script
#	   Make sure there was no errors
#	4- Run Part 3 of the script
#	   Make sure there was no errors

# Make sure you update the variable for this script

	SET @organization_id := 2 ;
	SET @neurtal_user_type := 22 ;

############
#
# Part 1 of the script:
# This part is commented out to avoid silly mistakes
# MAKE SURE TO REMOVE THE COMMENT DELIMITORS (`/*` AND `*/`)BEFORE RUNNING THIS SCRIPT
#
############
/*
# Create a table with all the users and their existing user type for the given organization

	DROP TABLE IF EXISTS `temp_current_user_type` ;

	CREATE TABLE `temp_current_user_type`
	AS 
	SELECT 
		`id_person`
		, `unee_t_user_type_id`
		FROM `external_persons`
		WHERE `created_by_id` = @organization_id
		;

	# Update all users type to the "neutral" type

		UPDATE `external_persons`
			SET `unee_t_user_type_id` := @neurtal_user_type
			WHERE 
				`unee_t_user_type_id` IS NOT NULL
				AND `created_by_id` = @organization_id
				;
*/
############
#
# Part 2 of the script:
# This part is commented out to avoid silly mistakes
# MAKE SURE TO REMOVE THE COMMENT DELIMITORS (`/*` AND `*/`)BEFORE RUNNING THIS SCRIPT
#
############
/*
	# Update all users type back to the type they had in Step 1

		UPDATE `external_persons` AS `a`
			INNER JOIN `temp_current_user_type` AS `b`
			ON (`a`.`id_person` = `b`.`id_person`)
			SET 
				`a`.`unee_t_user_type_id` := `b`.`unee_t_user_type_id`
				;
*/
############
#
# Part 3 of the script:
# This part is commented out to avoid silly mistakes
# MAKE SURE TO REMOVE THE COMMENT DELIMITORS (`/*` AND `*/`)BEFORE RUNNING THIS SCRIPT
#
############
/*
	# Cleanup: 

		DROP TABLE IF EXISTS `temp_current_user_type` ;
*/