#################
# Pre-requisite: 
#################
#
# - You have created the database `unee_t_enterprise`
# - You have created all the necessary tables in the database `unee_t_enterprise`
# - The DB engine MUST be RDS Aurora 5.7+
# - You MUST have a user `lambda_invoker` configured in your database `unee_t_enterprise`
#	Privileges for this user are
#		- Create Routine
#		- Create Temp tables
#		- Execute
#		- Index
#		- Insert
#		- Lock Tables
#		- Select
#		- Show View
#		- Trigger
#		- Update
# - The EC2 parameter store for each environment should have values for:
#		- `LAMBDA_INVOKER_USERNAME`
#		  The username for the db user that will invoke the lambdas from the `unee_t_enterprise` database
#		- `LAMBDA_INVOKER_PASSWORD`
#		  The password attached to the user `LAMBDA_INVOKER_USERNAME`
#
#################
# WARNING!!!
#################
#
######################################################################################
#
# you also need to run 
#	- part 2: `2_Triggers_and_procedure_unee-t_enterprise_v1_7_0_for_local_dev_lambda_related_objects.sql`
#	- part 3: `3_Triggers_and_procedure_unee-t_enterprise_v1_7_0_for_local_dev_updates_TO_external_xxx_tables.sql`
#
######################################################################################
#
# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
#	- DEV/Staging: 812644853088
#	- Prod: 192458993663
#	- Demo: 915001051872
#
# BY DEFAULT THIS SCRIPT USES THE LAMBDA FOR THE PROD ENVIRONMENT!!!
#
######################################################################################
#
# MAKE SURE TO UPDATE THE MEFE Creator_id AND USE THE CORRECT ONE FOR EACH ENVO
#
######################################################################################
#
# MEFE Creator_id:
#   - DEV/Staging: YYeAutqzDY3MeqbNC (hmlet.enterprise.dev@unee-t.com)
#   - PROD: NXnKGEdEwEvMgWQtG (hmlet.enterprise@unee-t.com)
#   - DEMO: hF4AxDx6r6ue2TgFD (hmlet.enterprise.demo@unee-t.com)
#
# BY DEFAULT THIS SCRIPT USES THE MEFE Creator_id FOR THE PROD ENVIRONMENT!!!
#
######################################
# Important information and GOTCHAs
######################################
# 
# - Create a person:
#		- We will NOT allow the creation of a record in the `persons` table if we have the same
#		  `external_id`, `external_system`, `external_table` for that person.
# 		- It is OK to insert person records if these exist in Unee-T: 
#		  the MEFE API will check if the email exists and update the MEFE user id if we have one
#		- There is an edge case where an email address exists in the BZ Db but does NOT exist in the MEFE
#		  In this scenario the user creation API will fail.
#		- Make sure that the `created_by_id` is a valid MEFE user id
#		  It should be the user ID associated with the API key for the Unee-T Enterprise User who will "own" these records.
# 		- It IS possible to re-try the lambda to create a new Unee-T user.
#		  To do this you have to call the procedure `retry_create_user`
#		  The user MUST have been inserted in the table `ut_map_external_source_users` already
#
# - Create a unit
#		- We will NOT allow the creation of a record in the `property_level_1_buildings` table if we have the same
#			  - `external_id`, 
#			  - `external_system`, 
#			  - `external_table`, 
#			  - `tower` 
#		  for that property.
#		- We will NOT allow the creation of a record in the `property_level_2_units` table if we have the same
#			  - `external_id`,
#			  - `external_system`, 
#			  - `external_table` 
#		  for that property.
#		- We will NOT allow the creation of a record in the `property_level_3_rooms` table if we have the same
#			  - `external_id`,
#			  - `external_system`, 
#			  - `external_table` 
#		  for that property.
#		- Make sure that the `created_by_id` is a valid MEFE user id
#		  It should be the user ID associated with the API key for the Unee-T Enterprise User who will "own" these records.
#		- To insert units which already exist in Unee-T in the Db we need to
#			- Insert the records in the tables
#				- `property_level_1_buildings`
#				  make sure that the field `do_not_insert` = 1
#				- `property_level_2_units`
#				  make sure that the field `do_not_insert` = 1
#				- `property_level_3_rooms`
#				  make sure that the field `do_not_insert` = 1
#			- Insert the records for the properties in the table `ut_map_external_source_units`
#			  make sure that we have a MEFE unit ID for the property (`unee_t_mefe_unit_id` IS NOT NULL)
#		- Make sure that the trigger `update_the_log_of_enabled_units_when_unit_is_created` is DROP in the `bugzilla` database 
#
# - Create a relation between a person and a unit:
#		- Make sure that the `created_by_id` is a valid MEFE user id
#		  It should be the user ID associated with the API key for the Unee-T Enterprise User who will "own" these records.
#
# - Update a person
#		- The MEFE API will check this user id with its record of who was the creator of the record and only allow
#		  the change if the user requesting the update is the creator of the record.
#		- Make sure that the `updated_by_id` is a valid MEFE user id
#		  It should be the user ID associated with the API key for the Unee-T Enterprise User who will "own" these records.
#
# - Update a unit
#		- The MEFE API will check this user id with its record of who was the creator of the record and only allow
#		  the change if the user requesting the update is the creator of the record.
#		- Make sure that the `updated_by_id` is a valid MEFE user id
#		  It should be the user ID associated with the API key for the Unee-T Enterprise User who will "own" these records.
#
# - Remove a relationship person/unit.
#		- The MEFE API will check this user id with its record of who was the creator of the record and only allow
#		  the change if the user requesting the update is the creator of the record.
#		- Make sure that the `updated_by_id` is a valid MEFE user id
#		  It should be the user ID associated with the API key for the Unee-T Enterprise User who will "own" these records.
#
#################
# Overview
#################
# 
# This script creates the objects we need in the Unee-T Enterprise Database 
#		- Views
#		- Triggers
#		- Procedures
#
# This is so we can:
#   - Create and manage properties
#       - Buildings (level 1)
#       - Untis (level 2)
#       - Rooms (level 3)
#   - Create and manage Unee-T users
#   - Create and manage Une-T type of users and their default preferences (visibility and notifications)
#   - Create Groups of units:
#       - Countries
#       - Areas in Countries
#   - Decide who are the users that you will assign to Properties and decide their role types:
#       - Buildings in Areas (and Propagate)
#       - Units in buildings (and Propagate)
#       - Rooms in Units (and Propagate)
#   - Manage API and users who are used to create objects
#   - Manage Links between objects in External Systems and Unee-T Objects (mapping)
#   - Manage 'Owners' of the Unee-T units (possible to add more Owners)
#   - Decide who are the default assignee when a case is created in a unit (for each role and each unit)
#
# We use Triggers, procedure and lambdas to do what needs to be done.
#   - SQL triggers will fire lambdas
#	- PRocedures to call pre-determined actions
#   - GoLang scripts will update this database once the MEFE APIs are successfull
#
# With this mechanism we can:
#OK   - Create new Unee-T users
#OK		- Insert record in the table that will fire the lambda
#OK			- When we add a new person to the 'person table' AND it is marked as 'is creation needed in Unee-T'
#OK			- When we edit a person and mark it as 'is creation needed in Unee-T'
#OK		- Create the trigger that fires the lambda when we need to create a user
#OK		- Create the procedure that updates the record once the API as returned a success
#		  Comment:
#			This updates the MEFE user id for an existing MEFE user 
#			AND marke is as `is_created_by_me` = 0 (False)
#OK		- Create the view that verifies that all is OK once the API as returned a success
#
#	- Create Units
#OK		- Prepare the necessary information if the unit is 
#OK			- a Building
#OK			- a Unit/flat
#OK			- a Room
#OK		- Insert record in the table that will fire the lambda
#OK			- Buildings
#OK				- When we add one AND it is marked as 'is creation needed in Unee-T'
#OK				- When we edit one AND mark it as 'is creation needed in Unee-T'
#OK				- If the option is selected Propagate to:
#					- Units/Flats
#					- Rooms
#OK			- Units/Flats
#OK				- When we add one AND it is marked as 'is creation needed in Unee-T'
#OK				- When we edit one AND mark it as 'is creation needed in Unee-T'
#OK				- If the option is selected Propagate to:
#					- Rooms
#OK			- Rooms
#OK				- When we add one AND it is marked as 'is creation needed in Unee-T'
#OK				- When we edit one AND mark it as 'is creation needed in Unee-T'
#OK		- Add views to verify that all is OK once the unit is created in MEFE
#OK			- Level 1 - buildings
#OK			- Level 2 - units/flats
#OK			- Level 3 - rooms
#
#OK	- Add a user in a role for a given unit and set visibility parameters for this user.
#OK		- Insert record in the table that will fire the lambda
#OK		- Create the trigger that fires the lambda 
#
#	- Update information for a user 
#	  This is done in 2 steps:
#		- remove the existing relationship user/unit
#		- re-create a new relationship user/unit
#		

#	- Edit default notification for a user in a given unit
#   - Update Units
#	- Update the table that store all the different levels of unit once the unit is created in MEFE
#   - Edit a MEFE user IF and ONLY IF this user was created by me
#   - For all the units that I have created in the MEFE
#      - Add Owners to a MEFE unit
#       - Remove Owner from a MEFE unit
#       - Define the Default assignee for a role in a unit
#       - Add default CC for a role in a unit
#       - Add user to a role in a unit together with all the preferences (notification, visibility) for this user for that unit
#       - Remove a user from a role in a unit.
#
# The FK we use in the MEFE are
#   - MEFE unit ID - varchar(255)
#   - MEFE user ID - varchar(255)
#
# We create the additional objects to automate tasks and trigger stuff
#	- Triggers that insert or update data
#		- `persons` data 
#		  (via insert/updates to the table `ut_map_external_source_users`)
#			- `ut_update_map_uneet_user_person`
#			- `ut_update_map_uneet_user_person_ut_account_creation_needed`
#			- `ut_person_has_been_updated_and_ut_account_needed`
#		- `properties` data 
#		  (via insert/updates to the table `ut_map_external_source_units`)
#			- `ut_update_map_external_source_unit_add_building`
#			- `ut_update_map_external_source_unit_add_building_creation_needed`
#			- `ut_update_map_external_source_unit_add_unit`
#			- `ut_update_map_external_source_unit_add_unit_creation_needed`
#			- `ut_update_map_external_source_unit_add_room`
#			- `ut_update_map_external_source_unit_add_room_creation_needed`
#		- relations `unit` and `users` (with permissions)
#			(via insert/updates to the table `ut_map_user_permissions_unit_all`)
#			- `ut_add_user_to_role_in_unit_with_visibility_level_1`
#			- `ut_add_user_to_role_in_unit_with_visibility_level_2`
#			- `ut_add_user_to_role_in_unit_with_visibility_level_3`
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#
#	- Triggers that fire lambdas:
#		- `ut_create_user` 
#		  from table `ut_map_external_source_users`
#		- `ut_create_unit` 
#		  from table `ut_map_external_source_units`
#		- `ut_add_user_to_role_in_unit_with_visibility` 
#		  from table `ut_map_user_permissions_unit_all`
#		- `ut_update_unit` 
#		  from table `ut_map_external_source_units`
#		- `ut_remove_user_from_unit` 
#		  from table `ut_map_user_permissions_unit_all`
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``
#		- ``