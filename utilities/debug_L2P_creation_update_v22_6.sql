#################
#
# This delete all the triggers we use to create 
# a property_level_2
# via the Unee-T Enterprise Interface
#
#################

# When a record is added to the `external_property_level_2_units` table

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_2`;

# When a record is updated in the `external_property_level_2_units` table
#	- The unit DOES exist in the table `external_property_level_2_units`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2`;

# When a record is updated in the `external_property_level_2_units` table
#	- The unit DOES exist in the table `external_property_level_2_units`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2_creation_needed`;

# Trigger to update the table that will fire the lambda each time a new Flat/Unit needs to be created

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit`;

# Trigger to update the table that will fire the lambda each time a new unit/flat is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit_creation_needed`;

# Trigger to update the table that will fire the lambda each time 
# a new Property Level 2 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_2`;