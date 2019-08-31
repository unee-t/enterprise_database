#################
#
# This removes all the triggers we use to create 
# a property_level_1
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following objects:
#	- Triggers
#		- `ut_insert_external_property_level_1`
#		- `ut_update_external_property_level_1`
#		- `ut_update_external_property_level_1_creation_needed`
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_edit_level_1`

# When a record is added to the `external_property_level_1_buildings` table

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_1`;

# When a record is updated in the `external_property_level_1_buildings` table
#	- The property DOES exist in the table `property_level_1_buildings`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1`;

# When a record is updated in the `external_property_level_1_buildings` table
#	- The unit DOES exist in the table `property_level_1_buildings`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1_creation_needed`;

# Trigger to update the table that will fire the lambda each time a new building needs to be created

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building`;

# Trigger to update the table that will fire the lambda each time a new building is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building_creation_needed`;

# Trigger to update the table that will fire the lambda each time 
# a new Property Level 1 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_1`;