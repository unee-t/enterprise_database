#
# For any question about this script, ask Franck
#
####################################################################################
#
# We MUST use at least Aurora MySQl 5.7.22+ if you want 
# to be able to use the Lambda function Unee-T depends on to work as intended
#
# Alternativey if you do NOT need to use the Lambda function, it is possible to use
#	- MySQL 5.7.22 +
#	- MariaDb 10.2.3 +
#
####################################################################################
#
####################################################
#i
# Make sure to 
#	- update the below variable(s)
#
# For easier readability and maintenance, we use dedicated scripts to 
# Create or update:
#	- Views
#	- Procedures
#	- Triggers
#	- Lambda related objects for the relevant environments
#
# Make sure to run all these scripts too!!!
#
####################################################
#
# What are the version of the Unee-T BZ Database schema BEFORE and AFTER this update?

	SET @old_schema_version := 'v1.19.2';
	SET @new_schema_version := 'v1.20.0';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
# Bug fix - typo in a trigger
#	- `ut_add_user_to_role_in_a_level_3_property`
#
# - Create new tables
#	- ``
#	- ``
#
# - Drop tables we do not need anymore
#	- ``
#	- ``
#
# - Alter a existing tables
#	- Add indexes for improved performances 
#		- ``
#		- ``
#	- Rebuild index for better performances
#		- ``
#		- ``
#	- Remove unnecessary columns
#		- ``
#		- ``
#	- Add a new column
#		- ``
#		- ``
#	- Make sure that, in a given organization, the main email for a person is unique
#		- `external_persons`
#		- `persons`
#
# - Drop Views:
#	- ``
#	- ``
#
# - Drop procedures :
#	- ``
#	- ``
#	- ``
#
# - Drop triggers:
#	- ``
#	- ``
#
#
###############################
#
# We have everything we need - Do it!
#
###############################

# When are we doing this?

	SET @the_timestamp := NOW();

# Do the changes:






















# We can now update the version of the database schema
	# A comment for the update
		SET @comment_update_schema_version := CONCAT (
			'Database updated from '
			, @old_schema_version
			, ' to '
			, @new_schema_version
		)
		;
	
	# We record that the table has been updated to the new version.
	INSERT INTO `db_schema_version`
		(`schema_version`
		, `update_datetime`
		, `update_script`
		, `comment`
		)
		VALUES
		(@new_schema_version
		, @the_timestamp
		, @this_script
		, @comment_update_schema_version
		)
		;