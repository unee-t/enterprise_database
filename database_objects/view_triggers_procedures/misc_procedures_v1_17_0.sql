#################
#	
# This creates all the Ad hoc procedures we need
#
#################

####################################################################
#
# This script creates additional procedure that we can run if needed
#	- `retry_create_user`
#	- ``
#	- ``
#
####################################################################

# Edge case - the lambda has failed and we need to trigger it one more time

	DROP PROCEDURE IF EXISTS `retry_create_user`;

DELIMITER $$
CREATE PROCEDURE `retry_create_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure 
#	- checks all the users with no MEFE ID in the table `ut_map_external_source_users`
#	- Delete these users in the table `ut_map_external_source_users`
#	- 

		# Create a table with all the records with no MEFE user_id in the table `ut_map_external_source_users`

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

			CREATE TABLE `temp_table_retry_mefe_user_creation`
			AS 
			SELECT * 
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We delete all the record in the table `ut_map_external_source_users` where we have no MEFE_user_id

			DELETE FROM `ut_map_external_source_users`
			WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We insert the failed record again in the table `Condominium` - this re-fires the lambdas to create these users

			INSERT INTO `ut_map_external_source_users`
			SELECT * 
			FROM 
			`temp_table_retry_mefe_user_creation`
			;

		# Clean up - Remove the temp table

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

END $$
DELIMITER ;
