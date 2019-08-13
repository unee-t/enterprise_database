# This script
#	- Change the user_type of some user back to the `neutral` user type
#	- Revert this change
#
# Because of the way Unee-T enterprise works, this makes sure that all the
# users in this type of user have access to all the units they need.

# Update the below variables:

	SET @neutral_user_type_id := 22 ;
	SET @user_type_id_to_cleanup := 8 ;


# Bonus: uncomment this to make sure that no one is currently assign to the `neutral` user type
# if yes then this script will automatically give `neutral` users the role @user_type_id_to_cleanup 
/*
SELECT *
FROM `external_persons`
WHERE `unee_t_user_type_id` = 22
	AND `person_status_id` = 2
;
*/

# First set the user role to the `neutral` role:

	UPDATE `external_persons` 
	SET `unee_t_user_type_id` := @neutral_user_type_id
	WHERE `unee_t_user_type_id` = @user_type_id_to_cleanup
		AND `person_status_id` = 2
	;

# Then rever the change back
# This will automatically fire the triggers we need
# and grant permissions to these users for the correct units.

	UPDATE `external_persons` 
	SET `unee_t_user_type_id` := @user_type_id_to_cleanup
	WHERE `unee_t_user_type_id` = @neutral_user_type_id
		AND `person_status_id` = 2
	;