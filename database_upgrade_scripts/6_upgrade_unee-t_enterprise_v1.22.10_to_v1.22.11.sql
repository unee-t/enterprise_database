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
#
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
# 
####################################################
#
# What are the version of the Unee-T BZ Database schema BEFORE and AFTER this update?

	SET @old_schema_version := 'v1.22.10';
	SET @new_schema_version := 'v1.22.11';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix issue where association User/units are not cretated.
#
#WIP	- Understand why some MEFE units have no parent information.
#
#
######################################################################################
#
# WARNING:
#
#
# 	We need to look at the code and make sure that 
#	the view `ut_organization_associated_mefe_user` is NOT used anywhere
#
#
######################################################################################
#
#
#WIP	- Update the routine to create new user (persons)
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#WIP		- Make sure that we propagate:
#WIP			- MEFE parent ID if applicable
#
#WIP	- Update the routine to create new areas
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#WIP		- Make sure that we propagate to the table `ut_map_external_source_areas`
#
#WIP - Update the routine to create new L1P.
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#
#WIP - Update the routine to create new L2P. 
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#
#WIP - Update the routine to create new L3P.
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
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