#################
#
# This deletes ists all the triggers we use to create 
# a property_level_3
# via the Unee-T Enterprise Interface
#
#################
#
# This script creates or updates the following triggers:
#	- `ut_insert_external_property_level_3`
#	- `ut_update_external_property_level_3`
#	- `ut_update_external_property_level_3_creation_needed`
#	- `ut_update_map_external_source_unit_add_room`
#	- `ut_update_map_external_source_unit_add_room_creation_needed`
#

# When a record is added to the `external_property_level_3_rooms` table

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_3`;

# When a record is updated in the `external_property_level_3_rooms` table
#	- The unit DOES exist in the table `external_property_level_3_rooms`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_3`;

# When a record is updated in the `external_property_level_3_rooms` table
#	- The unit DOES exist in the table `external_property_level_3_rooms`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_3_creation_needed`;

# Trigger to update the table that will fire the lambda each time a new Room needs to be created

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_room`;

# Trigger to update the table that will fire the lambda each time a new Room is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_room_creation_needed`;

# Trigger to update the table that will fire the lambda each time 
# a new Property Level 3 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_3`;
