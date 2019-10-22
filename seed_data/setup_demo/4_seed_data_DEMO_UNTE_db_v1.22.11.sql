# This is a seed script to create multiple objects in the UNTE datatabase.
# This will make it easier to have data in the DEMO environment so people can try it out.

#####################################################
#
# IMPORTANT INFORMATION:
# To do this step, we need to make sure that MEFE has created the following objects:
#	- MEFE Master USer
#	- Default Assignees for the company
#		- Mgt Cny
#		- Landlord
#		- Agent
#		- Tenant
#	- Default Area for the organization.
#	- Default L1P for the organization.
#
#####################################################


# In the previous Step 1 2 and 3. We have created the following objects:
#	- Organization
#	- SoT for this organization
#	- Update the default SoT for the organization
#	- Admin user for UNTE for the organization
#	- MEFE Super User for the organization
#	- 5 user types:
#		 - SuperAdmin
#		 - Default Public User - Tenant
#		 - Default Public User - Owner/Landlord
#		 - Default Public User - Management Company
#		 - Default Public User - Agent
#	- UNTE API key for the organization
#	- MEFE user ID for the master MEFE user
#	- MEFE API key for the master MEFE user
#	- Default Assignee
#		- Mgt Cny
#		- Landlord
#		- Agent
#		- Tenant
#	- Default Area
#
# We have also updated the organization with the following information:
#	- Default assignees
#		- Mgt Cny
#		- Agent
#		- Landlord
#		- Tenant
#	- Default Area
#
# This Step 4 we:
#	- Update the organization table
#		- Default L1P information
#	- Creates the following objects:
#		- Default L2P
#

# We need to know which organization we are dealing with

	SET @organization_id_for_step_4 = 10 ;

# The variables below should be identical as is Step 1
	
	SET @demo_email_prefix = 'demo.email+' ;

	SET @demo_email_suffix = '@unee-t.com' ;

	SET @demo_cny_country_code = 'US' ;

# We are creating the following type of unit:
	# 1: Apartment/Flat
	# 2: House
	# 3: Villa
	# 4: Office
	# 7: Shop
	# 8: Salon
	# 9: Restaurant/Cafe
	# 18: Other/Unit
	# 22: Unknown/Unit

	SET @unee_t_unit_type = 'Apartment/Flat' ;

#####################################
#
# We have everything, we can run the script
#
#####################################

# Define the variables that we need:

	SET @demo_cny_name = (SELECT `designation`
		FROM `uneet_enterprise_organizations`
		WHERE `id_organization` = @organization_id_for_step_4
		)
		;

	SET @default_role_type_id =  (SELECT `default_role_type_id`
		FROM `uneet_enterprise_organizations`
		WHERE `id_organization` = @organization_id_for_step_4
		)
		;

	SET @default_sot_id = (SELECT `default_sot_id`
		FROM `uneet_enterprise_organizations`
		WHERE `id_organization` = @organization_id_for_step_4
		)
		;

	SET @default_sot_designation = (SELECT `designation`
		FROM `ut_external_sot_for_unee_t_objects`
		WHERE `id_external_sot_for_unee_t` = @default_sot_id
		)
		;

	# The default tables:

		SET @default_table_person = (SELECT `person_table`
		FROM `ut_external_sot_for_unee_t_objects`
		WHERE `id_external_sot_for_unee_t` = @default_sot_id
		)
		;

		SET @default_table_area = (SELECT `area_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

		SET @default_table_L1P = (SELECT `properties_level_1_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

		SET @default_table_L2P = (SELECT `properties_level_2_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

		SET @default_table_L3P = (SELECT `properties_level_3_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

	# The Master MEFE user for this organization

		SET @mefe_master_user_external_person_id = (SELECT `mefe_master_user_external_person_id`
			FROM `uneet_enterprise_organizations`
			WHERE `id_organization` = @organization_id_for_step_4
			)
			;

		SET @mefe_master_user_external_person_table = 'Setup';

		SET @mefe_master_user_external_person_system = 'Setup';

		SET @mefe_master_user_mefe_id = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_4
				AND `external_person_id` = @mefe_master_user_external_person_id
				AND `table_in_external_system` = @mefe_master_user_external_person_table
				AND `external_system` = @mefe_master_user_external_person_system
			)
			;

	# The MEFE IDs for the default Assignees for this organization

		# Mgt Cny

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'support.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;

			SET @mefe_id_default_mgt_cny = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_4
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
			)
			;
	
			SET @external_person_id = NULL ;

		# Agent

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'agent.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;

			SET @mefe_id_default_agent = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_4
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
				)
				;
	
			SET @external_person_id = NULL ;

		# Landlord

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'landlord.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;

			SET @mefe_id_default_landlord = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_4
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
				)
				;
	
			SET @external_person_id = NULL ;

		# Tenant

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'tenant.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;
		
			SET @mefe_id_default_tenant = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_4
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
				)
				;
	
			SET @external_person_id = NULL ;

# The default area for that organization:

	SET @default_area = (SELECT `id_area`
		FROM `external_property_groups_areas`
		WHERE `created_by_id` = @organization_id_for_step_4
			AND `is_default` = 1
		)
		;

# The default l1p for that organization:

	SET @default_l1p_external_id =  (CONCAT('unknown_'
			, 'building'
			, '_'
			, LOWER(@demo_cny_name)
			)
		)
		;

	SET @default_l1p_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `organization_id` = @organization_id_for_step_4
			AND `external_system` = @default_sot_designation
			AND `table_in_external_system` = @default_table_L1P
			AND `external_property_id` = @default_l1p_external_id
			AND `external_property_type_id` = 1
		)
		;

	SET @l1p_external_system = (SELECT `external_system`
		FROM `ut_map_external_source_units`
		WHERE `unee_t_mefe_unit_id` = @default_l1p_mefe_unit_id
		)
		;

	SET @l1p_external_table = (SELECT `table_in_external_system`
		FROM `ut_map_external_source_units`
		WHERE `unee_t_mefe_unit_id` = @default_l1p_mefe_unit_id
		)
		;

	SET @l1p_external_id = (SELECT `external_property_id`
		FROM `ut_map_external_source_units`
		WHERE `unee_t_mefe_unit_id` = @default_l1p_mefe_unit_id
		)
		;

	SET @l1p_tower = (SELECT `tower`
		FROM `ut_map_external_source_units`
		WHERE `unee_t_mefe_unit_id` = @default_l1p_mefe_unit_id
		)
		;

	SET @default_l1p_id_in_external_property_level_1_buildings =  (SELECT `id_building`
		FROM `external_property_level_1_buildings`
		WHERE `created_by_id` = @organization_id_for_step_4
			AND `external_id` = @l1p_external_id
			AND `external_table` = @l1p_external_table
			AND `external_system_id` = @l1p_external_system
			AND `tower` = @l1p_tower
		)
		;

########################################
#
# We have all the variables we need
#
########################################

# Update the organization record - Add the default L1P:
	
	UPDATE `uneet_enterprise_organizations`
		SET 
			`default_building` = @default_l1p_mefe_unit_id
		WHERE `id_organization` = @organization_id_for_step_4
		;

# Create the default unit for this organization

	SET @create_what = 'unit' ;

	SET @default_l2p_name = (CONCAT('Unknown '
			, @create_what
			, ' - '
			, UPPER(@demo_cny_name)
			)
		)
		;

	SET @default_l2p_external_id= (CONCAT('unknown_'
			, @create_what
			, '_'
			, LOWER(@demo_cny_name)
			)
		)
		;

	SET @default_l2p_description = (CONCAT(UPPER(@demo_cny_name)
			, ' - We have no information on the '
			, @create_what
			, ' for these properties.'
			)
		)
		;

	INSERT INTO `external_property_level_2_units`
		(`external_id`
		, `external_system_id`
		, `external_table`
		, `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `is_update_on_duplicate_key`
		, `is_obsolete`
		, `is_creation_needed_in_unee_t`
		, `do_not_insert`
		, `unee_t_unit_type`
		, `building_system_id`
		, `l1p_external_system`
		, `l1p_external_table`
		, `l1p_external_id`
		, `tower`
		, `designation`
		, `description`
		, `mgt_cny_default_assignee`
		, `agent_default_assignee`
		, `landlord_default_assignee`
		, `tenant_default_assignee`
		)
		VALUES
			(@default_l2p_external_id
			, @default_sot_designation
			, @default_table_L2P
			, NOW() 
			, @default_sot_id
			, @organization_id_for_step_4
			, 'Manage_Units_Add_Page'
			, 0
			, 0
			, 1
			, 0
			, @unee_t_unit_type
			, @default_l1p_id_in_external_property_level_1_buildings
			, @l1p_external_system
			, @l1p_external_table
			, @l1p_external_id
			, 1
			, @default_l2p_name
			, @default_l2p_description
			, @mefe_id_default_mgt_cny
			, @mefe_id_default_agent
			, @mefe_id_default_landlord
			, @mefe_id_default_tenant
			)
		;